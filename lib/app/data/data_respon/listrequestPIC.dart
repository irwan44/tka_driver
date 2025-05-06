class ListRequesServicePIC {
  int? id;
  String? kodeRequestService;
  String? kodeSvc;
  String? kodePelanggan;
  String? kodeKendaraan;
  String? kodeService;
  String? kodeOttogo;
  String? keluhan;
  String? status;
  String? tanggalService;
  String? jamService;
  int? deleted;
  int? prosesSvc;
  int? createdBy;
  String? createdAt;
  String? updatedAt;
  String? noPolisi;
  List<String>? mediaFiles;

  ListRequesServicePIC({
    this.id,
    this.kodeRequestService,
    this.kodeSvc,
    this.kodePelanggan,
    this.kodeKendaraan,
    this.kodeService,
    this.kodeOttogo,
    this.keluhan,
    this.status,
    this.tanggalService,
    this.jamService,
    this.deleted,
    this.prosesSvc,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.noPolisi,
    this.mediaFiles,
  });

  ListRequesServicePIC.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kodeRequestService = json['kode_request_service'];
    kodeSvc = json['kode_svc'];
    kodePelanggan = json['kode_pelanggan'];
    kodeKendaraan = json['kode_kendaraan'];
    kodeService = json['kode_service'];
    kodeOttogo = json['kode_ottogo'];
    keluhan = json['keluhan'];
    status = json['status'];
    tanggalService = json['tanggal_service'];
    jamService = json['jam_service'];
    deleted = json['deleted'];
    prosesSvc = json['proses_svc'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    noPolisi = json['no_polisi'];
    mediaFiles = json['media_files'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['kode_request_service'] = this.kodeRequestService;
    data['kode_svc'] = this.kodeSvc;
    data['kode_pelanggan'] = this.kodePelanggan;
    data['kode_kendaraan'] = this.kodeKendaraan;
    data['kode_service'] = this.kodeService;
    data['kode_ottogo'] = this.kodeOttogo;
    data['keluhan'] = this.keluhan;
    data['status'] = this.status;
    data['tanggal_service'] = this.tanggalService;
    data['jam_service'] = this.jamService;
    data['deleted'] = this.deleted;
    data['proses_svc'] = this.prosesSvc;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['no_polisi'] = this.noPolisi;
    data['media_files'] = this.mediaFiles;
    return data;
  }
}
