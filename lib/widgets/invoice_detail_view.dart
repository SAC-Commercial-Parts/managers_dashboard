import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/invoice.dart';

class InvoiceDetailView extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailView({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Client Information
            _buildClientInfo(),
            const SizedBox(height: 24),

            // Invoice Details
            _buildInvoiceDetails(),
            const SizedBox(height: 24),

            // Items
            _buildItemsList(),
            const SizedBox(height: 24),

            // Total
            _buildTotal(),

            // Notes
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[ // Check if notes is not null and not empty
              const SizedBox(height: 24),
              _buildNotes(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Determine status color and text, considering if it's a credited invoice
    Color displayStatusColor = invoice.isCredited ? Colors.purple : _getStatusColor(invoice.status);
    String displayStatusText = invoice.isCredited ? 'Credited' : _getStatusText(invoice.status);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: displayStatusColor.withAlpha(60),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            invoice.isCredited ? Icons.assignment_return : Icons.receipt, // Icon for credited
            color: displayStatusColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice #${invoice.id}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: displayStatusColor.withAlpha(60),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: displayStatusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill To',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.business, 'Company', invoice.clientName),
          if (invoice.clientEmail != null && invoice.clientEmail!.isNotEmpty)
            _buildInfoRow(Icons.email, 'Email', invoice.clientEmail!),
          if (invoice.clientPhone != null && invoice.clientPhone!.isNotEmpty)
            _buildInfoRow(Icons.phone, 'Phone', invoice.clientPhone!),
          if (invoice.clientAddress != null && invoice.clientAddress!.isNotEmpty)
            _buildInfoRow(Icons.location_on, 'Address', invoice.clientAddress!),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          if (invoice.quoteId != null && invoice.quoteId!.isNotEmpty)
            _buildInfoRow(Icons.description, 'Quote ID', invoice.quoteId!),
          _buildInfoRow(Icons.calendar_today, 'Invoice Date',
              DateFormat('MMM dd, yyyy').format(invoice.dateCreated)),
          _buildInfoRow(Icons.schedule, 'Due Date',
              DateFormat('MMM dd, yyyy').format(invoice.dueDate)),
          if (invoice.employeeName != null && invoice.employeeName!.isNotEmpty)
            _buildInfoRow(Icons.person, 'Sales Rep', invoice.employeeName!),
          if (invoice.branchCode != null && invoice.branchCode!.isNotEmpty)
            _buildInfoRow(Icons.location_on, 'Branch', invoice.branchCode!),
          if (invoice.datePaid != null)
            _buildInfoRow(Icons.check_circle, 'Paid Date',
                DateFormat('MMM dd, yyyy').format(invoice.datePaid!)),
          if (invoice.paymentMethod != null && invoice.paymentMethod!.isNotEmpty)
            _buildInfoRow(Icons.payment, 'Payment Method', invoice.paymentMethod!),
          if (invoice.isCredited) // Show credit note ID if invoice is credited
            _buildInfoRow(Icons.assignment_return, 'Credit Note ID', invoice.creditNoteId ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Description', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                    // Removed 'Total' column as it's not in the InvoiceItem model now
                  ],
                ),
              ),
              // Items
              ...invoice.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: index > 0 ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(item.description)),
                      Expanded(flex: 1, child: Text('${item.quantity}', textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('\$${item.unitPrice.toStringAsFixed(2)}', textAlign: TextAlign.right)),
                      // Removed 'Total' cell
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withAlpha(32),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryRed.withAlpha(64)),
      ),
      child: Column(
        children: [
          // Subtotal and Tax are now optional as 'amount' and 'taxAmount' are nullable
          if (invoice.amount != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                Text('\$${invoice.amount!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (invoice.taxAmount != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax:', style: TextStyle(fontSize: 16)),
                Text('\$${invoice.taxAmount!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              Text(
                '\$${invoice.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            invoice.notes!, // Already checked for null in build method
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.grey;
      case InvoiceStatus.pending:
        return Colors.orange; // Color for pending status
    }
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.pending:
        return 'Pending'; // Text for pending status
    }
  }
}
