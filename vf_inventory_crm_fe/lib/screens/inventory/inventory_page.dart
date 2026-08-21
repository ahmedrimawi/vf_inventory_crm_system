import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/add_item_dialog.dart';
import '../../widgets/data_table_widget.dart';
import '../../widgets/search_filter_bar.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ProductService _productService = ProductService();

  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];

  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final products = await _productService.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Products API Error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<Product> get _filteredProducts {
    final search = _searchController.text.trim().toLowerCase();

    return _products.where((product) {
      final matchesSearch =
          search.isEmpty ||
          product.name.toLowerCase().contains(search) ||
          product.sku.toLowerCase().contains(search) ||
          product.category.toLowerCase().contains(search);

      final matchesCategory =
          _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get _categories {
    final categories = _products
        .map((product) => product.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    categories.sort();

    return categories;
  }

  Future<void> _showAddProductDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AddItemDialog(
          title: 'Add Product',
          saveButtonText: 'Add Product',

          fields: [
            AddItemField(name: 'name', label: 'Product Name', required: true),

            AddItemField(name: 'sku', label: 'SKU'),

            AddItemField(name: 'category', label: 'Category'),

            AddItemField(name: 'unit', label: 'Unit'),

            AddItemField(
              name: 'purchase_price',
              label: 'Purchase Price',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            AddItemField(
              name: 'selling_price',
              label: 'Selling Price',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            AddItemField(
              name: 'stock_quantity',
              label: 'Stock Quantity',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            AddItemField(
              name: 'minimum_stock_level',
              label: 'Minimum Stock Level',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],

          onSave: (values) async {
            await _productService.createProduct(
              name: values['name']!,
              sku: values['sku'],
              category: values['category'],
              unit: values['unit'] ?? 'piece',

              purchasePrice:
                  double.tryParse(values['purchase_price'] ?? '') ?? 0,

              sellingPrice: double.tryParse(values['selling_price'] ?? '') ?? 0,

              stockQuantity:
                  double.tryParse(values['stock_quantity'] ?? '') ?? 0,

              minimumStockLevel:
                  double.tryParse(values['minimum_stock_level'] ?? '') ?? 10,
            );
          },
        );
      },
    );

    if (result == true) {
      await _loadProducts();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),

          content: Text('Are you sure you want to delete "${product.name}"?'),

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
      await _productService.deleteProduct(product.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );

      await _loadProducts();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _buildHeader(),

            const SizedBox(height: 24),

            SearchFilterBar(
              controller: _searchController,
              hintText: 'Search products...',
              addButtonText: 'Add Product',
              onAdd: _showAddProductDialog,

              filters: [_buildCategoryFilter()],

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
                'Inventory',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text(
                'Manage your products and stock',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),

        IconButton(
          tooltip: 'Refresh',
          onPressed: _loadProducts,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return DropdownButton<String>(
      value: _selectedCategory,

      hint: const Text('Category'),

      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Categories'),
        ),

        ..._categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }),
      ],

      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    final products = _filteredProducts;

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return DataTableWidget(
      columns: const [
        DataColumn(label: Text('Product')),
        DataColumn(label: Text('SKU')),
        DataColumn(label: Text('Category')),
        DataColumn(label: Text('Stock')),
        DataColumn(label: Text('Min. Stock')),
        DataColumn(label: Text('Unit')),
        DataColumn(label: Text('Purchase Price')),
        DataColumn(label: Text('Selling Price')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],

      rows: products.map((product) {
        final isLowStock = product.stockQuantity <= product.minimumStockLevel;

        return DataRow(
          cells: [
            DataCell(
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            DataCell(Text(product.sku.isEmpty ? '-' : product.sku)),

            DataCell(Text(product.category.isEmpty ? '-' : product.category)),

            DataCell(
              Text(
                '${_formatNumber(product.stockQuantity)} ${product.unit}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLowStock ? Colors.red : null,
                ),
              ),
            ),

            DataCell(
              Text(
                '${_formatNumber(product.minimumStockLevel)} ${product.unit}',
              ),
            ),

            DataCell(Text(product.unit)),

            DataCell(Text(_formatCurrency(product.purchasePrice))),

            DataCell(Text(_formatCurrency(product.sellingPrice))),

            DataCell(_stockStatus(product)),

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
                      _deleteProduct(product);
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

  Widget _stockStatus(Product product) {
    if (product.stockQuantity <= product.minimumStockLevel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.red.withValues(alpha: 0.12),
        ),

        child: const Text(
          'Low Stock',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.green.withValues(alpha: 0.12),
      ),

      child: const Text(
        'In Stock',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          const Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),

          const SizedBox(height: 16),

          const Text(
            'No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            _searchController.text.isNotEmpty || _selectedCategory != null
                ? 'Try changing your filters.'
                : 'Add your first product.',
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
            'Failed to load inventory',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(_errorMessage!, textAlign: TextAlign.center),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
