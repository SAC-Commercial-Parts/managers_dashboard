import 'package:flutter/material.dart';
import '../models/performance_data.dart'; // Contains FilterPeriod enum
import '../services/firestore_dashboard_service.dart'; // Import the new Firestore service
import '../services/auth_service.dart'; // Ensure this import is correct

class DashboardViewModel extends ChangeNotifier
{
  final FirestoreDashboardService _dashboardService = FirestoreDashboardService(); // Instantiate the new service

  // Changed default filter period to 'allTime' to display all mock data
  FilterPeriod _selectedPeriod = FilterPeriod.allTime;
  Map<String, double> _branchSummary = {};
  bool _isLoading = false;

  FilterPeriod get selectedPeriod => _selectedPeriod;
  Map<String, double> get branchSummary => _branchSummary;
  bool get isLoading => _isLoading;

  // Updated to use AuthService.currentAppUser and AppUser properties
  String get currentBranch => AuthService.currentAppUser?.branchCode ?? '';
  String get managerName => AuthService.currentAppUser?.displayName ?? AuthService.currentAppUser?.email ?? ''; // Use displayName, fallback to email

  DashboardViewModel()
  {
    // It's crucial that this ViewModel is only instantiated when a user is logged in.
    // The AuthWrapper ensures this.
    _loadBranchSummary();
  }

  void setPeriod(FilterPeriod period)
  {
    _selectedPeriod = period;
    _loadBranchSummary();
    notifyListeners();
  }

  Future<void> _loadBranchSummary() async // Made async
      {
    // Use AuthService.currentAppUser for the check
    if (AuthService.currentAppUser == null || AuthService.currentAppUser!.branchCode == null) {
      // This case should ideally not be hit if AuthWrapper is working correctly,
      // but it's a good defensive check.
      _branchSummary = {}; // Clear data if no user
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Access branchCode from AuthService.currentAppUser
      _branchSummary = await _dashboardService.getBranchSummary(
          AuthService.currentAppUser!.branchCode!, // Use null-assertion operator as we've checked for null above
          _selectedPeriod
      );
    } catch (e) {
      print('Error loading branch summary: $e');
      _branchSummary = {}; // Clear on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh()
  {
    _loadBranchSummary();
  }
}
