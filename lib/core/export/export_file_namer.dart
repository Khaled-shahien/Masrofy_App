/// Builds stable, non-sensitive export file names.
class ExportFileNamer {
  const ExportFileNamer({DateTime Function()? now}) : _now = now;

  final DateTime Function()? _now;

  String transactionsExcel() => 'masrofy_transactions_${_stamp()}.xlsx';

  String reportPdf() => 'masrofy_report_${_stamp()}.pdf';

  String backupJson() => 'masrofy_backup_${_stamp()}.json';

  String _stamp() {
    final value = _now?.call() ?? DateTime.now();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}${two(value.month)}${two(value.day)}_'
        '${two(value.hour)}${two(value.minute)}';
  }
}
