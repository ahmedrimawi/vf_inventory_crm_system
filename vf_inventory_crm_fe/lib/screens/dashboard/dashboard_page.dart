import 'package:flutter/material.dart';

import '../../models/dashboard_summary.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/responsive_layout.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('VF Inventory CRM'),

        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),

          const SizedBox(width: 10),

          const CircleAvatar(child: Icon(Icons.person)),

          const SizedBox(width: 20),
        ],
      ),

      drawer: isDesktop
          ? null
          : Drawer(
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

      body: Row(
        children: [
          if (isDesktop)
            Sidebar(
              selectedIndex: selectedIndex,
              onSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),

          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 1:
        return const Center(child: Text('Inventory'));

      case 2:
        return const Center(child: Text('Customers'));

      case 3:
        return const Center(child: Text('Suppliers'));

      case 4:
        return const Center(child: Text('Sales'));

      case 5:
        return const Center(child: Text('Reports'));

      case 6:
        return const Center(child: Text('Settings'));

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          _buildSummaryCards(data),

          const SizedBox(height: 30),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(
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

          childAspectRatio: 2.4,

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
                    style: TextStyle(fontSize: 25, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lowStock(List<LowStockProduct> products) {
    return Card(
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

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
