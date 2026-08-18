import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';

class LowStockList extends StatelessWidget {
  final List<LowStockProduct> products;

  const LowStockList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
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

            const SizedBox(height: 16),

            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No low-stock products')),
              )
            else
              ...products.map((product) => _buildProductRow(context, product)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(BuildContext context, LowStockProduct product) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.orange.withOpacity(0.1),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.orange),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Minimum: '
                  '${product.minimumStockLevel}'
                  ' ${product.unit}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            '${product.stockQuantity} '
            '${product.unit}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
