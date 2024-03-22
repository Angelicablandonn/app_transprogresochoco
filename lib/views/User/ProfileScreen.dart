import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:app_transprogresochoco/views/User/Includes/Sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:app_transprogresochoco/views/User/HomeScreen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _userController = UserController();
  late UserModel _user;
  List<RouteModel> routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _isLoading = false;
  }

  Future<void> _signOut() async {
    await _userController.signOut(context);
  }

  Future<void> _loadRoutes() async {
    try {
      final retrievedRoutes = await _userController.getRoutes();
      setState(() {
        routes = retrievedRoutes;
      });
    } catch (error) {
      print('Error al cargar las rutas: $error');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        return UserModel(
          uid: user.uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
          profilePicture: user.photoURL,
          isAdmin: false,
          password: '',
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener el usuario actual: $e');
      return null;
    }
  }

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
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _signOut();
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: TextStyle(fontSize: 18.0),
        ),
        backgroundColor: Color(0xFF123456),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(_user.profilePicture ?? ''),
            ),
          ),
        ],
      ),
      drawer: Sidebar(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    'Información Personal',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123456),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  _buildProfileItem('Nombre:', _user.fullName),
                  _buildProfileItem('Correo Electrónico:', _user.email),
                  _buildProfileItem('Teléfono:', _user.phoneNumber),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(context);
                    },
                    child: Text('Cerrar Sesión'),
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
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Color(0xFF123456),
        showUnselectedLabels: true,
        currentIndex: 2,
        onTap: (index) async {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/purchase_history');
              break;
            case 2:
              UserModel? currentUser = await getCurrentUser();
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: currentUser),
                  ),
                );
              } else {
                print('No se pudo obtener el usuario actual');
              }
              break;
            case 3:
              Navigator.pushNamed(context, '/search');
              break;
            case 4:
              _signOut();
              break;
          }
        },
      ),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18.0),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}
