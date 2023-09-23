import 'dart:io';

import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddRouteScreen extends StatefulWidget {
  @override
  _AddRouteScreenState createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  DateTime _departureDateTime = DateTime.now();
  DateTime selectDateTime = DateTime.now();
  final TextEditingController _ticketPriceController = TextEditingController();
  final AdminController _adminController = AdminController();
  File? _imageFile;

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
    final newRoute = RouteModel(
      id: UniqueKey().toString(),
      name: _nameController.text,
      origin: _originController.text,
      destination: _destinationController.text,
      departureTime: _departureDateTime,
      ticketPrice: double.parse(_ticketPriceController.text),
      availableSeats: 0,
      busType: '',
      description: '',
      imageUrl: '', // Debes actualizar esta URL con la URL de la imagen cargada
    );

    if (_imageFile != null) {
      // Sube la imagen a Firebase Storage y obtén su URL
      final imageUrl = await _adminController.uploadRouteImage(_imageFile!);

      if (imageUrl != null) {
        // Actualiza la URL de la imagen en la nueva ruta
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
              TextFormField(
                controller: _ticketPriceController,
                decoration: InputDecoration(labelText: 'Precio del Tiquete'),
              ),
              ElevatedButton(
                onPressed: () {
                  _uploadImage();
                },
                child: Text('Seleccionar Imagen'),
              ),
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 100,
                  width: 100,
                )
              else
                Text('No has seleccionado una imagen'),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addRoute,
                child: Text('Agregar Ruta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
