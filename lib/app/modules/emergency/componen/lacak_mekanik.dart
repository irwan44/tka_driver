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

// ────────────────────────────────────────────────────────────────────────
// UTIL – bearing 0‑360°
// ------------------------------------------------------------------------
double computeBearing(LatLng begin, LatLng end) {
  final lat1 = begin.latitude * (pi / 180);
  final lat2 = end.latitude * (pi / 180);
  final dLon = (end.longitude - begin.longitude) * (pi / 180);
  final y = sin(dLon) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
  return ((atan2(y, x) * 180 / pi) + 360) % 360;
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({LatLng? begin, LatLng? end}) : super(begin: begin, end: end);
  @override
  LatLng lerp(double t) => LatLng(
    begin!.latitude  + (end!.latitude  - begin!.latitude ) * t,
    begin!.longitude + (end!.longitude - begin!.longitude) * t,
  );
}

// ────────────────────────────────────────────────────────────────────────
// PAGE LacakMekanik
// ------------------------------------------------------------------------
class LacakMekanik extends StatefulWidget {
  const LacakMekanik({Key? key, required this.data}) : super(key: key);
  final Data data;

  @override
  State<LacakMekanik> createState() => _LacakMekanikState();
}

class _LacakMekanikState extends State<LacakMekanik> with TickerProviderStateMixin {
  // GoogleMap controller
  late GoogleMapController _mapController;

  // GetX controller (per order)
  late TrackMekanikController trackCtrl;
  Worker? _mechanicWorker;

  // Marker animasi
  late AnimationController _markerAnimCtrl;
  Animation<LatLng>?  _markerPositionAnim;
  Animation<double>? _rotationAnim;
  LatLng?  _currentMechanicPos;
  double   _currentRotation = 0;

  // User + mechanic marker icons
  late LatLng _userLocation;
  late BitmapDescriptor _userIcon;
  late BitmapDescriptor _mechanicIcon;
  bool _loadingIcons = true;

  // Polyline & ETA
  final Set<Polyline> _polylines = {};
  List<LatLng> _polyPts = [];
  DateTime? _lastPolylineFetch;
  String _trafficTime = '';
  double? _trafficKm;
  bool _mapInteracting = false;

  // Google API key – SIMPAN DI ENV YA!
  final String _googleKey = const String.fromEnvironment('AIzaSyBCZvyqX4bFC7Zr8aLVIehq2SgjpI17_3M', defaultValue: 'AIzaSyBCZvyqX4bFC7Zr8aLVIehq2SgjpI17_3M');

  // ───────────────── INIT ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // animasi marker
    _markerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed && _markerPositionAnim != null) {
        _currentMechanicPos = _markerPositionAnim!.value;
        _currentRotation = _rotationAnim?.value ?? 0;
      }
    })
      ..addListener(() => setState(() {}));

    // lokasi user
    final ulat = double.tryParse(widget.data.latitude  ?? '0') ?? 0;
    final ulon = double.tryParse(widget.data.longitude ?? '0') ?? 0;
    _userLocation = LatLng(ulat, ulon);

    // controller GetX
    final tag = widget.data.kode ?? 'defaultOrder';
    trackCtrl = Get.put(
      TrackMekanikController(widget.data.kode ?? ''),
      tag: tag,
      permanent: true,
    );

    // posisi awal mechanic kalau sudah ada
    final last = trackCtrl.mechanicLocation.value;
    if (last != null) {
      _currentMechanicPos = last;
      if (!(ulat == 0 && ulon == 0)) {
        _updateRoute(last, _userLocation);
      }
    }

    // listener realtime posisi mechanic
    _mechanicWorker = ever<LatLng?>(trackCtrl.mechanicLocation, (loc) {
      if (loc == null) return;
      _animateMechanicMarker(loc);
      _updateRoute(loc, _userLocation);
    });

    _loadIcons();
  }

  // ───────────────── MARKER ICONS ──────────────────────────────────────
  Future<void> _loadIcons() async {
    _userIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2),
      'assets/icon/car.png',
    );
    _mechanicIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2),
      'assets/icon/mark_mekanik.png',
    );
    setState(() => _loadingIcons = false);
  }

  // ───────────────── ROTASI HELPER ─────────────────────────────────────
  double _normalize360(double deg) => (deg % 360 + 360) % 360;
  double _shortestDiff(double from, double to) {
    final diff = (_normalize360(to) - _normalize360(from) + 540) % 360 - 180;
    return diff;
  }

  // ───────────────── ANIMASI MARKER ────────────────────────────────────
  void _animateMechanicMarker(LatLng newPos) {
    // pertama kali → tampil statis
    if (_currentMechanicPos == null) {
      _currentMechanicPos = newPos;
      setState(() {});
      return;
    }

    // abaikan noise < 5 m
    final moveKm = _distanceKm(_currentMechanicPos!, newPos);
    if (moveKm < 0.005) {
      _currentMechanicPos = newPos;
      setState(() {});
      return;
    }

    final newBearing = computeBearing(_currentMechanicPos!, newPos);
    final targetRot = _normalize360(
      _currentRotation + _shortestDiff(_currentRotation, newBearing),
    );

    final durMs = (600 + moveKm * 1000).clamp(600, 1500).toInt();
    _markerAnimCtrl.duration = Duration(milliseconds: durMs);

    final beginPos = _markerPositionAnim?.value ?? _currentMechanicPos!;
    _markerPositionAnim = LatLngTween(begin: beginPos, end: newPos).animate(
      CurvedAnimation(parent: _markerAnimCtrl, curve: Curves.fastOutSlowIn),
    );
    _rotationAnim = Tween<double>(
      begin: _currentRotation,
      end: targetRot,
    ).animate(
      CurvedAnimation(parent: _markerAnimCtrl, curve: Curves.fastOutSlowIn),
    );

    _markerAnimCtrl..reset()..forward();
  }

  // ────────────────── DISPOSE ──────────────────────────────────────────
  @override
  void dispose() {
    _mechanicWorker?.dispose();
    _markerAnimCtrl.dispose();
    super.dispose();
  }

  // ────────────────── UI BUILD ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loadingIcons) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lacak Mekanik')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Obx(() {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      if (!trackCtrl.isFirstFetchCompleted.value && _currentMechanicPos == null) {
        return _waitingScreen(isDark);
      }
      return _mapScreen(isDark);
    });
  }

  // ────────────────── UI HELPER ────────────────────────────────────────
  PreferredSizeWidget _appBar(bool isDark) => AppBar(
    backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
    elevation: 1,
    iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
    title: Text('Lacak Mekanik', style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black)),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
  );

  Widget _waitingScreen(bool isDark) => Scaffold(
    backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
    appBar: _appBar(isDark),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AssetsRes.MECHANIC, height: 70),
          const SizedBox(height: 20),
          const Text('Menunggu data lokasi mekanik…'),
        ],
      ),
    ),
  );

  Widget _mapScreen(bool isDark) {
    final mechPos = _markerPositionAnim?.value ?? _currentMechanicPos;
    final mechRot = _rotationAnim?.value ?? _currentRotation;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
      appBar: _appBar(isDark),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _userLocation, zoom: 16),
            markers: {
              Marker(
                markerId: const MarkerId('User'),
                position: _userLocation,
                icon: _userIcon,
                infoWindow: const InfoWindow(title: 'Lokasi Saya'),
              ),
              if (mechPos != null)
                Marker(
                  markerId: const MarkerId('Mechanic'),
                  position: mechPos,
                  icon: _mechanicIcon,
                  anchor: const Offset(0.5, 0.5),
                  rotation: mechRot,
                  flat: false, // 🚩 marker TIDAK ikut berputar saat user rotate map
                  infoWindow: InfoWindow(title: widget.data.status ?? 'Mekanik'),
                ),
            },
            polylines: _polylines,
            onMapCreated: (c) async {
              _mapController = c;
              if (mechPos != null) {
                await Future.delayed(const Duration(milliseconds: 600));
                _mapController.showMarkerInfoWindow(const MarkerId('Mechanic'));
              }
            },
            onCameraMoveStarted: () => setState(() => _mapInteracting = true),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _infoPanel(context, mechPos, isDark),
          ),
        ],
      ),
    );
  }

  // ────────────────── INFO PANEL ───────────────────────────────────────
  Widget _infoPanel(BuildContext ctx, LatLng? mechPos, bool isDark) {
    final polyKm = _polylineDistance(_polyPts);
    final distKm = _trafficKm ?? polyKm;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // tombol zooom/refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _mapInteracting = false);
                  _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _userLocation, zoom: 16)));
                },
                icon: Icon(Icons.my_location, color: isDark ? Colors.white : Colors.black),
                label: Text('Lokasi Saya', style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black)),
                style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.grey[800] : Colors.white),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  setState(() => _mapInteracting = false);
                  if (mechPos != null) {
                    await _updateRoute(mechPos, _userLocation);
                    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: mechPos, zoom: 16)));
                    await Future.delayed(const Duration(milliseconds: 300));
                    _mapController.showMarkerInfoWindow(const MarkerId('Mechanic'));
                  }
                },
                icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black),
                label: Text('Refresh Maps', style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black)),
                style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.grey[800] : Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CARD INFO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Informasi Tracking Mekanik', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 8),

                // alamat mechanic
                Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: isDark ? Colors.white : Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() {
                        final addr = trackCtrl.mechanicAddress.value;
                        return Text(
                          addr ?? 'Mengambil alamat mekanik…',
                          style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white : Colors.black),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // jarak
                Row(
                  children: [
                    Icon(Icons.directions_car, size: 20, color: isDark ? Colors.white : Colors.black),
                    const SizedBox(width: 8),
                    Text('Jarak: ${distKm.toStringAsFixed(2)} km', style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),

                // ETA
                Row(
                  children: [
                    Icon(Icons.timer, size: 20, color: isDark ? Colors.white : Colors.black),
                    const SizedBox(width: 8),
                    Text('Estimasi Waktu: ${_trafficTime.isNotEmpty ? _trafficTime : _fallbackTravelTime(distKm)}', style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────── ROUTE + POLYLINE ─────────────────────────────────
  Future<void> _updateRoute(LatLng origin, LatLng dest) async {
    if ((origin.latitude == 0 && origin.longitude == 0) || (dest.latitude == 0 && dest.longitude == 0)) return;

    // throttle 10 s
    if (_lastPolylineFetch != null && DateTime.now().difference(_lastPolylineFetch!) < const Duration(seconds: 10)) return;
    _lastPolylineFetch = DateTime.now();

    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}&mode=driving&departure_time=now&traffic_model=best_guess&key=$_googleKey';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return;
      final data = json.decode(res.body);
      if ((data['routes'] as List).isEmpty) return;

      final leg = data['routes'][0]['legs'][0];
      _trafficTime = leg['duration_in_traffic']?['text'] ?? leg['duration']['text'];
      _trafficKm = leg['distance']['value'] / 1000;

      final pts = PolylinePoints().decodePolyline(data['routes'][0]['overview_polyline']['points']);
      _polyPts = pts.map((p) => LatLng(p.latitude, p.longitude)).toList();

      if (!mounted) return;
      setState(() {
        _polylines
          ..clear()
          ..add(Polyline(polylineId: const PolylineId('route'), points: _polyPts, color: Colors.blue, width: 5));
      });

      if (!_mapInteracting) {
        final bounds = _boundsFrom([origin, dest]);
        if (bounds != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
          });
        }
      }
    } catch (e) {
      debugPrint('updateRoute error: $e');
    }
  }

  LatLngBounds? _boundsFrom(List<LatLng> pts) {
    if (pts.isEmpty) return null;
    var minLat = pts.first.latitude, maxLat = pts.first.latitude, minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude  < minLat) minLat = p.latitude;
      if (p.latitude  > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    if ([minLat, maxLat, minLng, maxLng].every((v) => v == 0)) return null;
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  // ────────────────── UTILITIES ────────────────────────────────────────
  double _distanceKm(LatLng a, LatLng b) {
    const rad = pi / 180;
    final dLat = (b.latitude - a.latitude) * rad;
    final dLon = (b.longitude - a.longitude) * rad;
    final h = sin(dLat / 2) * sin(dLat / 2) + cos(a.latitude * rad) * cos(b.latitude * rad) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * 6371 * asin(sqrt(h));
  }

  double _polylineDistance(List<LatLng> pts) {
    double total = 0;
    for (int i = 0; i < pts.length - 1; i++) {
      total += _distanceKm(pts[i], pts[i + 1]);
    }
    return total;
  }

  String _fallbackTravelTime(double km) {
    const v = 40.0; // km/h
    final hrs = km / v;
    if (hrs < 1) return '${(hrs * 60).round()} menit';
    final h = hrs.floor();
    final m = ((hrs - h) * 60).round();
    return m == 0 ? '$h jam' : '$h jam $m menit';
  }
}