import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  String _selectedCategory = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper.instance.getAllExpenses();

    setState(() {
      _expenses = expenses;
      _isLoading = false;

      final categories = _availableCategories;
      if (!categories.contains(_selectedCategory)) {
        _selectedCategory = 'Todas';
      }
    });
  }

  List<String> get _availableCategories {
    final categories = _expenses
        .map((expense) => expense.category)
        .toSet()
        .toList();

    categories.sort();

    return ['Todas', ...categories];
  }

  List<Expense> get _filteredExpenses {
    if (_selectedCategory == 'Todas') {
      return _expenses;
    }

    return _expenses
        .where((expense) => expense.category == _selectedCategory)
        .toList();
  }

  double get _monthlyTotal {
    final now = DateTime.now();

    return _filteredExpenses
        .where(
          (expense) =>
              expense.date.year == now.year && expense.date.month == now.month,
        )
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  Future<void> _goToAddExpenseScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );

    if (result == true) {
      await _loadExpenses();
    }
  }

  Future<void> _goToStatisticsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsScreen()),
    );
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    await _loadExpenses();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatMoney(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final expensesToShow = _filteredExpenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Grow'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestor de gastos personales',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Controla tus gastos, revisa estadísticas y genera reportes.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCategory == 'Todas'
                        ? 'Total gastado este mes'
                        : 'Total gastado este mes en $_selectedCategory',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _formatMoney(_monthlyTotal),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _goToAddExpenseScreen,
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar gasto'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _goToStatisticsScreen,
                    icon: const Icon(Icons.pie_chart),
                    label: const Text('Estadísticas'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: exportar reporte'),
                    ),
                  );
                },
                icon: const Icon(Icons.file_download),
                label: const Text('Exportar reporte'),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                const Text(
                  'Filtrar por categoría:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(width: 16),

                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _availableCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Gastos recientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : expensesToShow.isEmpty
                  ? Center(
                      child: Text(
                        _expenses.isEmpty
                            ? 'Aún no hay gastos registrados.'
                            : 'No hay gastos para esta categoría.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: expensesToShow.length,
                      itemBuilder: (context, index) {
                        final expense = expensesToShow[index];

                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.attach_money),
                            title: Text(expense.description),
                            subtitle: Text(
                              '${expense.category} · ${_formatDate(expense.date)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatMoney(expense.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    if (expense.id != null) {
                                      _deleteExpense(expense.id!);
                                    }
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
