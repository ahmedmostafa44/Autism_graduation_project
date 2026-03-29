import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import '../bloc/community_bloc.dart';
import '../../data/models/resource_model.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  static const _tabs = ['Resources', 'Documents', 'Therapist Posts'];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          GalaxyAppBar(title: 'Community'),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) =>
                        context.read<CommunityBloc>().add(CommunitySearchChanged(v)),
                    style: TextStyle(
                        color: GalaxyColors.textPrimary(isDark), fontFamily: 'Nunito'),
                    decoration: InputDecoration(
                      hintText: 'Search resources...',
                      prefixIcon: Icon(Icons.search_rounded,
                          color: GalaxyColors.textHint(isDark), size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: GalaxyColors.surface(isDark),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: GalaxyColors.border(isDark)),
                  ),
                  child: Icon(Icons.tune_rounded,
                      color: GalaxyColors.textSecond(isDark), size: 20),
                ),
              ],
            ),
          ),
          // Tab switcher
          BlocBuilder<CommunityBloc, CommunityState>(
            builder: (context, state) {
              final selected =
                  state is CommunityLoaded ? state.selectedTab : 'Resources';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: GalaxyColors.surface2(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GalaxyColors.border(isDark), width: 0.5),
                  ),
                  child: Row(
                    children: _tabs.map((tab) {
                      final isSelected = tab == selected;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => context
                              .read<CommunityBloc>()
                              .add(CommunityTabSelected(tab)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(colors: [
                                      GalaxyColors.nebulaPurple,
                                      GalaxyColors.cosmicBlue
                                    ])
                                  : null,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: isSelected && isDark ? [
                                BoxShadow(
                                  color: GalaxyColors.nebulaPurple.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ] : null,
                            ),
                            child: Text(tab,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : GalaxyColors.textSecond(isDark),
                                  fontFamily: 'Nunito',
                                )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Expanded(
            child: BlocBuilder<CommunityBloc, CommunityState>(
              builder: (context, state) {
                if (state is CommunityLoading || state is CommunityInitial) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: GalaxyColors.nebulaViolet));
                }
                if (state is CommunityLoaded) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.filteredResources.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _ResourceCard(
                      resource: state.filteredResources[index],
                      isDark: isDark,
                      onLike: () => context.read<CommunityBloc>().add(
                          CommunityResourceLiked(state.filteredResources[index].id)),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final bool isDark;
  final VoidCallback onLike;

  const _ResourceCard(
      {required this.resource, required this.isDark, required this.onLike});

  static const _tagGradients = {
    'Sensory':       [Color(0xFF7C3AED), Color(0xFFEC4899)],
    'Visual Aids':   [Color(0xFF059669), Color(0xFF0EA5E9)],
    'Social Skills': [Color(0xFF2563EB), Color(0xFF7C3AED)],
    'Communication': [Color(0xFFF97316), Color(0xFFEF4444)],
    'Routines':      [Color(0xFF0EA5E9), Color(0xFF059669)],
    'Feelings':      [Color(0xFFEC4899), Color(0xFFF97316)],
  };

  List<Color> get _gradient =>
      (_tagGradients[resource.tag] ??
          [GalaxyColors.nebulaViolet, GalaxyColors.cosmicBlue])
          .cast<Color>();

  @override
  Widget build(BuildContext context) {
    return GalaxyCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: _gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                    color: _gradient.first.withOpacity(isDark ? 0.5 : 0.25),
                    blurRadius: 10, spreadRadius: -2),
              ],
            ),
            child: const Icon(Icons.auto_stories_rounded,
                size: 22, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.title,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: GalaxyColors.textPrimary(isDark),
                      fontFamily: 'Nunito',
                    )),
                const SizedBox(height: 2),
                Text('${resource.author} · ${_typeLabel(resource.type)}',
                    style: TextStyle(
                      fontSize: 11, color: GalaxyColors.textSecond(isDark),
                      fontFamily: 'Nunito',
                    )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          _gradient.first.withOpacity(isDark ? 0.25 : 0.12),
                          _gradient.last.withOpacity(isDark ? 0.18 : 0.08),
                        ]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _gradient.first.withOpacity(isDark ? 0.4 : 0.25)),
                  ),
                  child: Text(resource.tag,
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: _gradient.first,
                        fontFamily: 'Nunito',
                      )),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onLike,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                resource.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(resource.isLiked),
                size: 22,
                color: resource.isLiked
                    ? GalaxyColors.stardustPink
                    : GalaxyColors.textSecond(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(ResourceType t) {
    switch (t) {
      case ResourceType.article:  return 'Article';
      case ResourceType.document: return 'Document';
      case ResourceType.guide:    return 'Guide';
      case ResourceType.resource: return 'Resource';
    }
  }
}
