// - CREATED BY THATO MUSA 27/05/2025
/// ┌──────────────────────────────────────────────────────────────────────────┐
/// │                         UTILS FOR DATA SORTING                           │
/// └──────────────────────────────────────────────────────────────────────────┘
class DataUtils
{
  static List<String> sortBranches(Set<String> branchSet)
  {
    final branches = branchSet.toList();
    branches.sort((a, b) {
      if (a == 'All') return -1;
      if (b == 'All') return 1;

      final aInt = int.tryParse(a);
      final bInt = int.tryParse(b);

      if (aInt != null && bInt != null) {
        return aInt.compareTo(bInt);
      }

      return a.compareTo(b);
    });
    return branches;
  }
}