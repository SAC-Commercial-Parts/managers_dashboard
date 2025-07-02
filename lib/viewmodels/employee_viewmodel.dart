import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../models/performance_data.dart';
import '../services/mock_data_service.dart';
import '../services/auth_service.dart';

class EmployeeViewModel extends ChangeNotifier
{
  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  List<PerformanceData> _performanceData = [];
  FilterPeriod _selectedPeriod = FilterPeriod.thisMonth;
  bool _isLoading = false;

  List<Employee> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;
  List<PerformanceData> get performanceData => _performanceData;
  FilterPeriod get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;

  String get currentBranch => AuthService.currentUser?.branchCode ?? '';

  EmployeeViewModel()
  {
    _loadEmployees();
  }

  void setPeriod(FilterPeriod period)
  {
    _selectedPeriod = period;
    if (_selectedEmployee != null) {
      _loadPerformanceData(_selectedEmployee!.id);
    }
    notifyListeners();
  }

  void selectEmployee(Employee employee)
  {
    _selectedEmployee = employee;
    _loadPerformanceData(employee.id);
    notifyListeners();
  }

  void _loadEmployees()
  {
    if (AuthService.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      _employees = MockDataService.getEmployeesByBranch(
          AuthService.currentUser!.branchCode
      );
      _selectedEmployee = null;
      _performanceData = [];
      _isLoading = false;
      notifyListeners();
    });
  }

  void _loadPerformanceData(String employeeId)
  {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      _performanceData = MockDataService.getPerformanceData(employeeId, _selectedPeriod);
      _isLoading = false;
      notifyListeners();
    });
  }

  void refresh()
  {
    _loadEmployees();
  }
}