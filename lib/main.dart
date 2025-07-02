import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/employee_viewmodel.dart';
import 'viewmodels/quotes_invoices_viewmodel.dart';
import 'views/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => EmployeeViewModel()),
        ChangeNotifierProvider(create: (_) => QuotesInvoicesViewModel()),
      ],
      child: MaterialApp(
        title: 'Branch Managers App',
        theme: AppTheme.theme,
        home: const LoginView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}