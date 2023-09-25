import 'package:flutter/material.dart';

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

          // Opción "Ventas de Tiquetes"
          ExpansionTile(
            title: Text('Ventas de Tiquetes'),
            children: [
              ListTile(
                title: Text('Agregar Venta de Tiquete'),
                onTap: () {
                  Navigator.of(context).pushNamed('/add_ticket_sale');
                },
              ),
              ListTile(
                title: Text('Listar Ventas de Tiquetes'),
                onTap: () {
                  Navigator.of(context).pushNamed('/list_ticket_sales');
                },
              ),
              // Puedes agregar más elementos de menú relacionados con ventas de tiquetes si es necesario
            ],
          ),

          // Agrega más categorías o elementos de menú según tus necesidades
        ],
      ),
    );
  }
}
