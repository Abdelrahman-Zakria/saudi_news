import 'package:flutter/material.dart';
import '../../domain/entities/directory_item.dart';
import '../../data/repositories/directory_repository_impl.dart';
import 'directory_detail_screen.dart';
import 'package:saudi_news/features/news/presentation/widgets/category_pills.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _repository = DirectoryRepositoryImpl();
  String _activeCategory = "all";
  String _searchQuery = "";
  List<DirectoryItem> _allItems = [];
  bool _isLoading = true;

  final List<CategoryItem> _categories = [
    CategoryItem(id: "all", label: "الكل"),
    CategoryItem(id: "مستشفيات", label: "🏥 مستشفيات"),
    CategoryItem(id: "حكومي", label: "🏛 حكومي"),
    CategoryItem(id: "مطاعم", label: "🍽 مطاعم"),
    CategoryItem(id: "اتصالات", label: "📡 اتصالات"),
    CategoryItem(id: "طيران", label: "✈️ طيران"),
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _repository.getDirectoryItems();
    setState(() {
      _allItems = items;
      _isLoading = false;
    });
  }

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

  final saudiGreen = const Color(0xFF006C35);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: saudiGreen),
    );
    final isDark = theme.brightness == Brightness.dark;

    final filteredItems = _allItems.where((item) {
      final matchesCategory = _activeCategory == "all" || item.category == _activeCategory;
      final matchesSearch = item.name.contains(_searchQuery) || item.city.contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("دليل الهاتف", style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : Colors.black,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(isDark),
              CategoryPills(
                categories: _categories,
                activeCategoryId: _activeCategory,
                onCategorySelected: (id) {
                  setState(() => _activeCategory = id);
                },
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredItems.isEmpty
                        ? const Center(child: Text("لا توجد نتائج"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return _buildDirectoryCard(item, theme, isDark);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: "ابحث في الدليل...",
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryCard(DirectoryItem item, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              _getCategoryIcon(item.category),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Text("📍", style: TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text(item.city, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF00A651).withValues(alpha:0.1) : const Color(0xFF006C35).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.category,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF00A651) : const Color(0xFF006C35),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("⭐", style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  item.rating.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "›",
              style: TextStyle(
                fontSize: 18,
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DirectoryDetailScreen(item: item),
            ),
          );
        },
      ),
    );
  }
}
