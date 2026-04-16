class UserModel {
  final String id;  final String email;
  final String name;
  final String avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.avatar,
  });

  // ĐỊNH NGHĨA COPYWITH TẠI ĐÂY (Để hết lỗi)
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }

  // Chuyển từ JSON (PHP trả về) sang Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'].toString(),
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
    );
  }

  // Chuyển từ Object sang Map (Để lưu vào Hive/Session)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
    };
  }
}