import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onAdd;
  final String addButtonText;
  final ValueChanged<String>? onChanged;

  final List<Widget>? filters;

  const SearchFilterBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onAdd,
    this.addButtonText = 'Add',
    this.onChanged,
    this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchField(),
              const SizedBox(height: 12),

              if (filters != null && filters!.isNotEmpty) ...[
                Wrap(spacing: 10, runSpacing: 10, children: filters!),
                const SizedBox(height: 12),
              ],

              if (onAdd != null)
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: Text(addButtonText),
                  ),
                ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildSearchField()),

            if (filters != null && filters!.isNotEmpty) ...[
              const SizedBox(width: 12),

              ...filters!.map(
                (filter) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: filter,
                ),
              ),
            ],

            if (onAdd != null) ...[
              const SizedBox(width: 12),

              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(addButtonText),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();

                  if (onChanged != null) {
                    onChanged!('');
                  }
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
