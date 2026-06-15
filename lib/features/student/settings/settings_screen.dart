import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _appNotifications = true;
  bool _attendanceReminder = true;

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.titleLarge),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Password', style: AppTextStyles.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password changed successfully!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _sectionHeader('Account'),
            const SizedBox(height: 8),
            _settingsCard(context, [
              _settingsTile(
                context,
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                onTap: _showChangePasswordDialog,
              ),
              _divider(),
              _settingsTile(
                context,
                icon: Icons.person_outline_rounded,
                title: 'Update Profile',
                onTap: () => _showDialog('Update Profile',
                    'Profile editing feature is coming soon.'),
              ),
            ]),
            const SizedBox(height: 20),

            // Preferences section
            _sectionHeader('Preferences'),
            const SizedBox(height: 8),
            _settingsCard(context, [
              _switchTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              _divider(),
              _switchTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'App Notifications',
                value: _appNotifications,
                onChanged: (v) => setState(() => _appNotifications = v),
              ),
              _divider(),
              _switchTile(
                context,
                icon: Icons.alarm_outlined,
                title: 'Reminder for Attendance',
                value: _attendanceReminder,
                onChanged: (v) => setState(() => _attendanceReminder = v),
              ),
            ]),
            const SizedBox(height: 20),

            // Support section
            _sectionHeader('Support'),
            const SizedBox(height: 8),
            _settingsCard(context, [
              _settingsTile(
                context,
                icon: Icons.help_outline_rounded,
                title: 'Help & FAQs',
                onTap: () => _showDialog('Help & FAQs',
                    'For assistance, contact your class teacher or admin.'),
              ),
              _divider(),
              _settingsTile(
                context,
                icon: Icons.support_agent_rounded,
                title: 'Contact Support',
                onTap: () => _showDialog('Contact Support',
                    'Email us at support@veeravidhai.com'),
              ),
            ]),
            const SizedBox(height: 32),

            // App version
            Center(
              child: Text(
                'App Version 1.0.0',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.primary, fontWeight: FontWeight.bold),
    );
  }

  Widget _settingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _switchTile(BuildContext context,
      {required IconData icon,
      required String title,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56, endIndent: 16);
}
