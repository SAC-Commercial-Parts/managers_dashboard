import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quote.dart';
import '../models/invoice.dart';

class QuotesInvoicesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // No longer static lists, data is fetched from Firestore
  // static final List<Quote> _quotes = _generateMockQuotes();
  // static final List<Invoice> _invoices = _generateMockInvoices();

  // These methods are no longer needed as they were for in-memory data
  // static List<Quote> getQuotes() => _quotes;
  // static List<Invoice> getInvoices() => _invoices;

  // This method is now handled by getQuotesByDateRange with a broad date range
  // static List<Quote> getQuotesByBranch(String branchCode) {
  //   return _quotes.where((q) => q.branchCode == branchCode).toList();
  // }

  // This method is now handled by getInvoicesByDateRange with a broad date range
  // static List<Invoice> getInvoicesByBranch(String branchCode) {
  //   return _invoices.where((i) => i.branchCode == branchCode).toList();
  // }

  /// Fetches quotes for a specific branch within a date range from Firestore.
  /// Data is expected to be at /branches/{branchCode}/quotes/{quoteId}
  Future<List<Quote>> getQuotesByDateRange(String branchCode, DateTime startDate, DateTime endDate) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('branches')
          .doc(branchCode)
          .collection('quotes')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String().substring(0, 10)) // Compare as YYYY-MM-DD string
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String().substring(0, 10)) // Compare as YYYY-MM-DD string
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Quote.fromFirestore(doc.id, data); // Use the fromFirestore factory
      }).toList();
    } catch (e) {
      print('Error fetching quotes from Firestore: $e');
      return [];
    }
  }

  /// Fetches invoices for a specific branch within a date range from Firestore.
  /// Data is expected to be at /branches/{branchCode}/invoices/{invoiceId}
  Future<List<Invoice>> getInvoicesByDateRange(String branchCode, DateTime startDate, DateTime endDate) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('branches')
          .doc(branchCode)
          .collection('invoices')
          .where('invoiceDate', isGreaterThanOrEqualTo: startDate.toIso8601String().substring(0, 10))
          .where('invoiceDate', isLessThanOrEqualTo: endDate.toIso8601String().substring(0, 10))
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Invoice.fromFirestore(doc.id, data); // Use the fromFirestore factory
      }).toList();
    } catch (e) {
      print('Error fetching invoices from Firestore: $e');
      return [];
    }
  }

  /// Fetches a single quote by its ID from Firestore.
  Future<Quote?> getQuoteById(String branchCode, String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('branches')
          .doc(branchCode)
          .collection('quotes')
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Quote.fromFirestore(doc.id, data);
      }
      return null;
    } catch (e) {
      print('Error fetching quote by ID from Firestore: $e');
      return null;
    }
  }

  /// Fetches a single invoice by its ID from Firestore.
  Future<Invoice?> getInvoiceById(String branchCode, String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('branches')
          .doc(branchCode)
          .collection('invoices')
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Invoice.fromFirestore(doc.id, data);
      }
      return null;
    } catch (e) {
      print('Error fetching invoice by ID from Firestore: $e');
      return null;
    }
  }

// Removed all _generateMock... methods as they are no longer needed.
}
