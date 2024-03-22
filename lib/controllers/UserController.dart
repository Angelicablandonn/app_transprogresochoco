import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import '../../models/RouteModel.dart';
import '../../models/TicketSale.dart';
import '../../models/UserModel.dart';
import 'AdminController.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  Future<void> downloadInvoice(
    BuildContext context,
    TicketSale ticketSale,
    RouteModel route,
  ) async {
    // Verificar si el usuario está autenticado
    if (_auth.currentUser == null) {
      print('Usuario no autenticado. Inicia sesión para descargar la factura.');
      // Puedes redirigir al usuario a la pantalla de inicio de sesión si es necesario
      return;
    }

    // Verificar y solicitar permisos de almacenamiento
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Permiso de almacenamiento denegado.');
        return;
      }
    }

    try {
      // Crear el documento PDF y configurar su contenido
      final pdfLib.Document pdf = pdfLib.Document();
      final pdfLib.Font font =
          pdfLib.Font.ttf(await rootBundle.load("fonts/arial.ttf"));

      pdf.addPage(
        pdfLib.Page(
          build: (pdfLib.Context context) {
            return pdfLib.Column(
              crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
              children: [
                // Contenido del PDF
              ],
            );
          },
        ),
      );

      // Obtener el directorio de la aplicación
      final String dir = (await getApplicationDocumentsDirectory()).path;

      // Generar el archivo PDF
      final String pdfPath = '$dir/invoice_${ticketSale.id}.pdf';
      final List<int> pdfBytes = await pdf.save();
      final File file = File(pdfPath);
      await file.writeAsBytes(pdfBytes);

      // Subir el archivo a Firebase Storage
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('invoices/${ticketSale.id}.pdf');
      final UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask
          .whenComplete(() => print('Archivo subido a Firebase Storage'));

      // Almacenar la referencia del archivo en Firestore
      final String downloadURL = await storageReference.getDownloadURL();
      await storeInvoiceReference(ticketSale, downloadURL);

      // Informar al usuario que la factura se generó y almacenó con éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Factura generada y almacenada con éxito.'),
        ),
      );

      print('Factura generada y almacenada en: $pdfPath');
    } catch (error) {
      print('Error al descargar y almacenar la factura: $error');
      throw error;
    }
  }

  Future<void> storeInvoiceReference(
      TicketSale ticketSale, String downloadURL) async {
    try {
      await FirebaseFirestore.instance
          .collection('invoice_references')
          .doc(ticketSale.id)
          .set({'downloadURL': downloadURL});
    } catch (error) {
      print('Error al almacenar la referencia de la factura: $error');
      throw error;
    }
  }

  Future<String?> getInvoiceDownloadURL(String ticketSaleId) async {
    try {
      final DocumentSnapshot referenceDoc = await FirebaseFirestore.instance
          .collection('invoice_references')
          .doc(ticketSaleId)
          .get();

      if (referenceDoc.exists) {
        final data = referenceDoc.data() as Map<String, dynamic>;
        return data['downloadURL'];
      } else {
        return null;
      }
    } catch (error) {
      print('Error al obtener la referencia de descarga de la factura: $error');
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
        final userData = userDoc.data() as Map<String, dynamic>;
        return UserModel.fromMap(userData);
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

  Future<List<RouteModel>> searchRoutes(
      String origin, String destination, DateTime date) async {
    try {
      final routesSnapshot = await _firestore
          .collection('routes')
          .where('origin', isEqualTo: origin)
          .where('destination', isEqualTo: destination)
          .where('departureTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(date))
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

  Future<String> storePurchaseHistory(TicketSale ticketSale) async {
    try {
      // Almacenar la venta en Firestore
      final DocumentReference ticketSaleRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(ticketSale.userId)
          .collection('purchaseHistory')
          .add(ticketSale.toMap());

      // Devolver el ID de la venta almacenada
      return ticketSaleRef.id;
    } catch (error) {
      print('Error al almacenar la venta: $error');
      throw error;
    }
  }

  Future<void> selectRouteAndBuyTickets(
    BuildContext context,
    UserModel user,
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
        // Declarar la variable purchaseHistoryId antes de su primer uso
        String purchaseHistoryId = '';

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
          downloadURL: '', // No necesitamos la URL al momento de la creación
          purchaseHistoryId:
              purchaseHistoryId, // Agrega el campo purchaseHistoryId
        );

        // Almacenar la venta en Firestore
        purchaseHistoryId = await storePurchaseHistory(ticketSale);

        // Restablecer el campo purchaseHistoryId en el objeto TicketSale
        ticketSale.purchaseHistoryId = purchaseHistoryId;

        // Almacenar la compra en el historial del usuario
        await storePurchaseHistory(ticketSale);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compra de boletos registrada con éxito.'),
          ),
        );

        // Solicitar permisos de almacenamiento
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            print('Permiso de almacenamiento denegado.');
            return;
          }
        }

        // Generar y descargar la factura
        await downloadInvoice(context, ticketSale, selectedRoute);
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

      return querySnapshot.docs
          .map((doc) => TicketSale.fromSnapshot(doc))
          .toList();
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
