import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/color_utils.dart';

enum FeatureState {
  enabled,
  disabled,
  premiumRequired,
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currencySymbol = '\$';
  String _dateFormat = 'MM/dd/yyyy';
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currencySymbol = prefs.getString('currency_symbol') ?? '\$';
      _dateFormat = prefs.getString('date_format') ?? 'MM/dd/yyyy';
      _themeMode = prefs.getString('theme_mode') ?? 'system';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  FeatureState _getFeatureState(bool isPremium, bool isEnabled) {
    if (isPremium) {
      return FeatureState.enabled;
    }
    return isEnabled ? FeatureState.premiumRequired : FeatureState.disabled;
  }

  void _showPremiumDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: Text('$featureName is available with Premium. Upgrade to unlock this feature and many more!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium upgrade screen
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium upgrade coming soon')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF3E5F5),
            ],
          ),
        ),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildSectionHeader('Profile'),
                  _buildProfileCard(userProvider),

                  const SizedBox(height: 24),

                  // Preferences Section
                  _buildSectionHeader('Preferences'),
                  _buildPreferencesCard(),

                  const SizedBox(height: 24),

                  // Notifications Section
                  _buildSectionHeader('Notifications'),
                  _buildNotificationsCard(),

                  const SizedBox(height: 24),

                  // Data Management Section
                  _buildSectionHeader('Data Management'),
                  _buildDataManagementCard(),

                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionHeader('About'),
                  _buildAboutCard(),

                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildProfileCard(UserProvider userProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF4CAF50),
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userProvider.user.name ?? 'User',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userProvider.user.email ?? 'user@example.com',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showEditProfileDialog(context, userProvider),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingItem(
                  'Currency',
                  user.currencySymbol,
                  Icons.attach_money,
                  onTap: () => _showCurrencyDialog(userProvider),
                ),
                const Divider(),
                _buildSettingItem(
                  'Date Format',
                  _dateFormat,
                  Icons.calendar_today,
                  onTap: () => _showDateFormatDialog(),
                ),
                const Divider(),
                _buildSettingItem(
                  'Theme',
                  _getThemeDisplayName(_themeMode),
                  Icons.brightness_6,
                  onTap: () => _showThemeDialog(userProvider),
                ),
                const Divider(),
                _buildSettingItem(
                  'App Color',
                  _getColorDisplayName(userProvider.user.customPrimaryColor),
                  Icons.palette,
                  onTap: () => _showColorPickerDialog(userProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSwitchItem(
                  'Push Notifications',
                  'Receive budget and goal reminders',
                  user.pushNotificationsEnabled,
                  Icons.notifications,
                  (value) async {
                    if (value) {
                      // Request permission when enabling
                      final status = await Permission.notification.request();
                      if (mounted) {
                        if (status.isGranted) {
                          await userProvider.updatePushNotifications(true);
                        } else if (status.isPermanentlyDenied) {
                          // Show dialog to open settings
                          _showPermissionSettingsDialog();
                          return;
                        } else {
                          // Permission denied
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification permission is required')),
                          );
                          return;
                        }
                      }
                    } else {
                      await userProvider.updatePushNotifications(false);
                      // Disable sub-settings when push notifications are off
                      await userProvider.updateBudgetAlerts(false);
                      await userProvider.updateGoalReminders(false);
                    }
                  },
                ),
                const Divider(),
                _buildNotificationSubItem(
                  'Budget Alerts',
                  'Get notified when approaching limits',
                  Icons.warning,
                  user.pushNotificationsEnabled,
                  user.budgetAlertsEnabled,
                  true, // Always enabled
                  () async {
                    await userProvider.updateBudgetAlerts(!user.budgetAlertsEnabled);
                  },
                ),
                const Divider(),
                _buildNotificationSubItem(
                  'Goal Reminders',
                  'Reminders for savings goals',
                  Icons.savings,
                  user.pushNotificationsEnabled,
                  user.goalRemindersEnabled,
                  true, // Always enabled
                  () async {
                    await userProvider.updateGoalReminders(!user.goalRemindersEnabled);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataManagementCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataManagementItem(
                  'Backup & Restore',
                  'Export or import your data',
                  Icons.backup,
                  true, // Always available
                  () => context.go('/backup-data'),
                ),
                const Divider(),
                _buildDataManagementItem(
                  'Clear All Data',
                  'Permanently delete all data',
                  Icons.delete_forever,
                  true, // Always available
                  () => _showClearDataDialog(userProvider),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Finance & Budgeting App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Track your expenses, manage budgets, and achieve your savings goals with this comprehensive financial management app.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAboutButton('Privacy Policy', Icons.privacy_tip, () => _launchUrl('https://example.com/privacy')),
                _buildAboutButton('Terms of Service', Icons.description, () => _launchUrl('https://example.com/terms')),
                _buildAboutButton('Help & Support', Icons.help, () => _launchUrl('https://example.com/support')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, {
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF4CAF50)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: color ?? Colors.grey.shade600,
        ),
      ),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool value, IconData icon, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildNotificationSubItem(String title, String subtitle, IconData icon, bool pushEnabled, bool value, bool isPremium, VoidCallback onTap) {
    final isEnabled = pushEnabled && (isPremium || value);
    final iconColor = isEnabled ? const Color(0xFF4CAF50) : Colors.grey;
    final textColor = isEnabled ? null : Colors.grey;
    final subtitleText = !pushEnabled
        ? 'Enable push notifications first'
        : !isPremium && !value
            ? 'Premium feature'
            : subtitle;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitleText,
        style: TextStyle(
          fontSize: 14,
          color: textColor ?? Colors.grey.shade600,
        ),
      ),
      trailing: isEnabled ? Switch(
        value: value,
        onChanged: (newValue) => onTap(),
        activeThumbColor: const Color(0xFF4CAF50),
      ) : (!pushEnabled ? null : IconButton(
        icon: const Icon(Icons.lock, color: Colors.amber),
        onPressed: onTap,
      )),
      onTap: isEnabled ? onTap : (!pushEnabled ? null : onTap),
    );
  }

  Widget _buildDataManagementItem(String title, String subtitle, IconData icon, bool isPremium, VoidCallback onTap, {Color? color}) {
    final iconColor = isPremium ? (color ?? const Color(0xFF4CAF50)) : Colors.grey;
    final textColor = isPremium ? color : Colors.grey;
    final subtitleText = isPremium ? subtitle : 'Premium feature - Upgrade to unlock';

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitleText,
        style: TextStyle(
          fontSize: 14,
          color: textColor ?? Colors.grey.shade600,
        ),
      ),
      trailing: isPremium ? const Icon(Icons.chevron_right) : IconButton(
        icon: const Icon(Icons.lock, color: Colors.amber),
        onPressed: onTap,
      ),
      onTap: onTap,
    );
  }

  Widget _buildAboutButton(String title, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4CAF50),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    final nameController = TextEditingController(text: userProvider.user.name ?? '');
    final emailController = TextEditingController(text: userProvider.user.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update user profile
              final updatedUser = userProvider.user.copyWith(
                name: nameController.text,
                email: emailController.text,
              );
              if (context.mounted) {
                if (updatedUser != null) {
                  await userProvider.updateUser(updatedUser);
                  if (mounted) {
                    Navigator.of(context).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully')),
                      );
                    }
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(UserProvider userProvider) {
    final currencies = [
      {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
      {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
      {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
      {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
      {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
      {'code': 'RUB', 'symbol': '₽', 'name': 'Russian Ruble'},
      {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
      {'code': 'MXN', 'symbol': 'MX\$', 'name': 'Mexican Peso'},
      {'code': 'PKR', 'symbol': '₨', 'name': 'Pakistani Rupee'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return ListTile(
                title: Text('${currency['symbol']} ${currency['name']}'),
                subtitle: Text(currency['code'] as String),
                onTap: () async {
                  await userProvider.updateCurrency(currency['code'] as String);
                  setState(() {
                    _currencySymbol = currency['symbol'] as String;
                  });
                  _saveSetting('currency_symbol', currency['symbol']);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDateFormatDialog() {
    final formats = ['MM/dd/yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) => ListTile(
            title: Text(format),
            onTap: () {
              setState(() {
                _dateFormat = format;
              });
              _saveSetting('date_format', format);
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showNotificationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: const Text('Notification permission has been permanently denied. Please enable it in your device settings to receive notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted) {
                openAppSettings();
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Your financial data will be exported as a JSON file. This may take a few moments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement data export
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export feature coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('Select a backup file to import your financial data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement data import
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data import feature coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This action cannot be undone. All your financial data will be permanently deleted. This includes transactions, budgets, savings goals, and categories.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (context.mounted) {
                Navigator.of(context).pop();
                // Clear all data
                await userProvider.clearAllData();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been cleared')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  String _getThemeDisplayName(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
      default:
        return 'System Default';
    }
  }

  void _showThemeDialog(UserProvider userProvider) {
    final themes = [
      {'mode': 'system', 'name': 'System Default', 'icon': Icons.brightness_auto},
      {'mode': 'light', 'name': 'Light', 'icon': Icons.brightness_5},
      {'mode': 'dark', 'name': 'Dark', 'icon': Icons.brightness_2},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) => ListTile(
            leading: Icon(theme['icon'] as IconData),
            title: Text(theme['name'] as String),
            onTap: () async {
              await userProvider.updateThemeMode(theme['mode'] as String);
              setState(() {
                _themeMode = theme['mode'] as String;
              });
              _saveSetting('theme_mode', theme['mode']);
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: const Text('Notification permission has been permanently denied. Please enable it in your device settings to receive notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted) {
                openAppSettings();
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  String _getColorDisplayName(int? colorValue) {
    if (colorValue == null) return 'Default (Green)';
    final color = Color(colorValue);
    return ColorUtils.getColorName(color);
  }

  void _showColorPickerDialog(UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose App Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a color theme for your app:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ColorUtils.customColorOptions.map((color) {
                  final isSelected = userProvider.user.customPrimaryColor == color.toARGB32();
                  return GestureDetector(
                    onTap: () async {
                      await userProvider.updateCustomPrimaryColor(color.toARGB32());
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('App color changed to ${ColorUtils.getColorName(color)}'),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async {
                      await userProvider.updateCustomPrimaryColor(null);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reset to default color')),
                      );
                    },
                    child: const Text('Reset to Default'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showAdvancedColorPicker(userProvider),
                    child: const Text('Custom Color'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAdvancedColorPicker(UserProvider userProvider) {
    Color selectedColor = userProvider.user.customPrimaryColor != null
        ? Color(userProvider.user.customPrimaryColor!)
        : Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Custom Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsl,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await userProvider.updateCustomPrimaryColor(selectedColor.toARGB32());
              if (mounted) {
                Navigator.of(context).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Custom color applied')),
                  );
                }
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (mounted) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }
}
