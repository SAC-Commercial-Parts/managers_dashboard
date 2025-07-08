import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../models/performance_data.dart';
import '../services/firestore_employee_service.dart'; // Import the new Firestore service
import '../services/auth_service.dart';

class EmployeeViewModel extends ChangeNotifier
{
  final FirestoreEmployeeService _employeeService = FirestoreEmployeeService(); // Instantiate the new service

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

  String get currentBranch => AuthService.currentAppUser?.branchCode ?? '';

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

  Future<void> _loadEmployees() async // Made async
      {
    if (AuthService.currentAppUser == null || AuthService.currentAppUser!.branchCode == null) {
      _employees = [];
      _selectedEmployee = null;
      _performanceData = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _employees = await _employeeService.getEmployeesByBranch(
          AuthService.currentAppUser!.branchCode!
      );
      _selectedEmployee = null; // Reset selection after loading new list
      _performanceData = []; // Clear performance data
    } catch (e) {
      print('Error loading employees: $e');
      _employees = []; // Clear on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPerformanceData(String employeeId) async // Made async
  {
    _isLoading = true;
    notifyListeners();

    try {
      _performanceData = await _employeeService.getPerformanceData(employeeId, _selectedPeriod);
    } catch (e) {
      print('Error loading performance data: $e');
      _performanceData = []; // Clear on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh()
  {
    _loadEmployees(); // Reload all employees
    // If selected employee is still valid, reload their performance data too
    if (_selectedEmployee != null) {
      _loadPerformanceData(_selectedEmployee!.id);
    }
  }
}
