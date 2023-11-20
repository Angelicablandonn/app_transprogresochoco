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
            // Manejar el error según tus necesidades
            return Center(
              child: Text('Error al obtener el usuario'),
            );
          } else {
            final UserModel? user = snapshot.data;

            return ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(0, 0, 94, 255),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tu contenido del DrawerHeader
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Inicio'),
                  onTap: () {
                    // Navegar a la pantalla de inicio con el argumento 'user'
                    Navigator.pushNamed(
                      context,
                      '/home',
                      arguments: {'user': user},
                    );
                  },
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
