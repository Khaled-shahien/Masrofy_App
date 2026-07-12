import 'dart:typed_data';

import 'package:excel/excel.dart';
import '../../core/export/export_file_namer.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/exported_file.dart';
import '../../domain/entities/financial_transaction.dart';

class TransactionExcelExporter {
  const TransactionExcelExporter({ExportFileNamer? namer})
    : _namer = namer ?? const ExportFileNamer();

  final ExportFileNamer _namer;

  ExportedFile build({
    required Iterable<FinancialTransaction> transactions,
    required Map<String, Category> categoriesById,
    required String localeName,
  }) {
    final workbook = Excel.createExcel();
    final sheet = workbook['Transactions'];
    workbook.setDefaultSheet('Transactions');
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Type'),
      TextCellValue('Category'),
      TextCellValue('Amount'),
      TextCellValue('Wallet'),
      TextCellValue('Person'),
      TextCellValue('Note'),
    ]);

    for (final transaction in transactions) {
      sheet.appendRow([
        TextCellValue(_dateText(transaction.date)),
        TextCellValue(transaction.type.name),
        TextCellValue(
          categoriesById[transaction.categoryId]?.name ??
              transaction.categoryId,
        ),
        DoubleCellValue(transaction.amount),
        TextCellValue(transaction.wallet?.name ?? ''),
        TextCellValue(transaction.personName ?? ''),
        TextCellValue(transaction.note ?? ''),
      ]);
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw StateError('Failed to encode Excel export.');
    }

    return ExportedFile(
      fileName: _namer.transactionsExcel(),
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      bytes: Uint8List.fromList(bytes),
    );
  }
}

String _dateText(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}
