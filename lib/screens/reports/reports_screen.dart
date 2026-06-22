import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/info_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monthlyData = [
      _MonthBar('Jan', 0.60, '₹3.6L'),
      _MonthBar('Feb', 0.75, '₹4.5L'),
      _MonthBar('Mar', 0.55, '₹3.3L'),
      _MonthBar('Apr', 0.85, '₹5.1L'),
      _MonthBar('May', 0.70, '₹4.2L'),
      _MonthBar('Jun', 0.90, '₹5.4L'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.9,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _SummaryCard(label: 'Revenue (Jun)', value: '₹5.4L', color: AppColors.statusReady),
                _SummaryCard(label: 'Orders (Jun)', value: '7', color: AppColors.accent),
                _SummaryCard(label: 'Avg. Lead Time', value: '6.2 days'),
                _SummaryCard(label: 'On-time Rate', value: '85%', color: AppColors.statusReady),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Monthly Revenue',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            InfoCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: monthlyData.map((bar) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  bar.label2,
                                  style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 3),
                                Flexible(
                                  child: FractionallySizedBox(
                                    heightFactor: 1.0,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: bar.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: bar.value >= 0.85
                                                ? AppColors.accent
                                                : AppColors.accentSoft,
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: monthlyData.map((bar) {
                      return Expanded(
                        child: Text(
                          bar.month,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Stages (This Month)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            ...const [
              _StageRow('Queued', 1, 7, AppColors.statusQueued),
              _StageRow('Cutting', 1, 7, AppColors.statusCutting),
              _StageRow('Welding', 1, 7, AppColors.statusWelding),
              _StageRow('QC', 1, 7, AppColors.statusQC),
              _StageRow('Ready/Delivered', 2, 7, AppColors.statusReady),
            ].map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: row,
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MonthBar {
  final String month;
  final double value;
  final String label2;
  _MonthBar(this.month, this.value, this.label2);
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _SummaryCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StageRow(this.label, this.count, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ),
          Text(
            '$count',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: count / total,
                minHeight: 6,
                backgroundColor: const Color(0xFFEFEBE3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
