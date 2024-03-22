import 'package:cloud_firestore/cloud_firestore.dart';

class TicketSale {
  String id;
  String customerName;
  String customerEmail;
  double amount;
  int quantity;
  String paymentMethod;
  Timestamp saleDate;
  String routeId;
  double ticketPrice;
  String approvalStatus;
  String userId;
  String downloadURL; // Nuevo campo para almacenar la URL de descarga
  String
      purchaseHistoryId; // Nuevo campo para almacenar la referencia a PurchaseHistory

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
    required this.userId,
    required this.downloadURL, // Agrega el campo 'downloadURL' al constructor
    required this.purchaseHistoryId, // Agrega el campo 'purchaseHistoryId'
    this.approvalStatus = 'No Aprobado',
  });

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
      userId: data['userId'],
      downloadURL: data['downloadURL'], // Agregar el campo 'downloadURL'
      purchaseHistoryId:
          data['purchaseHistoryId'], // Agregar el campo 'purchaseHistoryId'
      approvalStatus: data['approvalStatus'] ?? 'No Aprobado',
    );
  }

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
      'userId': userId,
      'downloadURL': downloadURL, // Agregar el campo 'downloadURL'
      'purchaseHistoryId':
          purchaseHistoryId, // Agregar el campo 'purchaseHistoryId'
      'approvalStatus': approvalStatus,
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
      userId: data['userId'] ?? '',
      downloadURL: data['downloadURL'] ?? '', // Agregar el campo 'downloadURL'
      purchaseHistoryId: data['purchaseHistoryId'] ??
          '', // Agregar el campo 'purchaseHistoryId'
      approvalStatus: data['approvalStatus'] ?? '',
    );
  }
}
