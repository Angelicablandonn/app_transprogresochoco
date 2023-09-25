import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:app_transprogresochoco/views/Admin/Routes/EditRouteScreen.dart';
import 'package:intl/intl.dart';

class ListRoutesScreen extends StatefulWidget {
  @override
  _ListRoutesScreenState createState() => _ListRoutesScreenState();
}

class _ListRoutesScreenState extends State<ListRoutesScreen> {
  final AdminController _adminController = AdminController();
  List<RouteModel> _routes = [];
  TextEditingController _searchController =
      TextEditingController(); // Nuevo controlador para la búsqueda

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final routes = await _adminController.getRoutes();
    setState(() {
      _routes = routes;
    });
  }

  Future<void> _deleteRoute(String routeId) async {
    await _adminController.deleteRoute(routeId);
    _loadRoutes();
  }

  // Función para realizar la búsqueda de rutas
  Future<void> _searchRoutes(String query) async {
    final searchResults = await _adminController.searchRoutes(
        query, query); // Puedes ajustar los criterios de búsqueda
    setState(() {
      _routes = searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de Rutas'),
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                if (query.isEmpty) {
                  _loadRoutes(); // Cargar todas las rutas si el campo de búsqueda está vacío
                } else {
                  _searchRoutes(
                      query); // Realizar búsqueda cuando se escribe en el campo
                }
              },
              decoration: InputDecoration(
                labelText: 'Buscar rutas por origen, destino, etc.',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                return ListTile(
                  leading: Image.network(route.imageUrl),
                  title: Text(route.name),
                  subtitle: Text(
                      'Origen: ${route.origin}, Destino: ${route.destination}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Navega a la pantalla de edición pasando el ID de la ruta
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditRouteScreen(routeId: route.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Muestra un cuadro de diálogo de confirmación antes de eliminar
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Eliminar Ruta'),
                                content: Text(
                                    '¿Está seguro de que desea eliminar esta ruta?'),
                                actions: [
                                  TextButton(
                                    child: Text('Cancelar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Eliminar'),
                                    onPressed: () {
                                      // Elimina la ruta y cierra el cuadro de diálogo
                                      _deleteRoute(route.id);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RouteDetailsScreen(route: route),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RouteDetailsScreen extends StatelessWidget {
  final RouteModel route;

  RouteDetailsScreen({required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Ruta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.network(route.imageUrl), // Agrega esta línea
            Text('Nombre de la Ruta: ${route.name}'),
            Text('Origen: ${route.origin}'),
            Text('Destino: ${route.destination}'),
            Text(
                'Precio del Tiquete: \$${route.ticketPrice.toStringAsFixed(2)}'),
            Text(
                'Fecha de Salida: ${DateFormat('yyyy-MM-dd HH:mm').format(route.departureTime)}'),
          ],
        ),
      ),
    );
  }
}
