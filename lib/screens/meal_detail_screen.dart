import 'dart:io';

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
        title: Text(_isEditing ? 'Edit Meal' : widget.title),
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
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildMealImage(),
              ),
            ),
            const SizedBox(height: 24),
            
            if (!_isEditing)
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.local_fire_department,
                    label: _isEditing
                        ? TextFormField(
                            controller: _caloriesController,
                            decoration: const InputDecoration(
                              labelText: 'Calories',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            ),
                          )
                        : Text(widget.calories),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.timer,
                    label: _isEditing
                        ? TextFormField(
                            controller: _timeController,
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            ),
                          )
                        : Text(widget.time),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.fitness_center,
                    label: _isEditing
                        ? TextFormField(
                            controller: _proteinController,
                            decoration: const InputDecoration(
                              labelText: 'Protein',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            ),
                          )
                        : Text(widget.protein),
                  ),
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
                    minLines: 3,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Expanded(
            child: label is TextFormField
                ? label
                : Text(
                    label is Text ? (label.data ?? '') : label.toString(),
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    try {
      await _firestoreService.updateMeal(widget.mealId, {
        'title': _titleController.text,
        'calories': _caloriesController.text,
        'time': _timeController.text,
        'protein': _proteinController.text,
        'recipe': _recipeController.text,
      });
      
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
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

    if (confirmed == true) {
      try {
        await _firestoreService.deleteMeal(widget.mealId);
        Navigator.pop(context, true); // Return true to indicate deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete meal: $e')),
        );
      }
    }
  }

  Widget _buildMealImage() {
    if (widget.image.isEmpty) {
      return const Center(
        child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
      );
    }

    if (widget.image.startsWith('http')) {
      return Image.network(
        widget.image,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(widget.image),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
        ),
      );
    }
  }
}