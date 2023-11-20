import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:app_transprogresochoco/views/User/Includes/Footer.dart';
import 'package:app_transprogresochoco/views/User/Includes/Sidebar.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserController _userController = UserController();
  final TextEditingController _searchController = TextEditingController();
  List<RouteModel> routes = [];
  int _selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
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

  Future<void> _searchRoutes(String query) async {
    try {
      final foundRoutes = await _userController.searchRoutes(query);
      setState(() {
        routes = foundRoutes;
      });
    } catch (error) {
      print('Error al buscar rutas: $error');
    }
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
                    selectedRoute,
                    _selectedQuantity,
                  );
                  // Actualiza la lista de rutas después de la compra (opcional)
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
      // Puedes mostrar un mensaje de error si es necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenido, ${widget.user.fullName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _userController.signOut(context);
            },
          ),
        ],
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      drawer: Sidebar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFF018a2c),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    _searchRoutes(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar rutas por destino',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Rutas Disponibles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, index) {
                RouteModel route = routes[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5.0,
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      route.name,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Origen: ${route.origin}'),
                        Text('Destino: ${route.destination}'),
                        Text('Hora de Salida: ${route.departureTime}'),
                        Text(
                          'Precio: \$${route.ticketPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    trailing: Image.network(
                      route.imageUrl,
                      width: 80.0,
                      height: 80.0,
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      _showBuyTicketDialog(route);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
