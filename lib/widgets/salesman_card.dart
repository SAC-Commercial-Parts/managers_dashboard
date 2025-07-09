// lib/widgets/salesman_card.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/rep.dart'; // Salesmen are also Rep objects

class SalesmanCard extends StatelessWidget {
  final Rep salesman; // Using Rep model for salesman
  final bool isSelected;
  final VoidCallback onTap;

  const SalesmanCard({
    super.key,
    required this.salesman,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      color: isSelected ? AppTheme.primaryRed.withAlpha(56) : Theme.of(context).cardColor,
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryRed : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryRed.withAlpha(64),
                child: Text(
                  salesman.name.isNotEmpty ? salesman.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppTheme.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${salesman.name} ${salesman.surname}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Salesman Code: ${salesman.repCode ?? 'N/A'}', // Using repCode as salesman code
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Calls: ${salesman.totalCalls}', // Assuming total_calls is relevant for salesmen
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  // You might want to add other relevant metrics for salesmen here
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}