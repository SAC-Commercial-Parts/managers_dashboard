// lib/viewmodels/quotes_invoices_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../models/invoice.dart';
import '../services/quotes_invoice_service.dart';
import '../services/auth_service.dart';

////////////////////////////////////////////////////////////////////////////
//                       QUOTES/INVOICE VIEWMODEL                         //
////////////////////////////////////////////////////////////////////////////
class QuotesInvoicesViewModel extends ChangeNotifier
{
  final AuthService _authService;

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

  String? _userBranch; // Private variable to store fetched branch

  String get currentBranch => _userBranch ?? '';


  // Filtered lists
  List<Quote> get unconvertedQuotes => _quotes.where((q) => q.status == QuoteStatus.pending).toList();
  List<Quote> get convertedQuotes => _quotes.where((q) => q.status == QuoteStatus.converted).toList();
  List<Invoice> get unpaidInvoices => _invoices.where((i) => i.status != InvoiceStatus.paid).toList();
  List<Invoice> get paidInvoices => _invoices.where((i) => i.status == InvoiceStatus.paid).toList();
  List<Invoice> get creditedInvoices => _invoices.where((i) => i.isCredited).toList();

  ////////////////////////////////////////////////////////////////////////////
  //                                CONSTRUCTOR                             //
  ////////////////////////////////////////////////////////////////////////////
  QuotesInvoicesViewModel(this._authService)
  {
    _loadInitialData(); // Call a new method to load initial data including user details
  }

  ////////////////////////////////////////////////////////////////////////////
  //                               INITIAL DATA                             //
  ////////////////////////////////////////////////////////////////////////////
  void _loadInitialData() async
  {
    // Fetch the user's branch initially
    if (_authService.currentUser != null) {
      _userBranch = await _authService.getUserBranch();
      notifyListeners();
    }
    _loadData();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                TAB INDEX                               //
  ////////////////////////////////////////////////////////////////////////////
  void setTabIndex(int index)
  {
    _selectedTabIndex = index;
    _selectedQuote = null;
    _selectedInvoice = null;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                            DATE RANGE FILTER                           //
  ////////////////////////////////////////////////////////////////////////////
  void setDateRange(DateTime start, DateTime end)
  {
    _startDate = start;
    _endDate = end;
    _loadData();
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                           SHOWING QUOTE DETAIL                         //
  ////////////////////////////////////////////////////////////////////////////
  void selectQuote(Quote quote)
  {
    _selectedQuote = quote;
    _selectedInvoice = null;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                           SHOWING INVOICE DATA                         //
  ////////////////////////////////////////////////////////////////////////////
  void selectInvoice(Invoice invoice)
  {
    _selectedInvoice = invoice;
    _selectedQuote = null;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                  CLEAR                                 //
  ////////////////////////////////////////////////////////////////////////////
  void clearSelection()
  {
    _selectedQuote = null;
    _selectedInvoice = null;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                LOAD DATA                               //
  ////////////////////////////////////////////////////////////////////////////
  void _loadData() async
  {
    if (_authService.currentUser == null) {
      _quotes = [];
      _invoices = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    // Ensure _userBranch is available before proceeding
    if (_userBranch == null) {
      _userBranch = await _authService.getUserBranch();
      if (_userBranch == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
    }


    Future.delayed(const Duration(milliseconds: 300), () {
      _quotes = QuotesInvoicesService.getQuotesByDateRange(
        _userBranch!, // Use the fetched branch
        _startDate,
        _endDate,
      );

      _invoices = QuotesInvoicesService.getInvoicesByDateRange(
        _userBranch!, // Use the fetched branch
        _startDate,
        _endDate,
      );

      _isLoading = false;
      notifyListeners();
    });
  }
  void refresh()
  {
    _loadData();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                               STATISTICS                               //
  ////////////////////////////////////////////////////////////////////////////
  Map<String, dynamic> get quotesStats
  {
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
  Map<String, dynamic> get invoicesStats
  {
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
  Map<String, dynamic> get creditStats
  {
    final totalCredited = _invoices.where((i) => i.isCredited).length;
    final totalCreditedValue = _invoices.where((i) => i.isCredited).fold(0.0, (sum, i) => sum + i.totalAmount);

    return {
      'totalCredited': totalCredited,
      'totalCreditedValue': totalCreditedValue,
    };
  }
}