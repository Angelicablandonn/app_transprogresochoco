import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_transprogresochoco/views/User/LoginScreen.dart';
import 'package:app_transprogresochoco/views/Admin/DashboardScreen.dart';
import 'package:app_transprogresochoco/views/Admin/Users/ListUsersView.dart';
import 'package:app_transprogresochoco/views/Admin/Users/AddUserView.dart';
import 'package:app_transprogresochoco/views/Admin/Users/EditUserScreen.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'views/Admin/Routes/EditRouteScreen.dart';
import 'views/Admin/Routes/AddRouteScreen.dart';
import 'views/Admin/Routes/ListRoutesScreen.dart';

// Importa las vistas de ventas de tiquetes y sus respectivos editores y eliminadores aquí
import 'package:app_transprogresochoco/views/Admin/Tickets/AddTicketSale.dart';
import 'package:app_transprogresochoco/views/Admin/Tickets/EditTicketSaleScreen.dart';
import 'package:app_transprogresochoco/views/Admin/Tickets/TicketSalesListScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transporte progreso del Choco LTDA.',
      theme: ThemeData(
        primaryColor: Color(0xFF3F51B5), // Color primario
        fontFamily: 'Roboto', // Fuente de texto predeterminada
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF3F51B5), // Color de fondo del AppBar
        ),
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontSize: 16),
          button: TextStyle(fontSize: 18, color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFFFC107), // Color de fondo de botones
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      initialRoute: '/login', // Ruta inicial
      routes: {
        '/login': (context) => LoginScreen(), // Pantalla de inicio de sesión
        '/dashboard': (context) => AdminDashboard(),
        //users
        '/list_users': (context) => ListUsersView(), // lista de usuarios
        '/add_user': (context) => AddUserView(),
        '/edit_user': (context) {
          // Obtener los argumentos de la ruta
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final uid = arguments['uid'] as String;
          final user = arguments['user'] as UserModel;
          return EditUserScreen(uid: uid, user: user);
        },

        //rutas
        '/add_route': (context) => AddRouteScreen(),
        '/edit_route': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final routeId = arguments['routeId'] as String;
          return EditRouteScreen(routeId: routeId);
        },
        '/list_routes': (context) => ListRoutesScreen(),

        // Rutas relacionadas con las ventas de tiquetes
        '/add_ticket_sale': (context) => AddTicketSaleView(),
        '/list_ticket_sales': (context) => TicketSalesListScreen(),
      },
    );
  }
}
