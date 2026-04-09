class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
  });

  UserModel copyWith({String? name, String? avatar}) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }
}
