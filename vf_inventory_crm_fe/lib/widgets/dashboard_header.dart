import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const DashboardHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      height: isMobile ? 50 : 70,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28),
      decoration: const BoxDecoration(
        color: AppColors.background,
        // border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Expanded(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         title,
          //         style: TextStyle(
          //           fontSize: isMobile ? 22 : 26,
          //           fontWeight: FontWeight.bold,
          //           color: AppColors.textPrimary,
          //         ),
          //       ),

          //       if (subtitle != null && !isMobile) ...[
          //         Text(
          //           subtitle!,
          //           style: const TextStyle(
          //             fontSize: 13,
          //             color: AppColors.textSecondary,
          //           ),
          //         ),
          //       ],
          //     ],
          //   ),
          // ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),

          const SizedBox(width: 8),

          const CircleAvatar(
            radius: 18,
            child: Icon(Icons.person_outline, size: 20),
          ),

          if (!isMobile) ...[
            const SizedBox(width: 10),

            const Text('Admin', style: TextStyle(fontWeight: FontWeight.w600)),

            const SizedBox(width: 20),
          ],
        ],
      ),
    );
  }
}
