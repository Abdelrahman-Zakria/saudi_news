import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/directory_cubit.dart';
import '../cubit/directory_state.dart';
import '../../domain/entities/directory_contact.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_details_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Logic removed from here to prevent permission request on app startup
    
    _searchController.addListener(() {
      context.read<DirectoryCubit>().searchFirestore(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildSearchBar(isDark),
          Expanded(
            child: BlocBuilder<DirectoryCubit, DirectoryState>(
              builder: (context, state) {
                if (state is DirectoryLoading && !state.isSearchView) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
                }

                if (state is DirectoryError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.contact_phone_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text("يرجى منح الإذن للوصول إلى جهات الاتصال"),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<DirectoryCubit>().init();
                              context.read<DirectoryCubit>().syncUserContacts();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006C35)),
                            child: const Text("السماح بالوصول", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is DirectoryLoaded) {
                  final bool isSearch = state.isSearchView;
                  final contacts = isSearch ? state.searchResults : state.localContacts;

                  if (contacts.isEmpty) {
                    return _buildEmptyState(isSearch);
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: contacts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return _buildContactCard(context, contact, isDark, isSearch);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "ابحث في الدليل العام (اسم أو رقم)...",
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, DirectoryContact contact, bool isDark, bool isSearch) {
    final bool isEmergency = contact.category == 'طوارئ';

    return GestureDetector(
      onTap: () {
        if (isSearch) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactDetailsScreen(contact: contact)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFF1F1F1)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isEmergency 
                    ? Colors.red.withOpacity(0.1) 
                    : const Color(0xFF006C35).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                isEmergency ? "🚨" : (contact.name.isNotEmpty ? contact.name[0] : "👤"),
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: isEmergency ? Colors.red : const Color(0xFF006C35)
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.phone,
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
            if (!isSearch)
              IconButton(
                icon: const Icon(Icons.call, color: Color(0xFF006C35)),
                onPressed: () => launchUrl(Uri.parse('tel:${contact.phone}')),
              )
            else
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isSearch ? "🔍" : "👤", style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            isSearch ? "لم يتم العثور على نتائج في الدليل العام" : "لا توجد جهات اتصال محلية للعرض", 
            style: const TextStyle(color: Color(0xFF9CA3AF))
          ),
        ],
      ),
    );
  }
}
