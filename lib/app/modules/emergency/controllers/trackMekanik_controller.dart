import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tka_customer/app/data/endpoint.dart';

class TrackMekanikController extends GetxController {
  TrackMekanikController(this.kode);

  final String kode;
  final mechanicLocation = Rxn<LatLng>();
  final mechanicAddress  = RxnString();
  final isFirstFetchCompleted = false.obs;
  final isOnline = false.obs;

  static const _pollInterval   = Duration(seconds: 3);
  static const _routeRefreshGap= Duration(seconds: 10);
  static const _addrThresholdKm= 0.05;

  Timer?   _timer;
  bool     _pollRunning = false;
  LatLng?  _lastAddrLoc;
  DateTime? _lastRouteUpdate;

  @override
  void onInit() {
    super.onInit();
    _startPolling();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startPolling(){
    _safeFetch();
    _timer=Timer.periodic(_pollInterval,(_)=>_safeFetch());
  }
  Future<void> _safeFetch()async{
    if(_pollRunning)return;
    _pollRunning=true;
    try{await _fetchMechanicPos();}finally{_pollRunning=false;}
  }
  Future<void> _fetchMechanicPos()async{
    try{
      final pos=await API.fetchMekanikPosisi(kode);
      final lat=double.tryParse(pos.latitude??'');
      final lon=double.tryParse(pos.longitude??'');
      if(lat==null||lon==null||(lat==0&&lon==0))return;
      final newLoc=LatLng(lat,lon);
      mechanicLocation.value=newLoc;
      isFirstFetchCompleted.value=true;
      isOnline.value=true;
      if(_lastAddrLoc==null||_haversineKm(_lastAddrLoc!,newLoc)>_addrThresholdKm){
        _lastAddrLoc=newLoc;
        _updateAddress(newLoc);
      }
      final now=DateTime.now();
      if(_lastRouteUpdate==null||now.difference(_lastRouteUpdate!)>_routeRefreshGap){
        _lastRouteUpdate=now;update();}
    }catch(e){debugPrint('[TrackMekanik][$kode] fetch error: $e');}
  }
  Future<void> _updateAddress(LatLng loc)async{
    try{
      final list=await placemarkFromCoordinates(loc.latitude,loc.longitude);
      if(list.isNotEmpty){final p=list.first;mechanicAddress.value='${p.street??''}, ${p.subLocality??''}, ${p.locality??''}';}
    }catch(_){mechanicAddress.value=null;}
  }
  double _haversineKm(LatLng a,LatLng b){
    const rad=pi/180;
    final dLat=(b.latitude-a.latitude)*rad;
    final dLon=(b.longitude-a.longitude)*rad;
    final h=sin(dLat/2)*sin(dLat/2)+cos(a.latitude*rad)*cos(b.latitude*rad)*sin(dLon/2)*sin(dLon/2);
    return 2*6371*asin(sqrt(h));
  }
}