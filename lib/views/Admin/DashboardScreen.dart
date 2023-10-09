import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/views/Admin/Includes/header.dart';
import 'package:app_transprogresochoco/views/Admin/Includes/sidebar.dart';
import 'package:app_transprogresochoco/views/Admin/Includes/footer.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminController _adminController = AdminController();

  int _totalUsers = 0;
  int _totalRoutes = 0;
  int _totalTicketSales = 0;

  @override
  void initState() {
    super.initState();
    _getDashboardData();
  }

  Future<void> _getDashboardData() async {
    final List<Map<String, dynamic>> users = await _adminController.getUsers();
    final List<RouteModel> routes = await _adminController.getRoutes();
    final List<TicketSale> ticketSales =
        await _adminController.getTicketSales();

    setState(() {
      _totalUsers = users.length;
      _totalRoutes = routes.length;
      _totalTicketSales = ticketSales.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      drawer: Sidebar(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Panel de administrador',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.person_add),
                          onPressed: () {
                            // Lógica para agregar un usuario
                          },
                        ),
                        SizedBox(height: 10),
                        Text('Agregar Usuario', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        IconButton(
                          icon: Icon(Icons.list),
                          onPressed: () {
                            // Lógica para listar usuarios
                          },
                        ),
                        SizedBox(height: 10),
                        Text('Listar Usuarios', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        Text('$_totalUsers', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_location),
                          onPressed: () {
                            // Lógica para agregar una ruta
                          },
                        ),
                        SizedBox(height: 10),
                        Text('Agregar Ruta', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        IconButton(
                          icon: Icon(Icons.list),
                          onPressed: () {
                            // Lógica para listar rutas
                          },
                        ),
                        SizedBox(height: 10),
                        Text('Listar Rutas', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        Text('$_totalRoutes', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            // Lógica para agregar una venta de tiquete
                          },
                        ),
                        SizedBox(height: 10),
                        Text('Agregar Venta', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        IconButton(
                          icon: Icon(Icons.list),
                          onPressed: () {
                            // Lógica para listar ventas de tiquetes
                          },
                        ),
                        SizedBox(height: 10),
                        Text('Listar Ventas', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        Text('$_totalTicketSales',
                            style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: Footer(),
            ),
          ),
        ],
      ),
    );
  }
}
