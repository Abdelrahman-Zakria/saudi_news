import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/directory_item.dart';

class DirectoryDetailScreen extends StatelessWidget {
  final DirectoryItem item;

  const DirectoryDetailScreen({super.key, required this.item});

  String _getCategoryIcon(String category) {
    switch (category) {
      case "مستشفيات": return "🏥";
      case "حكومي": return "🏛";
      case "مطاعم": return "🍽";
      case "اتصالات": return "📡";
      case "طيران": return "✈️";
      default: return "📍";
    }
  }

  Future<void> _makeCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: item.phone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMaps() async {
    final String query = Uri.encodeComponent("${item.name} ${item.address}");
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp() async {
    final String url = "https://wa.me/${item.phone}";
    final Uri whatsappUri = Uri.parse(url);
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saudiGreen = const Color(0xFF006C35);
    final theme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: saudiGreen),
    );
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : Colors.black,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Large Icon
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryIcon(item.category),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          item.category,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF006C35),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Detail Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: "📞",
                      title: "رقم الهاتف",
                      value: item.phone,
                      theme: theme,
                      isDark: isDark,
                      isLtr: true,
                    ),
                    const Divider(height: 24, color: Color(0xFF1F2937)),
                    _buildInfoTile(
                      icon: "📍",
                      title: "العنوان",
                      value: item.address,
                      theme: theme,
                      isDark: isDark,
                    ),
                    const Divider(height: 24, color: Color(0xFF1F2937)),
                    _buildInfoTile(
                      icon: "⭐",
                      title: "التقييم",
                      value: "${item.rating} / ٥",
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: "اتصال",
                      icon: "📞",
                      color: const Color(0xFF006C35),
                      onPressed: _makeCall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: "الموقع",
                      icon: "🗺",
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      textColor: isDark ? Colors.white : const Color(0xFF374151),
                      borderColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      onPressed: _openMaps,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: "واتساب",
                icon: "💬",
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                textColor: isDark ? Colors.white : const Color(0xFF374151),
                borderColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                onPressed: _openWhatsApp,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String icon,
    required String title,
    required String value,
    required ThemeData theme,
    required bool isDark,
    bool isLtr = false,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
                textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required String icon,
    required Color color,
    required VoidCallback onPressed,
    Color textColor = Colors.white,
    Color? borderColor,
    bool isFullWidth = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: isFullWidth ? const Size(double.infinity, 50) : const Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
