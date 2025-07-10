// lib/views/quotes_invoices_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/quote.dart';
import '../models/invoice.dart';
import '../viewmodels/quotes_invoices_viewmodel.dart';
import '../widgets/quote_detail_view.dart';
import '../widgets/invoice_detail_view.dart';
import '../widgets/date_range_picker.dart';

class QuotesInvoicesView extends StatelessWidget {
  static const id = '/quotes_and_invoices';
  const QuotesInvoicesView({super.key});

  ////////////////////////////////////////////////////////////////////////////
  //                                UI OUTPUT                               //
  ////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context)
  {
    return Consumer<QuotesInvoicesViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ////////////////////////////////////////////////////////////////////////////
              //                              HEADER SECTION                            //
              ////////////////////////////////////////////////////////////////////////////
              _buildHeaderSection(context, viewModel),
              const SizedBox(height: 24),

              ////////////////////////////////////////////////////////////////////////////
              //                            STATS CARD SECTION                          //
              ////////////////////////////////////////////////////////////////////////////
              _buildStatsSection(viewModel),
              const SizedBox(height: 24),

              ////////////////////////////////////////////////////////////////////////////
              //                                MAIN DATA                               //
              ////////////////////////////////////////////////////////////////////////////
              if (viewModel.isLoading)
                // LOADING INDICATOR
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
              ////////////////////////////////////////////////////////////////////////////
              //                       QUOTES/INVOICE/CREDITS LIST                      //
              ////////////////////////////////////////////////////////////////////////////
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildListSection(viewModel),
                      ),
                      if (viewModel.selectedQuote != null || viewModel.selectedInvoice != null) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildDetailSection(viewModel),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             HEADER SECTION                             //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildHeaderSection(BuildContext context, QuotesInvoicesViewModel viewModel)
  {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // TITLE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quotes & Invoices',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Branch ${viewModel.currentBranch}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // RANGE PICKER
                DateRangePicker(
                  startDate: viewModel.startDate,
                  endDate: viewModel.endDate,
                  onDateRangeChanged: viewModel.setDateRange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // TAB SECTION
            Row(
              children: [
                // QUOTES
                _buildTabButton(
                  'Quotes',
                  Icons.description,
                  0,
                  viewModel.selectedTabIndex == 0,
                      () => viewModel.setTabIndex(0),
                ),
                const SizedBox(width: 12),

                // INVOICES
                _buildTabButton(
                  'Invoices',
                  Icons.receipt,
                  1,
                  viewModel.selectedTabIndex == 1,
                      () => viewModel.setTabIndex(1),
                ),
                const SizedBox(width: 12),

                // CREDITS
                _buildTabButton(
                  'Credits',
                  Icons.assignment_return,
                  2,
                  viewModel.selectedTabIndex == 2,
                      () => viewModel.setTabIndex(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                TAB BUTTON                              //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildTabButton(String title, IconData icon, int index, bool isSelected, VoidCallback onTap)
  {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRed : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.darkGray,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.darkGray,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             STATS SECTION                              //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildStatsSection(QuotesInvoicesViewModel viewModel)
  {
    if (viewModel.selectedTabIndex == 0) {
      final stats = viewModel.quotesStats;
      ////////////////////////////////////////////////////////////////////////////
      //                                  QUOTES                                //
      ////////////////////////////////////////////////////////////////////////////
      return Row(
        children: [

          // TOTAL QUOTES
          Expanded(
            child: _buildStatCard(
              'Total Quotes',
              stats['total'].toString(),
              Icons.description,
              AppTheme.primaryRed,
            ),
          ),
          const SizedBox(width: 16),

          // PENDING QUOTES
          Expanded(
            child: _buildStatCard(
              'Pending',
              stats['pending'].toString(),
              Icons.pending,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 16),

          // CONVERTED QUOTES
          Expanded(
            child: _buildStatCard(
              'Converted',
              stats['converted'].toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),

          // CONVERSION RATE
          Expanded(
            child: _buildStatCard(
              'Conversion Rate',
              '${stats['conversionRate'].toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.blue,
            ),
          ),

        ],
      );
    } else if (viewModel.selectedTabIndex == 1) {
      final stats = viewModel.invoicesStats;

      ////////////////////////////////////////////////////////////////////////////
      //                                INVOICES                                //
      ////////////////////////////////////////////////////////////////////////////
      return Row(
        children: [
          // INVOICES
          Expanded(
            child: _buildStatCard(
              'Total Invoices',
              stats['total'].toString(),
              Icons.receipt,
              AppTheme.primaryRed,
            ),
          ),
          const SizedBox(width: 16),

          // PAID INVOICES
          Expanded(
            child: _buildStatCard(
              'Paid',
              stats['paid'].toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),

          // OVERDUE PAYMENTS
          Expanded(
            child: _buildStatCard(
              'Overdue',
              stats['overdue'].toString(),
              Icons.warning,
              Colors.red,
            ),
          ),
          const SizedBox(width: 16),

          // PAYMENT RATE
          Expanded(
            child: _buildStatCard(
              'Payment Rate',
              '${stats['paymentRate'].toStringAsFixed(1)}%',
              Icons.payment,
              Colors.blue,
            ),
          ),
        ],
      );
    } else { // selectedTabIndex == 2 for Credits
      final stats = viewModel.creditStats;

      ////////////////////////////////////////////////////////////////////////////
      //                                  CREDITS                               //
      ////////////////////////////////////////////////////////////////////////////
      return Row(
        children: [

          // CREDITS
          Expanded(
            child: _buildStatCard(
              'Total Credits',
              stats['totalCredited'].toString(),
              Icons.assignment_return,
              AppTheme.primaryRed,
            ),
          ),
          const SizedBox(width: 16),

          // CREDIT VALUE
          Expanded(
            child: _buildStatCard(
              'Total Credited Value',
              '\$${stats['totalCreditedValue'].toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.purple,
            ),
          ),

          const Expanded(child: SizedBox.shrink()), // Fill remaining space
          const Expanded(child: SizedBox.shrink()), // Fill remaining space
        ],
      );
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                STATS CARD                              //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildStatCard(String title, String value, IconData icon, Color color)
  {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(60),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                              LIST SECTION                              //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildListSection(QuotesInvoicesViewModel viewModel)
  {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  viewModel.selectedTabIndex == 0
                      ? Icons.description
                      : viewModel.selectedTabIndex == 1
                      ? Icons.receipt
                      : Icons.assignment_return, // <--- ADD THIS
                  color: AppTheme.primaryRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                // TITLE
                Text(
                  viewModel.selectedTabIndex == 0
                      ? 'Quotes'
                      : viewModel.selectedTabIndex == 1
                      ? 'Invoices'
                      : 'Credits', // <--- ADD THIS
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // LIST
          Expanded(
            child: Builder(
              builder: (context) {
                if (viewModel.selectedTabIndex == 0) {
                  return _buildQuotesList(viewModel);
                } else if (viewModel.selectedTabIndex == 1) {
                  return _buildInvoicesList(viewModel);
                } else {
                  return _buildCreditedInvoicesList(viewModel); // <--- ADD THIS
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                              QUOTES LIST                               //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildQuotesList(QuotesInvoicesViewModel viewModel)
  {
    if (viewModel.quotes.isEmpty) {
      return _buildEmptyState('No quotes found', Icons.description);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: viewModel.quotes.length,
      itemBuilder: (context, index) {
        final quote = viewModel.quotes[index];
        return _buildQuoteListItem(quote, viewModel);
      },
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             INVOICE LIST                               //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildInvoicesList(QuotesInvoicesViewModel viewModel)
  {
    if (viewModel.invoices.isEmpty) {
      return _buildEmptyState('No invoices found', Icons.receipt);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: viewModel.invoices.length,
      itemBuilder: (context, index) {
        final invoice = viewModel.invoices[index];
        return _buildInvoiceListItem(invoice, viewModel);
      },
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             CREDITS LIST                               //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildCreditedInvoicesList(QuotesInvoicesViewModel viewModel)
  {
    final creditedInvoices = viewModel.creditedInvoices;
    if (creditedInvoices.isEmpty) {
      return _buildEmptyState('No credited invoices found', Icons.assignment_return);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: creditedInvoices.length,
      itemBuilder: (context, index) {
        final invoice = creditedInvoices[index];
        return _buildInvoiceListItem(invoice, viewModel, isCredit: true); // Pass isCredit flag
      },
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                            QUOTE LIST ITEM                             //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildQuoteListItem(Quote quote, QuotesInvoicesViewModel viewModel)
  {
    final isSelected = viewModel.selectedQuote?.id == quote.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getQuoteStatusColor(quote.status).withAlpha(60),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.description,
            color: _getQuoteStatusColor(quote.status),
            size: 20,
          ),
        ),
        title: Text(
          quote.clientName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quote #${quote.id}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              DateFormat('MMM dd, yyyy').format(quote.dateCreated),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${quote.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getQuoteStatusColor(quote.status).withAlpha(60),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getQuoteStatusText(quote.status),
                style: TextStyle(
                  fontSize: 10,
                  color: _getQuoteStatusColor(quote.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryRed.withAlpha(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => viewModel.selectQuote(quote),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                           INVOICE LIST ITEM                            //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildInvoiceListItem(Invoice invoice, QuotesInvoicesViewModel viewModel, {bool isCredit = false})
  {
    final isSelected = viewModel.selectedInvoice?.id == invoice.id;

    Color statusColor = isCredit ? Colors.purple : _getInvoiceStatusColor(invoice.status); // <--- Conditional color
    String statusText = isCredit ? 'Credited' : _getInvoiceStatusText(invoice.status); // <--- Conditional text
    IconData leadingIcon = isCredit ? Icons.assignment_return : Icons.receipt; // <--- Conditional icon

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(60), // Use statusColor
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            leadingIcon, // Use leadingIcon
            color: statusColor, // Use statusColor
            size: 20,
          ),
        ),
        title: Text(
          invoice.clientName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice #${invoice.id}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              DateFormat('MMM dd, yyyy').format(invoice.dateCreated),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${invoice.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(60), // Use statusColor
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusText, // Use statusText
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor, // Use statusColor
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryRed.withAlpha(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => viewModel.selectInvoice(invoice),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                            DETAILS SECTION                             //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildDetailSection(QuotesInvoicesViewModel viewModel)
  {
    if (viewModel.selectedQuote != null) {
      return QuoteDetailView(quote: viewModel.selectedQuote!);
    } else if (viewModel.selectedInvoice != null) {
      // You might want to pass a flag to InvoiceDetailView if it needs to display
      // "Credited" differently, or if there's a separate CreditDetailView.
      return InvoiceDetailView(invoice: viewModel.selectedInvoice!);
    }
    return const SizedBox.shrink();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                EMPTY STATE                             //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildEmptyState(String message, IconData icon)
  {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             QUOTE STATUS COLOR                         //
  ////////////////////////////////////////////////////////////////////////////
  Color _getQuoteStatusColor(QuoteStatus status)
  {
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

  ////////////////////////////////////////////////////////////////////////////
  //                              QUOTE STATUS TEXT                         //
  ////////////////////////////////////////////////////////////////////////////
  String _getQuoteStatusText(QuoteStatus status)
  {
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

  ////////////////////////////////////////////////////////////////////////////
  //                            INVOICE STATUS COLOR                        //
  ////////////////////////////////////////////////////////////////////////////
  Color _getInvoiceStatusColor(InvoiceStatus status)
  {
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
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             INVOICE STATUS TEXT                        //
  ////////////////////////////////////////////////////////////////////////////
  String _getInvoiceStatusText(InvoiceStatus status)
  {
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
    }
  }
}