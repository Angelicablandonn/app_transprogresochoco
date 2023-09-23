import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddUserView extends StatefulWidget {
  @override
  _AddUserViewState createState() => _AddUserViewState();
}

class _AddUserViewState extends State<AddUserView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AdminController _adminController = AdminController();

  File?
      _profilePicture; // Variable para almacenar la foto de perfil seleccionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Nombre Completo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un correo electrónico';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Número de Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un número de teléfono';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed:
                    _selectProfilePicture, // Agregar la llamada a _selectProfilePicture
                child: Text('Seleccionar Foto de Perfil'),
              ),
              if (_profilePicture !=
                  null) // Mostrar la imagen seleccionada si existe
                Image.file(_profilePicture!),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una contraseña';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final String newUid =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    final newUser = UserModel(
                      uid: newUid,
                      fullName: _fullNameController.text,
                      email: _emailController.text,
                      phoneNumber: _phoneNumberController.text,
                      profilePicture: '', // No se usa aquí
                      password: _passwordController.text,
                    );
                    _showPasswordDialog(newUser);
                  }
                },
                child: Text('Agregar Usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para seleccionar la foto de perfil
  void _selectProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  void _showPasswordDialog(UserModel newUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Establecer Contraseña'),
          content: TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa una contraseña';
              }
              return null;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                final String password = _passwordController.text;
                newUser.profilePicture = ''; // No se usa aquí
                _adminController.addUserWithPassword(
                    newUser, password, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
