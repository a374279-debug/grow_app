import 'package:flutter_test/flutter_test.dart';
import 'package:grow_app/main.dart';

void main() {
  testWidgets('La pantalla principal de Grow se muestra correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GrowApp());

    expect(find.text('Grow'), findsOneWidget);
    expect(find.text('Gestor de gastos personales'), findsOneWidget);
    expect(
      find.text('Controla tus gastos, revisa estadísticas y genera reportes.'),
      findsOneWidget,
    );
  });
}
