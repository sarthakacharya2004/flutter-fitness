import 'package:flutter/material.dart';

class MealDetailScreen extends StatefulWidget {
  final String title;
  final String image;
  final String calories;
  final String time;
  final String protein;
  final String recipe;

  const MealDetailScreen({
    Key? key,
    required this.title,
    required this.image,
    required this.calories,
    required this.time,
    required this.protein,
    required this.recipe,
  }) : super(key: key);

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  int _servings = 1; // Placeholder for future serving adjustments

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 16),
                  _buildNutritionSection(),
                  const SizedBox(height: 16),
                  _buildRecipeSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AppBar with background image
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.asset(
          widget.image,
          fit: BoxFit.cover,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: Implement favorite toggle
          },
        ),
      ],
    );
  }

  // Header title and share icon
  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Implement share functionality
          },
        ),
      ],
    );
  }

  // Nutrition info like calories, time, and protein
  Widget _buildNutritionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNutritionItem(
          Icons.local_fire_department,
          'Calories',
          widget.calories,
        ),
        _buildNutritionItem(
          Icons.timer_outlined,
          'Time',
          widget.time,
        ),
        _buildNutritionItem(
          Icons.fitness_center,
          'Protein',
          widget.protein,
        ),
      ],
    );
  }

  // Single nutrition card
  Widget _buildNutritionItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700]), // slightly darker icon
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Recipe section
  Widget _buildRecipeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipe',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.recipe,
          style: TextStyle(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
