class Listemergency {
  List<Data>? data;

  Listemergency({this.data});

  Listemergency.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? kode;
  String? kodeSvc;
  String? kodeForman;
  String? kodeOttogo;
  String? tgl;
  String? jam;
  String? noPolisi;
  String? nama;
  String? hp;
  String? email;
  String? keluhan;
  String? latitude;
  String? catatanMekanik;
  String? longitude;
  String? status;
  int? deleted;
  int? prosesSvc;
  String? createdAt;
  String? updatedAt;
  List<EmergencyMedia>? emergencyMedia;

  Data(
      {this.id,
        this.kode,
        this.kodeSvc,
        this.kodeForman,
        this.kodeOttogo,
        this.tgl,
        this.jam,
        this.noPolisi,
        this.nama,
        this.hp,
        this.email,
        this.keluhan,
        this.latitude,
        this.catatanMekanik,
        this.longitude,
        this.status,
        this.deleted,
        this.prosesSvc,
        this.createdAt,
        this.updatedAt,
        this.emergencyMedia});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kode = json['kode'];
    kodeSvc = json['kode_svc'];
    kodeForman = json['kode_forman'];
    kodeOttogo = json['kode_ottogo'];
    tgl = json['tgl'];
    jam = json['jam'];
    noPolisi = json['no_polisi'];
    nama = json['nama'];
    hp = json['hp'];
    email = json['email'];
    keluhan = json['keluhan'];
    latitude = json['latitude'];
    catatanMekanik = json['catatan_mekanik'];
    longitude = json['longitude'];
    status = json['status'];
    deleted = json['deleted'];
    prosesSvc = json['proses_svc'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['emergency_media'] != null) {
      emergencyMedia = <EmergencyMedia>[];
      json['emergency_media'].forEach((v) {
        emergencyMedia!.add(new EmergencyMedia.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['kode'] = this.kode;
    data['kode_svc'] = this.kodeSvc;
    data['kode_forman'] = this.kodeForman;
    data['kode_ottogo'] = this.kodeOttogo;
    data['tgl'] = this.tgl;
    data['jam'] = this.jam;
    data['no_polisi'] = this.noPolisi;
    data['nama'] = this.nama;
    data['hp'] = this.hp;
    data['email'] = this.email;
    data['keluhan'] = this.keluhan;
    data['latitude'] = this.latitude;
    data['catatan_mekanik'] = this.catatanMekanik;
    data['longitude'] = this.longitude;
    data['status'] = this.status;
    data['deleted'] = this.deleted;
    data['proses_svc'] = this.prosesSvc;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.emergencyMedia != null) {
      data['emergency_media'] =
          this.emergencyMedia!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EmergencyMedia {
  String? media;
  String? type;

  EmergencyMedia({this.media, this.type});

  EmergencyMedia.fromJson(Map<String, dynamic> json) {
    media = json['media'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['media'] = this.media;
    data['type'] = this.type;
    return data;
  }
}
