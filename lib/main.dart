import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_transprogresochoco/views/Admin/Tickets/AddTicketSale.dart';
import 'package:app_transprogresochoco/views/User/ProfileScreen.dart';
import 'package:app_transprogresochoco/views/Admin/Tickets/EditTicketSaleScreen.dart';
import 'package:app_transprogresochoco/views/User/PurchaseHistoryScreen.dart';
import 'package:app_transprogresochoco/views/Admin/Tickets/TicketSalesListScreen.dart';
import 'package:app_transprogresochoco/views/User/SettingsScreen.dart';
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
import 'views/User/HomeScreen.dart';

void main() async {
  initializeDateFormatting('es_ES', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transporte progreso del Choco LTDA.',
      theme: ThemeData(
        primaryColor: Colors.black,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontSize: 16),
          button: TextStyle(fontSize: 18, color: Colors.white),
          bodyText1: TextStyle(fontSize: 18, color: Colors.black),
        ).apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFFFC107),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final arguments = settings.arguments as Map<String, dynamic>;
          final user = arguments['user'] as UserModel;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(user: user),
          );
        }
        // Agrega lógica similar para otras rutas si es necesario
      },
      initialRoute: '/login',
      routes: {
        '/home': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final user = arguments['user'] as UserModel;
          return HomeScreen(user: user);
        },
        '/purchase_history': (context) => PurchaseHistoryScreen(),
        '/profile': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;

          if (arguments != null && arguments.containsKey('user')) {
            final user = arguments['user'] as UserModel;
            return ProfileScreen(user: user);
          } else {
            // Manejar el caso en el que los argumentos no sean válidos
            return Scaffold(
              body: Center(
                child: Text(
                    'Error: Argumentos no válidos para la pantalla de perfil.'),
              ),
            );
          }
        },
        '/settings': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final user = arguments['user'] as UserModel;
          return SettingsScreen(user: user);
        },
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => AdminDashboard(),
        '/list_users': (context) => ListUsersView(),
        '/add_user': (context) => AddUserView(),
        '/edit_user': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final uid = arguments['uid'] as String;
          final user = arguments['user'] as UserModel;
          return EditUserScreen(uid: uid, user: user);
        },
        '/add_route': (context) => AddRouteScreen(),
        '/edit_route': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final routeId = arguments['routeId'] as String;
          return EditRouteScreen(routeId: routeId);
        },
        '/list_routes': (context) => ListRoutesScreen(),
        '/add_ticket_sale': (context) => AddTicketSaleView(),
        '/list_ticket_sales': (context) => TicketSalesListScreen(),
      },
    );
  }
}

Future<void> _checkAndRequestStoragePermission() async {
  if (io.Platform.isAndroid || io.Platform.isIOS) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else if (status.isPermanentlyDenied) {}
  }
}
