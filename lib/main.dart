import 'package:branch_managers_app/prviders/theme_provider.dart';
import 'package:branch_managers_app/services/auth_wrapper.dart';
import 'package:branch_managers_app/viewmodels/employee_viewmodel.dart';
import 'package:branch_managers_app/viewmodels/salesman_call_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/quotes_invoices_viewmodel.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardViewModel(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => VisitViewModel( // <--- CHANGED THIS LINE
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SalesmanCallViewModel(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => QuotesInvoicesViewModel(
            context.read<AuthService>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Branch Managers App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}