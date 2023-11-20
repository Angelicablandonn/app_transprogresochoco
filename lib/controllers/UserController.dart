import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/UserModel.dart';
import '../../models/RouteModel.dart';
import '../../models/TicketSale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AdminController.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;
  UserModel? get user => _user;
  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      // Intenta cargar los datos del usuario desde Firestore
      try {
        UserModel? user = await getUserData(firebaseUser.uid);
        return user;
      } catch (e) {
        print("Error al cargar datos de usuario: $e");
        return null;
      }
    } else {
      return null;
    }
  }

  // Método para cargar los datos del usuario actual
  Future<void> loadUserData(String userId) async {
    try {
      _user = await getUserData(userId);
    } catch (e) {
      print("Error al cargar datos de usuario: $e");
    }
  }

  // Método para mostrar un cuadro de diálogo de error
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

  // Método para iniciar sesión de usuario
  Future<bool> loginUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final bool isAdmin = await isUserAdmin(firebaseUser.uid);
        isAdmin
            ? Navigator.pushReplacementNamed(context, '/dashboard')
            : Navigator.pushReplacementNamed(context, '/home');
        return true;
      } else {
        _showErrorDialog(
          context,
          'Error al iniciar sesión. Por favor, inténtalo de nuevo.',
        );
        return false;
      }
    } catch (e) {
      print("Error al iniciar sesión: $e");
      _showErrorDialog(
        context,
        'Error al iniciar sesión. Por favor, inténtalo de nuevo.',
      );
      return false;
    }
  }

// Método para actualizar los datos del usuario
  Future<void> updateUserData({
    required String fullName,
    required String email,
    required String phoneNumber,
    String? profilePicture,
    String? newPassword,
  }) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'profilePicture': profilePicture,
        });

        if (newPassword != null) {
          await _updateUserPassword(newPassword, currentUser.email!);
        }
      } else {
        print("El usuario actual es nulo.");
      }
    } catch (e) {
      print("Error al actualizar los datos del usuario: $e");
      throw e;
    }
  }

  Future<void> _updateUserPassword(String newPassword, String email) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        AuthCredential credentials = EmailAuthProvider.credential(
          email: email,
          password: user?.password ?? '',
        );

        await currentUser.reauthenticateWithCredential(credentials);
        await currentUser.updatePassword(newPassword);
      } else {
        print("El usuario actual es nulo.");
      }
    } catch (e) {
      print("Error al actualizar la contraseña del usuario: $e");
      throw e;
    }
  }

  // Método para registrar un nuevo usuario
  Future<UserModel?> registerUser(
    BuildContext context,
    String email,
    String password,
    String fullName,
    String phoneNumber,
  ) async {
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
          isAdmin: false,
          password: password,
        );

        await _firestore.collection('users').doc(user.uid).set(user.toMap());

        Navigator.pushReplacementNamed(context, '/dashboard');

        return user;
      } else {
        _showErrorDialog(
          context,
          'Error al registrar usuario. Por favor, inténtalo de nuevo.',
        );
        return null;
      }
    } catch (e) {
      print("Error al registrar usuario: $e");
      _showErrorDialog(
        context,
        'Error al registrar usuario. Por favor, inténtalo de nuevo.',
      );
      return null;
    }
  }

  // Método para obtener datos de usuario
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

  // Método para obtener la lista de rutas disponibles
  Future<List<RouteModel>> getRoutes() async {
    try {
      final routesSnapshot = await _firestore.collection('routes').get();
      final routesList = routesSnapshot.docs.map((doc) {
        final routeData = doc.data() as Map<String, dynamic>;
        return RouteModel.fromMap(routeData, doc.id);
      }).toList();
      return routesList;
    } catch (e) {
      print('Error al obtener las rutas: $e');
      return [];
    }
  }

  // Método para buscar rutas por destino
  Future<List<RouteModel>> searchRoutes(String query) async {
    try {
      final routesSnapshot = await _firestore
          .collection('routes')
          .where('destination', isEqualTo: query)
          .get();

      final routesList = routesSnapshot.docs.map((doc) {
        final routeData = doc.data() as Map<String, dynamic>;
        return RouteModel.fromMap(routeData, doc.id);
      }).toList();

      return routesList;
    } catch (e) {
      print('Error al buscar rutas: $e');
      return [];
    }
  }

  // Método para verificar si el usuario es administrador
  Future<bool> isUserAdmin(String userId) async {
    try {
      final UserModel? userData = await getUserData(userId);
      return userData != null && userData.isAdmin;
    } catch (e) {
      print("Error al verificar si el usuario es administrador: $e");
      return false;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error al cerrar sesión: $e");
      _showErrorDialog(
        context,
        'Error al cerrar sesión. Por favor, inténtalo de nuevo.',
      );
    }
  }

// Método para almacenar una venta en el historial de compras del usuario
  Future<void> storePurchaseHistory(TicketSale ticketSale) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ticketSale.userId) // Usamos el campo userId para la referencia
          .collection('purchaseHistory')
          .add(ticketSale.toMap());
    } catch (error) {
      print('Error al almacenar la venta: $error');
      throw error;
    }
  }

  Future<void> selectRouteAndBuyTickets(
    BuildContext context,
    UserModel user,
    RouteModel selectedRoute,
    int quantity,
  ) async {
    try {
      final List<RouteModel> routes = await getRoutes();

      final selectedRoute = await showDialog<RouteModel>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Selecciona una ruta'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return ListTile(
                    title: Text(route.name),
                    subtitle: Text(
                      'Hora de Salida: ${route.departureTime}',
                    ),
                    onTap: () {
                      Navigator.pop(context, route);
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedRoute != null) {
        final ticketSale = TicketSale(
          id: '',
          customerName: user.fullName,
          customerEmail: user.email,
          amount: selectedRoute.ticketPrice * quantity,
          quantity: quantity,
          paymentMethod: 'Efectivo',
          saleDate: Timestamp.now(),
          routeId: selectedRoute.id,
          ticketPrice: selectedRoute.ticketPrice,
          userId: user.uid, // Asignamos el ID del usuario como userId
        );

        final adminController = AdminController();
        await adminController.addTicketSale(
          ticketSale,
          selectedRoute,
          quantity,
        );

        await storePurchaseHistory(ticketSale);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compra de boletos registrada con éxito.'),
          ),
        );
      }
    } catch (e) {
      print('Error al seleccionar la ruta y comprar boletos: $e');
      // Muestra un mensaje de error si es necesario
    }
  }

  // Método para recuperar el historial de compras del usuario
  Future<List<TicketSale>> getPurchaseHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth
              .currentUser?.uid) // Asegúrate de tener el ID del usuario actual
          .collection('purchaseHistory')
          .get();

      return querySnapshot.docs
          .map((doc) => TicketSale.fromSnapshot(doc))
          .toList();
    } catch (error) {
      print('Error al obtener el historial de compras: $error');
      throw error;
    }
  }
}
