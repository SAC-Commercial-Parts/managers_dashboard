import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Import the updated AuthService
import '../widgets/responsive_layout.dart';
import '../widgets/sidebar.dart';
import '../views/login_view.dart';
import 'dashboard_view.dart';
import 'employees_view.dart';
import 'quotes_invoices_view.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuthException

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _sidebarMinimized = false;

  final List<Widget> _views = [
    const DashboardView(),
    const EmployeesView(),
    const QuotesInvoicesView(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Employees',
    'Quotes & Invoices',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarMinimized = !_sidebarMinimized;
    });
  }

  void _logout() async {
    await AuthService.logout();
    // After logout, navigate to the LoginView.
    // Use pushAndRemoveUntil to clear the navigation stack,
    // so the user cannot go back to MainScreen with the back button.
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginView()),
            (Route<dynamic> route) => false, // Remove all routes below
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder to react to authentication state changes
    return StreamBuilder<AppUser?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // If there's an error in the stream (e.g., permission-denied from AuthService)
        if (snapshot.hasError) {
          // If the error is a FirebaseAuthException and it's a permission-denied,
          // it means the user was logged out due to incorrect role.
          // In this case, navigate back to LoginView and show the error.
          if (snapshot.error is FirebaseAuthException &&
              (snapshot.error as FirebaseAuthException).code == 'permission-denied') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginView()),
                    (Route<dynamic> route) => false,
              );
            });
            // Return a placeholder while navigation happens
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // For other errors, you might want to show a generic error screen
          return Scaffold(
            body: Center(
              child: Text('An error occurred: ${snapshot.error.toString()}'),
            ),
          );
        }

        // If the connection is waiting, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Get the AppUser from the snapshot
        final AppUser? user = snapshot.data;

        // If no user is logged in, redirect to LoginView
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginView()),
                  (Route<dynamic> route) => false,
            );
          });
          // Return a placeholder while navigation happens
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If a user is logged in and has the correct role, build the MainScreen
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_titles[_selectedIndex]),
                // Display user's branch code and display name from AppUser
                Text(
                  '${user.branchCode ?? 'N/A'} - ${user.displayName ?? user.email}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            leading: ResponsiveLayout.isDesktop(context)
                ? IconButton(
              icon: Icon(_sidebarMinimized ? Icons.menu : Icons.menu_open),
              onPressed: _toggleSidebar,
            )
                : null,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display user's display name, email, and branch code
                        Text(
                          user.displayName ?? user.email, // Fallback to email if displayName is null
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'Branch: ${user.branchCode ?? 'N/A'}', // Fallback for branchCode
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          drawer: ResponsiveLayout.isMobile(context)
              ? Sidebar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            isMinimized: false,
          )
              : null,
          body: ResponsiveLayout.isDesktop(context)
              ? Row(
            children: [
              Sidebar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
                isMinimized: _sidebarMinimized,
              ),
              Expanded(
                child: _views[_selectedIndex],
              ),
            ],
          )
              : _views[_selectedIndex],
        );
      },
    );
  }
}
