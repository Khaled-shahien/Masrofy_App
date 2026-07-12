import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/export/export_file_namer.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/exported_file.dart';
import '../../domain/entities/report_summary.dart';

class ReportPdfExporter {
  const ReportPdfExporter({ExportFileNamer? namer})
    : _namer = namer ?? const ExportFileNamer();

  final ExportFileNamer _namer;

  Future<ExportedFile> build({
    required ReportData report,
    required Map<String, Category> categoriesById,
    required String title,
    required String dateRangeLabel,
    required String localeName,
  }) async {
    final regularFont = localeName == 'ar'
        ? await PdfGoogleFonts.notoSansArabicRegular()
        : await PdfGoogleFonts.notoSansRegular();
    final boldFont = localeName == 'ar'
        ? await PdfGoogleFonts.notoSansArabicBold()
        : await PdfGoogleFonts.notoSansBold();
    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );
    final document = pw.Document(theme: theme);

    document.addPage(
      pw.MultiPage(
        textDirection: localeName == 'ar'
            ? pw.TextDirection.rtl
            : pw.TextDirection.ltr,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(title)),
          pw.Text(dateRangeLabel),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: const ['Metric', 'Value'],
            data: [
              ['Income', report.summary.totalIncome.toStringAsFixed(2)],
              ['Expenses', report.summary.totalExpense.toStringAsFixed(2)],
              ['Net', report.summary.netBalance.toStringAsFixed(2)],
              ['Transactions', report.summary.transactionCount.toString()],
              [
                'Daily average',
                report.summary.averageDailyExpense.toStringAsFixed(2),
              ],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Categories',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Category', 'Expenses', 'Income'],
            data: [
              for (final summary in report.categorySummaries)
                [
                  categoriesById[summary.categoryId]?.name ??
                      summary.categoryId,
                  summary.expenseAmount.toStringAsFixed(2),
                  summary.incomeAmount.toStringAsFixed(2),
                ],
            ],
          ),
        ],
      ),
    );

    return ExportedFile(
      fileName: _namer.reportPdf(),
      mimeType: 'application/pdf',
      bytes: Uint8List.fromList(await document.save()),
    );
  }
}
