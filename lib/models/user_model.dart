class UserModel {
  final String id;
  final String email;
  final String? codePostal;
  final String? commune;

  UserModel({
    required this.id,
    required this.email,
    this.codePostal,
    this.commune,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      codePostal: map['code_postal'],
      commune: map['commune'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'code_postal': codePostal,
      'commune': commune,
    };
  }
}
