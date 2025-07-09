import 'package:branch_managers_app/views/salesman_call_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase User type
import '../prviders/theme_provider.dart';
import '../services/auth_service.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/sidebar.dart';
import 'dashboard_view.dart';
import 'employees_view.dart';
import 'quotes_invoices_view.dart';
import 'package:branch_managers_app/views/login_view.dart'; // Ensure correct path for LoginView

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _sidebarMinimized = false;
  String? _userBranchCode; // To store fetched branchCode
  String? _userName; // To store fetched user name

  final List<Widget> _views = [
    const DashboardView(),
    const VisitsView(),
    const SalesmanCallView(),
    const QuotesInvoicesView(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Reps',
    'Salesmen & Calls',
    'Quotes & Invoices',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch user details immediately when the screen loads
    _fetchUserDetails();
  }

  // Method to fetch user details from Firestore
  Future<void> _fetchUserDetails() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      _userName = currentUser.displayName ?? currentUser.email?.split('@')[0];

      // Fetch branch code from Firestore using the existing method
      _userBranchCode = await authService.getUserBranch();

      setState(() {
        // Update state to rebuild UI with fetched details
      });
    }
  }

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
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
              (Route<dynamic> route) => false,
        );
      });
      return const SizedBox.shrink();
    }

    final String displayUserName = _userName ?? user.email ?? 'Loading Name...';
    final String displayBranchCode = _userBranchCode ?? 'Loading Branch...';
    final String displayUserEmail = user.email ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titles[_selectedIndex]),
            Text(
              '$displayBranchCode - $displayUserName', // Use fetched data
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
                      displayUserName, // Use fetched data
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      displayUserEmail, // Use fetched email
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Branch: $displayBranchCode', // Use fetched data
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              // START OF THE ONLY CHANGE: ADD THEME TOGGLE
              PopupMenuItem(
                enabled: false, // Make it not selectable itself, just its content
                padding: EdgeInsets.zero, // Remove default padding for better control
                child: Consumer<ThemeProvider>( // Use Consumer to access ThemeProvider
                  builder: (context, themeProvider, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding here
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row( // Group icon and text
                            children: [
                              Icon(Icons.dark_mode, size: 18),
                              SizedBox(width: 8),
                              Text('Dark Mode'),
                            ],
                          ),
                          Switch(
                            value: themeProvider.themeMode == ThemeMode.dark,
                            onChanged: (value) {
                              // Close the popup menu immediately when the switch is toggled
                              Navigator.pop(context);
                              themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                            },
                            activeColor: Theme.of(context).primaryColor, // Use app's primary color
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const PopupMenuDivider(),
              // END OF THE ONLY CHANGE
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