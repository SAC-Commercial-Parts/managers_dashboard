import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/performance_data.dart'; // For FilterPeriod enum

class FirestoreDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches and aggregates summary data for a specific branch.
  /// This example calculates total sales from paid invoices, total quotes,
  /// total deliveries, and total calls.
  Future<Map<String, double>> getBranchSummary(String branchCode, FilterPeriod period) async {
    Map<String, double> summary = {
      'totalSales': 0.0,
      'totalQuotes': 0.0,
      'deliveries': 0.0, // New metric
      'calls': 0.0,      // New metric
      'conversions': 0.0, // Added for consistency with dashboard view
    };

    // Determine date range based on FilterPeriod
    final DateTime startDate = period.startDate;
    final DateTime endDate = period.endDate;

    try {
      // Fetch invoices for total sales and conversions
      final invoiceSnapshot = await _firestore
          .collection('branches')
          .doc(branchCode)
          .collection('invoices')
          .where('invoiceDate', isGreaterThanOrEqualTo: startDate.toIso8601String().substring(0, 10))
          .where('invoiceDate', isLessThanOrEqualTo: endDate.toIso8601String().substring(0, 10))
          .get();

      double totalSales = 0.0;
      for (var doc in invoiceSnapshot.docs) {
        final data = doc.data();
        final invoiceStatus = data['status'] as String?;
        final isCredited = data['isCredited'] as bool? ?? false;
        final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

        // Only count paid and non-credited invoices towards total sales
        if (invoiceStatus == 'paid' && !isCredited) {
          totalSales += totalAmount;
        }
      }
      summary['totalSales'] = totalSales;


      // Fetch quotes for total quotes and conversions
      final quoteSnapshot = await _firestore
          .collection('branches')
          .doc(branchCode)
          .collection('quotes')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String().substring(0, 10))
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String().substring(0, 10))
          .get();

      summary['totalQuotes'] = quoteSnapshot.docs.length.toDouble();
      summary['conversions'] = quoteSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['status'] == 'converted';
      }).length.toDouble();


      // Fetch deliveries
      final deliverySnapshot = await _firestore
          .collection('branches')
          .doc(branchCode)
          .collection('deliveries')
          .where('deliveryDate', isGreaterThanOrEqualTo: startDate.toIso8601String().substring(0, 10))
          .where('deliveryDate', isLessThanOrEqualTo: endDate.toIso8601String().substring(0, 10))
          .where('status', isEqualTo: 'delivered') // Only count delivered ones for dashboard
          .get();

      summary['deliveries'] = deliverySnapshot.docs.length.toDouble();

      // Fetch calls
      final callSnapshot = await _firestore
          .collection('branches')
          .doc(branchCode)
          .collection('calls')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String().substring(0, 10))
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String().substring(0, 10))
          .get();

      summary['calls'] = callSnapshot.docs.length.toDouble();

      return summary;
    } catch (e) {
      print('Error fetching branch summary from Firestore: $e');
      return {
        'totalSales': 0.0,
        'totalQuotes': 0.0,
        'deliveries': 0.0,
        'calls': 0.0,
        'conversions': 0.0,
      }; // Return empty summary on error
    }
  }
}
