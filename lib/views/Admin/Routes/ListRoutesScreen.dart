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
  TextEditingController _searchController = TextEditingController();

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

  Future<void> _searchRoutes(String query) async {
    final searchResults = await _adminController.searchRoutes(query, query);
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchRoutes,
              decoration: InputDecoration(
                labelText: 'Buscar rutas',
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
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(route.imageUrl),
                  ),
                  title: Text(route.name),
                  subtitle: Text(
                      'Origen: ${route.origin}, Destino: ${route.destination}'),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
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
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(route.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
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
