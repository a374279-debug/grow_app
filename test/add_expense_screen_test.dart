import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grow_app/screens/add_expense_screen.dart';

void main() {
  group('Pruebas de widgets de AddExpenseScreen', () {
    testWidgets(
      'Muestra correctamente los elementos principales del formulario',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));

        expect(find.text('Registrar gasto'), findsOneWidget);
        expect(find.text('Nuevo gasto'), findsOneWidget);
        expect(find.text('Monto'), findsOneWidget);
        expect(find.text('Categoría'), findsOneWidget);
        expect(find.text('Descripción'), findsOneWidget);
        expect(find.textContaining('Fecha:'), findsOneWidget);
        expect(find.text('Guardar gasto'), findsOneWidget);
      },
    );

    testWidgets(
      'Muestra mensajes de validación cuando el formulario está vacío',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));

        await tester.tap(find.text('Guardar gasto'));
        await tester.pumpAndSettle();

        expect(find.text('Ingresa el monto del gasto'), findsOneWidget);
        expect(find.text('Ingresa una descripción'), findsOneWidget);
      },
    );

    testWidgets('Muestra error cuando el monto no es válido', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddExpenseScreen()));

      await tester.enterText(find.byType(TextFormField).first, 'abc');
      await tester.enterText(find.byType(TextFormField).last, 'Comida');

      await tester.tap(find.text('Guardar gasto'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresa un monto válido'), findsOneWidget);
    });
  });
}
