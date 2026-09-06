import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/directory_cubit.dart';
import '../cubit/directory_state.dart';
import '../../domain/entities/directory_contact.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../news/presentation/widgets/category_pills.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<CategoryItem> _categories = [
    CategoryItem(id: "الكل", label: "الكل"),
    CategoryItem(id: "طوارئ", label: "🚨 طوارئ"),
    CategoryItem(id: "تجارة", label: "🛍️ تجارة"),
    CategoryItem(id: "جهة اتصال شخصية", label: "👤 جهات اتصالي"),
    CategoryItem(id: "عام", label: "📁 عام"),
  ];

  @override
  void initState() {
    super.initState();
    context.read<DirectoryCubit>().init();
    
    _searchController.addListener(() {
      context.read<DirectoryCubit>().searchContacts(_searchController.text);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<DirectoryCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
          BlocBuilder<DirectoryCubit, DirectoryState>(
            buildWhen: (previous, current) => previous.activeCategory != current.activeCategory,
            builder: (context, state) {
              return CategoryPills(
                categories: _categories,
                activeCategoryId: state.activeCategory,
                onCategorySelected: (id) {
                  context.read<DirectoryCubit>().changeCategory(id);
                },
              );
            },
          ),
          Expanded(
            child: BlocBuilder<DirectoryCubit, DirectoryState>(
              builder: (context, state) {
                if (state is DirectoryLoading && state.searchQuery.isEmpty && state.activeCategory == "الكل") {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
                }

                if (state is DirectoryError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            "حدث خطأ أثناء تحميل البيانات.",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "يرجى التأكد من اتصال الإنترنت والمحاولة مرة أخرى.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
                          ),
                          TextButton(
                            onPressed: () => context.read<DirectoryCubit>().init(),
                            child: const Text("إعادة المحاولة", style: TextStyle(color: Color(0xFF006C35))),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (state is DirectoryLoaded || state is DirectoryLoading) {
                  final contacts = state is DirectoryLoaded ? state.contacts : <DirectoryContact>[];
                  final bool hasMore = state is DirectoryLoaded ? state.hasMore : false;

                  if (contacts.isEmpty && state is DirectoryLoaded) {
                    return _buildEmptyState();
                  }

                  return Stack(
                    children: [
                      ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: contacts.length + (hasMore ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == contacts.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF006C35))),
                            );
                          }
                          return _buildContactCard(contacts[index], isDark);
                        },
                      ),
                      if (state is DirectoryLoading && contacts.isNotEmpty)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: const LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006C35)),
                          ),
                        ),
                    ],
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
                  hintText: "ابحث عن اسم أو رقم...",
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<DirectoryCubit>().searchContacts("");
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

  Widget _buildContactCard(DirectoryContact contact, bool isDark) {
    final bool isEmergency = contact.category == 'طوارئ';

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
                if (contact.category != 'عام' && contact.category != 'الكل') ...[
                  const SizedBox(height: 4),
                  Text(
                    contact.category,
                    style: TextStyle(
                      color: isEmergency ? Colors.red : const Color(0xFF006C35), 
                      fontSize: 12, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF006C35)),
            onPressed: () async {
              final Uri url = Uri.parse('tel:${contact.phone}');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("📞", style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text("لم يتم العثور على نتائج", style: TextStyle(color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
