import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/expense.dart';

class PdfExportService {
  static Future<String> exportExpensesReport({
    required List<Expense> expenses,
    required String selectedCategory,
  }) async {
    final pdf = pw.Document();

    final total = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final tableData = expenses.isEmpty
        ? [
            ['Sin datos', '-', '-', '\$0.00'],
          ]
        : expenses.map((expense) {
            return [
              _formatDate(expense.date),
              expense.category,
              expense.description,
              _formatMoney(expense.amount),
            ];
          }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Text(
              'Grow - Reporte de gastos',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 12),

            pw.Text(
              'Fecha de generación: ${_formatDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12),
            ),

            pw.Text(
              selectedCategory == 'Todas'
                  ? 'Filtro aplicado: Todas las categorías'
                  : 'Filtro aplicado: $selectedCategory',
              style: const pw.TextStyle(fontSize: 12),
            ),

            pw.SizedBox(height: 20),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.green),
              ),
              child: pw.Text(
                'Total del reporte: ${_formatMoney(total)}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green,
                ),
              ),
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              'Detalle de gastos',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 12),

            pw.TableHelper.fromTextArray(
              headers: ['Fecha', 'Categoría', 'Descripción', 'Monto'],
              data: tableData,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellPadding: const pw.EdgeInsets.all(6),
            ),
          ];
        },
      ),
    );

    final documentsDirectory = await getApplicationDocumentsDirectory();

    final reportsDirectory = Directory(
      p.join(documentsDirectory.path, 'ReportesGrow'),
    );

    if (!await reportsDirectory.exists()) {
      await reportsDirectory.create(recursive: true);
    }

    final fileName = selectedCategory == 'Todas'
        ? 'grow_reporte_gastos.pdf'
        : 'grow_reporte_${_cleanFileName(selectedCategory)}.pdf';

    final filePath = p.join(reportsDirectory.path, fileName);
    final file = File(filePath);

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _formatMoney(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String _cleanFileName(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(' ', '_');
  }
}
