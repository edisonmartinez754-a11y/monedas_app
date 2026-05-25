import 'package:flutter_test/flutter_test.dart';
import 'package:monedas_app/main.dart';

void main() {
  testWidgets('App muestra pantalla de login', (WidgetTester tester) async {
    await tester.pumpWidget(const MonedasApp());
    expect(find.text('Monedas App'), findsOneWidget);
  });
}
