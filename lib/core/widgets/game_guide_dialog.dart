import 'package:flutter/material.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';

class GameGuideDialog extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final bool isDark;

  const GameGuideDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isDark,
  });

  static void show(BuildContext context, {
    required String title,
    required String description,
    required String icon,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      builder: (context) => GameGuideDialog(
        title: title,
        description: description,
        icon: icon,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GalaxyCard(
        glowing: true,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: GalaxyColors.textPrimary(isDark),
                  fontFamily: 'Nunito',
                )),
            const SizedBox(height: 16),
            Text(description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: GalaxyColors.textSecond(isDark),
                  fontFamily: 'Nunito',
                )),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    GalaxyColors.nebulaPurple,
                    GalaxyColors.cosmicBlue
                  ]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Let\'s Play! 🚀',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito',
                        fontSize: 16,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
