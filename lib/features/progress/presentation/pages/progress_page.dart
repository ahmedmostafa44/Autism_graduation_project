import 'package:autism_app/core/utils/contansts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/progress_bloc.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProgressBloc, ProgressState>(
          builder: (context, state) {
            if (state is ProgressLoading || state is ProgressInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProgressLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border)),
                            child: const Icon(Icons.arrow_back, size: 18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text('Track Progress', style: AppTextStyles.heading2),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Parent / Doctor toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: AppColors.divider, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: ['Parent', 'Doctor'].map((view) {
                          final isSelected = state.selectedView == view;
                          return Expanded(
                            child: GestureDetector(
                              // Dispatch event instead of calling cubit method
                              onTap: () => context
                                  .read<ProgressBloc>()
                                  .add(ProgressViewSwitched(view)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.surface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(view == 'Parent' ? '👨‍👩‍👧' : '🩺',
                                        style: const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text('$view View',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      children: [
                        _StatCard(icon: Icons.calendar_today_outlined, value: '${state.sessions}',      label: 'Sessions', bgColor: AppColors.gamesCardBg),
                        const SizedBox(width: 12),
                        _StatCard(icon: Icons.trending_up,             value: '${state.streakDays} days', label: 'Streak',   bgColor: AppColors.streakColor, highlighted: true),
                        const SizedBox(width: 12),
                        _StatCard(icon: Icons.emoji_events_outlined,   value: '${state.awards}',        label: 'Awards',   bgColor: AppColors.surface),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Weekly Activity chart
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Weekly Activity', style: AppTextStyles.heading3),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: state.weeklyData.map((data) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 3),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: FractionallySizedBox(
                                            heightFactor: data.value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: AppColors.progressBar.withOpacity(0.7),
                                                  borderRadius: BorderRadius.circular(6)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(data.day, style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daily logs
                    const Text('Daily Logs', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    ...state.dailyLogs.map((log) => _DailyLogCard(log: log)),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color bgColor;
  final bool highlighted;

  const _StatCard({
    required this.icon, required this.value,
    required this.label, required this.bgColor,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: highlighted ? Border.all(color: AppColors.secondary.withOpacity(0.3)) : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: highlighted ? AppColors.secondary : AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.heading3.copyWith(
                  fontSize: highlighted ? 18 : 20,
                  color: highlighted ? AppColors.secondary : AppColors.textPrimary,
                )),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _DailyLogCard extends StatelessWidget {
  final DailyLog log;
  const _DailyLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Text(log.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.label, style: AppTextStyles.heading3),
                const SizedBox(height: 2),
                Text(log.note, style: AppTextStyles.body2),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: AppColors.gamesCardBg, borderRadius: BorderRadius.circular(20)),
            child: Text('${log.score}/10',
                style: AppTextStyles.label
                    .copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
