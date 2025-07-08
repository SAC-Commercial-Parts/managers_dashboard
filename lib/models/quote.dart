enum QuoteStatus { pending, converted, rejected, expired }

class Quote {
  final String id; // This will be the Firestore document ID
  final String clientId;
  final String clientName;
  final String? clientEmail; // Not in mock data, made nullable
  final String? clientPhone; // Not in mock data, made nullable
  final String? employeeId; // Not in mock data, made nullable
  final String? employeeName; // Not in mock data, made nullable
  final String? branchCode; // Not directly in quote doc, but useful for context
  final DateTime dateCreated; // Corresponds to 'date' in Firestore
  final DateTime? dateConverted; // Not in mock data, made nullable
  final QuoteStatus status;
  final double amount;
  final List<QuoteItem> items;
  final String? notes; // Not in mock data, made nullable

  Quote({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.employeeId,
    this.employeeName,
    this.branchCode,
    required this.dateCreated,
    this.dateConverted,
    required this.status,
    required this.amount,
    required this.items,
    this.notes,
  });

  // Factory constructor to create Quote from a Firestore document
  factory Quote.fromFirestore(String id, Map<String, dynamic> data) {
    QuoteStatus parseQuoteStatus(String statusString) {
      switch (statusString.toLowerCase()) {
        case 'pending':
          return QuoteStatus.pending;
        case 'converted':
          return QuoteStatus.converted;
        case 'rejected':
          return QuoteStatus.rejected;
        case 'expired':
          return QuoteStatus.expired;
        default:
          return QuoteStatus.pending; // Default if status is missing or invalid
      }
    }

    return Quote(
      id: id,
      clientId: data['clientId'] as String,
      clientName: data['clientName'] as String,
      // The following fields are not in your Firestore mock data, so they'll be null
      clientEmail: null,
      clientPhone: null,
      employeeId: null,
      employeeName: null,
      branchCode: null, // This is derived from the path, not usually a field in the doc
      dateCreated: DateTime.parse(data['date'] as String), // 'date' in Firestore
      dateConverted: data['dateConverted'] != null ? DateTime.parse(data['dateConverted'] as String) : null,
      status: parseQuoteStatus(data['status'] as String),
      amount: (data['amount'] as num).toDouble(),
      items: (data['items'] as List<dynamic>)
          .map((item) => QuoteItem.fromFirestore(item as Map<String, dynamic>)) // Corrected to fromFirestore
          .toList(),
      notes: data['notes'] as String?,
    );
  }

  // Method to convert Quote to a map suitable for Firestore
  Map<String, dynamic> toFirestore() {
    String quoteStatusToString(QuoteStatus status) {
      return status.toString().split('.').last;
    }

    return {
      'clientId': clientId,
      'clientName': clientName,
      'date': dateCreated.toIso8601String().substring(0, 10), // Store as YYYY-MM-DD string
      'amount': amount,
      'status': quoteStatusToString(status),
      'items': items.map((item) => item.toFirestore()).toList(),
      // Optional fields if you add them to Firestore
      // 'dateConverted': dateConverted?.toIso8601String().substring(0, 10),
      // 'notes': notes,
      // 'clientEmail': clientEmail,
      // 'clientPhone': clientPhone,
      // 'employeeId': employeeId,
      // 'employeeName': employeeName,
    };
  }
}

class QuoteItem {
  // Removed 'id' and 'total' as they are not in the provided mock data for QuoteItem
  final String description; // Corresponds to 'name' in mock data
  final int quantity; // Corresponds to 'qty' in mock data
  final double unitPrice; // Corresponds to 'price' in mock data

  QuoteItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  // Factory constructor to create QuoteItem from a Firestore map
  factory QuoteItem.fromFirestore(Map<String, dynamic> data) { // Renamed from fromJson
    return QuoteItem(
      description: data['name'] as String, // Map 'name' from Firestore to 'description'
      quantity: data['qty'] as int,        // Map 'qty' from Firestore to 'quantity'
      unitPrice: (data['price'] as num).toDouble(), // Map 'price' from Firestore to 'unitPrice'
    );
  }

  // Method to convert QuoteItem to a map suitable for Firestore
  Map<String, dynamic> toFirestore() { // Renamed from toJson
    return {
      'name': description, // Map 'description' to 'name' for Firestore
      'qty': quantity,     // Map 'quantity' to 'qty' for Firestore
      'price': unitPrice,  // Map 'unitPrice' to 'price' for Firestore
    };
  }
}
