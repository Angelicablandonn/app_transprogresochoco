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
  DateTime _departureDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadRouteDetails();
  }

  Future<void> _loadRouteDetails() async {
    final route = await _adminController.getRouteDetails(widget.routeId);

    setState(() {
      _nameController.text = route.name;
      _originController.text = route.origin;
      _destinationController.text = route.destination;
      _ticketPriceController.text = route.ticketPrice.toStringAsFixed(2);
      _availableSeatsController.text = route.availableSeats.toString();
      _busTypeController.text = route.busType;
      _descriptionController.text = route.description;
      _imageUrlController.text = route.imageUrl;
      _departureDateTime = route.departureTime;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_departureDateTime),
      );
      if (selectedTime != null) {
        setState(() {
          _departureDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
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
              _buildTextField(_nameController, 'Nombre de la Ruta'),
              _buildTextField(_originController, 'Origen'),
              _buildTextField(_destinationController, 'Destino'),
              _buildTextField(_ticketPriceController, 'Precio del Tiquete'),
              _buildTextField(
                  _availableSeatsController, 'Asientos Disponibles'),
              _buildTextField(_busTypeController, 'Tipo de Bus'),
              _buildTextField(_descriptionController, 'Descripción'),
              _buildTextField(_imageUrlController, 'URL de la Imagen'),
              _buildDateTimePicker(),
              ElevatedButton(
                onPressed: () async {
                  final updatedRoute = RouteModel(
                    id: widget.routeId,
                    name: _nameController.text,
                    origin: _originController.text,
                    destination: _destinationController.text,
                    departureTime: _departureDateTime,
                    ticketPrice: double.parse(_ticketPriceController.text),
                    availableSeats: int.parse(_availableSeatsController.text),
                    busType: _busTypeController.text,
                    description: _descriptionController.text,
                    imageUrl: _imageUrlController.text,
                  );
                  await _adminController.updateRoute(updatedRoute);
                  Navigator.of(context).pop();
                },
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () {
            _selectDateTime(context);
          },
          child: Text('Seleccionar Fecha y Hora de Salida'),
        ),
        Text(
          'Fecha y Hora de Salida: ${_departureDateTime.toLocal()}'
              .split('.')[0],
        ),
      ],
    );
  }
}
