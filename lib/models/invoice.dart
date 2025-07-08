// lib/models/invoice.dart

enum InvoiceStatus { draft, sent, paid, overdue, cancelled, pending } // Added 'pending' for robustness

class Invoice {
  final String id; // This will be the Firestore document ID
  final String? quoteId; // Made nullable as per mock data
  final String clientName;
  final String? clientId; // Added as per mock data
  final String? clientEmail; // Made nullable
  final String? clientPhone; // Made nullable
  final String? clientAddress; // Made nullable
  final String? employeeId; // Made nullable
  final String? employeeName; // Made nullable
  final String? branchCode; // Not directly in invoice doc, but useful for context
  final DateTime dateCreated; // Corresponds to 'invoiceDate' in Firestore
  final DateTime dueDate;
  final DateTime? datePaid; // Made nullable
  final InvoiceStatus status;
  final double? amount; // Made nullable, only totalAmount is in mock
  final double? taxAmount; // Made nullable, only totalAmount is in mock
  final double totalAmount;
  final List<InvoiceItem> items;
  final String? notes; // Made nullable
  final String? paymentMethod; // Made nullable
  final bool isCredited;
  final String? creditNoteId; // Added as per mock data

  Invoice({
    required this.id,
    this.quoteId,
    required this.clientName,
    this.clientId, // Added
    this.clientEmail,
    this.clientPhone,
    this.clientAddress,
    this.employeeId,
    this.employeeName,
    this.branchCode,
    required this.dateCreated,
    required this.dueDate,
    this.datePaid,
    required this.status,
    this.amount,
    this.taxAmount,
    required this.totalAmount,
    required this.items,
    this.notes,
    this.paymentMethod,
    this.isCredited = false,
    this.creditNoteId, // Added
  });

  factory Invoice.fromFirestore(String id, Map<String, dynamic> data) {
    // Helper to parse string status to enum
    InvoiceStatus parseInvoiceStatus(String statusString) {
      switch (statusString.toLowerCase()) {
        case 'draft':
          return InvoiceStatus.draft;
        case 'sent':
          return InvoiceStatus.sent;
        case 'paid':
          return InvoiceStatus.paid;
        case 'overdue':
          return InvoiceStatus.overdue;
        case 'cancelled':
          return InvoiceStatus.cancelled;
        case 'pending': // Added 'pending' case
          return InvoiceStatus.pending;
        default:
          return InvoiceStatus.pending; // Default if status is missing or invalid
      }
    }

    return Invoice(
      id: id, // Use the Firestore document ID
      quoteId: data['quoteId'] as String?,
      clientId: data['clientId'] as String?, // Added
      clientName: data['clientName'] as String,
      // clientEmail, clientPhone, clientAddress, employeeId, employeeName, datePaid, amount, taxAmount, notes, paymentMethod are not in mock data, so they'll be null
      dateCreated: DateTime.parse(data['invoiceDate'] as String), // Map 'invoiceDate' to 'dateCreated'
      dueDate: DateTime.parse(data['dueDate'] as String),
      status: parseInvoiceStatus(data['status'] as String), // Map 'status' from Firestore to enum
      totalAmount: (data['totalAmount'] as num).toDouble(),
      items: (data['items'] as List<dynamic>)
          .map((item) => InvoiceItem.fromFirestore(item as Map<String, dynamic>))
          .toList(),
      isCredited: data['isCredited'] as bool? ?? false, // Handle null for existing docs
      creditNoteId: data['creditNoteId'] as String?,
    );
  }

  // toFirestore is typically used for sending data TO Firestore.
  // This version reflects the structure of the mock data you provided.
  Map<String, dynamic> toFirestore() {
    String invoiceStatusToString(InvoiceStatus status) {
      return status.toString().split('.').last;
    }

    return {
      'quoteId': quoteId,
      'clientId': clientId,
      'clientName': clientName,
      'invoiceDate': dateCreated.toIso8601String().substring(0, 10), // Store as YYYY-MM-DD string
      'dueDate': dueDate.toIso8601String().substring(0, 10), // Store as YYYY-MM-DD string
      'totalAmount': totalAmount,
      'status': invoiceStatusToString(status),
      'isCredited': isCredited,
      'creditNoteId': creditNoteId,
      'items': items.map((item) => item.toFirestore()).toList(),
      // Fields not in mock data are omitted here for consistency with Firestore structure
    };
  }
}

class InvoiceItem {
  // Removed 'id' and 'total' as they are not in the provided mock data for InvoiceItem
  final String description; // Corresponds to 'name' in mock data
  final int quantity; // Corresponds to 'qty' in mock data
  final double unitPrice; // Corresponds to 'price' in mock data

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  factory InvoiceItem.fromFirestore(Map<String, dynamic> data) {
    return InvoiceItem(
      description: data['name'] as String, // Map 'name' from Firestore to 'description'
      quantity: data['qty'] as int,        // Map 'qty' from Firestore to 'quantity'
      unitPrice: (data['price'] as num).toDouble(), // Map 'price' from Firestore to 'unitPrice'
    );
  }

  // toFirestore is typically used for sending data TO Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': description, // Map 'description' to 'name' for Firestore
      'qty': quantity,     // Map 'quantity' to 'qty' for Firestore
      'price': unitPrice,  // Map 'unitPrice' to 'price' for Firestore
    };
  }
}
