import 'package:flutter/material.dart';
import '../models/performance_data.dart'; // Import the new enum

////////////////////////////////////////////////////////////////////////////
//                            FILTER DROPDOWN                             //
////////////////////////////////////////////////////////////////////////////
class FilterDropdown extends StatelessWidget
{
  final FilterPeriod value;
  final ValueChanged<FilterPeriod?> onChanged;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  ////////////////////////////////////////////////////////////////////////////
  //                                UI OUTPUT                               //
  ////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context)
  {
    return DropdownButtonFormField<FilterPeriod>( // Changed type to FilterPeriod
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Filter Period',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: FilterPeriod.values.map((FilterPeriod period) { // Iterate over enum values
        return DropdownMenuItem<FilterPeriod>(
          value: period,
          child: Text(period.toDisplayString()), // Use the extension method
        );
      }).toList(),
    );
  }
}