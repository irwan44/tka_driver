class ListKendaraan {
  List<Data>? data;

  ListKendaraan({this.data});

  ListKendaraan.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mapData = <String, dynamic>{};
    if (data != null) {
      mapData['data'] = data!.map((v) => v.toJson()).toList();
    }
    return mapData;
  }
}

class Data {
  String? namaDriver;
  String? noPolisi;

  Data({this.namaDriver, this.noPolisi});

  Data.fromJson(Map<String, dynamic> json) {
    namaDriver = json['nama_driver'];
    noPolisi = json['no_polisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mapData = <String, dynamic>{};
    mapData['nama_driver'] = namaDriver;
    mapData['no_polisi'] = noPolisi;
    return mapData;
  }
}
