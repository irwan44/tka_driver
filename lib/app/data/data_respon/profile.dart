class Profile {
  int? id;
  String? name;
  String? email;
  String? shift;
  String? jamMasuk;
  String? jamPulang;
  String? hari;
  String? statusAbsen;
  String? posisi;

  Profile(
      {this.id,
        this.name,
        this.email,
        this.shift,
        this.jamMasuk,
        this.jamPulang,
        this.hari,
        this.statusAbsen,
        this.posisi});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    shift = json['shift'];
    jamMasuk = json['jam_masuk'];
    jamPulang = json['jam_pulang'];
    hari = json['hari'];
    statusAbsen = json['status_absen'];
    posisi = json['posisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['shift'] = this.shift;
    data['jam_masuk'] = this.jamMasuk;
    data['jam_pulang'] = this.jamPulang;
    data['hari'] = this.hari;
    data['status_absen'] = this.statusAbsen;
    data['posisi'] = this.posisi;
    return data;
  }
}
