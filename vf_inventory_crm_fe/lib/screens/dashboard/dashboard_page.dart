import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/dashboard_summary.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/dashboard_header.dart';
import '../customers/customers_page.dart';
import '../inventory/inventory_page.dart';
import '../sales/sales_page.dart';
import '../suppliers/suppliers_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final DashboardService _dashboardService = DashboardService();

  DashboardSummary? _dashboardData;

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _dashboardService.getDashboardSummary();

      if (!mounted) return;

      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      debugPrint('Dashboard API Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SIDEBAR
            Sidebar(
              selectedIndex: selectedIndex,
              onSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),

            // MAIN AREA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  DashboardHeader(
                    title: _getPageTitle(),
                    subtitle: _getPageSubtitle(),
                  ),

                  // CONTENT
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // MOBILE / TABLET
    return Scaffold(
      drawer: Drawer(
        child: Sidebar(
          selectedIndex: selectedIndex,
          onSelected: (index) {
            setState(() {
              selectedIndex = index;
            });

            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // MOBILE HEADER
          DashboardHeader(title: _getPageTitle(), subtitle: _getPageSubtitle()),

          // MOBILE CONTENT
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (selectedIndex) {
      case 1:
        return 'Inventory';

      case 2:
        return 'Customers';

      case 3:
        return 'Suppliers';

      case 4:
        return 'Sales';

      case 5:
        return 'Reports';

      case 6:
        return 'Settings';

      default:
        return 'Dashboard';
    }
  }

  String _getPageSubtitle() {
    switch (selectedIndex) {
      case 1:
        return 'Manage your products and stock';

      case 2:
        return 'Manage your customers';

      case 3:
        return 'Manage your suppliers';

      case 4:
        return 'Manage your sales';

      case 5:
        return 'View business reports';

      case 6:
        return 'Manage application settings';

      default:
        return 'Overview of your business';
    }
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 1:
        return const InventoryPage();

      case 2:
        return const CustomersPage();

      case 3:
        return const SuppliersPage();

      case 4:
        return const SalesPage();

      case 5:
        return const _PlaceholderPage(
          title: 'Reports',
          icon: Icons.bar_chart_outlined,
        );

      case 6:
        return const _PlaceholderPage(
          title: 'Settings',
          icon: Icons.settings_outlined,
        );

      default:
        return _dashboard();
    }
  }

  Widget _dashboard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),

              const SizedBox(height: 16),

              const Text(
                'Failed to load dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(_errorMessage!, textAlign: TextAlign.center),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loadDashboard,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _dashboardData!;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(data),

            const SizedBox(height: 30),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _salesChart(),

                      const SizedBox(height: 20),

                      _lowStock(data.lowStock),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _salesChart()),

                    const SizedBox(width: 20),

                    Expanded(child: _lowStock(data.lowStock)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(DashboardSummary data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns = 1;

        if (width > 1300) {
          columns = 4;
        } else if (width > 800) {
          columns = 2;
        }

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 2.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            DashboardCard(
              title: 'Total Products',
              value: data.totalProducts.toString(),
              icon: Icons.inventory_2,
            ),

            DashboardCard(
              title: 'Total Stock',
              value: '${_formatNumber(data.totalStock)} kg',
              icon: Icons.warehouse,
            ),

            DashboardCard(
              title: 'Customers',
              value: data.totalCustomers.toString(),
              icon: Icons.people,
            ),

            DashboardCard(
              title: 'Suppliers',
              value: data.totalSuppliers.toString(),
              icon: Icons.local_shipping,
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  Widget _salesChart() {
    return Card(
      color: AppColors.background,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: SizedBox(
          height: 350,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                const Expanded(
                  child: Center(
                    child: Text(
                      'Sales Chart',
                      style: TextStyle(
                        fontSize: 25,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lowStock(List<LowStockProduct> products) {
    return Card(
      color: AppColors.background,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: SizedBox(
          height: 350,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Low Stock',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      '${products.length} items',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: products.isEmpty
                      ? const Center(child: Text('No low-stock products'))
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _stockItem(products[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stockItem(LowStockProduct product) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: const Icon(Icons.warning_amber, color: Colors.orange),

      title: Text(product.name),

      subtitle: Text(
        'Minimum: '
        '${_formatNumber(product.minimumStockLevel)} '
        '${product.unit}',
      ),

      trailing: Text(
        '${_formatNumber(product.stockQuantity)} '
        '${product.unit}',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 28),

              const SizedBox(width: 12),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
