import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/views/Admin/Includes/header.dart';
import 'package:app_transprogresochoco/views/Admin/Includes/sidebar.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';
import 'package:fl_chart/fl_chart.dart';

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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'Acciones',
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDashboardItem(
                      icon: Icons.person_add,
                      label: 'Agregar Usuario',
                      value: '$_totalUsers',
                      onTap: () {
                        // Lógica para agregar usuario
                      },
                    ),
                    _buildDashboardItem(
                      icon: Icons.add_location,
                      label: 'Agregar Ruta',
                      value: '$_totalRoutes',
                      onTap: () {
                        // Lógica para agregar ruta
                      },
                    ),
                    _buildDashboardItem(
                      icon: Icons.add_shopping_cart,
                      label: 'Agregar Venta',
                      value: '$_totalTicketSales',
                      onTap: () {
                        // Lógica para agregar venta
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSection(
              title: 'Estadísticas',
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBarChart(
                      title: 'Total Usuarios',
                      value: _totalUsers,
                      color: Colors.blue,
                    ),
                    _buildBarChart(
                      title: 'Total Rutas',
                      value: _totalRoutes,
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSection(
              title: 'Ventas',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 20,
                            title: '20%',
                            color: Colors.blue,
                          ),
                          PieChartSectionData(
                            value: 30,
                            title: '30%',
                            color: Colors.green,
                          ),
                          PieChartSectionData(
                            value: 50,
                            title: '50%',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900], // Color de fondo del BottomAppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // Lógica para manejar la selección de usuarios
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.location_on),
              onPressed: () {
                // Lógica para manejar la selección de rutas
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                // Lógica para manejar la selección de ventas
              },
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.indigo, // Color principal para los títulos
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildDashboardItem(
      {required IconData icon,
      required String label,
      required String value,
      required VoidCallback onTap}) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 36, color: Colors.indigo),
          onPressed: onTap,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(fontSize: 18, color: Colors.indigo),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
      ],
    );
  }

  Widget _buildBarChart(
      {required String title, required int value, required Color color}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 150,
          height: 200,
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (context, value) => const TextStyle(
                    color: Colors.indigo,
                  ),
                  margin: 10,
                ),
                topTitles: SideTitles(showTitles: false),
                rightTitles: SideTitles(showTitles: false),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (context, value) => const TextStyle(
                    color: Colors.indigo,
                  ),
                  margin: 10,
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      y: value.toDouble(),
                      colors: [color],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
