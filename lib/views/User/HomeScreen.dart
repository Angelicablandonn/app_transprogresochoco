import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';

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

  @override
  void initState() {
    super.initState();
    loadRoutes();
  }

  void loadRoutes() {
    _userController.getRoutes().then((retrievedRoutes) {
      setState(() {
        routes = retrievedRoutes;
      });
    }).catchError((error) {
      print('Error al cargar las rutas: $error');
    });
  }

  void searchRoutes(String query) {
    _userController.searchRoutes(query).then((foundRoutes) {
      setState(() {
        routes = foundRoutes;
      });
    }).catchError((error) {
      print('Error al buscar rutas: $error');
    });
  }

  Future<void> showBuyTicketDialog(RouteModel selectedRoute) async {
    try {
      await _userController.selectRouteAndBuyTickets(
          context, widget.user, selectedRoute);
      // Actualiza la lista de rutas después de la compra (opcional)
      loadRoutes();
    } catch (e) {
      print('Error al comprar boletos: $e');
      // Puedes mostrar un mensaje de error si es necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${widget.user.fullName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _userController.signOut(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar rutas por destino',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchRoutes(_searchController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Rutas Disponibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  RouteModel route = routes[index];
                  return Card(
                    elevation: 5.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(route.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Origen: ${route.origin}'),
                          Text('Destino: ${route.destination}'),
                          Text('Hora de Salida: ${route.departureTime}'),
                          Text(
                            'Precio: \$${route.ticketPrice.toStringAsFixed(2)}',
                          ),
                          // Agrega más información si es necesario
                        ],
                      ),
                      trailing: Image.network(
                        route.imageUrl,
                        width: 60.0,
                        height: 60.0,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        showBuyTicketDialog(route);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
