import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:onesave/src/app.dart';

void main() {
  testWidgets('App builds and shows a MaterialApp titled Edusave',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: OneSaveApp()));
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Edusave');

    // Let pending animation/delayed timers complete before teardown.
    await tester.pump(const Duration(seconds: 10));
  });
}
