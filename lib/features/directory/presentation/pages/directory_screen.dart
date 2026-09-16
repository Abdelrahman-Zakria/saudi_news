import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/directory_cubit.dart';
import '../cubit/directory_state.dart';
import '../../domain/entities/directory_contact.dart';
import 'contact_details_screen.dart';
import '../../../../core/services/iap_service.dart';
import '../../../../core/services/ad_service.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _numberController = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _handleSearch() async {
    final text = _numberController.text.trim();
    if (text.isEmpty || text.length < 3) {
      setState(() {
        _showError = true;
      });
      return;
    }

    setState(() {
      _showError = false;
    });

    final results = await context.read<DirectoryCubit>().performLookup(text);

    // Show interstitial ad after search results are fetched
    AdService().showInterstitialAd();

    // If exactly one result, go to details immediately.
    if (results.length == 1) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactDetailsScreen(contact: results.first)),
        );
      }
    }
  }

  void _showRemoveAdsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إزالة الإعلانات للأبد',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'استمتع بتجربة تصفح أسرع وأكثر سلاسة بدون أي إعلانات مزعجة داخل التطبيق.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    IAPService().buyRemoveAds();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006C35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'شراء الآن - ٣ دولار',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  IAPService().restorePurchases();
                },
                child: const Text('استعادة المشتروات'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const SizedBox.shrink(),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
          leading: StreamBuilder<bool>(
            stream: IAPService().proStatusStream,
            initialData: IAPService().isPro,
            builder: (context, snapshot) {
              if (snapshot.data == true) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showRemoveAdsDialog(context),
                child: const Text('إيقاف الإعلانات', style: TextStyle(color: Color(0xFF006C35), fontSize: 12)),
              );
            }
          ),
          leadingWidth: 100,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Search Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161B22) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'ادخل رقم هاتف سعودي',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF006C35)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D1117) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _numberController,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 18, letterSpacing: 2),
                          decoration: InputDecoration(
                            hintText: '05 - - - - - - - -',
                            hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 2),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (v) {
                            if (_showError && v.length >= 3) {
                              setState(() => _showError = false);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006C35),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'بحث',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_showError)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'الرجاء إدخال رقم هاتف سعودي صحيح',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 32),

              BlocBuilder<DirectoryCubit, DirectoryState>(
                builder: (context, state) {
                  if (state is DirectoryLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
                  }
                  
                  if (state is DirectoryLoaded && state.searchQuery.isNotEmpty) {
                    if (state.searchResults.isEmpty) {
                      return _buildNotFoundState(isDark);
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(isDark, "نتائج البحث"),
                        const SizedBox(height: 12),
                        ...state.searchResults.map((contact) => _buildContactItem(context, contact, isDark)).toList(),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _buildAd(isDark),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14, 
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey[400] : Colors.grey[700]
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, DirectoryContact contact, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactDetailsScreen(contact: contact)),
          );
        },
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF006C35).withOpacity(0.1),
          child: Text(
            contact.name.isNotEmpty ? contact.name[0] : "👤",
            style: const TextStyle(color: Color(0xFF006C35), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(contact.phone, textDirection: TextDirection.ltr, textAlign: TextAlign.right),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildNotFoundState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text("😕", style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            "عذراً، لم نتمكن من العثور على نتائج لهذا الرقم",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text(
            "تأكد من الرقم وحاول مرة أخرى",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAd(bool isDark) {
    return AdNative(adUnitId: AdIds.directoryNative);
  }
}
