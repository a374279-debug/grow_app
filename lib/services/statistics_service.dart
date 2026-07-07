import '../models/expense.dart';

class StatisticsService {
  static double getTotal(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  static int getExpenseCount(List<Expense> expenses) {
    return expenses.length;
  }

  static double getAverage(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return 0;
    }

    return getTotal(expenses) / expenses.length;
  }

  static Map<String, double> getTotalByCategory(List<Expense> expenses) {
    final Map<String, double> totals = {};

    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }
}
