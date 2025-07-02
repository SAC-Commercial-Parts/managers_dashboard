// lib/viewmodels/quotes_invoices_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../models/invoice.dart';
import '../services/quotes_invoice_service.dart';
import '../services/auth_service.dart';

class QuotesInvoicesViewModel extends ChangeNotifier {
  List<Quote> _quotes = [];
  List<Invoice> _invoices = [];
  Quote? _selectedQuote;
  Invoice? _selectedInvoice;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
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

  String get currentBranch => AuthService.currentUser?.branchCode ?? '';

  // Filtered lists
  List<Quote> get unconvertedQuotes => _quotes.where((q) => q.status == QuoteStatus.pending).toList();
  List<Quote> get convertedQuotes => _quotes.where((q) => q.status == QuoteStatus.converted).toList();
  List<Invoice> get unpaidInvoices => _invoices.where((i) => i.status != InvoiceStatus.paid).toList();
  List<Invoice> get paidInvoices => _invoices.where((i) => i.status == InvoiceStatus.paid).toList();
  List<Invoice> get creditedInvoices => _invoices.where((i) => i.isCredited).toList(); // <--- ADD THIS

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

  void _loadData() {
    if (AuthService.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      _quotes = QuotesInvoicesService.getQuotesByDateRange(
        AuthService.currentUser!.branchCode,
        _startDate,
        _endDate,
      );

      _invoices = QuotesInvoicesService.getInvoicesByDateRange(
        AuthService.currentUser!.branchCode,
        _startDate,
        _endDate,
      );

      _isLoading = false;
      notifyListeners();
    });
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
    final paid = _invoices.where((i) => i.status == InvoiceStatus.paid && !i.isCredited).length; // <--- Exclude credited
    final overdue = _invoices.where((i) => i.status == InvoiceStatus.overdue && !i.isCredited).length; // <--- Exclude credited
    final credited = _invoices.where((i) => i.isCredited).length; // <--- ADD THIS
    final totalValue = _invoices.where((i) => !i.isCredited).fold(0.0, (sum, i) => sum + i.totalAmount); // <--- Exclude credited
    final paidValue = _invoices.where((i) => i.status == InvoiceStatus.paid && !i.isCredited)
        .fold(0.0, (sum, i) => sum + i.totalAmount);

    return {
      'total': total,
      'paid': paid,
      'overdue': overdue,
      'credited': credited, // <--- ADD THIS
      'totalValue': totalValue,
      'paidValue': paidValue,
      'paymentRate': total > 0 ? (paid / total * 100) : 0.0,
    };
  }

  // New getter for Credit stats (if needed, otherwise invoicesStats can be adapted)
  Map<String, dynamic> get creditStats {
    final totalCredited = _invoices.where((i) => i.isCredited).length;
    final totalCreditedValue = _invoices.where((i) => i.isCredited).fold(0.0, (sum, i) => sum + i.totalAmount);

    return {
      'totalCredited': totalCredited,
      'totalCreditedValue': totalCreditedValue,
    };
  }
}