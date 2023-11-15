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
        final bool isAdmin = await isUserAdmin(firebaseUser.uid);
        if (isAdmin) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
        return true;
      } else {
        _showErrorDialog(
            context, 'Error al iniciar sesión. Por favor, inténtalo de nuevo.');
        return false;
      }
    } catch (e) {
      print("Error al iniciar sesión: $e");
      _showErrorDialog(
          context, 'Error al iniciar sesión. Por favor, inténtalo de nuevo.');
      return false;
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
          isAdmin: false, // Por defecto, no es un administrador
          password: password,
        );

        await _firestore.collection('users').doc(user.uid).set(user.toMap());

        Navigator.pushReplacementNamed(context, '/dashboard');

        return user;
      } else {
        _showErrorDialog(context,
            'Error al registrar usuario. Por favor, inténtalo de nuevo.');
        return null;
      }
    } catch (e) {
      print("Error al registrar usuario: $e");
      _showErrorDialog(context,
          'Error al registrar usuario. Por favor, inténtalo de nuevo.');
      return null;
    }
  }

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
          context, 'Error al cerrar sesión. Por favor, inténtalo de nuevo.');
    }
  }

  Future<void> selectRouteAndBuyTickets(
      BuildContext context, UserModel user, RouteModel selectedRoute) async {
    try {
      // Obtén la lista de rutas disponibles
      final List<RouteModel> routes = await getRoutes();

      // Muestra un diálogo de selección de ruta
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
        // La ruta ha sido seleccionada, ahora puedes registrar la compra de boletos
        // Puedes mostrar un formulario o un diálogo para ingresar la cantidad de boletos, por ejemplo.
        final quantity = await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text('Ingrese la cantidad de boletos'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 1);
                  },
                  child: Text('1 boleto'),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 2);
                  },
                  child: Text('2 boletos'),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 3);
                  },
                  child: Text('3 boletos'),
                ),
                // Puedes agregar más opciones según tus necesidades
              ],
            );
          },
        );

        if (quantity != null) {
          // Ahora puedes registrar la compra de boletos
          final ticketSale = TicketSale(
            id: '', // El ID se generará automáticamente en Firestore
            customerName: user.fullName,
            customerEmail: user.email,
            amount: selectedRoute.ticketPrice * quantity,
            quantity: quantity,
            paymentMethod: 'Efectivo', // Puedes cambiar esto según tu lógica
            saleDate: Timestamp.now(),
            routeId: selectedRoute.id,
            ticketPrice: selectedRoute.ticketPrice,
          );

          // Llama al método para agregar la venta de boletos
          final adminController = AdminController();
          await adminController.addTicketSale(
              ticketSale, selectedRoute, quantity);

          // Muestra un mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Compra de boletos registrada con éxito.'),
            ),
          );
        }
      }
    } catch (e) {
      print('Error al seleccionar la ruta y comprar boletos: $e');
      // Muestra un mensaje de error si es necesario
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
