import 'dart:convert';

StudioEntry studioEntryFromJson(String str) =>
    StudioEntry.fromJson(json.decode(str));

String studioEntryToJson(StudioEntry data) => json.encode(data.toJson());

class StudioEntry {
  UserKota userKota;
  List<City> cities;
  bool hasUserKota;

  StudioEntry({
    required this.userKota,
    required this.cities,
    required this.hasUserKota,
  });

  factory StudioEntry.fromJson(Map<String, dynamic> json) {
    final rawUserKota = json["user_kota"];
    return StudioEntry(
      // Default to Jakarta if user_kota is null
      userKota: userKotaValues.map[rawUserKota] ?? UserKota.JAKARTA,
      cities: List<City>.from(json["cities"].map((x) => City.fromJson(x))),
      hasUserKota: rawUserKota != null
    );
  }

  Map<String, dynamic> toJson() => {
    "user_kota": userKotaValues.reverse[userKota],
    "cities": List<dynamic>.from(cities.map((x) => x.toJson())),
  };
}

class City {
  UserKota name;
  bool isUserCity;
  List<Studio> studios;

  City({required this.name, required this.isUserCity, required this.studios});

  factory City.fromJson(Map<String, dynamic> json) => City(
    name: userKotaValues.map[json["name"]]!,
    isUserCity: json["is_user_city"],
    studios: List<Studio>.from(json["studios"].map((x) => Studio.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": userKotaValues.reverse[name],
    "is_user_city": isUserCity,
    "studios": List<dynamic>.from(studios.map((x) => x.toJson())),
  };
}

enum UserKota { JAKARTA, BOGOR, DEPOK, TANGERANG, BEKASI }

final userKotaValues = EnumValues({
  "Bekasi": UserKota.BEKASI,
  "Bogor": UserKota.BOGOR,
  "Depok": UserKota.DEPOK,
  "Jakarta": UserKota.JAKARTA,
  "Tangerang": UserKota.TANGERANG,
});

class Studio {
  String id;
  String namaStudio;
  String thumbnail;
  UserKota kota;
  String area;
  String alamat;
  String gmapsLink;
  String nomorTelepon;
  double rating;

  Studio({
    required this.id,
    required this.namaStudio,
    required this.thumbnail,
    required this.kota,
    required this.area,
    required this.alamat,
    required this.gmapsLink,
    required this.nomorTelepon,
    required this.rating,
  });

  factory Studio.fromJson(Map<String, dynamic> json) => Studio(
    id: json["id"],
    namaStudio: json["nama_studio"],
    thumbnail: json["thumbnail"],
    kota: userKotaValues.map[json["kota"]]!,
    area: json["area"],
    alamat: json["alamat"],
    gmapsLink: json["gmaps_link"],
    nomorTelepon: json["nomor_telepon"],
    rating: json["rating"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama_studio": namaStudio,
    "thumbnail": thumbnail,
    "kota": userKotaValues.reverse[kota],
    "area": area,
    "alamat": alamat,
    "gmaps_link": gmapsLink,
    "nomor_telepon": nomorTelepon,
    "rating": rating,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
