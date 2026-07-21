class UserModel {
  String? name;
  String? profilePhoto;
  String? currencyCode;

  UserModel({this.name, this.profilePhoto, this.currencyCode});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['username'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      currencyCode: json['currency_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profile_photo': profilePhoto,
      'currency_code': currencyCode,
    };
  }

  UserModel copyWith(
      {String? name, String? profilePhoto, String? currencyCode}) {
    return UserModel(
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
