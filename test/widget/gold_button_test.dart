import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luy_money/app/shared/widgets/gold_button.dart';
import 'package:luy_money/app/shared/themes/app_themes.dart';

Widget _wrap(Widget child) {
  return GetMaterialApp(
    theme: AppThemes.getTheme(AppTheme.black),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('GoldButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        GoldButton(label: 'Subscribe Now', onPressed: () {}),
      ));
      expect(find.text('Subscribe Now'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const GoldButton(label: 'Loading', isLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        GoldButton(label: 'Tap Me', onPressed: () => tapped = true),
      ));
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('disabled when loading', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        GoldButton(
          label: 'Tap',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('renders outlined variant', (tester) async {
      await tester.pumpWidget(_wrap(
        GoldButton(
          label: 'Outlined',
          isOutlined: true,
          onPressed: () {},
        ),
      ));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        GoldButton(
          label: 'With Icon',
          icon: Icons.send,
          onPressed: () {},
        ),
      ));
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
