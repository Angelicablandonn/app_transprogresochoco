import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/views/Admin/Users/AddUserView.dart';
import 'package:app_transprogresochoco/views/Admin/Users/ListUsersView.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              'Menú',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          // Opción "Usuarios"
          ExpansionTile(
            title: Text('Usuarios'),
            children: [
              ListTile(
                title: Text('Agregar Usuario'),
                onTap: () {
                  Navigator.of(context).pushNamed('/add_user');
                },
              ),
              ListTile(
                title: Text('Listar Usuarios'),
                onTap: () {
                  Navigator.of(context).pushNamed('/list_users');
                },
              ),
              // Agrega más elementos de menú relacionados con usuarios si es necesario
            ],
          ),

          // Opción "Rutas"
          ExpansionTile(
            title: Text('Rutas'),
            children: [
              ListTile(
                title: Text('Agregar Ruta'),
                onTap: () {
                  Navigator.of(context).pushNamed('/add_route');
                },
              ),
              ListTile(
                title: Text('Listar Rutas'),
                onTap: () {
                  Navigator.of(context).pushNamed('/list_routes');
                },
              ),
              // Agrega más elementos de menú relacionados con rutas si es necesario
            ],
          ),

          // Agrega más categorías o elementos de menú según tus necesidades
        ],
      ),
    );
  }
}
