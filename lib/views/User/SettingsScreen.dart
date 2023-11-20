import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';

class SettingsScreen extends StatefulWidget {
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
    // Inicializa los controladores de texto con los datos del usuario actual
    _fullNameController =
        TextEditingController(text: _userController.user?.fullName ?? '');
    _phoneNumberController =
        TextEditingController(text: _userController.user?.phoneNumber ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context); // Esta línea te lleva de vuelta a la pantalla anterior
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
                // Guarda los cambios en la información del usuario
                await _userController.updateUserData(
                  fullName: _fullNameController.text,
                  email: _userController.user?.email ??
                      '', // Asegúrate de obtener el correo electrónico del usuario
                  phoneNumber: _phoneNumberController.text,
                );
                // Muestra un mensaje de éxito
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
    );
  }
}
