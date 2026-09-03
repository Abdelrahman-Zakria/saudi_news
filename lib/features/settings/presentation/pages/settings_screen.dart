import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final bool isDarkMode;

  const SettingsScreen({
    super.key,
    this.onThemeChanged,
    this.isDarkMode = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _breakingNews = true;
  bool _sportsNews = false;
  bool _jobsNews = true;
  String _selectedLanguage = 'العربية';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileCard(isDark),
            const SizedBox(height: 24),
            _buildSectionHeader('المظهر'),
            _buildSettingTile(
              title: 'الوضع الليلي',
              subtitle: 'تغيير سمة التطبيق',
              trailing: Switch.adaptive(
                value: widget.onThemeChanged != null ? widget.isDarkMode : isDark,
                onChanged: (value) {
                  if (widget.onThemeChanged != null) {
                    widget.onThemeChanged!(value);
                  }
                },
                activeTrackColor: theme.colorScheme.primary,
              ),
              icon: Icons.dark_mode_outlined,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('الإشعارات'),
            _buildSettingTile(
              title: 'أخبار عاجلة',
              trailing: Switch.adaptive(
                value: _breakingNews,
                onChanged: (value) => setState(() => _breakingNews = value),
                activeTrackColor: theme.colorScheme.primary,
              ),
              icon: Icons.flash_on_outlined,
            ),
            _buildSettingTile(
              title: 'أخبار الرياضة',
              trailing: Switch.adaptive(
                value: _sportsNews,
                onChanged: (value) => setState(() => _sportsNews = value),
                activeTrackColor: theme.colorScheme.primary,
              ),
              icon: Icons.sports_soccer_outlined,
            ),
            _buildSettingTile(
              title: 'تنبيهات الوظائف',
              trailing: Switch.adaptive(
                value: _jobsNews,
                onChanged: (value) => setState(() => _jobsNews = value),
                activeTrackColor: theme.colorScheme.primary,
              ),
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('عام'),
            _buildSettingTile(
              title: 'اللغة',
              subtitle: _selectedLanguage,
              icon: Icons.language,
              onTap: () {
                // Show language picker
              },
            ),
            _buildSettingTile(
              title: 'الموقع',
              subtitle: 'الرياض، المملكة العربية السعودية',
              icon: Icons.location_on_outlined,
              onTap: () {},
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {},
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF006C35),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'م',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مستخدم أخبار السعودية',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'مفضلتك • ٣ مقالات محفوظة',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFF1F1F1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
