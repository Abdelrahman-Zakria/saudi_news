import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String label;

  CategoryItem({required this.id, required this.label});
}

class CategoryPills extends StatelessWidget {
  final List<CategoryItem> categories;
  final String activeCategoryId;
  final Function(String) onCategorySelected;

  const CategoryPills({
    super.key,
    required this.categories,
    required this.activeCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: categories.map((category) {
          final isActive = category.id == activeCategoryId;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: () => onCategorySelected(category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.colorScheme.primary
                      : (isDark ? const Color(0xFF1F2937) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? theme.colorScheme.primary
                        : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha:0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  category.label,
                  style: TextStyle(
                    color: isActive ? Colors.white : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
