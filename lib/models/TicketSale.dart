import 'package:cloud_firestore/cloud_firestore.dart';

class TicketSale {
  String id; // Identificador único de la venta
  String customerName; // Nombre del cliente
  String customerEmail; // Correo electrónico del cliente
  double amount; // Monto total de la venta
  int quantity; // Cantidad de tiquetes vendidos
  String paymentMethod; // Método de pago utilizado
  Timestamp saleDate; // Fecha y hora de la venta
  String routeId; // ID de la ruta seleccionada
  double ticketPrice; // Precio unitario del tiquete

  TicketSale({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.amount,
    required this.quantity,
    required this.paymentMethod,
    required this.saleDate,
    required this.routeId, // Nuevo campo para el ID de la ruta
    required this.ticketPrice, // Nuevo campo para el precio unitario
  });

  // Método para crear una instancia de TicketSale desde un documento Firestore
  factory TicketSale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketSale(
      id: doc.id,
      customerName: data['customerName'],
      customerEmail: data['customerEmail'],
      amount: data['amount'],
      quantity: data['quantity'],
      paymentMethod: data['paymentMethod'],
      saleDate: data['saleDate'],
      routeId: data['routeId'], // Asignar el valor del campo 'routeId'
      ticketPrice:
          data['ticketPrice'], // Asignar el valor del campo 'ticketPrice'
    );
  }

  // Método para convertir una instancia de TicketSale en un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerEmail': customerEmail,
      'amount': amount,
      'quantity': quantity,
      'paymentMethod': paymentMethod,
      'saleDate': saleDate,
      'routeId': routeId, // Agregar el campo 'routeId' al mapa
      'ticketPrice': ticketPrice, // Agregar el campo 'ticketPrice' al mapa
    };
  }
}
