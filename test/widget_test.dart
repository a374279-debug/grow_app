import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grow_app/main.dart';

void main() {
  testWidgets('La pantalla principal de Grow se muestra correctamente', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));

    await tester.pumpWidget(const GrowApp());

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Grow'), findsOneWidget);
    expect(find.text('Gestor de gastos personales'), findsOneWidget);
    expect(
      find.text('Controla, analiza y exporta tus gastos de forma sencilla'),
      findsOneWidget,
    );

    expect(find.text('Registrar gasto'), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('Exportar PDF'), findsOneWidget);
    expect(find.text('Exportar Excel'), findsOneWidget);
  });
}
