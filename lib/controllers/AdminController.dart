import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'dart:io';

class AdminController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

//Agregar usuario
  Future<void> addUserWithPassword(
      UserModel user, String password, BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Asignar el UID generado por Firebase al usuario
        user = user.copyWith(uid: firebaseUser.uid);

        // Subir la imagen de perfil y obtener la URL de descarga
        final String? profilePictureUrl =
            await _selectAndUploadProfilePicture();

        if (profilePictureUrl != null) {
          // Actualizar el campo de imagen de perfil con la URL
          user = user.copyWith(profilePicture: profilePictureUrl);
        }

        // Guardar los datos del usuario en Firestore
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(user.toMap());

        print('Usuario agregado con éxito.');

        // Redirigir a la vista de listar usuarios
        Navigator.of(context).pushNamed('/list_users');
      } else {
        print('Error al crear el usuario.');
      }
    } catch (e) {
      print('Error al agregar el usuario: $e');
    }
  }

// seleccionar y subir foto de perfil
  Future<String?> _selectAndUploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final Reference ref = _storage.ref().child(
            'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final UploadTask uploadTask = ref.putFile(File(pickedFile.path));
        final TaskSnapshot snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          final String downloadUrl = await snapshot.ref.getDownloadURL();
          return downloadUrl;
        } else {
          print('Error al subir la imagen de perfil.');
        }
      } catch (e) {
        print('Error al subir la imagen de perfil: $e');
      }
    }

    return null;
  }

// Función para obtener la lista de usuarios registrados
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final usersList = usersSnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
      return usersList;
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return []; // Devuelve una lista vacía en caso de error
    }
  }

//actualizar usuario
  Future<void> updateUser(UserModel user) async {
    try {
      // Actualizar los datos del usuario en Firestore utilizando su UID
      await _firestore.collection('users').doc(user.uid).update(user.toMap());

      print('Usuario actualizado con éxito.');
    } catch (e) {
      print('Error al actualizar el usuario: $e');
    }
  }

//eliminar usuario
  Future<void> deleteUser(String uid) async {
    try {
      // Eliminar al usuario de Firestore utilizando su UID
      await _firestore.collection('users').doc(uid).delete();

      print('Usuario eliminado con éxito.');
    } catch (e) {
      print('Error al eliminar el usuario: $e');
    }
  }

// Método para agregar una nueva ruta
  Future<void> addRoute(RouteModel route) async {
    try {
      final routeData = route.toMap();
      final docRef = await _firestore.collection('routes').add(routeData);
      print('Ruta agregada con ID: ${docRef.id}');
    } catch (e) {
      print('Error al agregar la ruta: $e');
    }
  }

// Método para obtener todas las rutas
  Future<List<RouteModel>> getRoutes() async {
    try {
      final routesSnapshot = await _firestore.collection('routes').get();
      final routesList = routesSnapshot.docs.map((doc) {
        final routeData = doc.data() as Map<String, dynamic>;
        return RouteModel.fromMap(routeData, doc.id);
      }).toList();
      print('Rutas obtenidas con éxito: $routesList');
      return routesList;
    } catch (e) {
      print('Error al obtener las rutas: $e');
      return [];
    }
  }

  // Método para actualizar una ruta existente
  Future<void> updateRoute(RouteModel route) async {
    try {
      final routeData = route.toMap();
      await _firestore.collection('routes').doc(route.id).update(routeData);
      print('Ruta actualizada con ID: ${route.id}');
    } catch (e) {
      print('Error al actualizar la ruta: $e');
    }
  }

  // Método para eliminar una ruta
  Future<void> deleteRoute(String routeId) async {
    try {
      await _firestore.collection('routes').doc(routeId).delete();
      print('Ruta eliminada con ID: $routeId');
    } catch (e) {
      print('Error al eliminar la ruta: $e');
    }
  }

//obtener una ruta
  Future<RouteModel> getRouteDetails(String routeId) async {
    try {
      final routeDoc = await _firestore.collection('routes').doc(routeId).get();
      if (routeDoc.exists) {
        final routeData = routeDoc.data() as Map<String, dynamic>;
        return RouteModel.fromMap(routeData, routeId); // Pasa ambos argumentos
      } else {
        throw Exception('La ruta con el ID $routeId no existe.');
      }
    } catch (e) {
      print('Error al obtener los detalles de la ruta: $e');
      rethrow;
    }
  }

  // Subir imagen de ruta.
  Future<String?> uploadRouteImage(File imageFile) async {
    try {
      final Reference ref = _storage
          .ref()
          .child('route_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        print('Error al subir la imagen de la ruta.');
      }
    } catch (e) {
      print('Error al subir la imagen de la ruta: $e');
    }

    return null;
  }
}
