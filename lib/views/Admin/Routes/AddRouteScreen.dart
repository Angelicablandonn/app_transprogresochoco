import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';

class AddRouteScreen extends StatefulWidget {
  @override
  _AddRouteScreenState createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _availableSeatsController =
      TextEditingController();
  final TextEditingController _busTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _departureDateTime = DateTime.now();
  final TextEditingController _ticketPriceController = TextEditingController();
  final AdminController _adminController = AdminController();
  File? _imageFile;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addRoute() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newRoute = RouteModel(
      id: UniqueKey().toString(),
      name: _nameController.text,
      origin: _originController.text,
      destination: _destinationController.text,
      departureTime: _departureDateTime,
      ticketPrice: double.parse(_ticketPriceController.text),
      availableSeats: int.parse(_availableSeatsController.text),
      busType: _busTypeController.text,
      description: _descriptionController.text,
      imageUrl: '', // Actualizar con la URL de la imagen cargada
    );

    if (_imageFile != null) {
      // Subir imagen a Firebase Storage y obtener su URL
      final imageUrl = await _adminController.uploadRouteImage(_imageFile!);

      if (imageUrl != null) {
        // Actualizar la URL de la imagen en la nueva ruta
        newRoute.imageUrl = imageUrl;
      }
    }

    await _adminController.addRoute(newRoute);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Ruta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildTextField(
                    _nameController, 'Nombre de la Ruta', Icons.directions_bus),
                _buildTextField(_originController, 'Origen', Icons.location_on),
                _buildTextField(
                    _destinationController, 'Destino', Icons.location_on),
                _buildTextField(_availableSeatsController,
                    'Asientos Disponibles', Icons.event_seat),
                _buildTextField(_busTypeController, 'Tipo de Vehículo',
                    Icons.directions_car),
                _buildTextField(_descriptionController,
                    'Descripción de la Ruta', Icons.description),
                _buildDateTimePicker(context),
                _buildTextField(_ticketPriceController, 'Precio del Tiquete',
                    Icons.attach_money),
                _buildImageUploader(context),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _addRoute,
                  child: Text('Agregar Ruta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingresa un valor';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _selectDateTime(context);
          },
          icon: Icon(Icons.calendar_today),
          label: Text('Seleccionar Fecha y Hora de Salida'),
        ),
        SizedBox(height: 8.0),
        Text(
          'Fecha y Hora de Salida: ${_departureDateTime.toLocal()}'
              .split('.')[0],
        ),
      ],
    );
  }

  Widget _buildImageUploader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _uploadImage();
          },
          icon: Icon(Icons.image),
          label: Text('Seleccionar Imagen'),
        ),
        SizedBox(height: 8.0),
        if (_imageFile != null)
          Image.file(
            _imageFile!,
            height: 100,
            width: 100,
          )
        else
          Text('No has seleccionado una imagen'),
      ],
    );
  }
}
