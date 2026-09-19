// Nexpool - Widget Smoke Test
//
// Test dasar untuk memastikan aplikasi Nexpool
// berhasil di-render tanpa error.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexpool/main.dart';

void main() {
  testWidgets('Nexpool app smoke test', (WidgetTester tester) async {
    // Build aplikasi dan trigger frame.
    await tester.pumpWidget(const MyApp());

    // Verifikasi bahwa MaterialApp berhasil dirender.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verifikasi bahwa Scaffold ada di dalam app.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
