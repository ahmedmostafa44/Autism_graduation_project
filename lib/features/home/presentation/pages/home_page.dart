import 'package:autism_app/core/bloc/nav_bloc.dart';
import 'package:autism_app/core/utils/contansts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeLoaded) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HomeHeader(state: state),
                    const SizedBox(height: 20),
                    _TodayTipCard(tip: state.todayTip),
                    const SizedBox(height: 24),
                    const _FeatureGrid(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final HomeLoaded state;
  const _HomeHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12)),
          child:
              const Icon(Icons.smart_toy, color: AppColors.primary, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning 👋',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary, fontSize: 13)),
              Text(state.parentName, style: AppTextStyles.heading2),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 12, color: AppColors.secondary),
              const SizedBox(width: 4),
              Text('Offline Ready',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Stack(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.notifications_outlined, size: 20),
            ),
            if (state.hasNotification)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.notificationBadge,
                      shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TodayTipCard extends StatelessWidget {
  final String tip;
  const _TodayTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Tip 💡",
              style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(tip,
              style: AppTextStyles.body2
                  .copyWith(color: AppColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _features = [
    _FeatureItem(
        title: 'Educational Game',
        subtitle: '12 games',
        icon: Icons.sports_esports,
        bgColor: AppColors.gamesCardBg,
        iconColor: Color(0xFF3B82F6),
        route: '/games',
        tabIndex: 1),
    _FeatureItem(
        title: 'Chat Bot',
        subtitle: 'AI assistant',
        icon: Icons.chat_bubble_outline,
        bgColor: AppColors.chatCardBg,
        iconColor: Color(0xFF8B5CF6),
        route: '/chat',
        tabIndex: 2),
    _FeatureItem(
        title: 'Text to Speech',
        subtitle: 'Speak out loud',
        icon: Icons.volume_up,
        bgColor: AppColors.speakCardBg,
        iconColor: Color(0xFF22C55E),
        route: '/speak',
        tabIndex: 3),
    _FeatureItem(
        title: 'Community',
        subtitle: 'Resources',
        icon: Icons.people_outline,
        bgColor: AppColors.communityCardBg,
        iconColor: Color(0xFFF97316),
        route: '/community',
        tabIndex: 4),
    _FeatureItem(
        title: 'Track Progress',
        subtitle: 'View insights',
        icon: Icons.bar_chart,
        bgColor: AppColors.progressCardBg,
        iconColor: Color(0xFF3B82F6),
        route: '/progress',
        tabIndex: 5,
        isNew: true),
    _FeatureItem(
        title: 'Subscription',
        subtitle: 'Manage plan',
        icon: Icons.credit_card_outlined,
        bgColor: AppColors.subscriptionCardBg,
        iconColor: Color(0xFF8B5CF6),
        route: '/',
        tabIndex: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.05),
      itemCount: _features.length,
      itemBuilder: (context, index) => _FeatureCard(feature: _features[index]),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context
            .read<NavigationBloc>()
            .add(NavigationTabChanged(feature.tabIndex));
        context.go(feature.route);
      },
      child: Container(
        decoration: BoxDecoration(
            color: feature.bgColor, borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 38,
                    decoration: BoxDecoration(
                        color: feature.iconColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14)),
                    child:
                        Icon(feature.icon, color: feature.iconColor, size: 26),
                  ),
                  const SizedBox(height: 14),
                  Text(feature.title,
                      style: AppTextStyles.heading3.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(feature.subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (feature.isNew)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('New',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String route;
  final int tabIndex;
  final bool isNew;
  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.route,
    required this.tabIndex,
    this.isNew = false,
  });
}
