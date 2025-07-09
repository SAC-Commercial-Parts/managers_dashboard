import '../models/quote.dart';
import '../models/invoice.dart';
import 'dart:math';

class QuotesInvoicesService {
  static final List<Quote> _quotes = _generateMockQuotes();
  static final List<Invoice> _invoices = _generateMockInvoices();

  static List<Quote> getQuotes() => _quotes;
  static List<Invoice> getInvoices() => _invoices;

  static List<Quote> getQuotesByBranch(String branchCode) {
    return _quotes.where((q) => q.branchCode == branchCode).toList();
  }

  static List<Invoice> getInvoicesByBranch(String branchCode) {
    return _invoices.where((i) => i.branchCode == branchCode).toList();
  }

  static List<Quote> getQuotesByDateRange(String branchCode, DateTime startDate, DateTime endDate) {
    return _quotes.where((q) =>
    q.branchCode == branchCode &&
        q.dateCreated.isAfter(startDate.subtract(const Duration(days: 1))) &&
        q.dateCreated.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  static List<Invoice> getInvoicesByDateRange(String branchCode, DateTime startDate, DateTime endDate) {
    return _invoices.where((i) =>
    i.branchCode == branchCode &&
        i.dateCreated.isAfter(startDate.subtract(const Duration(days: 1))) &&
        i.dateCreated.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  static Quote? getQuoteById(String id) {
    try {
      return _quotes.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  static Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Quote> _generateMockQuotes() {
    final random = Random();
    final quotes = <Quote>[];
    final branches = ['BR001', 'BR002'];
    const statuses = QuoteStatus.values;

    final clientNames = [
      'ABC Corporation', 'XYZ Ltd', 'Tech Solutions Inc', 'Global Enterprises',
      'Local Business Co', 'Premium Services', 'Quality Products Ltd', 'Fast Delivery Co'
    ];

    final products = [
      'Office Supplies Package', 'Computer Equipment', 'Furniture Set',
      'Cleaning Services', 'Security System', 'Marketing Materials',
      'Software License', 'Maintenance Contract'
    ];

    for (int i = 0; i < 50; i++) {
      final id = 'Q-${1000 + i}';
      final clientName = clientNames[random.nextInt(clientNames.length)];
      final clientEmail = '${clientName.replaceAll(' ', '').toLowerCase()}@example.com';
      final clientPhone = '555-${1000 + random.nextInt(9000)}';
      final employeeId = 'EMP-${100 + random.nextInt(50)}';
      final employeeName = 'Employee ${employeeId.split('-')[1]}';
      final branchCode = branches[random.nextInt(branches.length)];
      final dateCreated = DateTime.now().subtract(Duration(days: random.nextInt(365)));
      final status = statuses[random.nextInt(statuses.length)];
      final amount = (random.nextDouble() * 1000 + 50).toDouble();

      final items = List.generate(random.nextInt(3) + 1, (idx) {
        final description = products[random.nextInt(products.length)];
        final quantity = random.nextInt(5) + 1;
        final unitPrice = (random.nextDouble() * 100 + 10).toDouble();
        return QuoteItem(
          id: 'QI-${idx + 1}',
          description: description,
          quantity: quantity,
          unitPrice: unitPrice,
          total: quantity * unitPrice,
        );
      });

      quotes.add(
        Quote(
          id: id,
          clientName: clientName,
          clientEmail: clientEmail,
          clientPhone: clientPhone,
          employeeId: employeeId,
          employeeName: employeeName,
          branchCode: branchCode,
          dateCreated: dateCreated,
          dateConverted: status == QuoteStatus.converted ? dateCreated.add(Duration(days: random.nextInt(30))) : null,
          status: status,
          amount: amount,
          items: items,
          notes: random.nextBool() ? 'Some random notes for quote $id' : null,
        ),
      );
    }
    return quotes;
  }

  static List<Invoice> _generateMockInvoices() {
    final random = Random();
    final invoices = <Invoice>[];
    final branches = ['BR001', 'BR002'];
    const statuses = InvoiceStatus.values;

    final clientNames = [
      'ABC Corporation', 'XYZ Ltd', 'Tech Solutions Inc', 'Global Enterprises',
      'Local Business Co', 'Premium Services', 'Quality Products Ltd', 'Fast Delivery Co'
    ];

    final products = [
      'Office Supplies Package', 'Computer Equipment', 'Furniture Set',
      'Cleaning Services', 'Security System', 'Marketing Materials',
      'Software License', 'Maintenance Contract', 'Hardware Upgrade' // Added a new product for variety
    ];

    // --- Explicitly add some credited invoices ---
    // Example 1: A credited invoice from a month ago, fully returned
    invoices.add(
      Invoice(
        id: 'INV-CRD001',
        quoteId: 'Q-1005', // Assuming a linked quote exists
        clientName: 'Global Enterprises',
        clientEmail: 'global.enterprises@example.com',
        clientPhone: '555-9876',
        clientAddress: '456 Tech Lane, Metropoli, USA',
        employeeId: 'EMP-110',
        employeeName: 'Employee 110',
        branchCode: 'BR001',
        dateCreated: DateTime.now().subtract(const Duration(days: 45)),
        dueDate: DateTime.now().subtract(const Duration(days: 30)),
        datePaid: DateTime.now().subtract(const Duration(days: 40)), // Could have been paid, then credited
        status: InvoiceStatus.cancelled, // Credited invoices often marked as cancelled
        amount: 500.00,
        taxAmount: 75.00,
        totalAmount: 575.00,
        items: [
          InvoiceItem(id: 'IVI-CRD001-1', description: 'Faulty Computer Equipment', quantity: 1, unitPrice: 500.00, total: 500.00),
        ],
        notes: 'Full credit issued due to product malfunction.',
        paymentMethod: 'Credit Card',
        isCredited: true,
      ),
    );

    // Example 2: Another credited invoice, more recent
    invoices.add(
      Invoice(
        id: 'INV-CRD002',
        quoteId: 'Q-1020',
        clientName: 'XYZ Ltd',
        clientEmail: 'xyz.ltd@example.com',
        clientPhone: '555-1234',
        clientAddress: '789 Business Blvd, Cyberville, USA',
        employeeId: 'EMP-103',
        employeeName: 'Employee 103',
        branchCode: 'BR002',
        dateCreated: DateTime.now().subtract(const Duration(days: 10)),
        dueDate: DateTime.now().add(const Duration(days: 5)),
        datePaid: null, // Might not have been paid yet
        status: InvoiceStatus.cancelled,
        amount: 120.00,
        taxAmount: 18.00,
        totalAmount: 138.00,
        items: [
          InvoiceItem(id: 'IVI-CRD002-1', description: 'Incorrect Marketing Materials', quantity: 10, unitPrice: 12.00, total: 120.00),
        ],
        notes: 'Partial order return, incorrect items sent.',
        paymentMethod: null,
        isCredited: true,
      ),
    );

    // Example 3: A paid invoice that was later credited
    invoices.add(
      Invoice(
        id: 'INV-CRD003',
        quoteId: 'Q-1033',
        clientName: 'ABC Corporation',
        clientEmail: 'abc.corporation@example.com',
        clientPhone: '555-2233',
        clientAddress: '123 Main St, Anytown, USA',
        employeeId: 'EMP-107',
        employeeName: 'Employee 107',
        branchCode: 'BR001',
        dateCreated: DateTime.now().subtract(const Duration(days: 90)),
        dueDate: DateTime.now().subtract(const Duration(days: 60)),
        datePaid: DateTime.now().subtract(const Duration(days: 70)),
        status: InvoiceStatus.cancelled, // Changed from paid to cancelled due to credit
        amount: 80.00,
        taxAmount: 12.00,
        totalAmount: 92.00,
        items: [
          InvoiceItem(id: 'IVI-CRD003-1', description: 'Overcharge on Cleaning Services', quantity: 1, unitPrice: 80.00, total: 80.00),
        ],
        notes: 'Customer dispute resolved, credit issued for overcharged service.',
        paymentMethod: 'Bank Transfer',
        isCredited: true,
      ),
    );

    // --- Generate regular invoices (with a random chance of being credited) ---
    for (int i = 0; i < 70; i++) { // Generate 70 more invoices
      final id = 'INV-${2000 + i + 3}'; // Adjust ID to avoid collision with explicit ones
      final quoteId = 'Q-${1000 + random.nextInt(50)}';
      final clientName = clientNames[random.nextInt(clientNames.length)];
      final clientEmail = '${clientName.replaceAll(' ', '').toLowerCase()}@example.com';
      final clientPhone = '555-${1000 + random.nextInt(9000)}';
      final clientAddress = '${random.nextInt(100)} Main St, Anytown, USA';
      final employeeId = 'EMP-${100 + random.nextInt(50)}';
      final employeeName = 'Employee ${employeeId.split('-')[1]}';
      final branchCode = branches[random.nextInt(branches.length)];
      final dateCreated = DateTime.now().subtract(Duration(days: random.nextInt(365)));
      final dueDate = dateCreated.add(Duration(days: random.nextInt(30) + 7));
      final status = statuses[random.nextInt(statuses.length)];
      final amount = (random.nextDouble() * 1500 + 100).toDouble();
      final taxAmount = amount * 0.15; // 15% tax
      final totalAmount = amount + taxAmount;
      final datePaid = status == InvoiceStatus.paid ? dateCreated.add(Duration(days: random.nextInt(dueDate.difference(dateCreated).inDays.abs()))) : null;

      final items = List.generate(random.nextInt(4) + 1, (idx) {
        final description = products[random.nextInt(products.length)];
        final quantity = random.nextInt(7) + 1;
        final unitPrice = (random.nextDouble() * 150 + 15).toDouble();
        return InvoiceItem(
          id: 'IVI-$id-${idx + 1}',
          description: description,
          quantity: quantity,
          unitPrice: unitPrice,
          total: quantity * unitPrice,
        );
      });

      // Randomly assign `isCredited` for these generated invoices
      final bool isCredited = random.nextDouble() < 0.10; // 10% chance of being credited for these
      final InvoiceStatus finalStatus = isCredited ? InvoiceStatus.cancelled : status; // If credited, mark as cancelled

      invoices.add(
        Invoice(
          id: id,
          quoteId: quoteId,
          clientName: clientName,
          clientEmail: clientEmail,
          clientPhone: clientPhone,
          clientAddress: clientAddress,
          employeeId: employeeId,
          employeeName: employeeName,
          branchCode: branchCode,
          dateCreated: dateCreated,
          dueDate: dueDate,
          datePaid: datePaid,
          status: finalStatus,
          amount: amount,
          taxAmount: taxAmount,
          totalAmount: totalAmount,
          items: items,
          notes: random.nextBool() ? 'Some random notes for invoice $id' : null,
          paymentMethod: random.nextBool() ? 'Bank Transfer' : 'Credit Card',
          isCredited: isCredited,
        ),
      );
    }
    return invoices;
  }
}