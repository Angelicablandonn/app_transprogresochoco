import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';

class EditRouteScreen extends StatefulWidget {
  final String routeId;

  EditRouteScreen({required this.routeId});

  @override
  _EditRouteScreenState createState() => _EditRouteScreenState();
}

class _EditRouteScreenState extends State<EditRouteScreen> {
  final AdminController _adminController = AdminController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _availableSeatsController =
      TextEditingController();
  final TextEditingController _busTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRouteDetails();
  }

  Future<void> _loadRouteDetails() async {
    // Obtén los detalles de la ruta a editar usando el ID
    final route = await _adminController.getRouteDetails(widget.routeId);

    // Actualiza los controladores de texto con los detalles de la ruta
    setState(() {
      _nameController.text = route.name;
      _originController.text = route.origin;
      _destinationController.text = route.destination;
      _ticketPriceController.text = route.ticketPrice.toStringAsFixed(2);
      _availableSeatsController.text = route.availableSeats.toString();
      _busTypeController.text = route.busType;
      _descriptionController.text = route.description;
      _imageUrlController.text = route.imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Ruta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre de la Ruta'),
              ),
              TextFormField(
                controller: _originController,
                decoration: InputDecoration(labelText: 'Origen'),
              ),
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(labelText: 'Destino'),
              ),
              TextFormField(
                controller: _ticketPriceController,
                decoration: InputDecoration(labelText: 'Precio del Tiquete'),
              ),
              TextFormField(
                controller: _availableSeatsController,
                decoration: InputDecoration(labelText: 'Asientos Disponibles'),
              ),
              TextFormField(
                controller: _busTypeController,
                decoration: InputDecoration(labelText: 'Tipo de Bus'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'URL de la Imagen'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final updatedRoute = RouteModel(
                    id: widget.routeId,
                    name: _nameController.text,
                    origin: _originController.text,
                    destination: _destinationController.text,
                    departureTime:
                        DateTime.now(), // Cambia esto con el valor deseado
                    ticketPrice: double.parse(_ticketPriceController.text),
                    availableSeats: int.parse(_availableSeatsController.text),
                    busType: _busTypeController.text,
                    description: _descriptionController.text,
                    imageUrl: _imageUrlController.text,
                  );
                  await _adminController.updateRoute(updatedRoute);
                  Navigator.of(context).pop(); // Vuelve a la pantalla anterior
                },
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
