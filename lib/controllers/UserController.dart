import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import '../../models/RouteModel.dart';
import '../../models/TicketSale.dart';
import '../../models/UserModel.dart';
import 'AdminController.dart';
import 'package:path_provider/path_provider.dart';

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  Future<void> downloadInvoice(TicketSale ticketSale, RouteModel route) async {
    print('Estado de aprobación: ${ticketSale.approvalStatus}');

    if (ticketSale.approvalStatus != 'Aprobado') {
      print('La factura no está aprobada. No se puede descargar.');
      return;
    }

    try {
      final pdfLib.Document pdf = pdfLib.Document();

      pdf.addPage(
        pdfLib.Page(
          build: (pdfLib.Context context) {
            return pdfLib.Column(
              children: [
                pdfLib.Header(
                  level: 0,
                  child: pdfLib.Text('Factura de Compra'),
                ),
                pdfLib.Text('ID de Venta: ${ticketSale.id}'),
                pdfLib.Text('Nombre del Cliente: ${ticketSale.customerName}'),
                pdfLib.Text('Correo Electrónico: ${ticketSale.customerEmail}'),
                pdfLib.Text('Monto Total: \$${ticketSale.amount.toString()}'),
                pdfLib.Text('Cantidad de Boletos: ${ticketSale.quantity}'),
                pdfLib.Text('Método de Pago: ${ticketSale.paymentMethod}'),
                pdfLib.Text('Fecha de Venta: ${ticketSale.saleDate.toDate()}'),
                pdfLib.Text('Ruta: ${route.name}'),
              ],
            );
          },
        ),
      );

      final List<int> pdfBytes = await pdf.save();

      // Obtener el directorio de documentos
      final Directory docDir = await getApplicationDocumentsDirectory();

      // Crear el archivo en el directorio de documentos
      final String pdfFileName = '${docDir.path}/invoice_${ticketSale.id}.pdf';
      final File pdfFile = File(pdfFileName);
      await pdfFile.writeAsBytes(pdfBytes);

      print('Factura descargada con éxito: $pdfFileName');
    } catch (error) {
      print('Error al descargar la factura: $error');
      throw error;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
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

  Future<void> loadUserData(String userId) async {
    try {
      _user = await getUserData(userId);
    } catch (e) {
      print("Error al cargar datos de usuario: $e");
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

  Future<bool> isUserAdmin(String userId) async {
    try {
      final UserModel? userData = await getUserData(userId);
      return userData != null && userData.isAdmin;
    } catch (e) {
      print("Error al verificar si el usuario es administrador: $e");
      return false;
    }
  }

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

  Future<void> storePurchaseHistory(TicketSale ticketSale) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ticketSale.userId)
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
          userId: user.uid,
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
    }
  }

  Future<List<TicketSale>> getPurchaseHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('purchaseHistory')
          .get();

      List<TicketSale> purchaseHistory = querySnapshot.docs.map((doc) {
        TicketSale ticketSale = TicketSale.fromSnapshot(doc);
        print(
            'Estado de aprobación para la venta ${ticketSale.id}: ${ticketSale.approvalStatus}');
        return ticketSale;
      }).toList();

      return purchaseHistory;
    } catch (error) {
      print('Error al obtener el historial de compras: $error');
      throw error;
    }
  }

  Future<RouteModel?> getRouteById(String routeId) async {
    try {
      final DocumentSnapshot routeDoc =
          await _firestore.collection('routes').doc(routeId).get();

      if (routeDoc.exists) {
        return RouteModel.fromMap(
            routeDoc.data() as Map<String, dynamic>, routeId);
      } else {
        return null;
      }
    } catch (e) {
      print("Error al obtener datos de la ruta: $e");
      return null;
    }
  }
}
