// // lib/features/dashboard/presentation/pages/dashboard_page.dart
// import 'package:autism_app/features/onboarding/widget/dashboard_widgets.dart';
// import 'package:autism_app/core/utils/contansts.dart';
// import 'package:autism_app/core/utils/widgets/nav_widgets.dart';
// import 'package:flutter/material.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Row(
//         children: [
//           // Sidebar (Visible on Tablet/Desktop)
//           if (MediaQuery.of(context).size.width > 900)
//             Container(
//               width: 260,
//               color: AppColors.sidebar,

//               child: const SidebarContent(),
//             ),

//           // Main Content Area
//           Expanded(
//             child: Column(
//               children: [
//                 _buildHeader(),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(24),
//                     child: _buildDashboardGrid(context),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       height: 70,
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(bottom: BorderSide(color: AppColors.border)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             "Overview",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.notifications_none),
//               ),
//               const CircleAvatar(
//                 backgroundColor: AppColors.primary,
//                 radius: 18,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDashboardGrid(BuildContext context) {
//     int crossAxisCount = MediaQuery.of(context).size.width > 1200 ? 4 : 2;
//     if (MediaQuery.of(context).size.width < 600) crossAxisCount = 1;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: crossAxisCount,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: 1.5,
//           children: const [
//             StatCard(
//               title: "Total Revenue",
//               value: "\$45,231",
//               icon: Icons.attach_money,
//               trend: "+12%",
//             ),
//             StatCard(
//               title: "Active Users",
//               value: "2,405",
//               icon: Icons.people_outline,
//               trend: "+5%",
//             ),
//             StatCard(
//               title: "New Projects",
//               value: "12",
//               icon: Icons.folder_open,
//               trend: "-2%",
//             ),
//             StatCard(
//               title: "Conversion",
//               value: "3.2%",
//               icon: Icons.bar_chart,
//               trend: "+0.4%",
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
//         _buildRecentActivityTable(),
//       ],
//     );
//   }

//   Widget _buildRecentActivityTable() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: const Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Recent Activity",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           Divider(height: 32),
//           // Add a ListView.builder here for actual data rows
//           Center(
//             child: Text(
//               "List of recent transactions/actions would appear here.",
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
