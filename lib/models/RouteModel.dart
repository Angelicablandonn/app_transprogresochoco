import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String id; // Identificador único de la ruta
  final String name; // Nombre o número de la ruta
  final String origin; // Punto de partida
  final String destination; // Punto de llegada
  final DateTime departureTime; // Fecha y hora de salida
  final double ticketPrice; // Precio del boleto
  final int availableSeats; // Número de asientos disponibles
  final String busType; // Tipo de vehículo
  final String description; // Descripción de la ruta
  String imageUrl; // URL de la imagen representativa

  RouteModel({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.ticketPrice,
    required this.availableSeats,
    required this.busType,
    required this.description,
    required this.imageUrl,
  });

  // Método para crear una instancia de RouteModel a partir de un mapa
  factory RouteModel.fromMap(Map<String, dynamic> map, String id) {
    return RouteModel(
      id: id,
      name: map['name'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      ticketPrice: (map['ticketPrice'] as num).toDouble(),
      availableSeats: map['availableSeats'] ?? 0,
      busType: map['busType'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // Método para convertir la instancia de RouteModel a un mapa
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'origin': origin,
      'destination': destination,
      'departureTime': departureTime,
      'ticketPrice': ticketPrice,
      'availableSeats': availableSeats,
      'busType': busType,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
