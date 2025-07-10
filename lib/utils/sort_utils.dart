// CREATED BY THATO MUSA 27/05/2025

import 'package:cloud_firestore/cloud_firestore.dart';

/// ┌──────────────────────────────────────────────────────────────────────────┐
/// │                             TABLE DATA SORT                              │
/// └──────────────────────────────────────────────────────────────────────────┘
class SortUtils
{
  static void sortData
      (
      {
        required List<QueryDocumentSnapshot> data,
        required int columnIndex,
        required bool ascending,
      }
      )

  /// ┌──────────────────────────────────────────────────────────────────────────┐
  /// │                              SORTING CASES                               │
  /// └──────────────────────────────────────────────────────────────────────────┘
  {
    data.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      dynamic aValue;
      dynamic bValue;

      switch (columnIndex) {
        case 0:
          aValue = '${aData['name'] ?? ''} ${aData['surname'] ?? ''}';
          bValue = '${bData['name'] ?? ''} ${bData['surname'] ?? ''}';
          break;
        case 1:
          aValue = aData['user_email'] ?? '';
          bValue = bData['user_email'] ?? '';
          break;
        case 2:
          aValue = aData['branch'] ?? '';
          bValue = bData['branch'] ?? '';
          break;
        case 3:
          aValue = aData['role'] ?? '';
          bValue = bData['role'] ?? '';
          break;
        case 4:
          aValue = aData['total_calls'] ?? 0;
          bValue = bData['total_calls'] ?? 0;
          break;
        case 5:
          aValue = aData['total_new_client_request'] ?? 0;
          bValue = bData['total_new_client_request'] ?? 0;
          break;
        case 6:
          aValue = aData['total_visits'] ?? 0;
          bValue = bData['total_visits'] ?? 0;
          break;
        default:
          return 0;
      }

      if (aValue is int && bValue is int) {
        return ascending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else {
        return ascending
            ? aValue.toString().compareTo(bValue.toString())
            : bValue.toString().compareTo(aValue.toString());
      }
    });
  }
}