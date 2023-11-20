import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _userController = UserController();

  late UserModel _user; // Variable para almacenar los datos del usuario
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar datos del usuario al iniciar la pantalla
  }

  // Función para cargar los datos del usuario
  Future<void> _loadUserData() async {
    try {
      // Obtén el usuario actual desde FirebaseAuth
      final currentUser = await _userController.getCurrentUser();

      if (currentUser != null) {
        // Obten el ID del usuario actual
        final userId = currentUser.uid;

        UserModel? user = await _userController.getUserData(userId);

        if (user != null) {
          setState(() {
            _user = user;
            _isLoading = false;
          });
        } else {
          // Manejar el caso en el que no se puedan cargar los datos del usuario
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // Manejar el caso en el que no haya un usuario autenticado
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      // Manejar el error según tus necesidades
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para mostrar un cuadro de diálogo de confirmación
  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _signOut(); // Cerrar sesión si se confirma
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Función para cerrar sesión
  Future<void> _signOut() async {
    await _userController.signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Esta línea te lleva de vuelta a la pantalla anterior
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Muestra los detalles del usuario (puedes personalizar según tu modelo de usuario)
                Text('Nombre: ${_user.fullName}'),
                Text('Correo Electrónico: ${_user.email}'),
                Text('Teléfono: ${_user.phoneNumber}'),
                // Añade más detalles según tus necesidades
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(
                        context); // Mostrar el cuadro de diálogo de confirmación al hacer clic en el botón
                  },
                  child: Text('Cerrar Sesión'),
                ),
              ],
            ),
    );
  }
}
