import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import '../../services/transaction_service.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final TransactionService _transactionService = TransactionService();

  List<InventoryTransaction> _transactions = [];

  bool _loading = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _transactionService.getTransactions();

      if (!mounted) return;

      setState(() {
        _transactions = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });

      debugPrint('Transactions API Error: $e');
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
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sales',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _showNewTransactionDialog,

                  icon: const Icon(Icons.add),

                  label: const Text('New Transaction'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),

            const SizedBox(height: 12),

            Text(_error!),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loadTransactions,

              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return const Center(child: Text('No sales or purchases found.'));
    }

    return _buildTransactionsTable();
  }

  Widget _buildTransactionsTable() {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,

        child: DataTable(
          columns: const [
            DataColumn(label: Text('Transaction')),

            DataColumn(label: Text('Type')),

            DataColumn(label: Text('Party')),

            DataColumn(label: Text('Total')),

            DataColumn(label: Text('Status')),
          ],

          rows: _transactions.map((transaction) {
            final isSale = transaction.transactionType == 'sale';

            return DataRow(
              cells: [
                DataCell(Text(transaction.transactionNumber)),

                DataCell(Text(isSale ? 'Sale' : 'Purchase')),

                DataCell(Text(isSale ? 'Customer' : 'Supplier')),

                DataCell(Text(transaction.totalAmount.toStringAsFixed(2))),

                DataCell(Text(transaction.status)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showNewTransactionDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('New Transaction'),

          content: const Text(
            'Here we will add the customer/supplier, products, quantities and prices.',
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
