import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_master/core/database/firestore.dart';
import 'package:quiz_master/core/widgets/categoryCard.dart';
import 'package:quiz_master/features/CategoryScreen/categoryScreen.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fireStoreService = FireStoreService();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Choose a Category',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: fireStoreService.getCategoriesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No categories found'));
                  }

                  final categoriesList = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: categoriesList.length,
                    itemBuilder: (context, index) {
                      final document = categoriesList[index];
                      final data = document.data() as Map<String, dynamic>;

                      final title = data['title'] as String? ?? 'No Title';
                      final icon = data['icon'] as String? ?? 'help_outline';
                      final primaryColor = data['primaryColor'] as String? ?? '#6366F1';
                      final totalQuizes = (data['totalQuizes'] as num?)?.toInt() ?? 0;
                      final quizesIDs = List<String>.from(data['quizesIds'] ?? []);

                      return CategoryCard(
                        icon: icon,
                        categoryName: title,
                        quizCount: totalQuizes,
                        primaryColor: primaryColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryScreen(
                                primaryColor: primaryColor,
                                quizesTotal: totalQuizes,
                                title: title,
                                quizesIDs: quizesIDs,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}