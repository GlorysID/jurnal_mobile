import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/data_manager.dart';
import '../../core/routing/app_router.dart';
import '../widgets/section_header.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/version_service.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account & Settings',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Information
              SectionHeader(title: 'Profile Information'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingItem(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  subtitle: 'Update your account information',
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.editProfile);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingItem(
                  icon: Icons.security,
                  title: 'Change Password',
                  subtitle: 'Update your security credentials',
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.changePassword);
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Data Management
              SectionHeader(title: 'Data Management'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingItem(
                  icon: Icons.file_download_outlined,
                  title: 'Export to CSV',
                  subtitle: 'Save your trades as a spreadsheet',
                  onTap: () async {
                    try {
                      await ref.read(dataManagerProvider).exportCsv();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Exported successfully!'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingItem(
                  icon: Icons.file_upload_outlined,
                  title: 'Import from CSV',
                  subtitle: 'Load trades from a spreadsheet',
                  onTap: () async {
                    try {
                      await ref.read(dataManagerProvider).importCsv();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Imported successfully!'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Backup & Restore
              SectionHeader(title: 'Backup & Restore'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingItem(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Backup Database',
                  subtitle: 'Create a backup of your local database',
                  onTap: () async {
                    try {
                      await ref.read(dataManagerProvider).backupDatabase();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Backup created successfully!'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingItem(
                  icon: Icons.restore_outlined,
                  title: 'Restore Database',
                  subtitle: 'Restore from a previous backup file',
                  onTap: () async {
                    try {
                      await ref.read(dataManagerProvider).restoreDatabase();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Restored successfully! Restart app.',
                            ),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Testing/Development
              SectionHeader(title: 'Testing Tools'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingItem(
                  icon: Icons.bug_report_outlined,
                  title: 'Generate Dummy Data',
                  subtitle: 'Add 50 random trades for testing',
                  iconColor: AppTheme.warningColor,
                  onTap: () async {
                    try {
                      await ref.read(dataManagerProvider).generateDummyData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Generated 50 dummy trades!'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceAll('Exception: ', ''),
                            ),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingItem(
                  icon: Icons.delete_outline,
                  title: 'Delete All Trades',
                  subtitle: 'Clear all data from the database',
                  iconColor: AppTheme.errorColor,
                  isDisabled: false,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.cardDark,
                        title: const Text(
                          'Delete All Trades?',
                          style: TextStyle(color: AppTheme.textColor),
                        ),
                        content: const Text(
                          'This action cannot be undone. All trades will be permanently deleted.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppTheme.accentColor),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Delete feature will be available soon',
                                  ),
                                  backgroundColor: AppTheme.warningColor,
                                ),
                              );
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // About Section
              SectionHeader(title: 'About'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: AppTheme.getCardDecoration(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trading Journal Pro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A comprehensive trading journal application for tracking and analyzing your trades.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingItem(
                  icon: Icons.system_update_alt_outlined,
                  title: 'Check for Updates',
                  subtitle: 'Stay on the latest version',
                  onTap: () {
                    VersionService().checkForUpdate(
                      context,
                      showNoUpdate: true,
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDisabled = false,
    Color? iconColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled ? null : onTap,
      child: Container(
        decoration: AppTheme.getCardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.accentColor).withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDisabled
                          ? AppTheme.textSecondary
                          : AppTheme.textColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDisabled
                  ? AppTheme.textSecondary.withValues(alpha: 0.3)
                  : AppTheme.accentColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
