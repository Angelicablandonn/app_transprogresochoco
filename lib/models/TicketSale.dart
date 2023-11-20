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
  String approvalStatus; // Estado de aprobación de la venta
  String userId; // ID del usuario asociado a la venta

  TicketSale({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.amount,
    required this.quantity,
    required this.paymentMethod,
    required this.saleDate,
    required this.routeId,
    required this.ticketPrice,
    required this.userId, // Agrega el campo 'userId' al constructor
    this.approvalStatus = 'No Aprobado', // Valor por defecto
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
      routeId: data['routeId'],
      ticketPrice: data['ticketPrice'],
      userId: data['userId'], // Agregar el campo 'userId'
      approvalStatus: data['approvalStatus'] ??
          'No Aprobado', // Valor por defecto si no existe
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
      'routeId': routeId,
      'ticketPrice': ticketPrice,
      'userId': userId, // Agregar el campo 'userId' al mapa
      'approvalStatus':
          approvalStatus, // Agregar el campo 'approvalStatus' al mapa
    };
  }

  factory TicketSale.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return TicketSale(
      id: snapshot.id,
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      paymentMethod: data['paymentMethod'] ?? '',
      saleDate: data['saleDate'] ?? Timestamp.now(),
      routeId: data['routeId'] ?? '',
      ticketPrice: (data['ticketPrice'] ?? 0.0).toDouble(),
      userId: data['userId'] ?? '', // Agregar el campo 'userId'
      approvalStatus: data['approvalStatus'] ?? '',
    );
  }
}
