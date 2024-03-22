import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:app_transprogresochoco/views/User/Includes/Sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_transprogresochoco/views/User/ProfileScreen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final UserController _userController = UserController();
  List<RouteModel> routes = [];
  int _selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadRoutes();
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
      // Verificar si hay un usuario actualmente autenticado
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Si hay un usuario autenticado, puedes retornar su información
        // Puedes acceder a su ID, email, etc., según tus necesidades
        return UserModel(
          uid: user.uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
          profilePicture: user.photoURL,
          isAdmin:
              false, // Deberías obtener esto de tu base de datos, ya que Firebase Auth no lo proporciona
          password:
              '', // No deberías acceder a la contraseña del usuario desde FirebaseAuth
        );
      } else {
        // Si no hay un usuario autenticado, puedes retornar null
        return null;
      }
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir al obtener el usuario actual
      print('Error al obtener el usuario actual: $e');
      return null;
    }
  }

  Future<void> _searchRoutes(
      String origin, String destination, DateTime date) async {
    try {
      final foundRoutes =
          await _userController.searchRoutes(origin, destination, date);
      setState(() {
        routes = foundRoutes;
      });
    } catch (error) {
      print('Error al buscar rutas: $error');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _showSearchRoutesDialog() async {
    final originController = TextEditingController();
    final destinationController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Text(
            'Buscar Rutas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123456),
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: [
                TextField(
                  controller: originController,
                  decoration: InputDecoration(
                    hintText: 'Origen',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    hintText: 'Destino',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text("Seleccionar fecha"),
                  subtitle: Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                primary: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                primary: Colors.white,
              ),
              onPressed: () {
                _searchRoutes(originController.text, destinationController.text,
                    selectedDate);
                Navigator.pop(context);
              },
              child: Text(
                'Buscar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBuyTicketDialog(RouteModel selectedRoute) async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Compra de Boletos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Selecciona la cantidad de boletos'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_selectedQuantity > 1) {
                            _selectedQuantity--;
                          }
                        });
                      },
                    ),
                    Text('$_selectedQuantity'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _selectedQuantity++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await _userController.selectRouteAndBuyTickets(
                    context,
                    widget.user,
                    _selectedQuantity,
                  );
                  _loadRoutes();
                  Navigator.pop(context);
                },
                child: Text('Comprar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error al comprar boletos: $e');
    }
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
      ),
      drawer: Sidebar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TextField(
                  controller: _originController,
                  decoration: InputDecoration(
                    labelText: 'Origen',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    // Apply button style color
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: 'Destino',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    // Apply button style color
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 8),
                      Text(
                        'Seleccionar fecha',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF387163), // Verde Natural
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _searchRoutes(
                      _originController.text,
                      _destinationController.text,
                      _selectedDate,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 8),
                      Text(
                        'Buscar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF4E7CA3), // Azul Agua
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Card(
              margin: EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Rutas Disponibles',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF123456),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          RouteModel route = routes[index];
                          String formattedDepartureTime =
                              DateFormat('EEEE d/MM - H:mm', 'es_ES')
                                  .format(route.departureTime);

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Image.network(
                                  route.imageUrl,
                                  width: double.infinity,
                                  height: 150.0,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        route.name,
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF123456),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'F. de Salida:  $formattedDepartureTime',
                                        style: TextStyle(fontSize: 17.0),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'Precio: \$${route.ticketPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(
                                              0xFF387163), // Verde Natural
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10.0),
                                      Container(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xFF123456),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            _showBuyTicketDialog(route);
                                          },
                                          child: Text(
                                            'Comprar boletos',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        onTap: (index) async {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/purchase_history');
              break;
            case 2:
              // Obtener el usuario actual
              UserModel? currentUser = await getCurrentUser();

              // Verificar si se obtuvo el usuario correctamente
              if (currentUser != null) {
                // Navegar a la pantalla de perfil y pasar el usuario como argumento
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: currentUser),
                  ),
                );
              } else {
                // Manejar el caso en el que no se pudo obtener el usuario
                print('No se pudo obtener el usuario actual');
              }
              break;

            case 3:
              _showSearchRoutesDialog();
              break;
            case 4:
              await _userController.signOut;
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
        },
      ),
    );
  }
}
