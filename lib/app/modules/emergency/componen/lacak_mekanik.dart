import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tka_customer/app/data/data_respon/list_emergency.dart';

import '../../../../res/assets_res.dart';
import '../controllers/trackMekanik_controller.dart';

double computeBearing(LatLng begin, LatLng end) {
  final lat1 = begin.latitude * (pi / 180);
  final lat2 = end.latitude * (pi / 180);
  final deltaLon = (end.longitude - begin.longitude) * (pi / 180);
  final y = sin(deltaLon) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);
  final bearing = atan2(y, x) * (180 / pi);
  return (bearing + 360) % 360;
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({LatLng? begin, LatLng? end}) : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}

class LacakMekanik extends StatefulWidget {
  final Data data;

  const LacakMekanik({Key? key, required this.data}) : super(key: key);

  @override
  _LacakMekanikState createState() => _LacakMekanikState();
}

class _LacakMekanikState extends State<LacakMekanik>
    with TickerProviderStateMixin {
  late GoogleMapController _mapController;
  late TrackMekanikController trackCtrl;
  Worker? _mechanicLocationWorker;
  late AnimationController _markerAnimationController;
  Animation<LatLng>? _markerAnimation;
  Animation<double>? _rotationAnimation;
  LatLng? _currentMechanicPosition;
  double _currentRotation = 0.0;
  late LatLng _userLocation;
  late BitmapDescriptor _userMarkerIcon;
  late BitmapDescriptor _mechanicMarkerIcon;
  bool _isLoadingMarkers = true;
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  String _trafficTravelTime = "";
  double? _trafficDistanceKm;
  bool _mapIsInteracting = false;
  final String _googleApiKey = "AIzaSyBCZvyqX4bFC7Zr8aLVIehq2SgjpI17_3M";

  @override
  void initState() {
    super.initState();
    _markerAnimationController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1200),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed &&
                _markerAnimation != null) {
              _currentMechanicPosition = _markerAnimation!.value;
              _currentRotation = _rotationAnimation?.value ?? 0.0;
            }
          })
          ..addListener(() => setState(() {}));
    final double userLat = double.tryParse(widget.data.latitude ?? "0") ?? 0;
    final double userLon = double.tryParse(widget.data.longitude ?? "0") ?? 0;
    _userLocation = LatLng(userLat, userLon);
    final String tag = widget.data.kode ?? "defaultOrder";
    if (Get.isRegistered<TrackMekanikController>(tag: tag)) {
      trackCtrl = Get.find<TrackMekanikController>(tag: tag);
    } else {
      trackCtrl = Get.put(
        TrackMekanikController(widget.data.kode ?? ""),
        tag: tag,
        permanent: true,
      );
    }
    final lastKnown = trackCtrl.lastKnownMechanicLocation.value;
    if (lastKnown != null &&
        !(lastKnown.latitude == 0 && lastKnown.longitude == 0)) {
      _currentMechanicPosition = lastKnown;
      if (!(_userLocation.latitude == 0 && _userLocation.longitude == 0)) {
        _updateRoute(_currentMechanicPosition!, _userLocation);
      }
    }
    _mechanicLocationWorker = ever<LatLng>(trackCtrl.mechanicLocation, (
      newLoc,
    ) {
      if (!mounted || (newLoc.latitude == 0 && newLoc.longitude == 0)) return;
      _animateMechanicMarker(newLoc);
      _updateRoute(newLoc, _userLocation);
    });
    _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    _userMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.0),
      'assets/icon/car.png',
    );
    _mechanicMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.0),
      'assets/icon/mark_mekanik.png',
    );
    _isLoadingMarkers = false;
    setState(() {});
  }

  void _animateMechanicMarker(LatLng newLoc) {
    if (_currentMechanicPosition == null) {
      _currentMechanicPosition = newLoc;
      _currentRotation = 0;
      setState(() {});
      return;
    }

    final double newRotation = computeBearing(
      _currentMechanicPosition!,
      newLoc,
    );

    var finalRotation = newRotation;
    double difference = (finalRotation - _currentRotation + 360) % 360;
    if (difference > 180) {
      finalRotation = finalRotation - 360;
    }

    final beginPos = _markerAnimation?.value ?? _currentMechanicPosition!;

    _markerAnimationController.reset();
    _markerAnimation = LatLngTween(begin: beginPos, end: newLoc).animate(
      CurvedAnimation(
        parent: _markerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: finalRotation,
    ).animate(
      CurvedAnimation(
        parent: _markerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _markerAnimationController.forward();
  }

  @override
  void dispose() {
    _mechanicLocationWorker?.dispose();
    _markerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingMarkers) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lacak Mekanik")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Obx(() {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      if (!trackCtrl.isFirstFetchCompleted.value &&
          _currentMechanicPosition == null) {
        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor:
                isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
            elevation: 1,
            title: Text(
              'Lacak Mekanik',
              style: GoogleFonts.nunito(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.black,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: Column(
              children: [
                const SizedBox(height: 150),
                Image.asset(AssetsRes.MECHANIC, height: 70),
                const SizedBox(height: 20),
                const Text("Menunggu data lokasi mekanik..."),
              ],
            ),
          ),
        );
      }
      return _buildMapScreen(context);
    });
  }

  Widget _buildMapScreen(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final LatLng? mechanicMarkerPos =
        _markerAnimation?.value ?? _currentMechanicPosition;
    final double mechanicMarkerRot =
        _rotationAnimation?.value ?? _currentRotation;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
        elevation: 1,
        title: Text(
          'Lacak Mekanik',
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userLocation,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId("UserMarker"),
                position: _userLocation,
                icon: _userMarkerIcon,
                infoWindow: const InfoWindow(title: "Lokasi Saya"),
              ),
              if (mechanicMarkerPos != null)
                Marker(
                  markerId: const MarkerId("MechanicMarker"),
                  position: mechanicMarkerPos,
                  icon: _mechanicMarkerIcon,
                  anchor: const Offset(0.5, 0.5),
                  rotation: mechanicMarkerRot,
                  infoWindow: InfoWindow(
                    title: widget.data.status ?? "Mekanik",
                  ),
                ),
            },
            polylines: _polylines,
            onMapCreated: (controller) async {
              _mapController = controller;
              if (mechanicMarkerPos != null) {
                await Future.delayed(const Duration(milliseconds: 600));
                _mapController.showMarkerInfoWindow(
                  const MarkerId("MechanicMarker"),
                );
              }
            },
            onCameraMoveStarted: () => setState(() => _mapIsInteracting = true),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildInfoPanel(context, mechanicMarkerPos, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(
    BuildContext context,
    LatLng? mechanicMarkerPos,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(
                    () => _mapIsInteracting = false,
                  ); // aktifkan auto‑center
                  _mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: _userLocation, zoom: 16),
                    ),
                  );
                },
                icon: Icon(
                  Icons.my_location,
                  color: isDark ? Colors.white : Colors.black,
                ),
                label: Text(
                  "Lokasi Saya",
                  style: GoogleFonts.nunito(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  setState(
                    () => _mapIsInteracting = false,
                  ); // aktifkan auto‑center
                  if (mechanicMarkerPos != null) {
                    await _updateRoute(mechanicMarkerPos, _userLocation);
                    _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: mechanicMarkerPos, zoom: 16),
                      ),
                    );
                    await Future.delayed(const Duration(milliseconds: 300));
                    _mapController.showMarkerInfoWindow(
                      const MarkerId("MechanicMarker"),
                    );
                  }
                },
                icon: Icon(
                  Icons.refresh,
                  color: isDark ? Colors.white : Colors.black,
                ),
                label: Text(
                  "Refresh Maps",
                  style: GoogleFonts.nunito(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Card Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Informasi Tracking Mekanik",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                if (mechanicMarkerPos == null)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Lokasi mekanik belum tersedia",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  FutureBuilder<String>(
                    future: _getRealTimeMechanicAddress(mechanicMarkerPos),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Mengambil alamat mekanik...",
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Error: ${snapshot.error}",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Alamat Mekanik: ${snapshot.data}",
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Jarak: ${_trafficDistanceKm != null ? _trafficDistanceKm!.toStringAsFixed(2) : _calculatePolylineDistance(_polylineCoordinates).toStringAsFixed(2)} km",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Estimasi Waktu: ${_trafficTravelTime.isNotEmpty ? _trafficTravelTime : _getTravelTimeFallback(_trafficDistanceKm ?? _calculatePolylineDistance(_polylineCoordinates))}",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRoute(LatLng origin, LatLng destination) async {
    if ((origin.latitude == 0.0 && origin.longitude == 0.0) ||
        (destination.latitude == 0.0 && destination.longitude == 0.0)) {
      return;
    }
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${origin.latitude},${origin.longitude}"
        "&destination=${destination.latitude},${destination.longitude}"
        "&mode=driving&departure_time=now"
        "&traffic_model=best_guess&key=$_googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["routes"] != null &&
            (jsonData["routes"] as List).isNotEmpty) {
          final route = jsonData["routes"][0];
          final leg = route["legs"][0];

          final durationInTraffic =
              leg["duration_in_traffic"] != null
                  ? leg["duration_in_traffic"]["text"]
                  : leg["duration"]["text"];
          _trafficTravelTime = durationInTraffic;
          _trafficDistanceKm = leg["distance"]["value"] / 1000;

          final polyline = route["overview_polyline"]["points"];
          final polylinePoints = PolylinePoints();
          final decodedPoints = polylinePoints.decodePolyline(polyline);
          _polylineCoordinates =
              decodedPoints
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList();

          if (!mounted) return;
          setState(() {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId("route"),
                points: _polylineCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            );
          });

          if (!_mapIsInteracting) {
            final bounds = _createBoundsForMarkers([origin, destination]);
            if (bounds != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _mapController.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 80),
                );
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  LatLngBounds? _createBoundsForMarkers(List<LatLng> positions) {
    if (positions.isEmpty) return null;
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;
    for (final pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }
    if (minLat == 0.0 && maxLat == 0.0 && minLng == 0.0 && maxLng == 0.0)
      return null;
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<String> _getRealTimeMechanicAddress(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.street ?? ''}, ${place.subLocality ?? ''}, "
            "${place.locality ?? ''}, ${place.administrativeArea ?? ''}, "
            "${place.country ?? ''}";
      } else {
        return "Alamat tidak ditemukan";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 12742 = diameter bumi dalam km
  }

  double _calculatePolylineDistance(List<LatLng> points) {
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _calculateDistance(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  String _getTravelTimeFallback(double distanceKm) {
    const speed = 40.0; // km/h
    final timeHours = distanceKm / speed;
    if (timeHours < 1) {
      final minutes = (timeHours * 60).round();
      return "$minutes menit";
    } else {
      final hours = timeHours.floor();
      final minutes = ((timeHours - hours) * 60).round();
      return minutes == 0 ? "$hours jam" : "$hours jam $minutes menit";
    }
  }
}
