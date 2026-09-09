import 'package:flutter/material.dart';
import 'package:saudi_news/features/directory/domain/entities/directory_contact.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailsScreen extends StatelessWidget {
  final DirectoryContact contact;

  const ContactDetailsScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final saudiGreen = const Color(0xFF006C35);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('تفاصيل جهة الاتصال', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : Colors.black,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: contact.category == 'طوارئ' 
                            ? Colors.red.withOpacity(0.1) 
                            : saudiGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        contact.category == 'طوارئ' ? "🚨" : (contact.name.isNotEmpty ? contact.name[0] : "👤"),
                        style: TextStyle(
                          fontSize: 40, 
                          fontWeight: FontWeight.bold, 
                          color: contact.category == 'طوارئ' ? Colors.red : saudiGreen
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      contact.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contact.category,
                      style: TextStyle(
                        fontSize: 16, 
                        color: contact.category == 'طوارئ' ? Colors.red : saudiGreen,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    context, 
                    Icons.call, 
                    "اتصال", 
                    () => launchUrl(Uri.parse('tel:${contact.phone}')),
                    saudiGreen
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFF1F1F1)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.phone_android, "رقم الجوال", contact.phone, isDark),
                    if (contact.email != null && contact.email!.isNotEmpty)
                      _buildDetailRow(Icons.email_outlined, "البريد الإلكتروني", contact.email!, isDark),
                    if (contact.region != null && contact.region!.isNotEmpty)
                      _buildDetailRow(Icons.location_on_outlined, "المنطقة", contact.region!, isDark),
                    if (contact.website != null && contact.website!.isNotEmpty)
                      _buildDetailRow(Icons.language_outlined, "الموقع الإلكتروني", contact.website!, isDark),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Text(
                "المصدر: ${contact.source == 'official_emergency' ? 'جهات رسمية' : contact.source}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, Color color) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
