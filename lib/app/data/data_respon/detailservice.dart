/// Helper to safely parse ints from dynamic JSON (handles int, double, String)
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

class DetailService {
  DataSvc? dataSvc;
  List<DataSvcPaket>? dataSvcPaket;
  List<DataSvcDtlPart>? dataSvcDtlPart;
  List<DataSvcDtlJasa>? dataSvcDtlJasa;
  List<Paket>? paket;
  String? deskripsiMembership;
  String? title;
  String? kdTitle;

  DetailService({
    this.dataSvc,
    this.dataSvcPaket,
    this.dataSvcDtlPart,
    this.dataSvcDtlJasa,
    this.paket,
    this.deskripsiMembership,
    this.title,
    this.kdTitle,
  });

  factory DetailService.fromJson(Map<String, dynamic> json) => DetailService(
    dataSvc: json['data_svc'] == null
        ? null
        : DataSvc.fromJson(json['data_svc']),
    dataSvcPaket: (json['data_svc_paket'] as List?)
        ?.map((e) => DataSvcPaket.fromJson(e))
        .toList(),
    dataSvcDtlPart: (json['data_svc_dtl_part'] as List?)
        ?.map((e) => DataSvcDtlPart.fromJson(e))
        .toList(),
    dataSvcDtlJasa: (json['data_svc_dtl_jasa'] as List?)
        ?.map((e) => DataSvcDtlJasa.fromJson(e))
        .toList(),
    paket:
    (json['paket'] as List?)?.map((e) => Paket.fromJson(e)).toList(),
    deskripsiMembership: json['deskripsi_membership'],
    title: json['title'],
    kdTitle: json['kd_title'],
  );

  Map<String, dynamic> toJson() => {
    'data_svc': dataSvc?.toJson(),
    'data_svc_paket': dataSvcPaket?.map((e) => e.toJson()).toList(),
    'data_svc_dtl_part': dataSvcDtlPart?.map((e) => e.toJson()).toList(),
    'data_svc_dtl_jasa': dataSvcDtlJasa?.map((e) => e.toJson()).toList(),
    'paket': paket?.map((e) => e.toJson()).toList(),
    'deskripsi_membership': deskripsiMembership,
    'title': title,
    'kd_title': kdTitle,
  };
}

class DataSvc {
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
  int? ppn;
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
  String? kode;
  String? noPolisi;
  int? idMerk;
  int? idTipe;
  String? tahun;
  String? warna;
  String? transmisi;
  String? noRangka;
  String? noMesin;
  String? modelKaroseri;
  String? drivingMode;
  String? power;
  String? kategoriKendaraan;
  String? jenisKontrak;
  String? masaBerlakuStnk;
  String? masaBerlakuPajak;
  String? masaBerlakuKir;
  String? noPintu;
  String? nama;
  String? alamat;
  String? telp;
  String? hp;
  String? email;
  String? kontak;
  int? due;
  String? jenisKontrakX;
  String? namaTagihan;
  String? alamatTagihan;
  String? telpTagihan;
  String? npwpTagihan;
  String? picTagihan;
  int? limitTrx;
  int? piutang;
  String? peran;
  String? namaMerk;
  String? namaTipe;

  DataSvc({
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
    this.kode,
    this.noPolisi,
    this.idMerk,
    this.idTipe,
    this.tahun,
    this.warna,
    this.transmisi,
    this.noRangka,
    this.noMesin,
    this.modelKaroseri,
    this.drivingMode,
    this.power,
    this.kategoriKendaraan,
    this.jenisKontrak,
    this.masaBerlakuStnk,
    this.masaBerlakuPajak,
    this.masaBerlakuKir,
    this.noPintu,
    this.nama,
    this.alamat,
    this.telp,
    this.hp,
    this.email,
    this.kontak,
    this.due,
    this.jenisKontrakX,
    this.namaTagihan,
    this.alamatTagihan,
    this.telpTagihan,
    this.npwpTagihan,
    this.picTagihan,
    this.limitTrx,
    this.piutang,
    this.peran,
    this.namaMerk,
    this.namaTipe,
  });

  factory DataSvc.fromJson(Map<String, dynamic> j) => DataSvc(
    id: _toInt(j['id']),
    kodeSvc: j['kode_svc'],
    kodeEstimasi: j['kode_estimasi'],
    kodePkb: j['kode_pkb'],
    kodePelanggan: j['kode_pelanggan'],
    kodeKendaraan: j['kode_kendaraan'],
    odometer: j['odometer'],
    pic: j['pic'],
    hpPic: j['hp_pic'],
    kodeMembership: j['kode_membership'],
    kodePaketmember: j['kode_paketmember'],
    tipeSvc: j['tipe_svc'],
    tipePelanggan: j['tipe_pelanggan'],
    referensi: j['referensi'],
    referensiTeman: j['referensi_teman'],
    poNumber: j['po_number'],
    paketSvc: j['paket_svc'],
    tglKeluar: j['tgl_keluar'],
    tglKembali: j['tgl_kembali'],
    kmKeluar: j['km_keluar'],
    kmKembali: j['km_kembali'],
    keluhan: j['keluhan'],
    perintahKerja: j['perintah_kerja'],
    pergantianPart: j['pergantian_part'],
    saran: j['saran'],
    ppn: _toInt(j['ppn']),
    tglEstimasi: j['tgl_estimasi'],
    tglPkb: j['tgl_pkb'],
    tglTutup: j['tgl_tutup'],
    pkb: _toInt(j['pkb']),
    tutup: _toInt(j['tutup']),
    faktur: _toInt(j['faktur']),
    deleted: _toInt(j['deleted']),
    notab: _toInt(j['notab']),
    planning: j['planning'],
    createdBy: j['created_by'],
    createdAt: j['created_at'],
    updatedAt: j['updated_at'],
    kodeOttogo: j['kode_ottogo'],
    kode: j['kode'],
    noPolisi: j['no_polisi'],
    idMerk: _toInt(j['id_merk']),
    idTipe: _toInt(j['id_tipe']),
    tahun: j['tahun'],
    warna: j['warna'],
    transmisi: j['transmisi'],
    noRangka: j['no_rangka'],
    noMesin: j['no_mesin'],
    modelKaroseri: j['model_karoseri'],
    drivingMode: j['driving_mode'],
    power: j['power'],
    kategoriKendaraan: j['kategori_kendaraan'],
    jenisKontrak: j['jenis_kontrak'],
    masaBerlakuStnk: j['masa_berlaku_stnk'],
    masaBerlakuPajak: j['masa_berlaku_pajak'],
    masaBerlakuKir: j['masa_berlaku_kir'],
    noPintu: j['no_pintu'],
    nama: j['nama'],
    alamat: j['alamat'],
    telp: j['telp'],
    hp: j['hp'],
    email: j['email'],
    kontak: j['kontak'],
    due: _toInt(j['due']),
    jenisKontrakX: j['jenis_kontrak_x'],
    namaTagihan: j['nama_tagihan'],
    alamatTagihan: j['alamat_tagihan'],
    telpTagihan: j['telp_tagihan'],
    npwpTagihan: j['npwp_tagihan'],
    picTagihan: j['pic_tagihan'],
    limitTrx: _toInt(j['limit_trx']),
    piutang: _toInt(j['piutang']),
    peran: j['peran'],
    namaMerk: j['nama_merk'],
    namaTipe: j['nama_tipe'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode_svc': kodeSvc,
    'kode_estimasi': kodeEstimasi,
    'kode_pkb': kodePkb,
    'kode_pelanggan': kodePelanggan,
    'kode_kendaraan': kodeKendaraan,
    'odometer': odometer,
    'pic': pic,
    'hp_pic': hpPic,
    'kode_membership': kodeMembership,
    'kode_paketmember': kodePaketmember,
    'tipe_svc': tipeSvc,
    'tipe_pelanggan': tipePelanggan,
    'referensi': referensi,
    'referensi_teman': referensiTeman,
    'po_number': poNumber,
    'paket_svc': paketSvc,
    'tgl_keluar': tglKeluar,
    'tgl_kembali': tglKembali,
    'km_keluar': kmKeluar,
    'km_kembali': kmKembali,
    'keluhan': keluhan,
    'perintah_kerja': perintahKerja,
    'pergantian_part': pergantianPart,
    'saran': saran,
    'ppn': ppn,
    'tgl_estimasi': tglEstimasi,
    'tgl_pkb': tglPkb,
    'tgl_tutup': tglTutup,
    'pkb': pkb,
    'tutup': tutup,
    'faktur': faktur,
    'deleted': deleted,
    'notab': notab,
    'planning': planning,
    'created_by': createdBy,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'kode_ottogo': kodeOttogo,
    'kode': kode,
    'no_polisi': noPolisi,
    'id_merk': idMerk,
    'id_tipe': idTipe,
    'tahun': tahun,
    'warna': warna,
    'transmisi': transmisi,
    'no_rangka': noRangka,
    'no_mesin': noMesin,
    'model_karoseri': modelKaroseri,
    'driving_mode': drivingMode,
    'power': power,
    'kategori_kendaraan': kategoriKendaraan,
    'jenis_kontrak': jenisKontrak,
    'masa_berlaku_stnk': masaBerlakuStnk,
    'masa_berlaku_pajak': masaBerlakuPajak,
    'masa_berlaku_kir': masaBerlakuKir,
    'no_pintu': noPintu,
    'nama': nama,
    'alamat': alamat,
    'telp': telp,
    'hp': hp,
    'email': email,
    'kontak': kontak,
    'due': due,
    'jenis_kontrak_x': jenisKontrakX,
    'nama_tagihan': namaTagihan,
    'alamat_tagihan': alamatTagihan,
    'telp_tagihan': telpTagihan,
    'npwp_tagihan': npwpTagihan,
    'pic_tagihan': picTagihan,
    'limit_trx': limitTrx,
    'piutang': piutang,
    'peran': peran,
    'nama_merk': namaMerk,
    'nama_tipe': namaTipe,
  };
}

class DataSvcPaket {
  int? id;
  String? kodeSvc;
  String? kode;
  String? nama;
  int? qty;
  int? harga;
  String? jenis;
  String? kodePaket;
  String? namaPaket;
  String? createdAt;
  String? updatedAt;

  DataSvcPaket({
    this.id,
    this.kodeSvc,
    this.kode,
    this.nama,
    this.qty,
    this.harga,
    this.jenis,
    this.kodePaket,
    this.namaPaket,
    this.createdAt,
    this.updatedAt,
  });

  factory DataSvcPaket.fromJson(Map<String, dynamic> j) => DataSvcPaket(
    id: _toInt(j['id']),
    kodeSvc: j['kode_svc'],
    kode: j['kode'],
    nama: j['nama'],
    qty: _toInt(j['qty']),
    harga: _toInt(j['harga']),
    jenis: j['jenis'],
    kodePaket: j['kode_paket'],
    namaPaket: j['nama_paket'],
    createdAt: j['created_at'],
    updatedAt: j['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode_svc': kodeSvc,
    'kode': kode,
    'nama': nama,
    'qty': qty,
    'harga': harga,
    'jenis': jenis,
    'kode_paket': kodePaket,
    'nama_paket': namaPaket,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class DataSvcDtlPart {
  int? id;
  String? kodeSvc;
  String? kodeSparepart;
  String? namaSparepart;
  int? qtySparepart;
  int? hargaSparepart;
  int? diskonSparepart;
  String? hidSparepart;
  int? nota;
  String? createdAt;
  String? updatedAt;
  String? kode;
  String? kode2;
  String? nama;
  String? divisi;
  String? brand;
  int? qty;
  int? hargaBeli;
  int? hargaJual;
  String? barcode;
  String? satuan;
  String? noStock;
  String? lokasi;
  String? note;
  String? tipe;
  String? kodeSupplier;
  int? qtyMin;
  int? qtyMax;
  String? ukuran;
  String? kualitas;
  int? demandBulanan;
  String? emergency;
  String? jenis;
  int? deleted;
  String? createdBy;

  DataSvcDtlPart({
    this.id,
    this.kodeSvc,
    this.kodeSparepart,
    this.namaSparepart,
    this.qtySparepart,
    this.hargaSparepart,
    this.diskonSparepart,
    this.hidSparepart,
    this.nota,
    this.createdAt,
    this.updatedAt,
    this.kode,
    this.kode2,
    this.nama,
    this.divisi,
    this.brand,
    this.qty,
    this.hargaBeli,
    this.hargaJual,
    this.barcode,
    this.satuan,
    this.noStock,
    this.lokasi,
    this.note,
    this.tipe,
    this.kodeSupplier,
    this.qtyMin,
    this.qtyMax,
    this.ukuran,
    this.kualitas,
    this.demandBulanan,
    this.emergency,
    this.jenis,
    this.deleted,
    this.createdBy,
  });

  factory DataSvcDtlPart.fromJson(Map<String, dynamic> j) => DataSvcDtlPart(
    id: _toInt(j['id']),
    kodeSvc: j['kode_svc'],
    kodeSparepart: j['kode_sparepart'],
    namaSparepart: j['nama_sparepart'],
    qtySparepart: _toInt(j['qty_sparepart']),
    hargaSparepart: _toInt(j['harga_sparepart']),
    diskonSparepart: _toInt(j['diskon_sparepart']),
    hidSparepart: j['hid_sparepart'],
    nota: _toInt(j['nota']),
    createdAt: j['created_at'],
    updatedAt: j['updated_at'],
    kode: j['kode'],
    kode2: j['kode_2'],
    nama: j['nama'],
    divisi: j['divisi'],
    brand: j['brand'],
    qty: _toInt(j['qty']),
    hargaBeli: _toInt(j['harga_beli']),
    hargaJual: _toInt(j['harga_jual']),
    barcode: j['barcode'],
    satuan: j['satuan'],
    noStock: j['no_stock'],
    lokasi: j['lokasi'],
    note: j['note'],
    tipe: j['tipe'],
    kodeSupplier: j['kode_supplier'],
    qtyMin: _toInt(j['qty_min']),
    qtyMax: _toInt(j['qty_max']),
    ukuran: j['ukuran'],
    kualitas: j['kualitas'],
    demandBulanan: _toInt(j['demand_bulanan']),
    emergency: j['emergency'],
    jenis: j['jenis'],
    deleted: _toInt(j['deleted']),
    createdBy: j['created_by'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode_svc': kodeSvc,
    'kode_sparepart': kodeSparepart,
    'nama_sparepart': namaSparepart,
    'qty_sparepart': qtySparepart,
    'harga_sparepart': hargaSparepart,
    'diskon_sparepart': diskonSparepart,
    'hid_sparepart': hidSparepart,
    'nota': nota,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'kode': kode,
    'kode_2': kode2,
    'nama': nama,
    'divisi': divisi,
    'brand': brand,
    'qty': qty,
    'harga_beli': hargaBeli,
    'harga_jual': hargaJual,
    'barcode': barcode,
    'satuan': satuan,
    'no_stock': noStock,
    'lokasi': lokasi,
    'note': note,
    'tipe': tipe,
    'kode_supplier': kodeSupplier,
    'qty_min': qtyMin,
    'qty_max': qtyMax,
    'ukuran': ukuran,
    'kualitas': kualitas,
    'demand_bulanan': demandBulanan,
    'emergency': emergency,
    'jenis': jenis,
    'deleted': deleted,
    'created_by': createdBy,
  };
}

class DataSvcDtlJasa {
  int? id;
  String? kodeSvc;
  String? kodeJasa;
  String? namaJasa;
  int? qtyJasa;
  int? hargaJasa;
  int? diskonJasa;
  String? hidJasa;
  String? createdAt;
  String? updatedAt;
  int? biaya;
  int? jam;
  String? divisiJasa;
  int? deleted;
  String? createdBy;

  DataSvcDtlJasa({
    this.id,
    this.kodeSvc,
    this.kodeJasa,
    this.namaJasa,
    this.qtyJasa,
    this.hargaJasa,
    this.diskonJasa,
    this.hidJasa,
    this.createdAt,
    this.updatedAt,
    this.biaya,
    this.jam,
    this.divisiJasa,
    this.deleted,
    this.createdBy,
  });

  factory DataSvcDtlJasa.fromJson(Map<String, dynamic> j) => DataSvcDtlJasa(
    id: _toInt(j['id']),
    kodeSvc: j['kode_svc'],
    kodeJasa: j['kode_jasa'],
    namaJasa: j['nama_jasa'],
    qtyJasa: _toInt(j['qty_jasa']),
    hargaJasa: _toInt(j['harga_jasa']),
    diskonJasa: _toInt(j['diskon_jasa']),
    hidJasa: j['hid_jasa'],
    createdAt: j['created_at'],
    updatedAt: j['updated_at'],
    biaya: _toInt(j['biaya']),
    jam: _toInt(j['jam']),
    divisiJasa: j['divisi_jasa'],
    deleted: _toInt(j['deleted']),
    createdBy: j['created_by'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode_svc': kodeSvc,
    'kode_jasa': kodeJasa,
    'nama_jasa': namaJasa,
    'qty_jasa': qtyJasa,
    'harga_jasa': hargaJasa,
    'diskon_jasa': diskonJasa,
    'hid_jasa': hidJasa,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'biaya': biaya,
    'jam': jam,
    'divisi_jasa': divisiJasa,
    'deleted': deleted,
    'created_by': createdBy,
  };
}

class Paket {
  int? id;
  String? kodeSvc;
  String? kode;
  String? nama;
  int? qty;
  int? harga;
  String? jenis;
  String? kodePaket;
  String? namaPaket;
  String? createdAt;
  String? updatedAt;
  int? total;

  Paket({
    this.id,
    this.kodeSvc,
    this.kode,
    this.nama,
    this.qty,
    this.harga,
    this.jenis,
    this.kodePaket,
    this.namaPaket,
    this.createdAt,
    this.updatedAt,
    this.total,
  });

  factory Paket.fromJson(Map<String, dynamic> j) => Paket(
    id: _toInt(j['id']),
    kodeSvc: j['kode_svc'],
    kode: j['kode'],
    nama: j['nama'],
    qty: _toInt(j['qty']),
    harga: _toInt(j['harga']),
    jenis: j['jenis'],
    kodePaket: j['kode_paket'],
    namaPaket: j['nama_paket'],
    createdAt: j['created_at'],
    updatedAt: j['updated_at'],
    total: _toInt(j['total']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode_svc': kodeSvc,
    'kode': kode,
    'nama': nama,
    'qty': qty,
    'harga': harga,
    'jenis': jenis,
    'kode_paket': kodePaket,
    'nama_paket': namaPaket,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'total': total,
  };
}
