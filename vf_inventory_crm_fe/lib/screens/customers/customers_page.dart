import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../services/customer_service.dart';
import '../../widgets/add_item_dialog.dart';
import '../../widgets/data_table_widget.dart';
import '../../widgets/search_filter_bar.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final CustomerService _customerService = CustomerService();

  final TextEditingController _searchController = TextEditingController();

  List<Customer> _customers = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final customers = await _customerService.getCustomers();

      if (!mounted) return;

      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Customers API Error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<Customer> get _filteredCustomers {
    final search = _searchController.text.trim().toLowerCase();

    if (search.isEmpty) {
      return _customers;
    }

    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(search) ||
          (customer.phone ?? '').toLowerCase().contains(search) ||
          (customer.email ?? '').toLowerCase().contains(search);
    }).toList();
  }

  Future<void> _showAddCustomerDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AddItemDialog(
          title: 'Add Customer',
          saveButtonText: 'Add Customer',

          fields: [
            AddItemField(name: 'name', label: 'Customer Name', required: true),

            AddItemField(
              name: 'phone',
              label: 'Phone',
              keyboardType: TextInputType.phone,
            ),

            AddItemField(
              name: 'email',
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),

            AddItemField(name: 'address', label: 'Address'),
          ],

          onSave: (values) async {
            await _customerService.createCustomer(
              name: values['name']!,
              phone: values['phone'],
              email: values['email'],
              address: values['address'],
            );
          },
        );
      },
    );

    if (result == true) {
      await _loadCustomers();
    }
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Customer'),

          content: Text('Are you sure you want to delete "${customer.name}"?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _customerService.deleteCustomer(customer.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted successfully')),
      );

      await _loadCustomers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete customer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _buildHeader(),

            const SizedBox(height: 24),

            SearchFilterBar(
              controller: _searchController,
              hintText: 'Search customers...',
              addButtonText: 'Add Customer',
              onAdd: _showAddCustomerDialog,
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 24),

            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'Customers',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text(
                'Manage your customers',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),

        IconButton(
          tooltip: 'Refresh',
          onPressed: _loadCustomers,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    final customers = _filteredCustomers;

    if (customers.isEmpty) {
      return _buildEmptyState();
    }

    return DataTableWidget(
      columns: const [
        DataColumn(label: Text('Customer')),
        DataColumn(label: Text('Phone')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Address')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],

      rows: customers.map((customer) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                customer.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            DataCell(Text(customer.phone ?? '-')),

            DataCell(Text(customer.email ?? '-')),

            DataCell(Text(customer.address ?? '-')),

            DataCell(_statusBadge(customer.isActive)),

            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      // Add edit functionality here.
                    },
                  ),

                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      _deleteCustomer(customer);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _statusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: active
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.red.withValues(alpha: 0.12),
      ),

      child: Text(
        active ? 'Active' : 'Inactive',

        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          const Icon(Icons.people_outline, size: 60, color: Colors.grey),

          const SizedBox(height: 16),

          const Text(
            'No customers found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search.'
                : 'Add your first customer.',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          const Icon(Icons.error_outline, size: 55, color: Colors.red),

          const SizedBox(height: 16),

          const Text(
            'Failed to load customers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(_errorMessage!, textAlign: TextAlign.center),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _loadCustomers,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
