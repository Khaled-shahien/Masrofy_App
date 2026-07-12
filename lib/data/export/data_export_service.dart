import 'package:printing/printing.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/exported_file.dart';
import '../../domain/entities/financial_transaction.dart';
import '../../domain/entities/report_summary.dart';
import 'local_export_writer.dart';
import 'report_pdf_exporter.dart';
import 'transaction_excel_exporter.dart';

class DataExportService {
  const DataExportService({
    TransactionExcelExporter? transactionExcelExporter,
    ReportPdfExporter? reportPdfExporter,
    LocalExportWriter? writer,
  }) : _transactionExcelExporter =
           transactionExcelExporter ?? const TransactionExcelExporter(),
       _reportPdfExporter = reportPdfExporter ?? const ReportPdfExporter(),
       _writer = writer ?? const LocalExportWriter();

  final TransactionExcelExporter _transactionExcelExporter;
  final ReportPdfExporter _reportPdfExporter;
  final LocalExportWriter _writer;

  ExportedFile buildTransactionsExcel({
    required Iterable<FinancialTransaction> transactions,
    required Map<String, Category> categoriesById,
    required String localeName,
  }) {
    return _transactionExcelExporter.build(
      transactions: transactions,
      categoriesById: categoriesById,
      localeName: localeName,
    );
  }

  Future<ExportedFile> buildReportPdf({
    required ReportData report,
    required Map<String, Category> categoriesById,
    required String title,
    required String dateRangeLabel,
    required String localeName,
  }) {
    return _reportPdfExporter.build(
      report: report,
      categoriesById: categoriesById,
      title: title,
      dateRangeLabel: dateRangeLabel,
      localeName: localeName,
    );
  }

  Future<String> save(ExportedFile file) => _writer.write(file);

  Future<void> sharePdf(ExportedFile file) {
    return Printing.sharePdf(bytes: file.bytes, filename: file.fileName);
  }
}
