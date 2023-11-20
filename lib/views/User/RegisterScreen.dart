import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final UserController _userController = UserController();
  String? _errorMessage; // Variable para almacenar el mensaje de error
  String?
      _profilePicture; // Variable para almacenar la ruta de la foto de perfil

  Future<void> _register() async {
    final String fullName = _fullNameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String phoneNumber = _phoneNumberController.text;

    // Verifica si _profilePicture tiene una ruta válida.
    if (_profilePicture != null) {
      showLoadingIndicator();

      final UserModel? registeredUser = await _userController.registerUser(
        context,
        email,
        password,
        fullName,
        phoneNumber,
      );

      hideLoadingIndicator();

      if (registeredUser != null) {
        // Registro exitoso, muestra un SnackBar y navega a la pantalla de inicio.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario registrado exitosamente.'),
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Registro fallido, muestra un mensaje de error.
        setState(() {
          _errorMessage =
              'Error al registrar usuario. Por favor, inténtalo de nuevo.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Debes seleccionar una foto de perfil.';
      });
    }
  }

  // Función para seleccionar una imagen de la galería.
  Future<void> _pickProfilePicture() async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource
          .gallery, // Puedes cambiarlo a ImageSource.camera si quieres tomar una foto.
    );

    if (pickedFile != null) {
      setState(() {
        _profilePicture = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Transprogreso Choco',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150.0,
                  height: 150.0,
                ),
                const SizedBox(height: 32.0),
                _buildTextField(
                    _fullNameController, 'Nombre Completo', Icons.person),
                const SizedBox(height: 16.0),
                _buildTextField(
                    _emailController, 'Correo Electrónico', Icons.email),
                const SizedBox(height: 16.0),
                _buildPasswordField(
                    _passwordController, 'Contraseña', Icons.lock),
                const SizedBox(height: 16.0),
                _buildTextField(
                    _phoneNumberController, 'Número de Teléfono', Icons.phone),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _pickProfilePicture,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 32.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Seleccionar Foto de Perfil',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                if (_profilePicture != null)
                  Text(
                    'Foto de Perfil seleccionada: $_profilePicture',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 32.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18.0,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para construir un campo de texto con icono.
  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        prefixIcon: Icon(icon),
      ),
    );
  }

  // Función para construir un campo de contraseña con icono.
  Widget _buildPasswordField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
