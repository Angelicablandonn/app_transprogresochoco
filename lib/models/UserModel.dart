import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // Identificador único del usuario
  final String fullName; // Nombre completo del usuario
  final String email; // Correo electrónico del usuario
  final String phoneNumber; // Número de teléfono del usuario
  String? profilePicture; // URL de la foto de perfil del usuario
  final bool isAdmin; // Indica si el usuario es un administrador
  final String password; // Contraseña del usuario>>>>>>>>>>

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture, // Permite una foto de perfil opcional
    this.isAdmin = false, // Por defecto, el usuario no es un administrador
    required this.password, // Agregar la contraseña al constructor
  });

  // Método para actualizar la foto de perfil
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    bool? isAdmin,
    String? password, // Agregar la contraseña al método copyWith
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      isAdmin: isAdmin ?? this.isAdmin,
      password: password ?? this.password, // Copiar la contraseña
    );
  }

  // Método para convertir UserModel a un mapa (JSON)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'isAdmin': isAdmin,
      'password': password, // Agregar la contraseña al mapa
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profilePicture: map['profilePicture'],
      isAdmin: map['isAdmin'],
      password: map['password'],
    );
  }
}
