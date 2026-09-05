import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/directory_cubit.dart';
import '../cubit/directory_state.dart';
import '../../domain/entities/directory_contact.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start sync and initial fetch
    context.read<DirectoryCubit>().syncUserContacts();
    context.read<DirectoryCubit>().init();
    
    _searchController.addListener(() {
      context.read<DirectoryCubit>().searchContacts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildSearchBar(isDark),
          Expanded(
            child: BlocBuilder<DirectoryCubit, DirectoryState>(
              builder: (context, state) {
                if (state is DirectoryLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
                }

                if (state is DirectoryError) {
                  return Center(child: Text(state.message));
                }

                if (state is DirectoryLoaded) {
                  if (state.contacts.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.contacts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildContactCard(state.contacts[index], isDark);
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
                decoration: const InputDecoration(
                  hintText: "ابحث عن اسم أو رقم...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(DirectoryContact contact, bool isDark) {
    return Container(
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
              color: const Color(0xFF006C35).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              contact.name.isNotEmpty ? contact.name[0] : "👤",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006C35)),
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
                ),
                if (contact.category != 'عام') ...[
                  const SizedBox(height: 4),
                  Text(
                    contact.category,
                    style: const TextStyle(color: Color(0xFF006C35), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF006C35)),
            onPressed: () => launchUrl(Uri.parse('tel:${contact.phone}')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("📞", style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text("لم يتم العثور على نتائج", style: TextStyle(color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
