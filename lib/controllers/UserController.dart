import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inicio de sesión
  Future<bool> loginUser(
      BuildContext context, String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Verificar si el usuario es un administrador
        final bool isAdmin = await isUserAdmin();
        if (isAdmin) {
          // Redirigir al dashboard después de iniciar sesión
          Navigator.pushNamed(context, '/dashboard');
          return true; // Inicio de sesión exitoso
        } else {
          // Redirigir al usuario a una página de error
          Navigator.pushNamed(context, '/error');
          return false; // Inicio de sesión fallido
        }
      } else {
        _showErrorDialog(context, 'Error al iniciar sesión.');
        return false; // Inicio de sesión fallido
      }
    } catch (e) {
      print("Error al iniciar sesión: $e");
      _showErrorDialog(
          context, 'Error al iniciar sesión. Por favor, inténtalo de nuevo.');
      return false; // Inicio de sesión fallido
    }
  }

  // Registro de usuario
  Future<UserModel?> registerUser(BuildContext context, String email,
      String password, String fullName, String phoneNumber) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final UserModel user = UserModel(
          uid: firebaseUser.uid,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
        );

        // Guardar el usuario en Firestore
        await _firestore.collection('users').doc(user.uid).set(user.toMap());

        // Redirigir al dashboard después de registrarse
        Navigator.pushNamed(context, '/dashboard');

        return user;
      } else {
        _showErrorDialog(context, 'Error al registrar usuario.');
        return null;
      }
    } catch (e) {
      print("Error al registrar usuario: $e");
      _showErrorDialog(context,
          'Error al registrar usuario. Por favor, inténtalo de nuevo.');
      return null;
    }
  }

  // Obtener datos de usuario desde Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Error al obtener datos de usuario: $e");
      return null;
    }
  }

  // Método para verificar si el usuario está autenticado y es administrador

  Future<bool> isUserAdmin() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Obtener los datos del usuario desde Firestore
        final UserModel? userData = await getUserData(firebaseUser.uid);
        if (userData != null && userData.isAdmin) {
          // El usuario está autenticado y es un administrador
          return true;
        }
      }
      // El usuario no está autenticado o no es un administrador
      return false;
    } catch (e) {
      print("Error al verificar si el usuario es administrador: $e");
      return false;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      // Redirigir al usuario a la pantalla de inicio de sesión después de cerrar sesión
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error al cerrar sesión: $e");
      _showErrorDialog(
          context, 'Error al cerrar sesión. Por favor, inténtalo de nuevo.');
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
