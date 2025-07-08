import 'package:branch_managers_app/services/quotes_invoice_service.dart';
import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../models/invoice.dart';
import '../services/auth_service.dart';
import '../models/performance_data.dart'; // Import for FilterPeriod extension

class QuotesInvoicesViewModel extends ChangeNotifier {
  final QuotesInvoicesService _quotesInvoicesService = QuotesInvoicesService();

  List<Quote> _quotes = [];
  List<Invoice> _invoices = [];
  Quote? _selectedQuote;
  Invoice? _selectedInvoice;
  // Changed default date range to 'allTime' to display all mock data
  DateTime _startDate = FilterPeriod.allTime.startDate;
  DateTime _endDate = FilterPeriod.allTime.endDate;
  bool _isLoading = false;
  int _selectedTabIndex = 0; // 0 for quotes, 1 for invoices, 2 for credits

  List<Quote> get quotes => _quotes;
  List<Invoice> get invoices => _invoices;
  Quote? get selectedQuote => _selectedQuote;
  Invoice? get selectedInvoice => _selectedInvoice;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isLoading => _isLoading;
  int get selectedTabIndex => _selectedTabIndex;

  String get currentBranch => AuthService.currentAppUser?.branchCode ?? '';

  // Filtered lists
  List<Quote> get unconvertedQuotes => _quotes.where((q) => q.status == QuoteStatus.pending).toList();
  List<Quote> get convertedQuotes => _quotes.where((q) => q.status == QuoteStatus.converted).toList();
  List<Invoice> get unpaidInvoices => _invoices.where((i) => i.status != InvoiceStatus.paid && !i.isCredited).toList(); // Exclude credited
  List<Invoice> get paidInvoices => _invoices.where((i) => i.status == InvoiceStatus.paid && !i.isCredited).toList(); // Exclude credited
  List<Invoice> get creditedInvoices => _invoices.where((i) => i.isCredited).toList();

  QuotesInvoicesViewModel() {
    _loadData();
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    _selectedQuote = null;
    _selectedInvoice = null;
    notifyListeners();
  }

  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    _loadData();
    notifyListeners();
  }

  void selectQuote(Quote quote) {
    _selectedQuote = quote;
    _selectedInvoice = null;
    notifyListeners();
  }

  void selectInvoice(Invoice invoice) {
    _selectedInvoice = invoice;
    _selectedQuote = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedQuote = null;
    _selectedInvoice = null;
    notifyListeners();
  }

  Future<void> _loadData() async {
    if (AuthService.currentAppUser == null || AuthService.currentAppUser!.branchCode == null) {
      _quotes = [];
      _invoices = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final String branchCode = AuthService.currentAppUser!.branchCode!;
      _quotes = await _quotesInvoicesService.getQuotesByDateRange(
        branchCode,
        _startDate,
        _endDate,
      );

      _invoices = await _quotesInvoicesService.getInvoicesByDateRange(
        branchCode,
        _startDate,
        _endDate,
      );
    } catch (e) {
      print('Error loading quotes/invoices: $e');
      _quotes = []; // Clear on error
      _invoices = []; // Clear on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    _loadData();
  }

  // Statistics
  Map<String, dynamic> get quotesStats {
    final total = _quotes.length;
    final pending = _quotes.where((q) => q.status == QuoteStatus.pending).length;
    final converted = _quotes.where((q) => q.status == QuoteStatus.converted).length;
    final rejected = _quotes.where((q) => q.status == QuoteStatus.rejected).length;
    final totalValue = _quotes.fold(0.0, (sum, q) => sum + q.amount);

    return {
      'total': total,
      'pending': pending,
      'converted': converted,
      'rejected': rejected,
      'totalValue': totalValue,
      'conversionRate': total > 0 ? (converted / total * 100) : 0.0,
    };
  }

  Map<String, dynamic> get invoicesStats {
    final total = _invoices.length;
    final paid = _invoices.where((i) => i.status == InvoiceStatus.paid && !i.isCredited).length;
    final overdue = _invoices.where((i) => i.status == InvoiceStatus.overdue && !i.isCredited).length;
    final credited = _invoices.where((i) => i.isCredited).length;
    final totalValue = _invoices.where((i) => !i.isCredited).fold(0.0, (sum, i) => sum + i.totalAmount);
    final paidValue = _invoices.where((i) => i.status == InvoiceStatus.paid && !i.isCredited)
        .fold(0.0, (sum, i) => sum + i.totalAmount);

    return {
      'total': total,
      'paid': paid,
      'overdue': overdue,
      'credited': credited,
      'totalValue': totalValue,
      'paidValue': paidValue,
      'paymentRate': total > 0 ? (paid / total * 100) : 0.0,
    };
  }

  Map<String, dynamic> get creditStats {
    final totalCredited = _invoices.where((i) => i.isCredited).length;
    final totalCreditedValue = _invoices.where((i) => i.isCredited).fold(0.0, (sum, i) => sum + i.totalAmount);

    return {
      'totalCredited': totalCredited,
      'totalCreditedValue': totalCreditedValue,
    };
  }
}
