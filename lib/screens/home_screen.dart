import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> expenses = [];

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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total gastado este mes',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$0.00',
                    style: TextStyle(
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente: registrar gasto'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar gasto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente: estadísticas'),
                        ),
                      );
                    },
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

            const SizedBox(height: 32),

            const Text(
              'Gastos recientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: expenses.isEmpty
                  ? const Center(
                      child: Text(
                        'Aún no hay gastos registrados.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: Text(expenses[index]),
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
