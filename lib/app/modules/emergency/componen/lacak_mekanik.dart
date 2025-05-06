// lib/app/modules/track_mekanik/views/lacak_mekanik.dart
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

// ──────────────────────────────────────────────────────────────────────────
// UTIL – bearing 0-360°
double computeBearing(LatLng begin, LatLng end) {
  final lat1 = begin.latitude * (pi / 180);
  final lat2 = end.latitude * (pi / 180);
  final dLon = (end.longitude - begin.longitude) * (pi / 180);
  final y = sin(dLon) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
  return ((atan2(y, x) * 180 / pi) + 360) % 360;
}

// Tween posisi LatLng
class LatLngTween extends Tween<LatLng> {
  LatLngTween({LatLng? begin, LatLng? end}) : super(begin: begin, end: end);
  @override
  LatLng lerp(double t) => LatLng(
    begin!.latitude + (end!.latitude - begin!.latitude) * t,
    begin!.longitude + (end!.longitude - begin!.longitude) * t,
  );
}

// ──────────────────────────────────────────────────────────────────────────
// PAGE
// ──────────────────────────────────────────────────────────────────────────
class LacakMekanik extends StatefulWidget {
  const LacakMekanik({Key? key, required this.data}) : super(key: key);
  final Data data;

  @override
  _LacakMekanikState createState() => _LacakMekanikState();
}

class _LacakMekanikState extends State<LacakMekanik>
    with TickerProviderStateMixin {
  // GoogleMap
  late GoogleMapController _mapController;

  // GetX controller
  late TrackMekanikController trackCtrl;
  Worker? _mechanicLocationWorker;

  // Animasi marker
  late AnimationController _markerAnimationController;
  Animation<LatLng>? _markerAnimation;
  Animation<double>? _rotationAnimation;
  LatLng? _currentMechanicPosition;
  double _currentRotation = 0;

  // Lokasi user & icon
  late LatLng _userLocation;
  late BitmapDescriptor _userMarkerIcon;
  late BitmapDescriptor _mechanicMarkerIcon;
  bool _isLoadingMarkers = true;

  // Polyline & ETA
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  DateTime? _lastPolylineUpdate;
  String _trafficTravelTime = '';
  double? _trafficDistanceKm;
  bool _mapIsInteracting = false;

  // Google API key
  final String _googleApiKey = 'AIzaSyBCZvyqX4bFC7Zr8aLVIehq2SgjpI17_3M';
  // ──────────────────────────────────────────────────────────────────────────
  //  ⇢ HITUNG JARAK POLYLINE (km)
  double _calculatePolylineDistance(List<LatLng> points) {
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _haversineKm(points[i], points[i + 1]);
    }
    return total;
  }

  // helper haversine km (pakai milik Anda jika sudah ada)
  double _haversineKm(LatLng a, LatLng b) {
    const p = 0.017453292519943295; // π/180
    final c =
        0.5 -
        cos((b.latitude - a.latitude) * p) / 2 +
        cos(a.latitude * p) *
            cos(b.latitude * p) *
            (1 - cos((b.longitude - a.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(c)); // diameter bumi km
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  ⇢ Fallback estimasi waktu tempuh
  String _getTravelTimeFallback(double distanceKm) {
    const speed = 40.0; // asumsi km/h
    final hours = distanceKm / speed;
    if (hours < 1) {
      return '${(hours * 60).round()} menit';
    } else {
      final h = hours.floor();
      final m = ((hours - h) * 60).round();
      return m == 0 ? '$h jam' : '$h jam $m menit';
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  ⇢ Reverse-geocode alamat mekanik
  Future<String> _getRealTimeMechanicAddress(LatLng pos) async {
    try {
      final list = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (list.isEmpty) return 'Alamat tidak ditemukan';
      final p = list.first;
      return '${p.street ?? ''}, ${p.subLocality ?? ''}, '
          '${p.locality ?? ''}, ${p.administrativeArea ?? ''}, '
          '${p.country ?? ''}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // INIT
  // ────────────────────────────────────────────────────────────────────────
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
              _currentRotation = _rotationAnimation?.value ?? 0;
            }
          })
          ..addListener(() => setState(() {}));

    // Lokasi user
    final userLat = double.tryParse(widget.data.latitude ?? '0') ?? 0;
    final userLon = double.tryParse(widget.data.longitude ?? '0') ?? 0;
    _userLocation = LatLng(userLat, userLon);

    // GetX controller (tag = kode order)
    final tag = widget.data.kode ?? 'defaultOrder';
    trackCtrl = Get.put(
      TrackMekanikController(widget.data.kode ?? ''),
      tag: tag,
      permanent: true,
    );

    // Posisi awal mekanik (jika sudah ada)
    final lastKnown = trackCtrl.lastKnownMechanicLocation.value;
    if (lastKnown != null &&
        !(lastKnown.latitude == 0 && lastKnown.longitude == 0)) {
      _currentMechanicPosition = lastKnown;
      if (!(userLat == 0 && userLon == 0)) {
        _updateRoute(lastKnown, _userLocation);
      }
    }

    // Listener realtime posisi mekanik
    _mechanicLocationWorker = ever<LatLng>(trackCtrl.mechanicLocation, (
      LatLng newLoc,
    ) {
      if (!mounted || (newLoc.latitude == 0 && newLoc.longitude == 0)) return;
      _animateMechanicMarker(newLoc);
      _updateRoute(newLoc, _userLocation);
    });

    _loadMarkerIcons();
  }

  // ────────────────────────────────────────────────────────────────────────
  // LOAD MARKER ICONS
  // ────────────────────────────────────────────────────────────────────────
  Future<void> _loadMarkerIcons() async {
    _userMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2),
      'assets/icon/car.png',
    );
    _mechanicMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2),
      'assets/icon/mark_mekanik.png',
    );
    _isLoadingMarkers = false;
    if (mounted) setState(() {});
  }

  // ────────────────────────────────────────────────────────────────────────
  // ROTASI – helper
  // ────────────────────────────────────────────────────────────────────────
  double _normalize360(double deg) => (deg % 360 + 360) % 360;
  double _shortestDiff(double fromDeg, double toDeg) {
    final diff =
        (_normalize360(toDeg) - _normalize360(fromDeg) + 540) % 360 - 180;
    return diff;
  }

  // ────────────────────────────────────────────────────────────────────────
  // ANIMATE MARKER (akurasi tinggi)
  // ────────────────────────────────────────────────────────────────────────
  void _animateMechanicMarker(LatLng newLoc) {
    // Pertama kali: tampilkan statis
    if (_currentMechanicPosition == null) {
      _currentMechanicPosition = newLoc;
      _currentRotation = 0;
      setState(() {});
      return;
    }

    // Abaikan noise < 5 m
    final moveKm = _calculateDistance(
      _currentMechanicPosition!.latitude,
      _currentMechanicPosition!.longitude,
      newLoc.latitude,
      newLoc.longitude,
    );
    if (moveKm < 0.005) {
      _currentMechanicPosition = newLoc; // tetap geser posisi
      setState(() {});
      return;
    }

    // Bearing & rotasi terpendek
    final newBearing = computeBearing(_currentMechanicPosition!, newLoc);
    final targetRotation = _normalize360(
      _currentRotation + _shortestDiff(_currentRotation, newBearing),
    );

    // Durasi animasi proporsional jarak (0.6-1.5 s)
    final durMs = (600 + moveKm * 1000).clamp(600, 1500).toInt();
    _markerAnimationController.duration = Duration(milliseconds: durMs);

    final beginPos = _markerAnimation?.value ?? _currentMechanicPosition!;
    _markerAnimation = LatLngTween(begin: beginPos, end: newLoc).animate(
      CurvedAnimation(
        parent: _markerAnimationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: targetRotation,
    ).animate(
      CurvedAnimation(
        parent: _markerAnimationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _markerAnimationController
      ..reset()
      ..forward();
  }

  // ────────────────────────────────────────────────────────────────────────
  // DISPOSE
  // ────────────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _mechanicLocationWorker?.dispose();
    _markerAnimationController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoadingMarkers) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lacak Mekanik')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Obx(() {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      // Tampilan “menunggu data pertama”
      if (!trackCtrl.isFirstFetchCompleted.value &&
          _currentMechanicPosition == null) {
        return _waitingScreen(isDark);
      }
      return _mapScreen(isDark);
    });
  }

  // ───────────────── UI helper
  PreferredSizeWidget _appBar(bool isDark) => AppBar(
    backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
    elevation: 1,
    iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
    title: Text(
      'Lacak Mekanik',
      style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black),
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
  );

  Widget _waitingScreen(bool isDark) => Scaffold(
    backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
    appBar: _appBar(isDark),
    body: Center(
      child: Column(
        children: [
          const SizedBox(height: 150),
          Image.asset(AssetsRes.MECHANIC, height: 70),
          const SizedBox(height: 20),
          const Text('Menunggu data lokasi mekanik...'),
        ],
      ),
    ),
  );

  Widget _mapScreen(bool isDark) {
    final mechPos = _markerAnimation?.value ?? _currentMechanicPosition;
    final mechRot = _rotationAnimation?.value ?? _currentRotation;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
      appBar: _appBar(isDark),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userLocation,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('UserMarker'),
                position: _userLocation,
                icon: _userMarkerIcon,
                infoWindow: const InfoWindow(title: 'Lokasi Saya'),
              ),
              if (mechPos != null)
                Marker(
                  markerId: const MarkerId('MechanicMarker'),
                  position: mechPos,
                  icon: _mechanicMarkerIcon,
                  anchor: const Offset(0.5, 0.5),
                  rotation: mechRot,
                  infoWindow: InfoWindow(
                    title: widget.data.status ?? 'Mekanik',
                  ),
                ),
            },
            polylines: _polylines,
            onMapCreated: (c) async {
              _mapController = c;
              if (mechPos != null) {
                await Future.delayed(const Duration(milliseconds: 600));
                _mapController.showMarkerInfoWindow(
                  const MarkerId('MechanicMarker'),
                );
              }
            },
            onCameraMoveStarted: () => setState(() => _mapIsInteracting = true),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildInfoPanel(context, mechPos, isDark),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // INFO PANEL & ROUTE — (UI & logika asli tidak diubah)
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildInfoPanel(
    BuildContext context,
    LatLng? mechanicMarkerPos,
    bool isDark,
  ) {
    // hitung jarak polyline sekali saja
    final double polylineKm = _calculatePolylineDistance(_polylineCoordinates);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ───── Tombol Lokasi & Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(
                    () => _mapIsInteracting = false,
                  ); // aktifkan auto-center
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
                  'Lokasi Saya',
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
                  ); // aktifkan auto-center
                  if (mechanicMarkerPos != null) {
                    await _updateRoute(mechanicMarkerPos, _userLocation);
                    _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: mechanicMarkerPos, zoom: 16),
                      ),
                    );
                    await Future.delayed(const Duration(milliseconds: 300));
                    _mapController.showMarkerInfoWindow(
                      const MarkerId('MechanicMarker'),
                    );
                  }
                },
                icon: Icon(
                  Icons.refresh,
                  color: isDark ? Colors.white : Colors.black,
                ),
                label: Text(
                  'Refresh Maps',
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

          // ───── Kartu info
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
                  'Informasi Tracking Mekanik',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // ───── Alamat mekanik
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
                          'Lokasi mekanik belum tersedia',
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
                      Widget text;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        text = const Text('Mengambil alamat mekanik...');
                      } else if (snapshot.hasError) {
                        text = Text('Error: ${snapshot.error}');
                      } else {
                        text = Text('Alamat Mekanik: ${snapshot.data}');
                      }
                      return Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DefaultTextStyle.merge(
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              child: text,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 8),

                // ───── Jarak
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Jarak: '
                      '${_trafficDistanceKm?.toStringAsFixed(2) ?? polylineKm.toStringAsFixed(2)} km',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ───── ETA
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estimasi Waktu: '
                      '${_trafficTravelTime.isNotEmpty ? _trafficTravelTime : _getTravelTimeFallback(_trafficDistanceKm ?? polylineKm)}',
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
    if ((origin.latitude == 0 && origin.longitude == 0) ||
        (destination.latitude == 0 && destination.longitude == 0))
      return;

    // throttle setiap 10 s
    if (_lastPolylineUpdate != null &&
        DateTime.now().difference(_lastPolylineUpdate!) <
            const Duration(seconds: 10)) {
      return;
    }
    _lastPolylineUpdate = DateTime.now();

    final url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving&departure_time=now'
        '&traffic_model=best_guess&key=$_googleApiKey';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return;
      final data = json.decode(res.body);
      if ((data['routes'] as List).isEmpty) return;

      final leg = data['routes'][0]['legs'][0];
      _trafficTravelTime =
          leg['duration_in_traffic']?['text'] ?? leg['duration']['text'];
      _trafficDistanceKm = leg['distance']['value'] / 1000;

      final pts = PolylinePoints().decodePolyline(
        data['routes'][0]['overview_polyline']['points'],
      );
      _polylineCoordinates =
          pts.map((p) => LatLng(p.latitude, p.longitude)).toList();

      if (!mounted) return;
      setState(() {
        _polylines
          ..clear()
          ..add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: _polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
      });

      if (!_mapIsInteracting) {
        final bounds = _createBoundsForMarkers([origin, destination]);
        if (bounds != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 80),
            );
          });
        }
      }
    } catch (e) {
      debugPrint('updateRoute error: $e');
    }
  }

  LatLngBounds? _createBoundsForMarkers(List<LatLng> pos) {
    if (pos.isEmpty) return null;
    double minLat = pos.first.latitude,
        maxLat = pos.first.latitude,
        minLng = pos.first.longitude,
        maxLng = pos.first.longitude;
    for (final p in pos) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    if (minLat == 0 && maxLat == 0 && minLng == 0 && maxLng == 0) return null;
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // ───────── UTIL distance
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
    return 12742 * asin(sqrt(a));
  }
}
