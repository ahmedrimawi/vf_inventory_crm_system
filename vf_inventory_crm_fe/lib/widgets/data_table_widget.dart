import 'package:flutter/material.dart';

class DataTableWidget extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;

  final bool showCheckboxColumn;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = false,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  int _rowsPerPage = 10;
  int _currentPage = 0;

  // ------------------------------------------------------------
  // CURRENT PAGE ROWS
  // ------------------------------------------------------------

  List<DataRow> get _currentRows {
    if (widget.rows.isEmpty) {
      return [];
    }

    final startIndex = _currentPage * _rowsPerPage;

    if (startIndex >= widget.rows.length) {
      return [];
    }

    final endIndex = (startIndex + _rowsPerPage).clamp(0, widget.rows.length);

    return widget.rows.sublist(startIndex, endIndex);
  }

  // ------------------------------------------------------------
  // TOTAL PAGES
  // ------------------------------------------------------------

  int get _totalPages {
    if (widget.rows.isEmpty) {
      return 1;
    }

    return (widget.rows.length / _rowsPerPage).ceil();
  }

  // ------------------------------------------------------------
  // CURRENT RECORD RANGE
  // ------------------------------------------------------------

  int get _startRecord {
    if (widget.rows.isEmpty) {
      return 0;
    }

    return (_currentPage * _rowsPerPage) + 1;
  }

  int get _endRecord {
    if (widget.rows.isEmpty) {
      return 0;
    }

    final end = (_currentPage + 1) * _rowsPerPage;

    return end > widget.rows.length ? widget.rows.length : end;
  }

  // ------------------------------------------------------------
  // GO TO PAGE
  // ------------------------------------------------------------

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages) {
      return;
    }

    setState(() {
      _currentPage = page;
    });
  }

  // ------------------------------------------------------------
  // CHANGE ROWS PER PAGE
  // ------------------------------------------------------------

  void _changeRowsPerPage(int value) {
    setState(() {
      _rowsPerPage = value;

      // Always go back to page 1 when changing page size.
      _currentPage = 0;
    });
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Make sure the current page is still valid
    // if the number of rows changes.
    if (_currentPage >= _totalPages) {
      _currentPage = _totalPages - 1;

      if (_currentPage < 0) {
        _currentPage = 0;
      }
    }

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,

      child: Column(
        children: [
          // ======================================================
          // TABLE
          // ======================================================
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),

                    child: DataTable(
                      showCheckboxColumn: widget.showCheckboxColumn,

                      headingRowHeight: 56,

                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 70,

                      columnSpacing: 30,

                      // Remove row dividers.
                      dividerThickness: 0,

                      // White table rows.
                      dataRowColor: WidgetStateProperty.all(Colors.white),

                      // Gray table header.
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF3F4F6),
                      ),

                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),

                      columns: widget.columns,

                      rows: _currentRows,
                    ),
                  ),
                );
              },
            ),
          ),

          // ======================================================
          // PAGINATION BAR
          // ======================================================
          _buildPaginationBar(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PAGINATION BAR
  // ------------------------------------------------------------

  Widget _buildPaginationBar() {
    return Container(
      height: 64,

      padding: const EdgeInsets.symmetric(horizontal: 20),

      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),

      child: Row(
        children: [
          // ======================================================
          // LEFT SIDE
          // ======================================================
          Expanded(
            child: Row(
              children: [
                // First page
                _paginationButton(
                  icon: Icons.first_page,
                  tooltip: 'First page',
                  enabled: _currentPage > 0,

                  onPressed: () {
                    _goToPage(0);
                  },
                ),

                const SizedBox(width: 4),

                // Previous page
                _paginationButton(
                  icon: Icons.chevron_left,
                  tooltip: 'Previous page',
                  enabled: _currentPage > 0,

                  onPressed: () {
                    _goToPage(_currentPage - 1);
                  },
                ),

                const SizedBox(width: 12),

                // Page numbers
                _buildPageNumbers(),

                const SizedBox(width: 12),

                // Next page
                _paginationButton(
                  icon: Icons.chevron_right,
                  tooltip: 'Next page',
                  enabled: _currentPage < _totalPages - 1,

                  onPressed: () {
                    _goToPage(_currentPage + 1);
                  },
                ),

                const SizedBox(width: 4),

                // Last page
                _paginationButton(
                  icon: Icons.last_page,
                  tooltip: 'Last page',
                  enabled: _currentPage < _totalPages - 1,

                  onPressed: () {
                    _goToPage(_totalPages - 1);
                  },
                ),
              ],
            ),
          ),

          // ======================================================
          // RIGHT SIDE
          // ======================================================
          Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              // Showing records
              Text(
                'Showing $_startRecord–$_endRecord '
                'of ${widget.rows.length} records',

                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),

              const SizedBox(width: 24),

              // Rows per page text
              const Text(
                'Rows per page',

                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),

              const SizedBox(width: 10),

              // Rows per page dropdown
              Container(
                height: 38,

                padding: const EdgeInsets.symmetric(horizontal: 10),

                decoration: BoxDecoration(
                  color: Colors.white,

                  border: Border.all(color: const Color(0xFFD1D5DB)),

                  borderRadius: BorderRadius.circular(6),
                ),

                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _rowsPerPage,

                    isDense: true,

                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),

                    items: const [
                      DropdownMenuItem(value: 10, child: Text('10')),

                      DropdownMenuItem(value: 20, child: Text('20')),

                      DropdownMenuItem(value: 30, child: Text('30')),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        _changeRowsPerPage(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PAGE NUMBERS
  // ------------------------------------------------------------

  Widget _buildPageNumbers() {
    final totalPages = _totalPages;

    // Show all pages if there are 5 or fewer.
    if (totalPages <= 5) {
      return Row(
        mainAxisSize: MainAxisSize.min,

        children: List.generate(totalPages, (index) {
          return _pageNumberButton(index);
        }),
      );
    }

    final pages = <int>[];

    // Always show first page.
    pages.add(0);

    // Show ellipsis if needed.
    if (_currentPage > 2) {
      pages.add(-1);
    }

    // Pages around current page.
    final start = (_currentPage - 1).clamp(1, totalPages - 2);

    final end = (_currentPage + 1).clamp(1, totalPages - 2);

    for (int i = start; i <= end; i++) {
      if (!pages.contains(i)) {
        pages.add(i);
      }
    }

    // Show ellipsis if needed.
    if (_currentPage < totalPages - 3) {
      pages.add(-1);
    }

    // Always show last page.
    if (!pages.contains(totalPages - 1)) {
      pages.add(totalPages - 1);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,

      children: pages.map((page) {
        // Ellipsis
        if (page == -1) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),

            child: Text('...', style: TextStyle(color: Color(0xFF6B7280))),
          );
        }

        return _pageNumberButton(page);
      }).toList(),
    );
  }

  // ------------------------------------------------------------
  // PAGE NUMBER BUTTON
  // ------------------------------------------------------------

  Widget _pageNumberButton(int page) {
    final isSelected = page == _currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),

      child: SizedBox(
        width: 36,
        height: 36,

        child: Material(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,

          borderRadius: BorderRadius.circular(6),

          child: InkWell(
            borderRadius: BorderRadius.circular(6),

            onTap: () {
              _goToPage(page);
            },

            child: Center(
              child: Text(
                '${page + 1}',

                style: TextStyle(
                  fontSize: 13,

                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,

                  color: isSelected ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FIRST / PREVIOUS / NEXT / LAST BUTTON
  // ------------------------------------------------------------

  Widget _paginationButton({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,

      child: SizedBox(
        width: 36,
        height: 36,

        child: IconButton(
          padding: EdgeInsets.zero,

          icon: Icon(icon, size: 20),

          color: const Color(0xFF374151),

          disabledColor: const Color(0xFFD1D5DB),

          onPressed: enabled ? onPressed : null,
        ),
      ),
    );
  }
}
