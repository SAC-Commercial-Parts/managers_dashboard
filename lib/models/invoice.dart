// lib/models/invoice.dart

enum InvoiceStatus { draft, sent, paid, overdue, cancelled }
////////////////////////////////////////////////////////////////////////////
//                             INVOICE MODEL                              //
////////////////////////////////////////////////////////////////////////////
// TO BE AMENDED [THIS WAS FOR MOCK DATA]
class Invoice {
  final String id;
  final String quoteId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String clientAddress;
  final String employeeId;
  final String employeeName;
  final String branchCode;
  final DateTime dateCreated;
  final DateTime dueDate;
  final DateTime? datePaid;
  final InvoiceStatus status;
  final double amount;
  final double taxAmount;
  final double totalAmount;
  final List<InvoiceItem> items;
  final String? notes;
  final String? paymentMethod;
  final bool isCredited; // <--- ADD THIS FIELD

  Invoice({
    required this.id,
    required this.quoteId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.clientAddress,
    required this.employeeId,
    required this.employeeName,
    required this.branchCode,
    required this.dateCreated,
    required this.dueDate,
    this.datePaid,
    required this.status,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.items,
    this.notes,
    this.paymentMethod,
    this.isCredited = false, // <--- Initialize with false
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      quoteId: json['quoteId'],
      clientName: json['clientName'],
      clientEmail: json['clientEmail'],
      clientPhone: json['clientPhone'],
      clientAddress: json['clientAddress'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      branchCode: json['branchCode'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dueDate: DateTime.parse(json['dueDate']),
      datePaid: json['datePaid'] != null ? DateTime.parse(json['datePaid']) : null,
      status: InvoiceStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      amount: json['amount'].toDouble(),
      taxAmount: json['taxAmount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      items: (json['items'] as List).map((item) => InvoiceItem.fromJson(item)).toList(),
      notes: json['notes'],
      paymentMethod: json['paymentMethod'],
      isCredited: json['isCredited'] ?? false, // <--- Retrieve from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quoteId': quoteId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'clientAddress': clientAddress,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'branchCode': branchCode,
      'dateCreated': dateCreated.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'datePaid': datePaid?.toIso8601String(),
      'status': status.toString().split('.').last,
      'amount': amount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'paymentMethod': paymentMethod,
      'isCredited': isCredited, // <--- Add to JSON
    };
  }
}

////////////////////////////////////////////////////////////////////////////
//                           INVOICE ITEM MODEL                           //
////////////////////////////////////////////////////////////////////////////
// TO BE AMENDED [THIS WAS FOR MOCK DATA]
class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      total: json['total'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}