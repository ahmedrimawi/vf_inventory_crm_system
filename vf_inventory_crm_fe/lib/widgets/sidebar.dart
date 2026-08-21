import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.background,
      child: Column(
        children: [
          // LOGO / TITLE
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: const Text(
              'VF Inventory CRM',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const Divider(height: 1, color: Colors.white24),

          // MENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _menuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  index: 0,
                ),

                _menuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory',
                  index: 1,
                ),

                _menuItem(
                  icon: Icons.people_outline,
                  title: 'Customers',
                  index: 2,
                ),

                _menuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Suppliers',
                  index: 3,
                ),

                _menuItem(
                  icon: Icons.point_of_sale_outlined,
                  title: 'Sales',
                  index: 4,
                ),

                _menuItem(
                  icon: Icons.bar_chart_outlined,
                  title: 'Reports',
                  index: 5,
                ),

                _menuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  index: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: selected ? AppColors.sidebarSelected : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.textLight,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? AppColors.textPrimary : AppColors.textLight,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => onSelected(index),
      ),
    );
  }
}
