import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/sample_data.dart';
import '../../models/machine.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/progress_bar.dart';

class MachinesScreen extends StatelessWidget {
  const MachinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final machines = SampleData.machines;
    final running = machines.where((m) => m.status == MachineStatus.running).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Machines'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Row(
              children: [
                _MiniStat(
                  label: 'Running',
                  value: '$running',
                  color: AppColors.machineRunning,
                ),
                const SizedBox(width: 10),
                _MiniStat(
                  label: 'Idle',
                  value: '${machines.where((m) => m.status == MachineStatus.idle).length}',
                  color: AppColors.machineIdle,
                ),
                const SizedBox(width: 10),
                _MiniStat(
                  label: 'Maintenance',
                  value: '${machines.where((m) => m.status == MachineStatus.maintenance).length}',
                  color: AppColors.machineMaintenance,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              itemCount: machines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final m = machines[i];
                final color = StatusChipColors.colorForMachine(m.status);
                return InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              m.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                m.statusLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (m.status == MachineStatus.running) ...[
                        const SizedBox(height: 9),
                        AppProgressBar(value: m.utilization, color: color, height: 6),
                        const SizedBox(height: 4),
                        Text(
                          '${(m.utilization * 100).toInt()}% utilization',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        m.note,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChipColors {
  static Color colorForMachine(MachineStatus status) {
    switch (status) {
      case MachineStatus.running:
        return AppColors.machineRunning;
      case MachineStatus.idle:
        return AppColors.machineIdle;
      case MachineStatus.maintenance:
        return AppColors.machineMaintenance;
    }
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
