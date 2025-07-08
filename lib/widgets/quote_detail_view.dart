import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/quote.dart';

class QuoteDetailView extends StatelessWidget {
  final Quote quote;

  const QuoteDetailView({
    super.key,
    required this.quote,
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

            // Quote Details
            _buildQuoteDetails(),
            const SizedBox(height: 24),

            // Items
            _buildItemsList(),
            const SizedBox(height: 24),

            // Total
            _buildTotal(),

            // Notes
            if (quote.notes != null && quote.notes!.isNotEmpty) ...[ // Check if notes is not null and not empty
              const SizedBox(height: 24),
              _buildNotes(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(quote.status).withAlpha(60),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.description,
            color: _getStatusColor(quote.status),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quote #${quote.id}',
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
                  color: _getStatusColor(quote.status).withAlpha(60),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(quote.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(quote.status),
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
            'Client Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.business, 'Company', quote.clientName),
          if (quote.clientEmail != null && quote.clientEmail!.isNotEmpty) // Conditionally show
            _buildInfoRow(Icons.email, 'Email', quote.clientEmail!),
          if (quote.clientPhone != null && quote.clientPhone!.isNotEmpty) // Conditionally show
            _buildInfoRow(Icons.phone, 'Phone', quote.clientPhone!),
        ],
      ),
    );
  }

  Widget _buildQuoteDetails() {
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
            'Quote Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Created',
              DateFormat('MMM dd, yyyy').format(quote.dateCreated)),
          if (quote.employeeName != null && quote.employeeName!.isNotEmpty) // Conditionally show
            _buildInfoRow(Icons.person, 'Sales Rep', quote.employeeName!),
          if (quote.branchCode != null && quote.branchCode!.isNotEmpty) // Conditionally show
            _buildInfoRow(Icons.location_on, 'Branch', quote.branchCode!),
          if (quote.dateConverted != null)
            _buildInfoRow(Icons.check_circle, 'Converted',
                DateFormat('MMM dd, yyyy').format(quote.dateConverted!)),
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
                    // Removed 'Total' column as it's not in the QuoteItem model now
                  ],
                ),
              ),
              // Items
              ...quote.items.asMap().entries.map((entry) {
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
      child: Row(
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
            '\$${quote.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
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
            quote.notes!, // Already checked for null in build method
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

  Color _getStatusColor(QuoteStatus status) {
    switch (status) {
      case QuoteStatus.pending:
        return Colors.orange;
      case QuoteStatus.converted:
        return Colors.green;
      case QuoteStatus.rejected:
        return Colors.red;
      case QuoteStatus.expired:
        return Colors.grey;
    }
  }

  String _getStatusText(QuoteStatus status) {
    switch (status) {
      case QuoteStatus.pending:
        return 'Pending';
      case QuoteStatus.converted:
        return 'Converted';
      case QuoteStatus.rejected:
        return 'Rejected';
      case QuoteStatus.expired:
        return 'Expired';
    }
  }
}
