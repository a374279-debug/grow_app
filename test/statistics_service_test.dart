import 'package:flutter_test/flutter_test.dart';
import 'package:grow_app/models/expense.dart';
import 'package:grow_app/services/statistics_service.dart';

void main() {
  group('Pruebas unitarias de StatisticsService', () {
    final expenses = [
      Expense(
        amount: 100.0,
        category: 'Alimentación',
        description: 'Comida',
        date: DateTime(2026, 7, 1),
      ),
      Expense(
        amount: 50.0,
        category: 'Alimentación',
        description: 'Café',
        date: DateTime(2026, 7, 2),
      ),
      Expense(
        amount: 200.0,
        category: 'Transporte',
        description: 'Gasolina',
        date: DateTime(2026, 7, 3),
      ),
    ];

    test('Calcula correctamente el total de gastos', () {
      final total = StatisticsService.getTotal(expenses);

      expect(total, 350.0);
    });

    test('Cuenta correctamente la cantidad de gastos', () {
      final count = StatisticsService.getExpenseCount(expenses);

      expect(count, 3);
    });

    test('Calcula correctamente el promedio de gastos', () {
      final average = StatisticsService.getAverage(expenses);

      expect(average, closeTo(116.66, 0.01));
    });

    test('Agrupa correctamente el total por categoría', () {
      final totalsByCategory = StatisticsService.getTotalByCategory(expenses);

      expect(totalsByCategory['Alimentación'], 150.0);
      expect(totalsByCategory['Transporte'], 200.0);
    });

    test('Devuelve 0 cuando se calcula el promedio de una lista vacía', () {
      final average = StatisticsService.getAverage([]);

      expect(average, 0);
    });

    test('Devuelve 0 cuando se calcula el total de una lista vacía', () {
      final total = StatisticsService.getTotal([]);

      expect(total, 0);
    });
  });
}
