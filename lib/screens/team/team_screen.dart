import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/sample_data.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/progress_bar.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final team = SampleData.team;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Team'),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        itemCount: team.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final member = team[i];
          return InfoCard(
            child: Row(
              children: [
                AvatarCircle(initials: member.initials, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.tagBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              member.role,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.tagText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      member.task,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
