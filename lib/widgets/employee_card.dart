import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/employee.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isSelected;
  final VoidCallback onTap;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(employee.type),
          child: Icon(
            _getTypeIcon(employee.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          employee.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${_getTypeString(employee.type)} • ${employee.branchCode}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryRed.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getTypeColor(EmployeeType type) {
    switch (type) {
      case EmployeeType.driver:
        return AppTheme.primaryRed;
      case EmployeeType.rep:
        return Colors.blue;
      case EmployeeType.salesman:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(EmployeeType type) {
    switch (type) {
      case EmployeeType.driver:
        return Icons.local_shipping;
      case EmployeeType.rep:
        return Icons.business;
      case EmployeeType.salesman:
        return Icons.person;
    }
  }

  String _getTypeString(EmployeeType type) {
    switch (type) {
      case EmployeeType.driver:
        return 'Driver';
      case EmployeeType.rep:
        return 'Sales Rep';
      case EmployeeType.salesman:
        return 'Salesman';
    }
  }
}