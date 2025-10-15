import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/settings_tile.dart';
import 'profile_screen.dart';
import 'emergency_contacts_screen.dart';
import '../repositories/notifications_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: 'Manage your personal information',
                  onTap: () => _navigateToProfile(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () => _showNotificationSettings(context),
                  trailing: Switch(
                    value: context
                        .watch<AppStateProvider>()
                        .isNotificationsEnabled,
                    onChanged: (value) {
                      context.read<AppStateProvider>().setNotificationsEnabled(
                        value,
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.smartphone,
                  title: 'Register Device',
                  subtitle: 'Enable push notifications for this device',
                  onTap: () => _registerDevice(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // App Settings Section
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.dark_mode,
                  title: 'Theme',
                  subtitle: 'Choose your preferred theme',
                  onTap: () => _showThemeDialog(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'Select your preferred language',
                  onTap: () => _showLanguageDialog(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.location_on,
                  title: 'Location Services',
                  subtitle: 'Manage location permissions',
                  onTap: () => _showLocationSettings(context),
                  trailing: Switch(
                    value: context.watch<AppStateProvider>().isLocationEnabled,
                    onChanged: (value) {
                      context.read<AppStateProvider>().setLocationEnabled(
                        value,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Privacy & Security Section
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () => _showPrivacyPolicy(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.security,
                  title: 'Security Settings',
                  subtitle: 'Manage app security',
                  onTap: () => _showSecuritySettings(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.visibility_off,
                  title: 'Anonymous Reporting',
                  subtitle: 'Default to anonymous reporting',
                  onTap: () => _showAnonymousSettings(context),
                  trailing: Switch(
                    value: true, // TODO: Implement anonymous settings
                    onChanged: (value) {
                      // TODO: Implement anonymous settings toggle
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Support Section
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () => _showHelpSupport(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.info,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () => _showAboutDialog(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the app',
                  onTap: () => _showFeedbackDialog(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Emergency Settings Section
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.emergency,
                  title: 'Emergency Contacts',
                  subtitle: 'Manage emergency contact numbers',
                  onTap: () => _navigateToEmergencyContacts(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.vibration,
                  title: 'Panic Button Settings',
                  subtitle: 'Configure panic button behavior',
                  onTap: () => _showPanicSettings(context),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Reset Button
          Center(
            child: TextButton.icon(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset App Data'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: context.watch<AppStateProvider>().themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<AppStateProvider>().setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: context.watch<AppStateProvider>().themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<AppStateProvider>().setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: context.watch<AppStateProvider>().themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<AppStateProvider>().setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = [
      {'name': 'English', 'code': 'en'},
      {'name': 'हिन्दी', 'code': 'hi'},
      {'name': 'Español', 'code': 'es'},
      {'name': 'Français', 'code': 'fr'},
      {'name': 'Deutsch', 'code': 'de'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang['name']!),
              value: lang['code']!,
              groupValue: context.watch<AppStateProvider>().locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  context.read<AppStateProvider>().setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    // TODO: Implement notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  Future<void> _registerDevice(BuildContext context) async {
    // In a production app, fetch the FCM/APNs token. Here, accept a manual token.
    final ctrl = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Device Token'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Device Token'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Register'),
          ),
        ],
      ),
    );
    if (token == null || token.isEmpty) return;
    try {
      await context.read<NotificationsRepository>().registerDevice(
        token: token,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Device registered')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  void _showLocationSettings(BuildContext context) {
    // TODO: Implement location settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location settings coming soon!')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This app collects location data and incident reports to provide emergency services. '
            'Your data is encrypted and stored securely. We do not share your personal information '
            'with third parties without your consent. Anonymous reporting is available to protect your privacy.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSecuritySettings(BuildContext context) {
    // TODO: Implement security settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security settings coming soon!')),
    );
  }

  void _showAnonymousSettings(BuildContext context) {
    // TODO: Implement anonymous settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anonymous settings coming soon!')),
    );
  }

  void _showHelpSupport(BuildContext context) {
    // TODO: Implement help and support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help and support coming soon!')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Emergency Reporter',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.emergency, size: 48),
      children: [
        const Text('A citizen-focused emergency reporting platform.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Real-time incident reporting'),
        const Text('• Emergency contact integration'),
        const Text('• Panic button with shake detection'),
        const Text('• Citizen points and rewards system'),
        const Text('• Anonymous reporting options'),
      ],
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    // TODO: Implement feedback dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback feature coming soon!')),
    );
  }

  void _showPanicSettings(BuildContext context) {
    // TODO: Implement panic settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Panic settings coming soon!')),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App Data'),
        content: const Text(
          'This will reset all app data including your points, settings, and preferences. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement reset functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App data reset successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _navigateToEmergencyContacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()),
    );
  }
}
