import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_transprogresochoco/views/User/RegisterScreen.dart';

import 'package:app_transprogresochoco/models/UserModel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserController _userController = UserController();
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Transprogreso Choco',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Color(0xFF123456),
      elevation: 0.0,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 80.0),
            _buildLogo(),
            SizedBox(height: 32.0),
            _buildEmailField(),
            SizedBox(height: 16.0),
            _buildPasswordField(),
            SizedBox(height: 32.0),
            _buildLoginButton(),
            SizedBox(height: 16.0),
            _buildForgotPasswordLink(),
            SizedBox(height: 30.0),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 180.0,
      height: 180.0,
      fit: BoxFit.contain,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Correo Electrónico',
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
        prefixIcon: Icon(Icons.email, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(20.0),
      ),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.05,
        color: Colors.black,
        fontFamily: 'Arial',
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(20.0),
      ),
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.05,
        color: Colors.black,
        fontFamily: 'Arial',
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF0D9276), // Verde
        padding: EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 32.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        shadowColor: Colors.black38,
        elevation: 8.0,
      ),
      child: Text(
        'Iniciar Sesión',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.white,
          fontFamily: 'Arial',
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return GestureDetector(
      onTap: _forgotPassword,
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontFamily: 'Arial',
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: _goToRegisterScreen,
      child: Text(
        '¿No tienes una cuenta? Regístrate',
        style: TextStyle(
          color: Color(0xFF40A2E3), // Azul
          fontSize: 19.0,
          fontFamily: 'Arial',
        ),
      ),
    );
  }

  void _showError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final UserModel? userData =
          await _userController.getUserData(userCredential.user!.uid);
      if (userData != null) {
        if (userData.isAdmin) {
          Navigator.pushNamed(context, '/dashboard');
        } else {
          Navigator.pushNamed(context, '/home', arguments: {'user': userData});
        }
      } else {
        _showError('Error al obtener los datos del usuario.');
      }
    } on FirebaseAuthException catch (e) {
      _showError('Error al iniciar sesión. Verifica tus credenciales.');
    }
  }

  void _goToRegisterScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterScreen(),
      ),
    );
  }

  void _forgotPassword() async {
    final String email = _emailController.text;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Se ha enviado un correo electrónico de restablecimiento de contraseña.'),
          duration: Duration(seconds: 3),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(
          'Error al enviar el correo electrónico de restablecimiento de contraseña.');
    }
  }
}
