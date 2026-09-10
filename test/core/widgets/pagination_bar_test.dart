import 'package:apartment_maintenance_frontent/core/widgets/pagination_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supports a current page size outside the standard options', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaginationBar(
            page: 1,
            totalPages: 1,
            pageSize: 20,
            onPageChanged: (_) {},
            onPageSizeChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('20'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
