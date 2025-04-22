class ListService {
  int? id;
  String? kodeSvc;
  String? kodeEstimasi;
  String? kodePkb;
  String? kodePelanggan;
  String? kodeKendaraan;
  String? odometer;
  String? pic;
  String? hpPic;
  String? kodeMembership;
  String? kodePaketmember;
  String? tipeSvc;
  String? tipePelanggan;
  String? referensi;
  String? referensiTeman;
  String? poNumber;
  String? paketSvc;
  String? tglKeluar;
  String? tglKembali;
  String? kmKeluar;
  String? kmKembali;
  String? keluhan;
  String? perintahKerja;
  String? pergantianPart;
  String? saran;
  String? ppn;
  String? tglEstimasi;
  String? tglPkb;
  String? tglTutup;
  int? pkb;
  int? tutup;
  int? faktur;
  int? deleted;
  int? notab;
  String? planning;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  String? kodeOttogo;
  String? pelanggan;
  String? noPolisi;
  String? serviceType;
  String? status;

  ListService({
    this.id,
    this.kodeSvc,
    this.kodeEstimasi,
    this.kodePkb,
    this.kodePelanggan,
    this.kodeKendaraan,
    this.odometer,
    this.pic,
    this.hpPic,
    this.kodeMembership,
    this.kodePaketmember,
    this.tipeSvc,
    this.tipePelanggan,
    this.referensi,
    this.referensiTeman,
    this.poNumber,
    this.paketSvc,
    this.tglKeluar,
    this.tglKembali,
    this.kmKeluar,
    this.kmKembali,
    this.keluhan,
    this.perintahKerja,
    this.pergantianPart,
    this.saran,
    this.ppn,
    this.tglEstimasi,
    this.tglPkb,
    this.tglTutup,
    this.pkb,
    this.tutup,
    this.faktur,
    this.deleted,
    this.notab,
    this.planning,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.kodeOttogo,
    this.pelanggan,
    this.noPolisi,
    this.serviceType,
    this.status,
  });

  ListService.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kodeSvc = json['kode_svc'];
    kodeEstimasi = json['kode_estimasi'];
    kodePkb = json['kode_pkb'];
    kodePelanggan = json['kode_pelanggan'];
    kodeKendaraan = json['kode_kendaraan'];
    odometer = json['odometer'];
    pic = json['pic'];
    hpPic = json['hp_pic'];
    kodeMembership = json['kode_membership'];
    kodePaketmember = json['kode_paketmember'];
    tipeSvc = json['tipe_svc'];
    tipePelanggan = json['tipe_pelanggan'];
    referensi = json['referensi'];
    referensiTeman = json['referensi_teman'];
    poNumber = json['po_number'];
    paketSvc = json['paket_svc'];
    tglKeluar = json['tgl_keluar'];
    tglKembali = json['tgl_kembali'];
    kmKeluar = json['km_keluar'];
    kmKembali = json['km_kembali'];
    keluhan = json['keluhan'];
    perintahKerja = json['perintah_kerja'];
    pergantianPart = json['pergantian_part'];
    saran = json['saran'];
    ppn = json['ppn']?.toString();
    tglEstimasi = json['tgl_estimasi'];
    tglPkb = json['tgl_pkb'];
    tglTutup = json['tgl_tutup'];
    pkb = json['pkb'];
    tutup = json['tutup'];
    faktur = json['faktur'];
    deleted = json['deleted'];
    notab = json['notab'];
    planning = json['planning'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    kodeOttogo = json['kode_ottogo'];
    pelanggan = json['pelanggan'];
    noPolisi = json['no_polisi'];
    serviceType = json['service_type'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['kode_svc'] = kodeSvc;
    data['kode_estimasi'] = kodeEstimasi;
    data['kode_pkb'] = kodePkb;
    data['kode_pelanggan'] = kodePelanggan;
    data['kode_kendaraan'] = kodeKendaraan;
    data['odometer'] = odometer;
    data['pic'] = pic;
    data['hp_pic'] = hpPic;
    data['kode_membership'] = kodeMembership;
    data['kode_paketmember'] = kodePaketmember;
    data['tipe_svc'] = tipeSvc;
    data['tipe_pelanggan'] = tipePelanggan;
    data['referensi'] = referensi;
    data['referensi_teman'] = referensiTeman;
    data['po_number'] = poNumber;
    data['paket_svc'] = paketSvc;
    data['tgl_keluar'] = tglKeluar;
    data['tgl_kembali'] = tglKembali;
    data['km_keluar'] = kmKeluar;
    data['km_kembali'] = kmKembali;
    data['keluhan'] = keluhan;
    data['perintah_kerja'] = perintahKerja;
    data['pergantian_part'] = pergantianPart;
    data['saran'] = saran;
    data['ppn'] = ppn;
    data['tgl_estimasi'] = tglEstimasi;
    data['tgl_pkb'] = tglPkb;
    data['tgl_tutup'] = tglTutup;
    data['pkb'] = pkb;
    data['tutup'] = tutup;
    data['faktur'] = faktur;
    data['deleted'] = deleted;
    data['notab'] = notab;
    data['planning'] = planning;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['kode_ottogo'] = kodeOttogo;
    data['pelanggan'] = pelanggan;
    data['no_polisi'] = noPolisi;
    data['service_type'] = serviceType;
    data['status'] = status;
    return data;
  }
}
