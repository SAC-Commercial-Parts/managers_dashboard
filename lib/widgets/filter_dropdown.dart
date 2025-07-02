import 'package:flutter/material.dart';
import '../models/performance_data.dart';

class FilterDropdown extends StatelessWidget {
  final FilterPeriod value;
  final Function(FilterPeriod) onChanged;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FilterPeriod>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Period',
        border: OutlineInputBorder(),
      ),
      items: FilterPeriod.values.map((period) {
        return DropdownMenuItem(
          value: period,
          child: Text(period.displayName),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}