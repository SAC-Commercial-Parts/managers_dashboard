import 'package:flutter/material.dart';
import '../models/performance_data.dart';
import '../services/mock_data_service.dart';
import '../services/auth_service.dart';

class DashboardViewModel extends ChangeNotifier
{
  FilterPeriod _selectedPeriod = FilterPeriod.thisMonth;
  Map<String, double> _branchSummary = {};
  bool _isLoading = false;

  FilterPeriod get selectedPeriod => _selectedPeriod;
  Map<String, double> get branchSummary => _branchSummary;
  bool get isLoading => _isLoading;

  String get currentBranch => AuthService.currentUser?.branchCode ?? '';
  String get managerName => AuthService.currentUser?.name ?? '';

  DashboardViewModel()
  {
    _loadBranchSummary();
  }

  void setPeriod(FilterPeriod period)
  {
    _selectedPeriod = period;
    _loadBranchSummary();
    notifyListeners();
  }

  void _loadBranchSummary()
  {
    if (AuthService.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _branchSummary = MockDataService.getBranchSummary(
          AuthService.currentUser!.branchCode,
          _selectedPeriod
      );
      _isLoading = false;
      notifyListeners();
    });
  }

  void refresh()
  {
    _loadBranchSummary();
  }
}