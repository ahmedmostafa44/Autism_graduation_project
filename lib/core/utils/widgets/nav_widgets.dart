// lib/features/dashboard/presentation/widgets/sidebar_content.dart
import 'package:autism_app/features/auth/bloc/auth_bloc.dart';
import 'package:autism_app/features/auth/bloc/auth_event.dart';
import 'package:autism_app/core/utils/contansts.dart';
import 'package:autism_app/core/utils/widgets/sidebar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SidebarContent extends StatelessWidget {
  const SidebarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand/Logo Area
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 32.0),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.primary, size: 30),
                const SizedBox(width: 10),
                Text(
                  "LOVABLE",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          SidebarItem(
            icon: Icons.grid_view_rounded,
            label: "Dashboard",
            isActive: true,
          ),
          SidebarItem(icon: Icons.analytics_outlined, label: "Analytics"),
          SidebarItem(icon: Icons.layers_outlined, label: "Projects"),
          SidebarItem(icon: Icons.settings_outlined, label: "Settings"),

          const Spacer(), // Pushes the logout button to the bottom
          // Logout Section
          const Divider(color: AppColors.border),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
