import 'package:autism_app/core/utils/contansts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/community_bloc.dart';
import '../../data/models/resource_model.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  static const _tabs = ['Resources', 'Documents', 'Therapist Posts'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
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
                  const Text('Community', style: AppTextStyles.heading2),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      // Dispatch event on search change
                      onChanged: (v) =>
                          context.read<CommunityBloc>().add(CommunitySearchChanged(v)),
                      decoration: const InputDecoration(
                        hintText: 'Search resources...',
                        prefixIcon: Icon(Icons.search, color: AppColors.textHint, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.filter_alt_outlined,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            BlocBuilder<CommunityBloc, CommunityState>(
              builder: (context, state) {
                final selected =
                    state is CommunityLoaded ? state.selectedTab : 'Resources';
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: AppColors.divider, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: _tabs.map((tab) {
                      final isSelected = tab == selected;
                      return Expanded(
                        child: GestureDetector(
                          // Dispatch event instead of calling cubit method
                          onTap: () => context
                              .read<CommunityBloc>()
                              .add(CommunityTabSelected(tab)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(tab,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Resources list
            Expanded(
              child: BlocBuilder<CommunityBloc, CommunityState>(
                builder: (context, state) {
                  if (state is CommunityLoading || state is CommunityInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CommunityLoaded) {
                    final resources = state.filteredResources;
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: resources.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _ResourceCard(
                        resource: resources[index],
                        // Dispatch event instead of calling cubit method
                        onLike: () => context
                            .read<CommunityBloc>()
                            .add(CommunityResourceLiked(resources[index].id)),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback onLike;

  const _ResourceCard({required this.resource, required this.onLike});

  Color get _bgColor {
    switch (resource.type) {
      case ResourceType.article:  return AppColors.gamesCardBg;
      case ResourceType.document: return AppColors.speakCardBg;
      default:                    return AppColors.surface;
    }
  }

  IconData get _typeIcon => Icons.menu_book_outlined;

  String get _typeLabel {
    switch (resource.type) {
      case ResourceType.article:  return 'Article';
      case ResourceType.document: return 'Document';
      case ResourceType.guide:    return 'Guide';
      case ResourceType.resource: return 'Resource';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
            child: Icon(_typeIcon, size: 22, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.title, style: AppTextStyles.heading3.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text('${resource.author} · $_typeLabel', style: AppTextStyles.caption),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(resource.tag,
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onLike,
            child: Icon(
              resource.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: resource.isLiked ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
