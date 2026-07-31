import 'package:fl_chart/fl_chart.dart';
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

  final List<Color> _chartColors = const [
    Color(0xFF2E7D32),
    Color(0xFF43A047),
    Color(0xFF66BB6A),
    Color(0xFF26A69A),
    Color(0xFF9CCC65),
    Color(0xFFFFB74D),
    Color(0xFF78909C),
  ];

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
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade50,
                child: Icon(icon, color: Colors.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
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
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> totalsByCategory,
    double total,
  ) {
    final entries = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final double percentage = total == 0 ? 0.0 : (entry.value / total) * 100;
      final color = _chartColors[index % _chartColors.length];

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 85,
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegendItem({
    required String category,
    required double amount,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            _formatMoney(amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(Map<String, double> totalsByCategory, double total) {
    final entries = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gráfica de gastos por categoría',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Distribución visual del total gastado según cada categoría registrada.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 330,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(totalsByCategory, total),
                        centerSpaceRadius: 55,
                        sectionsSpace: 3,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final color = _chartColors[index % _chartColors.length];

                        return _buildLegendItem(
                          category: entry.key,
                          amount: entry.value,
                          color: color,
                        );
                      },
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

  Widget _buildCategoryDetail(
    Map<String, double> totalsByCategory,
    double total,
  ) {
    final entries = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalle por categoría',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            ...entries.map((entry) {
              final double percentage = total == 0 ? 0.0 : entry.value / total;

              return Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          _formatMoney(entry.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(20),
                      backgroundColor: Colors.green.shade50,
                      color: Colors.green,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Aún no hay gastos registrados para generar estadísticas.',
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = StatisticsService.getTotal(_expenses);
    final average = StatisticsService.getAverage(_expenses);
    final count = StatisticsService.getExpenseCount(_expenses);
    final totalsByCategory = StatisticsService.getTotalByCategory(_expenses);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  const Text(
                    'Resumen de gastos',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _buildSummaryCard(
                        title: 'Total gastado',
                        value: _formatMoney(total),
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(width: 14),
                      _buildSummaryCard(
                        title: 'Gastos registrados',
                        value: count.toString(),
                        icon: Icons.receipt_long,
                      ),
                      const SizedBox(width: 14),
                      _buildSummaryCard(
                        title: 'Promedio',
                        value: _formatMoney(average),
                        icon: Icons.trending_up,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildChartCard(totalsByCategory, total),
                  const SizedBox(height: 18),
                  _buildCategoryDetail(totalsByCategory, total),
                ],
              ),
            ),
    );
  }
}
