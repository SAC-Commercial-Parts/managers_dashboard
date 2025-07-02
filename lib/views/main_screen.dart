import 'package:flutter/material.dart';
// import '../core/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/sidebar.dart';
import '../views/login_view.dart';
import 'dashboard_view.dart';
import 'employees_view.dart';
import 'quotes_invoices_view.dart';

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

  void _logout() {
    AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const LoginView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titles[_selectedIndex]),
            Text(
              '${user.branchCode} - ${user.name}',
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
                    Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Branch: ${user.branchCode}',
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
  }
}