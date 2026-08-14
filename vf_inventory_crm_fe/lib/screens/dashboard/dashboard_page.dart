import 'package:flutter/material.dart';

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

          LayoutBuilder(
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

                children: const [
                  DashboardCard(
                    title: 'Total Products',
                    value: '245',
                    icon: Icons.inventory_2,
                  ),

                  DashboardCard(
                    title: 'Total Stock',
                    value: '1,250',
                    icon: Icons.warehouse,
                  ),

                  DashboardCard(
                    title: 'Customers',
                    value: '85',
                    icon: Icons.people,
                  ),

                  DashboardCard(
                    title: 'Suppliers',
                    value: '24',
                    icon: Icons.local_shipping,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) {
                return Column(
                  children: [
                    _salesChart(),
                    const SizedBox(height: 20),
                    _lowStock(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(flex: 2, child: _salesChart()),

                  const SizedBox(width: 20),

                  Expanded(child: _lowStock()),
                ],
              );
            },
          ),
        ],
      ),
    );
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

              Expanded(
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

  Widget _lowStock() {
    return Card(
      child: SizedBox(
        height: 350,

        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'Low Stock',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              _stockItem('Tomatoes', '15 kg'),

              _stockItem('Potatoes', '20 kg'),

              _stockItem('Apples', '8 kg'),

              _stockItem('Cucumbers', '12 kg'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stockItem(String name, String quantity) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: const Icon(Icons.warning_amber),

      title: Text(name),

      trailing: Text(quantity),
    );
  }
}
