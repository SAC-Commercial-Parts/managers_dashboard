// lib/utils/data_helpers.dart

class DataHelpers
{
  /// Checks if the given email address belongs to the 'sactrucks.co.za' domain.
  /// Returns true if it does, false otherwise.
  static bool isSactrucksEmail(String email)
  {
    // Convert email to lowercase to ensure case-insensitive comparison
    return email.toLowerCase().endsWith('@sactrucks.co.za');
  }

  /// Formats a role string to begin with a capital letter and replace underscores with spaces.
  /// Example: "rep_admin" -> "Rep Admin", "employee" -> "Employee"
  static String formatRole(String role)
  {
    if (role.isEmpty) {
      return '';
    }
    // Replace underscores with spaces
    String formatted = role.replaceAll('_', ' ');
    // Capitalize the first letter of each word
    return formatted.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}