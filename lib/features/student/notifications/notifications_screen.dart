import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<_NotifItem> _items = [
    _NotifItem(
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      iconBgColor: AppColors.successLight,
      title: 'Attendance Marked',
      description: 'Your attendance for 20 May 2024 has been marked.',
      date: '20 May 2024',
    ),
    _NotifItem(
      icon: Icons.currency_rupee_rounded,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.primaryLight,
      title: 'Fees Payment Successful',
      description: 'Your payment of ₹10,000 is received.',
      date: '12 May 2024',
    ),
    _NotifItem(
      icon: Icons.description_outlined,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.primaryLight,
      title: 'New Notice',
      description: 'College will remain closed on 25 May 2024.',
      date: '10 May 2024',
    ),
    _NotifItem(
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.warning,
      iconBgColor: AppColors.warningLight,
      title: 'Attendance Reminder',
      description: 'Please mark your attendance for today.',
      date: '08 May 2024',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Mark all read',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none_rounded,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('No notifications yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (context, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _NotifCard(item: _items[index], isRead: index > 1),
            ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  final bool isRead;

  const _NotifCard({required this.item, required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead
            ? Theme.of(context).cardTheme.color
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: isRead
            ? null
            : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item.title,
                          style: AppTextStyles.titleSmall.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.description,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 6),
                Text(item.date,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;
  final String date;

  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.date,
  });
}
