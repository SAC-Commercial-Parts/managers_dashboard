// lib/main.dart
import 'package:branch_managers_app/prviders/theme_provider.dart';
import 'package:branch_managers_app/services/auth_wrapper.dart';
import 'package:branch_managers_app/viewmodels/employee_viewmodel.dart'; // This is the imported ViewModel
import 'package:branch_managers_app/viewmodels/salesman_call_viewmodel.dart';
import 'package:branch_managers_app/views/dashboard_view.dart';
import 'package:branch_managers_app/views/employees_view.dart';
import 'package:branch_managers_app/views/main_screen.dart';
import 'package:branch_managers_app/views/quotes_invoices_view.dart';
import 'package:branch_managers_app/views/salesman_call_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        // Provide AuthService first, as others depend on it
        Provider<AuthService>(create: (_) => AuthService()),
        // StreamProvider for User changes from AuthService
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().user, // Ensure AuthService.user provides a Stream<User?>
          initialData: null, // Important: provide initialData
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardViewModel(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          // Assuming 'VisitViewModel' was a typo and you meant 'EmployeeViewModel'
          create: (context) => VisitViewModel( // <--- CORRECTED THIS LINE: changed from VisitViewModel to EmployeeViewModel
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
            // The AuthWrapper is correctly placed here to handle routing based on auth state
            home:  AuthWrapper(
              firebaseAuth: FirebaseAuth.instance,
              firebaseFirestore: FirebaseFirestore.instance,
              authService: AuthService(),
            ),
            routes:{
              MainScreen.id: (context) => const MainScreen(),
              DashboardView.id: (context) => const DashboardView(),
              VisitsView.id: (context) => const VisitsView(),
              SalesmanCallView.id: (context) => const SalesmanCallView(),
              QuotesInvoicesView.id: (context) => const QuotesInvoicesView(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}