import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel user;
  SettingsScreen({required this.user});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserController _userController = UserController();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneNumberController =
        TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Transprogreso Choco LTDA',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF123456),
        elevation: 0, // Remove elevation
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre Completo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'Ingrese su nombre completo',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Número de Teléfono:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: 'Ingrese su número de teléfono',
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                await _userController.updateUserData(
                  fullName: _fullNameController.text,
                  email: widget.user.email ?? '',
                  phoneNumber: _phoneNumberController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Configuración actualizada con éxito.'),
                  ),
                );
              },
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Registro de Compra',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Color(0xFF123456),
        showUnselectedLabels: true,
        onTap: (index) async {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/purchase_history');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings',
                  arguments: widget.user);
              break;
            case 4:
              await _userController.signOut(context);
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
        },
      ),
    );
  }
}
