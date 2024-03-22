import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';

class Sidebar extends StatelessWidget {
  final UserController _userController = UserController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<UserModel?>(
        future: _userController.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al obtener el usuario'),
            );
          } else {
            final UserModel? user = snapshot.data;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user?.fullName ?? 'Usuario'),
                  accountEmail: Text(user?.email ?? 'Correo electrónico'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.fullName.substring(0, 1).toUpperCase() ?? '',
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF123456),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('Registro de Compras'),
                  onTap: () {
                    // Navegar a la pantalla de registro de compras
                    Navigator.pushReplacementNamed(
                        context, '/purchase_history');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Perfil'),
                  onTap: () {
                    // Navegar a la pantalla de perfil
                    Navigator.pushReplacementNamed(context, '/profile');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configuración'),
                  onTap: () {
                    // Navegar a la pantalla de configuración
                    Navigator.pushReplacementNamed(context, '/settings');
                  },
                ),
                // Otros elementos del menú según sea necesario
              ],
            );
          }
        },
      ),
    );
  }
}
