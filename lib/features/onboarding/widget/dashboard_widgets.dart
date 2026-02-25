// lib/features/dashboard/presentation/widgets/stat_card.dart
import 'package:autism_app/core/utils/contansts.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title, value, trend;
  final IconData icon;

  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.trend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textSecondary)),
              Icon(icon, color: AppColors.primary, size: 20),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(trend, style: TextStyle(color: trend.contains('+') ? Colors.green : Colors.red, fontSize: 12)),
        ],
      ),
    );
  }
}