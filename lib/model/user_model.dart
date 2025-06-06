class UserModel {
  String? name;
  String? profilePhoto;

  UserModel({this.name, this.profilePhoto});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String?,
      profilePhoto: json['profile_photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profile_photo': profilePhoto,
    };
  }

  UserModel copyWith({String? name, String? profilePhoto}) {
    return UserModel(
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}