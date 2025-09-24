class UserModel {
  final String id;
  final String email;
  final String codePostal;
  final String commune;
  final String? name;
  final String? avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.codePostal,
    required this.commune,
    this.name,
    this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'code_postal': codePostal,
      'commune': commune,
      'name': name,
      'avatar': avatar,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      codePostal: map['code_postal'] ?? '',
      commune: map['commune'] ?? '',
      name: map['name'],
      avatar: map['avatar'],
    );
  }
}