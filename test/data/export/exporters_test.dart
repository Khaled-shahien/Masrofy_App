import 'package:flutter_test/flutter_test.dart';
import 'package:masrofy/core/export/export_file_namer.dart';
import 'package:masrofy/data/export/report_pdf_exporter.dart';
import 'package:masrofy/data/export/transaction_excel_exporter.dart';
import 'package:masrofy/domain/entities/category.dart';
import 'package:masrofy/domain/entities/financial_transaction.dart';
import 'package:masrofy/domain/entities/report_filter.dart';
import 'package:masrofy/domain/entities/transaction_type.dart';
import 'package:masrofy/domain/usecases/reports/build_report.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const category = Category(
    id: 'food',
    type: TransactionType.expense,
    name: 'Food',
    localizationKey: null,
    iconKey: 'restaurant',
    colorValue: 0xFF2A9D8F,
    sortOrder: 0,
  );
  final categoriesById = {category.id: category};

  test('ExportFileNamer creates stable non-sensitive names', () {
    final namer = ExportFileNamer(now: () => DateTime(2026, 7, 12, 9, 5));

    expect(
      namer.transactionsExcel(),
      'masrofy_transactions_20260712_0905.xlsx',
    );
    expect(namer.reportPdf(), 'masrofy_report_20260712_0905.pdf');
    expect(namer.backupJson(), 'masrofy_backup_20260712_0905.json');
  });

  test('TransactionExcelExporter creates a non-empty workbook', () {
    final exporter = TransactionExcelExporter(
      namer: ExportFileNamer(now: () => DateTime(2026, 7, 12, 9, 5)),
    );

    final file = exporter.build(
      transactions: [_transaction()],
      categoriesById: categoriesById,
      localeName: 'en',
    );

    expect(file.fileName, endsWith('.xlsx'));
    expect(file.mimeType, contains('spreadsheetml'));
    expect(file.bytes, isNotEmpty);
  });

  test('ReportPdfExporter creates a PDF document', () async {
    final report = BuildReport(now: () => DateTime(2026, 7, 12))(
      transactions: [_transaction()],
      filter: const ReportFilter(periodType: ReportPeriodType.thisMonth),
    );
    final exporter = ReportPdfExporter(
      namer: ExportFileNamer(now: () => DateTime(2026, 7, 12, 9, 5)),
    );

    final file = await exporter.build(
      report: report,
      categoriesById: categoriesById,
      title: 'Spending report',
      dateRangeLabel: 'Jul 2026',
      localeName: 'en',
    );

    expect(file.fileName, endsWith('.pdf'));
    expect(String.fromCharCodes(file.bytes.take(4)), '%PDF');
  });
}

FinancialTransaction _transaction() {
  return FinancialTransaction(
    id: 'tx-1',
    type: TransactionType.expense,
    amount: 120,
    categoryId: 'food',
    date: DateTime(2026, 7, 10),
    createdAt: DateTime(2026, 7, 10),
    updatedAt: DateTime(2026, 7, 10),
  );
}
