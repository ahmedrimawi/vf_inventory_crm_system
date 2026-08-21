import 'package:flutter/material.dart';

import '../../models/supplier.dart';
import '../../services/supplier_service.dart';
import '../../widgets/add_item_dialog.dart';
import '../../widgets/data_table_widget.dart';
import '../../widgets/search_filter_bar.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final SupplierService _supplierService = SupplierService();

  final TextEditingController _searchController = TextEditingController();

  List<Supplier> _suppliers = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final suppliers = await _supplierService.getSuppliers();

      if (!mounted) return;

      setState(() {
        _suppliers = suppliers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Suppliers API Error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<Supplier> get _filteredSuppliers {
    final search = _searchController.text.trim().toLowerCase();

    if (search.isEmpty) {
      return _suppliers;
    }

    return _suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(search) ||
          (supplier.contactPerson ?? '').toLowerCase().contains(search) ||
          (supplier.phone ?? '').toLowerCase().contains(search) ||
          (supplier.email ?? '').toLowerCase().contains(search);
    }).toList();
  }

  Future<void> _showAddSupplierDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AddItemDialog(
          title: 'Add Supplier',
          saveButtonText: 'Add Supplier',
          fields: [
            AddItemField(name: 'name', label: 'Supplier Name', required: true),
            AddItemField(name: 'contact_person', label: 'Contact Person'),
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
            await _supplierService.createSupplier(
              name: values['name']!,
              contactPerson: values['contact_person'],
              phone: values['phone'],
              email: values['email'],
              address: values['address'],
            );
          },
        );
      },
    );

    if (result == true) {
      await _loadSuppliers();
    }
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Supplier'),
          content: Text('Are you sure you want to delete "${supplier.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _supplierService.deleteSupplier(supplier.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier deleted successfully')),
      );

      await _loadSuppliers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete supplier: $e'),
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
              hintText: 'Search suppliers...',
              addButtonText: 'Add Supplier',
              onAdd: _showAddSupplierDialog,
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
                'Suppliers',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Manage your suppliers',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),

        IconButton(
          tooltip: 'Refresh',
          onPressed: _loadSuppliers,
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

    final suppliers = _filteredSuppliers;

    if (suppliers.isEmpty) {
      return _buildEmptyState();
    }

    return DataTableWidget(
      columns: const [
        DataColumn(label: Text('Supplier')),
        DataColumn(label: Text('Contact Person')),
        DataColumn(label: Text('Phone')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Address')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows: suppliers.map((supplier) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                supplier.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            DataCell(Text(supplier.contactPerson ?? '-')),

            DataCell(Text(supplier.phone ?? '-')),

            DataCell(Text(supplier.email ?? '-')),

            DataCell(Text(supplier.address ?? '-')),

            DataCell(_statusBadge(supplier.isActive)),

            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      // Edit functionality can be added here.
                    },
                  ),

                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      _deleteSupplier(supplier);
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
          const Icon(
            Icons.local_shipping_outlined,
            size: 60,
            color: Colors.grey,
          ),

          const SizedBox(height: 16),

          const Text(
            'No suppliers found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search.'
                : 'Add your first supplier.',
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
            'Failed to load suppliers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(_errorMessage!, textAlign: TextAlign.center),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _loadSuppliers,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
