import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/masrofy_theme_extension.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/report_filter.dart';
import '../../../domain/entities/report_summary.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/entities/wallet_type.dart';
import '../../../data/export/data_export_service.dart';
import '../../../di/service_locator.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cubits/reports/reports_cubit.dart';
import '../../cubits/reports/reports_state.dart';
import '../../widgets/categories/category_localization.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/privacy/financial_privacy.dart';
import '../../widgets/transactions/transaction_formatters.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state.status == ReportsStatus.loading && state.report == null) {
          return const LoadingSkeleton();
        }
        if (state.status == ReportsStatus.failure && state.report == null) {
          return EmptyState(
            icon: Icons.query_stats,
            title: localizations.reportsLoadError,
            body: localizations.reportsEmptyBody,
            action: FilledButton.icon(
              onPressed: context.read<ReportsCubit>().retry,
              icon: const Icon(Icons.refresh),
              label: Text(localizations.commonRetry),
            ),
          );
        }

        final report = state.report;
        if (report == null) {
          return const LoadingSkeleton();
        }

        return _ReportsBody(state: state, report: report);
      },
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody({required this.state, required this.report});

  final ReportsState state;
  final ReportData report;

  @override
  Widget build(BuildContext context) {
    final categoriesById = {
      for (final category in state.categories) category.id: category,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = responsivePagePadding(constraints);
        return RefreshIndicator(
          onRefresh: () async => context.read<ReportsCubit>().load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  AppSpacing.md,
                  padding.right,
                  AppSpacing.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: _ReportHero(
                    report: report,
                    categoriesById: categoriesById,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding.left),
                sliver: SliverToBoxAdapter(
                  child: _ReportFilters(
                    filter: state.filter,
                    categories: state.categories,
                  ),
                ),
              ),
              if (!report.hasTransactions)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSpacing.lg,
                    padding.right,
                    padding.bottom,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.query_stats,
                      title: AppLocalizations.of(context).reportsEmptyTitle,
                      body:
                          '${AppLocalizations.of(context).reportsEmptyBody}\n'
                          '${AppLocalizations.of(context).reportsStartHint}',
                    ),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSpacing.sm,
                    padding.right,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _SummaryGrid(
                      report: report,
                      categoriesById: categoriesById,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSpacing.sm,
                    padding.right,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _ReportCharts(
                      report: report,
                      categoriesById: categoriesById,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSpacing.sm,
                    padding.right,
                    padding.bottom,
                  ),
                  sliver: SliverList.separated(
                    itemCount: report.categorySummaries.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final summary = report.categorySummaries[index];
                      return _CategoryReportRow(
                        summary: summary,
                        category: categoriesById[summary.categoryId],
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

enum _ReportExportAction { pdf, excel }

class _ReportHero extends StatelessWidget {
  const _ReportHero({
    required this.report,
    required this.categoriesById,
  });

  final ReportData report;
  final Map<String, Category> categoriesById;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final rangeLabel = _formatRange(localizations, report.range);

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.reportsTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                PopupMenuButton<_ReportExportAction>(
                  tooltip: localizations.reportsExportMenu,
                  iconColor: colorScheme.onPrimaryContainer,
                  onSelected: (action) => _export(context, action, rangeLabel),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ReportExportAction.pdf,
                      child: Text(localizations.exportReportPdf),
                    ),
                    PopupMenuItem(
                      value: _ReportExportAction.excel,
                      child: Text(localizations.exportTransactionsExcel),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              rangeLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    _ReportExportAction action,
    String rangeLabel,
  ) async {
    final localizations = AppLocalizations.of(context);
    final service = serviceLocator<DataExportService>();
    try {
      switch (action) {
        case _ReportExportAction.excel:
          final file = service.buildTransactionsExcel(
            transactions: report.transactions,
            categoriesById: categoriesById,
            localeName: localizations.localeName,
          );
          final path = await service.save(file);
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.exportSavedMessage(path))),
          );
        case _ReportExportAction.pdf:
          final file = await service.buildReportPdf(
            report: report,
            categoriesById: categoriesById,
            title: localizations.reportsTitle,
            dateRangeLabel: rangeLabel,
            localeName: localizations.localeName,
          );
          await service.sharePdf(file);
      }
    } on Object {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.exportFailedMessage)),
      );
    }
  }
}

class _ReportFilters extends StatelessWidget {
  const _ReportFilters({
    required this.filter,
    required this.categories,
  });

  final ReportFilter filter;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.reportsFiltersTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: context.read<ReportsCubit>().clearFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: Text(localizations.reportsClearFilters),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final period in ReportPeriodType.values)
                  ChoiceChip(
                    key: ValueKey('report-period-${period.name}'),
                    label: Text(_periodLabel(localizations, period)),
                    selected: filter.periodType == period,
                    onSelected: (_) => period == ReportPeriodType.custom
                        ? _pickCustomRange(context)
                        : context.read<ReportsCubit>().setPeriod(period),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= AppBreakpoints.desktop;
                final controls = [
                  _CategoryFilter(filter: filter, categories: categories),
                  _WalletFilter(filter: filter),
                  _TypeFilter(filter: filter),
                ];
                if (!wide) {
                  return Column(
                    children: [
                      for (final control in controls) ...[
                        control,
                        if (control != controls.last)
                          const SizedBox(height: AppSpacing.xs),
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    for (final control in controls) ...[
                      Expanded(child: control),
                      if (control != controls.last)
                        const SizedBox(width: AppSpacing.xs),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: filter.customStart == null || filter.customEnd == null
          ? null
          : DateTimeRange(start: filter.customStart!, end: filter.customEnd!),
    );
    if (selected == null || !context.mounted) {
      return;
    }
    context.read<ReportsCubit>().setCustomRange(
      selected.start,
      selected.end,
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.filter, required this.categories});

  final ReportFilter filter;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      key: const ValueKey('reports-category-filter'),
      initialValue: filter.categoryId ?? '',
      isExpanded: true,
      decoration: InputDecoration(
        labelText: localizations.reportsCategoryFilter,
      ),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(localizations.reportsAllCategories),
        ),
        for (final category in categories)
          DropdownMenuItem(
            value: category.id,
            child: Text(localizedCategoryName(localizations, category)),
          ),
      ],
      onChanged: (value) => context.read<ReportsCubit>().setCategory(
        value == null || value.isEmpty ? null : value,
      ),
    );
  }
}

class _WalletFilter extends StatelessWidget {
  const _WalletFilter({required this.filter});

  final ReportFilter filter;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      key: const ValueKey('reports-wallet-filter'),
      initialValue: filter.wallet?.name ?? '',
      isExpanded: true,
      decoration: InputDecoration(labelText: localizations.reportsWalletFilter),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(localizations.reportsAllWallets),
        ),
        for (final wallet in WalletType.values)
          DropdownMenuItem(
            value: wallet.name,
            child: Text(localizedWalletName(localizations, wallet)),
          ),
      ],
      onChanged: (value) => context.read<ReportsCubit>().setWallet(
        _walletFromName(value),
      ),
    );
  }
}

class _TypeFilter extends StatelessWidget {
  const _TypeFilter({required this.filter});

  final ReportFilter filter;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      key: const ValueKey('reports-type-filter'),
      initialValue: filter.transactionType?.name ?? '',
      isExpanded: true,
      decoration: InputDecoration(labelText: localizations.reportsTypeFilter),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(localizations.reportsAllTypes),
        ),
        for (final type in TransactionType.values)
          DropdownMenuItem(
            value: type.name,
            child: Text(localizedTransactionType(localizations, type)),
          ),
      ],
      onChanged: (value) => context.read<ReportsCubit>().setTransactionType(
        _transactionTypeFromName(value),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.report,
    required this.categoriesById,
  });

  final ReportData report;
  final Map<String, Category> categoriesById;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
    final obscureAmounts = financialAmountsObscured(context);
    final summary = report.summary;
    final highestCategory = summary.highestSpendingCategory;
    final highestCategoryName = highestCategory == null
        ? localizations.unknownCategory
        : _categoryName(
            localizations,
            categoriesById[highestCategory.categoryId],
          );
    final highestCategoryAmount = formatMoney(
      highestCategory?.expenseAmount ?? 0,
      localeName: localizations.localeName,
      currencySymbol: localizations.currencySymbol,
      obscure: obscureAmounts,
    );
    final comparisonAmount = formatMoney(
      summary.comparison.changeAmount,
      localeName: localizations.localeName,
      currencySymbol: localizations.currencySymbol,
      obscure: obscureAmounts,
    );
    final cards = [
      _MetricCard(
        icon: Icons.south_west,
        label: localizations.summaryExpense,
        value: _money(localizations, summary.totalExpense, obscureAmounts),
        color: colors.expense,
      ),
      _MetricCard(
        icon: Icons.north_east,
        label: localizations.summaryIncome,
        value: _money(localizations, summary.totalIncome, obscureAmounts),
        color: colors.income,
      ),
      _MetricCard(
        icon: Icons.account_balance_wallet_outlined,
        label: localizations.reportsNetBalance(''),
        value: _money(localizations, summary.netBalance, obscureAmounts),
        color: colors.info,
      ),
      _MetricCard(
        icon: Icons.receipt_long_outlined,
        label: localizations.reportsTransactionCount(
          summary.transactionCount,
        ),
        value: '',
        color: colors.info,
      ),
      _MetricCard(
        icon: Icons.trending_flat,
        label: localizations.reportsAverageDailyExpense(
          _money(localizations, summary.averageDailyExpense, obscureAmounts),
        ),
        value: '',
        color: colors.warning,
      ),
      _MetricCard(
        icon: Icons.arrow_circle_up_outlined,
        label: summary.highestExpenseTransaction == null
            ? localizations.reportsNoHighestExpense
            : localizations.reportsHighestExpense(
                _money(
                  localizations,
                  summary.highestExpenseTransaction!.amount,
                  obscureAmounts,
                ),
              ),
        value: '',
        color: colors.danger,
      ),
      _MetricCard(
        icon: Icons.category_outlined,
        label: highestCategory == null
            ? localizations.reportsNoChartData
            : localizations.reportsHighestCategory(
                highestCategoryName,
                highestCategoryAmount,
              ),
        value: '',
        color: colors.success,
      ),
      _MetricCard(
        icon: Icons.compare_arrows,
        label: localizations.reportsComparisonTitle,
        value: localizations.reportsComparisonExpenseChange(
          comparisonAmount,
          summary.comparison.changePercentage.toStringAsFixed(0),
        ),
        color: colors.info,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppBreakpoints.desktop
            ? 4
            : constraints.maxWidth >= AppBreakpoints.tablet
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: AppSpacing.xs,
          mainAxisSpacing: AppSpacing.xs,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: columns >= 3 ? 1.7 : 1.3,
          children: cards,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(
              label.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (value.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportCharts extends StatelessWidget {
  const _ReportCharts({
    required this.report,
    required this.categoriesById,
  });

  final ReportData report;
  final Map<String, Category> categoriesById;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final charts = [
          _ExpenseDistributionChart(
            report: report,
            categoriesById: categoriesById,
          ),
          _TrendChart(report: report),
          _IncomeExpenseChart(report: report),
        ];
        if (constraints.maxWidth < AppBreakpoints.desktop) {
          return Column(
            children: [
              for (final chart in charts) ...[
                chart,
                if (chart != charts.last) const SizedBox(height: AppSpacing.xs),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final chart in charts) ...[
              Expanded(child: chart),
              if (chart != charts.last) const SizedBox(width: AppSpacing.xs),
            ],
          ],
        );
      },
    );
  }
}

class _ExpenseDistributionChart extends StatelessWidget {
  const _ExpenseDistributionChart({
    required this.report,
    required this.categoriesById,
  });

  final ReportData report;
  final Map<String, Category> categoriesById;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final summaries = report.categorySummaries
        .where((summary) => summary.expenseAmount > 0)
        .take(6)
        .toList(growable: false);

    return _ChartCard(
      title: localizations.reportsDistributionTitle,
      child: summaries.isEmpty
          ? _NoChartData(message: localizations.reportsNoChartData)
          : PieChart(
              PieChartData(
                centerSpaceRadius: 32,
                sectionsSpace: 2,
                sections: [
                  for (final summary in summaries)
                    PieChartSectionData(
                      value: summary.expenseAmount,
                      color: _categoryColor(
                        context,
                        categoriesById[summary.categoryId],
                      ),
                      title: '${(summary.expenseRatio * 100).round()}%',
                      radius: 64,
                      titleStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.report});

  final ReportData report;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
    final maxY = report.timeSeries.fold<double>(
      0,
      (max, point) => [
        max,
        point.expenseAmount,
        point.incomeAmount,
      ].reduce((left, right) => left > right ? left : right),
    );

    return _ChartCard(
      title: localizations.reportsTrendTitle,
      child: maxY == 0
          ? _NoChartData(message: localizations.reportsNoChartData)
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY * 1.2,
                gridData: const FlGridData(drawVerticalLine: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _line(
                    report.timeSeries,
                    color: colors.expense,
                    value: (point) => point.expenseAmount,
                  ),
                  _line(
                    report.timeSeries,
                    color: colors.income,
                    value: (point) => point.incomeAmount,
                  ),
                ],
              ),
            ),
    );
  }

  LineChartBarData _line(
    List<TimeSeriesPoint> points, {
    required Color color,
    required double Function(TimeSeriesPoint point) value,
  }) {
    return LineChartBarData(
      spots: [
        for (var index = 0; index < points.length; index++)
          FlSpot(index.toDouble(), value(points[index])),
      ],
      color: color,
      barWidth: 3,
      isCurved: true,
      dotData: const FlDotData(show: false),
    );
  }
}

class _IncomeExpenseChart extends StatelessWidget {
  const _IncomeExpenseChart({required this.report});

  final ReportData report;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<MasrofyThemeExtension>()!;
    final maxY = [
      report.summary.totalIncome,
      report.summary.totalExpense,
    ].reduce((left, right) => left > right ? left : right);

    return _ChartCard(
      title: localizations.reportsIncomeVsExpenseTitle,
      child: maxY == 0
          ? _NoChartData(message: localizations.reportsNoChartData)
          : BarChart(
              BarChartData(
                maxY: maxY * 1.2,
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: report.summary.totalIncome,
                        color: colors.income,
                        width: 28,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: report.summary.totalExpense,
                        color: colors.expense,
                        width: 28,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: title,
              child: SizedBox(height: 220, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoChartData extends StatelessWidget {
  const _NoChartData({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CategoryReportRow extends StatelessWidget {
  const _CategoryReportRow({
    required this.summary,
    required this.category,
  });

  final CategorySpendingSummary summary;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final color = _categoryColor(context, category);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _categoryName(localizations, category),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  _money(localizations, summary.expenseAmount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              minHeight: 8,
              value: summary.expenseRatio.clamp(0, 1).toDouble(),
              color: color,
              borderRadius: AppRadii.pill,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              localizations.reportsExpenseRatio(
                (summary.expenseRatio * 100).round(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _periodLabel(AppLocalizations localizations, ReportPeriodType period) {
  return switch (period) {
    ReportPeriodType.today => localizations.reportsPeriodToday,
    ReportPeriodType.thisWeek => localizations.reportsPeriodThisWeek,
    ReportPeriodType.thisMonth => localizations.reportsPeriodThisMonth,
    ReportPeriodType.previousMonth => localizations.reportsPeriodPreviousMonth,
    ReportPeriodType.custom => localizations.reportsPeriodCustom,
  };
}

String _formatRange(
  AppLocalizations localizations,
  ReportDateRange range,
) {
  final formatter = DateFormat.yMMMd(localizations.localeName);
  final start = formatter.format(range.start);
  final end = formatter.format(
    range.endExclusive.subtract(const Duration(days: 1)),
  );
  return localizations.reportsDateRange(start, end);
}

String _money(
  AppLocalizations localizations,
  double value, [
  bool obscure = false,
]) {
  return formatMoney(
    value,
    localeName: localizations.localeName,
    currencySymbol: localizations.currencySymbol,
    obscure: obscure,
  );
}

String _categoryName(AppLocalizations localizations, Category? category) {
  return category == null
      ? localizations.unknownCategory
      : localizedCategoryName(localizations, category);
}

Color _categoryColor(BuildContext context, Category? category) {
  return category == null
      ? Theme.of(context).colorScheme.primary
      : Color(category.colorValue);
}

WalletType? _walletFromName(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  for (final wallet in WalletType.values) {
    if (wallet.name == value) {
      return wallet;
    }
  }
  return null;
}

TransactionType? _transactionTypeFromName(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  for (final type in TransactionType.values) {
    if (type.name == value) {
      return type;
    }
  }
  return null;
}
