import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/views/Admin/Users/AddUserView.dart';
import 'package:app_transprogresochoco/views/Admin/Includes/header.dart'; // Importa el archivo de encabezado
import 'package:app_transprogresochoco/views/Admin/Includes/sidebar.dart'; // Importa el archivo del menú lateral
import 'package:app_transprogresochoco/views/Admin/Includes/footer.dart'; // Importa el archivo del pie de página

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminController _adminController = AdminController();
  late Future<List<Map<String, dynamic>>> _userListFuture;

  @override
  void initState() {
    super.initState();
    _loadUserList();
  }

  Future<void> _loadUserList() async {
    try {
      final userList = await _adminController.getUsers();
      setState(() {
        _userListFuture = Future.value(userList);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar la lista de usuarios: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(), // Usar el encabezado
      drawer: Sidebar(), // Usar el menú lateral (sidebar)
      body: Column(
        children: [
          // Contenido principal
          // ...
        ],
      ),
    );
  }
}
