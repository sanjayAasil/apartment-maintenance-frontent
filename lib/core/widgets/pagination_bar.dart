import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    required this.page,
    required this.totalPages,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    super.key,
  });
  final int page;
  final int totalPages;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final pageSizes = {10, 25, 50, pageSize}.toList()..sort();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: [
        const Text('Rows per page'),
        DropdownButton<int>(
          value: pageSize,
          onChanged: (value) {
            if (value != null) onPageSizeChanged(value);
          },
          items: pageSizes
              .map(
                (size) => DropdownMenuItem(value: size, child: Text('$size')),
              )
              .toList(),
        ),
        Text('Page $page of $totalPages'),
        IconButton(
          tooltip: 'Previous page',
          onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
