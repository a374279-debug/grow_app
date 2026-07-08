import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/expense.dart';
import '../services/excel_export_service.dart';
import '../services/pdf_export_service.dart';
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

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gasto eliminado correctamente')),
    );
  }

  Future<void> _exportPdfReport() async {
    try {
      final filePath = await PdfExportService.exportExpensesReport(
        expenses: _filteredExpenses,
        selectedCategory: _selectedCategory,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte PDF generado: $filePath')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $error')));
    }
  }

  Future<void> _exportExcelReport() async {
    try {
      final filePath = await ExcelExportService.exportExpensesReport(
        expenses: _filteredExpenses,
        selectedCategory: _selectedCategory,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte Excel generado: $filePath')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al generar Excel: $error')));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatMoney(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.savings, color: Colors.green, size: 32),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gestor de gastos personales',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.green,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCategory == 'Todas'
                        ? 'Total gastado este mes'
                        : 'Total gastado este mes en $_selectedCategory',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatMoney(_monthlyTotal),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.filter_list, color: Colors.green),
            const SizedBox(width: 12),
            const Text(
              'Categoría:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: const Icon(Icons.attach_money, color: Colors.green),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${expense.category} · ${_formatDate(expense.date)}'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatMoney(expense.amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            IconButton(
              tooltip: 'Eliminar gasto',
              onPressed: () {
                if (expense.id != null) {
                  _deleteExpense(expense.id!);
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expensesToShow = _filteredExpenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Grow')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildTotalCard(),
            const SizedBox(height: 18),
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.add,
                  label: 'Registrar gasto',
                  onPressed: _goToAddExpenseScreen,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.pie_chart,
                  label: 'Estadísticas',
                  onPressed: _goToStatisticsScreen,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildExportButton(
                  icon: Icons.picture_as_pdf,
                  label: 'Exportar PDF',
                  onPressed: _exportPdfReport,
                ),
                const SizedBox(width: 12),
                _buildExportButton(
                  icon: Icons.table_chart,
                  label: 'Exportar Excel',
                  onPressed: _exportExcelReport,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildFilterCard(),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  'Gastos recientes',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${expensesToShow.length} registro(s)',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                        return _buildExpenseCard(expense);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
