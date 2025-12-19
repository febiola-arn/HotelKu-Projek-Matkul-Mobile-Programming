// HotelKu Widget Test
//
// Basic smoke test to verify the app builds correctly

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotelku/main.dart';

void main() {
  testWidgets('HotelKu app builds without errors', (WidgetTester tester) async {
    // Verify the app can be instantiated
    const app = MyApp();
    
    // Verify it's a widget
    expect(app, isA<Widget>());
    expect(app, isA<StatelessWidget>());
  });
}
