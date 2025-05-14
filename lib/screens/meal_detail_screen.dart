import 'package:flutter/material.dart';
import 'package:fitness_hub/services/firestore_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  final String title;
  final String calories;
  final String time;
  final String protein;
  final String image;
  final String recipe;

  const MealDetailScreen({
    super.key,
    required this.mealId,
    required this.title,
    required this.calories,
    required this.time,
    required this.protein,
    required this.image,
    required this.recipe,
  });

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _caloriesController;
  late TextEditingController _timeController;
  late TextEditingController _proteinController;
  late TextEditingController _recipeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _caloriesController = TextEditingController(text: widget.calories);
    _timeController = TextEditingController(text: widget.time);
    _proteinController = TextEditingController(text: widget.protein);
    _recipeController = TextEditingController(text: widget.recipe);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caloriesController.dispose();
    _timeController.dispose();
    _proteinController.dispose();
    _recipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEditing,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _toggleEditing,
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteMeal,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(widget.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isEditing
                ? TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  )
                : Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(
                  icon: Icons.local_fire_department,
                  label: _isEditing
                      ? TextFormField(
                          controller: _caloriesController,
                          decoration: const InputDecoration(labelText: 'Calories'),
                        )
                      : Text(widget.calories),
                ),
                _buildInfoChip(
                  icon: Icons.timer,
                  label: _isEditing
                      ? TextFormField(
                          controller: _timeController,
                          decoration: const InputDecoration(labelText: 'Time'),
                        )
                      : Text(widget.time),
                ),
                _buildInfoChip(
                  icon: Icons.fitness_center,
                  label: _isEditing
                      ? TextFormField(
                          controller: _proteinController,
                          decoration: const InputDecoration(labelText: 'Protein'),
                        )
                      : Text(widget.protein),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recipe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _isEditing
                ? TextFormField(
                    controller: _recipeController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Recipe Instructions',
                    ),
                  )
                : Text(
                    widget.recipe,
                    style: const TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required Widget label}) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: label,
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

 Future<void> _saveChanges() async {
  try {
    // Creating a map of fields that can be updated
    final updatedMealData = {
      'title': _titleController.text,
      'calories': _caloriesController.text,
      'time': _timeController.text,
      'protein': _proteinController.text,
      'recipe': _recipeController.text,
    };

    // Call to FirestoreService to update the meal using the mealId
    await _firestoreService.updateMeal(widget.mealId, updatedMealData);
    
    // Toggle the edit mode and show a confirmation snackbar
    _toggleEditing();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal updated successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update meal: $e')),
    );
  }
}


  Future<void> _deleteMeal() async {
  // Confirm deletion with a different approach
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Deletion'),
      content: const Text('This will permanently delete the meal. Are you sure?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  // If confirmed, delete the meal
  if (confirmed == true) {
    try {
      // Call Firestore service to delete the meal by mealId
      await _firestoreService.deleteMeal(widget.mealId);
      Navigator.pop(context, true); // Return true to indicate deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete meal: $e')),
      );
    }
  }
}
}