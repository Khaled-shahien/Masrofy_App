import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

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
    final fonts = await _PdfFonts.load();
    final regularFont = localeName == 'ar'
        ? fonts.arabicRegular
        : fonts.latinRegular;
    final boldFont = localeName == 'ar' ? fonts.arabicBold : fonts.latinBold;
    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      fontFallback: [
        fonts.arabicRegular,
        fonts.arabicBold,
        fonts.latinRegular,
        fonts.latinBold,
      ],
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

class _PdfFonts {
  const _PdfFonts({
    required this.arabicRegular,
    required this.arabicBold,
    required this.latinRegular,
    required this.latinBold,
  });

  static const _arabicRegularAsset =
      'assets/fonts/noto/NotoSansArabic-Regular.ttf';
  static const _arabicBoldAsset = 'assets/fonts/noto/NotoSansArabic-Bold.ttf';
  static const _latinRegularAsset = 'assets/fonts/noto/NotoSans-Regular.ttf';
  static const _latinBoldAsset = 'assets/fonts/noto/NotoSans-Bold.ttf';

  final pw.Font arabicRegular;
  final pw.Font arabicBold;
  final pw.Font latinRegular;
  final pw.Font latinBold;

  static Future<_PdfFonts> load() async {
    return _PdfFonts(
      arabicRegular: await _loadFont(_arabicRegularAsset),
      arabicBold: await _loadFont(_arabicBoldAsset),
      latinRegular: await _loadFont(_latinRegularAsset),
      latinBold: await _loadFont(_latinBoldAsset),
    );
  }

  static Future<pw.Font> _loadFont(String asset) async {
    return pw.Font.ttf(await rootBundle.load(asset));
  }
}
