enum QuoteStatus { pending, converted, rejected, expired }
////////////////////////////////////////////////////////////////////////////
//                              QUOTE MODEL                               //
////////////////////////////////////////////////////////////////////////////
// TO BE AMENDED [THIS WAS FOR MOCK DATA]
class Quote {
  final String id;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String employeeId;
  final String employeeName;
  final String branchCode;
  final DateTime dateCreated;
  final DateTime? dateConverted;
  final QuoteStatus status;
  final double amount;
  final List<QuoteItem> items;
  final String? notes;

  Quote({
    required this.id,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.employeeId,
    required this.employeeName,
    required this.branchCode,
    required this.dateCreated,
    this.dateConverted,
    required this.status,
    required this.amount,
    required this.items,
    this.notes,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      clientName: json['clientName'],
      clientEmail: json['clientEmail'],
      clientPhone: json['clientPhone'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      branchCode: json['branchCode'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateConverted: json['dateConverted'] != null ? DateTime.parse(json['dateConverted']) : null,
      status: QuoteStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      amount: json['amount'].toDouble(),
      items: (json['items'] as List).map((item) => QuoteItem.fromJson(item)).toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'branchCode': branchCode,
      'dateCreated': dateCreated.toIso8601String(),
      'dateConverted': dateConverted?.toIso8601String(),
      'status': status.toString().split('.').last,
      'amount': amount,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
    };
  }
}

class QuoteItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  QuoteItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
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