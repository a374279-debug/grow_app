import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/expense.dart';
import '../services/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

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
    });
  }

  String _formatMoney(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 32),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = StatisticsService.getTotal(_expenses);
    final count = StatisticsService.getExpenseCount(_expenses);
    final average = StatisticsService.getAverage(_expenses);
    final categoryTotals = StatisticsService.getTotalByCategory(_expenses);

    final categoryEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  const Text(
                    'Resumen de gastos',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  _buildSummaryCard(
                    title: 'Total general',
                    value: _formatMoney(total),
                    icon: Icons.attach_money,
                  ),

                  _buildSummaryCard(
                    title: 'Gastos registrados',
                    value: '$count',
                    icon: Icons.receipt_long,
                  ),

                  _buildSummaryCard(
                    title: 'Promedio por gasto',
                    value: _formatMoney(average),
                    icon: Icons.trending_up,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Total por categoría',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  if (categoryEntries.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'Aún no hay información para mostrar.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    ...categoryEntries.map((entry) {
                      final percentage = total == 0 ? 0.0 : entry.value / total;

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _formatMoney(entry.value),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              LinearProgressIndicator(
                                value: percentage,
                                minHeight: 8,
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${(percentage * 100).toStringAsFixed(1)}% del total',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
