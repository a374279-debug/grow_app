import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import '../models/expense.dart';

class ExcelExportService {
  static Future<String> exportExpensesReport({
    required List<Expense> expenses,
    required String selectedCategory,
  }) async {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];

    sheet.name = 'Reporte';

    final total = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    sheet.getRangeByName('A1').setText('Grow - Reporte de gastos');
    sheet.getRangeByName('A1:D1').merge();

    sheet.getRangeByName('A3').setText('Fecha de generación');
    sheet.getRangeByName('B3').setText(_formatDate(DateTime.now()));

    sheet.getRangeByName('A4').setText('Filtro aplicado');
    sheet
        .getRangeByName('B4')
        .setText(
          selectedCategory == 'Todas'
              ? 'Todas las categorías'
              : selectedCategory,
        );

    sheet.getRangeByName('A5').setText('Total del reporte');
    sheet.getRangeByName('B5').setNumber(total);

    sheet.getRangeByName('A7').setText('Fecha');
    sheet.getRangeByName('B7').setText('Categoría');
    sheet.getRangeByName('C7').setText('Descripción');
    sheet.getRangeByName('D7').setText('Monto');

    int row = 8;

    if (expenses.isEmpty) {
      sheet.getRangeByIndex(row, 1).setText('Sin datos');
      sheet.getRangeByIndex(row, 2).setText('-');
      sheet.getRangeByIndex(row, 3).setText('-');
      sheet.getRangeByIndex(row, 4).setNumber(0);
    } else {
      for (final expense in expenses) {
        sheet.getRangeByIndex(row, 1).setText(_formatDate(expense.date));
        sheet.getRangeByIndex(row, 2).setText(expense.category);
        sheet.getRangeByIndex(row, 3).setText(expense.description);
        sheet.getRangeByIndex(row, 4).setNumber(expense.amount);
        row++;
      }
    }

    sheet.autoFitColumn(1);
    sheet.autoFitColumn(2);
    sheet.autoFitColumn(3);
    sheet.autoFitColumn(4);

    final documentsDirectory = await getApplicationDocumentsDirectory();

    final reportsDirectory = Directory(
      p.join(documentsDirectory.path, 'ReportesGrow'),
    );

    if (!await reportsDirectory.exists()) {
      await reportsDirectory.create(recursive: true);
    }

    final fileName = selectedCategory == 'Todas'
        ? 'grow_reporte_gastos.xlsx'
        : 'grow_reporte_${_cleanFileName(selectedCategory)}.xlsx';

    final filePath = p.join(reportsDirectory.path, fileName);
    final file = File(filePath);

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
