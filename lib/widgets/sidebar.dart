import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isMinimized;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isMinimized,
  });

  ////////////////////////////////////////////////////////////////////////////
  //                                UI OUTPUT                               //
  ////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context)
  {
    return Container(
      width: isMinimized ? 60 : 240,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          right: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Column(
        ////////////////////////////////////////////////////////////////////////////
        //                               HYPERLINKS                               //
        ////////////////////////////////////////////////////////////////////////////
        children: [
          if (!isMinimized)
            // HEADING
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Branch Manager',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // DASHBOARD
          _buildMenuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
          ),

          // REPS
          _buildMenuItem(
            icon: Icons.people_alt,
            title: 'Reps',
            index: 1,
          ),

          // SALESMAN & CALLS
          _buildMenuItem(
            icon: Icons.person,
            title: 'Salesmen & Calls',
            index: 2,
          ),

          // QUOTES & INVOICES
          _buildMenuItem(
            icon: Icons.description,
            title: 'Quotes & Invoices',
            index: 3,
          ),

        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                MENU ITEM                               //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  })
  {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryRed : AppTheme.darkGray,
        ),
        title: isMinimized
            ? null
            : Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryRed : AppTheme.darkGray,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryRed.withAlpha(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => onItemTapped(index),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMinimized ? 8 : 16,
          vertical: isMinimized ? 8: 4,
        ),
      ),
    );
  }
}