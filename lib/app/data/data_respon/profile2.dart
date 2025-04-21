class Profile2 {
  int? id;
  String? name;
  String? email;
  String? posisi;

  Profile2({this.id, this.name, this.email, this.posisi});

  Profile2.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    posisi = json['posisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['posisi'] = this.posisi;
    return data;
  }
}
