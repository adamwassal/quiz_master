import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quiz_master/core/database/icon_mapper.dart';

class CategoryCard extends StatelessWidget {
  final String icon;
  final String categoryName;
  final int quizCount;
  final String primaryColor;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.categoryName,
    required this.quizCount,
    this.primaryColor = "#6366F1",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = Color(int.parse(primaryColor.replaceFirst('#', ''), radix: 16) | 0xFF000000);
    } catch (e) {
      print('Invalid color format for $primaryColor: $e');
      color = Theme.of(context).primaryColor;
    }

    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                getIconFromString(icon) ?? MdiIcons.helpCircle,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "$quizCount ${quizCount == 1 ? 'quiz' : 'quizzes'}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}