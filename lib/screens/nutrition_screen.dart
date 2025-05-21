import 'package:fitness_hub/services/firestore_service.dart';
import 'package:fitness_hub/services/goal_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'workout_screen.dart';
import 'meal_detail_screen.dart';
import 'add_meal_screen.dart';
import 'dart:io'; // Import dart:io for File operations

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final int _currentPage = 0;
  String _selectedCategory = 'All';
  final FirestoreService _firestoreService = FirestoreService();
  final GoalService _goalService = GoalService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _meals = [];
  bool isLoading = true;
  String _imageUrl = '';
  Set<String> _favoriteMealIds = {};

  Future<void> _loadImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imageUrl = prefs.getString('imageUrl') ?? 'https://example.com/default-image.jpg';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _initializeNutritionPlan();
    _loadImageUrl();
    _loadFavorites();
  }

  Future<void> _initializeNutritionPlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userGoal = await _goalService.getUserGoal(user.uid);
      setState(() {
        if (userGoal == 'Gain Muscles') {
          _meals = _gainMuscleNutrition.expand((category) => category['meals'] as List<Map<String, dynamic>>).toList();
        } else if (userGoal == 'Lose Weight') {
          _meals = _loseWeightNutrition.expand((category) => category['meals'] as List<Map<String, dynamic>>).toList();
        } else {
          _meals = _maintainNutrition.expand((category) => category['meals'] as List<Map<String, dynamic>>).toList();
        }
        isLoading = false;
      });
    }
  }

  Future<void> _loadMeals() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userGoal = await _goalService.getUserGoal(user.uid);
        
        // Get goal-specific meals
        List<Map<String, dynamic>> goalMeals;
        if (userGoal == 'Gain Muscles') {
          goalMeals = _gainMuscleNutrition.expand((category) => 
            (category['meals'] as List<Map<String, dynamic>>).map((meal) => {
              ...meal,
              'id': 'goal_${meal['title'].toString().toLowerCase().replaceAll(' ', '_')}',
            })
          ).toList();
        } else if (userGoal == 'Lose Weight') {
          goalMeals = _loseWeightNutrition.expand((category) => 
            (category['meals'] as List<Map<String, dynamic>>).map((meal) => {
              ...meal,
              'id': 'goal_${meal['title'].toString().toLowerCase().replaceAll(' ', '_')}',
            })
          ).toList();
        } else {
          goalMeals = _maintainNutrition.expand((category) => 
            (category['meals'] as List<Map<String, dynamic>>).map((meal) => {
              ...meal,
              'id': 'goal_${meal['title'].toString().toLowerCase().replaceAll(' ', '_')}',
            })
          ).toList();
        }
        
        // Combine with default meals and update state
        setState(() {
          _meals = [...goalMeals, ..._defaultMeals];
        });
      } else {
        setState(() {
          _meals = _defaultMeals;
        });
      }
    } catch (e) {
      print('Error loading meals: $e');
      setState(() {
        _meals = _defaultMeals;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc('meals')
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            _favoriteMealIds = (doc.data()?['mealIds'] as List<dynamic>? ?? [])
                .map((id) => id.toString())
                .toSet();
          });
        }
      } catch (e) {
        print('Error loading favorites: $e');
      }
    }
  }

  Future<void> _toggleFavorite(String mealId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      if (_favoriteMealIds.contains(mealId)) {
        _favoriteMealIds.remove(mealId);
      } else {
        _favoriteMealIds.add(mealId);
      }
    });
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc('meals')
          .set({
        'mealIds': _favoriteMealIds.toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving favorite: $e');
      // Revert the state if saving fails
      setState(() {
        if (_favoriteMealIds.contains(mealId)) {
          _favoriteMealIds.remove(mealId);
        } else {
          _favoriteMealIds.add(mealId);
        }
      });
    }
  }

  final List<Map<String, dynamic>> _dietCategories = [
    {'name': 'All', 'icon': Icons.all_inclusive, 'description': 'All Meal Types', 'image': 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'},
    {'name': 'Vegetarian', 'icon': Icons.grass, 'description': 'Plant-Based Meals', 'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'},
    {'name': 'Protein', 'icon': Icons.fitness_center, 'description': 'High Protein Diets', 'image': 'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'},
    {'name': 'Low Carb', 'icon': Icons.food_bank, 'description': 'Low Carbohydrate Meals', 'image': 'https://images.unsplash.com/photo-1512058564366-c9e7b5f7f6b3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'},
    {'name': 'Keto', 'icon': Icons.local_pizza, 'description': 'Ketogenic Diet Meals', 'image': 'https://images.unsplash.com/photo-1562967916-eb82221dfb5b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'},
    {'name': 'Vegan', 'icon': Icons.eco, 'description': 'Plant-Based No Animal Products', 'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'},
  ];

  // Default meals for each category
  final List<Map<String, dynamic>> _defaultMeals = [
    // Vegetarian meals
    {
      'id': 'veg1',
      'title': 'Vegetable Stir Fry',
      'calories': '320 kcal',
      'time': '15 min',
      'protein': '12g protein',
      'category': 'Vegetarian',
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'recipe': '1. Heat oil in a pan\n2. Add vegetables\n3. Stir fry for 10 minutes\n4. Add sauce and serve'
    },
    // Vegetarian Low Carb meals
    {
      'id': 'veg_lc1',
      'title': 'Cauliflower Rice Bowl',
      'calories': '250 kcal',
      'time': '20 min',
      'protein': '15g protein',
      'category': 'Low Carb',
      'image': 'https://images.unsplash.com/photo-1592417817098-8fd3d9eb14a5?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'recipe': '1. Rice cauliflower in food processor\n2. Sauté with olive oil\n3. Add seasoning and vegetables\n4. Serve hot'
    },
    {
      'id': 'veg_lc2',
      'title': 'Zucchini Noodle Salad',
      'calories': '180 kcal',
      'time': '15 min',
      'protein': '8g protein',
      'category': 'Low Carb',
      'image': 'https://images.unsplash.com/photo-1599020792689-9fde458e7e17?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'recipe': '1. Spiralize zucchini\n2. Add cherry tomatoes and olives\n3. Toss with olive oil and herbs\n4. Season to taste'
    },
    // Vegetarian Keto meals
    {
      'id': 'veg_k1',
      'title': 'Keto Cauliflower Mac',
      'calories': '350 kcal',
      'time': '25 min',
      'protein': '18g protein',
      'category': 'Keto',
      'image': 'https://images.unsplash.com/photo-1543339318-b43b1278d8f5?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'recipe': '1. Steam cauliflower florets\n2. Prepare cheese sauce\n3. Combine and bake\n4. Top with herbs'
    },
    {
      'title': 'Avocado Caprese Salad',
      'calories': '420 kcal',
      'time': '10 min',
      'protein': '12g protein',
      'category': 'Keto',
      'image': 'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'recipe': '1. Slice avocado and mozzarella\n2. Arrange with basil leaves\n3. Drizzle with olive oil\n4. Season with salt and pepper'
    }
  ];

  // Goal-specific nutrition plans
  final List<Map<String, dynamic>> _gainMuscleNutrition = [
    {
      'name': 'High Protein',
      'icon': Icons.fitness_center,
      'description': 'Meals rich in protein to support muscle growth',
      'meals': [
        {
          'title': 'Grilled Chicken Breast',
          'calories': '300 kcal',
          'time': '20 min',
          'protein': '40g',
          'image': 'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Season chicken\n2. Grill for 8 mins per side\n3. Rest and serve',
          'category': 'Protein'
        },
        {
          'title': 'Salmon Fillet',
          'calories': '350 kcal',
          'time': '25 min',
          'protein': '42g',
          'image': 'https://images.unsplash.com/photo-1485921325833-c519f76c4927?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Season salmon\n2. Pan-sear for 5 mins each side\n3. Serve with lemon',
          'category': 'Protein'
        },
        {
          'title': 'Greek Yogurt Bowl',
          'calories': '280 kcal',
          'time': '5 min',
          'protein': '25g',
          'image': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Add Greek yogurt to bowl\n2. Top with nuts and berries\n3. Drizzle honey',
          'category': 'Protein'
        },
      ],
    },
    {
      'name': 'Complex Carbs',
      'icon': Icons.grain,
      'description': 'Energy-rich complex carbohydrates for sustained energy',
      'meals': [
        {
          'title': 'Sweet Potato Bowl',
          'calories': '280 kcal',
          'time': '25 min',
          'protein': '8g',
          'image': 'https://images.unsplash.com/photo-1590301157890-4810ed352733?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Bake sweet potato\n2. Top with cinnamon\n3. Add nuts and honey',
          'category': 'Carbs'
        },
        {
          'title': 'Brown Rice Pilaf',
          'calories': '320 kcal',
          'time': '30 min',
          'protein': '7g',
          'image': 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Cook brown rice\n2. Sauté vegetables\n3. Mix and season',
          'category': 'Carbs'
        },
        {
          'title': 'Quinoa Power Bowl',
          'calories': '310 kcal',
          'time': '20 min',
          'protein': '12g',
          'image': 'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Cook quinoa\n2. Add roasted vegetables\n3. Top with seeds',
          'category': 'Carbs'
        },
      ],
    },
    {
      'name': 'Healthy Fats',
      'icon': Icons.eco,
      'description': 'Essential healthy fats for hormone balance and recovery',
      'meals': [
        {
          'title': 'Avocado Toast',
          'calories': '350 kcal',
          'time': '10 min',
          'protein': '10g',
          'image': 'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Toast whole grain bread\n2. Mash avocado\n3. Add seeds and spices',
          'category': 'Fats'
        },
        {
          'title': 'Nut Butter Smoothie',
          'calories': '400 kcal',
          'time': '5 min',
          'protein': '15g',
          'image': 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Blend banana and milk\n2. Add nut butter\n3. Add honey and blend',
          'category': 'Fats'
        },
        {
          'title': 'Trail Mix',
          'calories': '290 kcal',
          'time': '2 min',
          'protein': '12g',
          'image': 'https://images.unsplash.com/photo-1599003037886-f8b50bc290c8?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Mix nuts and seeds\n2. Add dried fruits\n3. Store in container',
          'category': 'Fats'
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _loseWeightNutrition = [
    {
      'name': 'Low Carb',
      'icon': Icons.food_bank,
      'description': 'Meals low in carbohydrates',
      'meals': [
        {
          'title': 'Cauliflower Rice',
          'calories': '180 kcal',
          'time': '15 min',
          'protein': '6g',
          'image': 'https://images.unsplash.com/photo-1592417817098-8fd3d9eb14a5?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Grate cauliflower\n2. Saute with oil\n3. Season and serve',
          'category': 'Low Carb'
        },
        {
          'title': 'Zucchini Noodles',
          'calories': '150 kcal',
          'time': '10 min',
          'protein': '5g',
          'image': 'https://images.unsplash.com/photo-1599020792689-9fde458e7e17?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Spiralize zucchini\n2. Saute briefly\n3. Add sauce and serve',
          'category': 'Low Carb'
        },
        {
          'title': 'Vegetable Lettuce Wraps',
          'calories': '220 kcal',
          'time': '20 min',
          'protein': '10g',
          'image': 'https://images.unsplash.com/photo-1529059997568-3d847b1154f0?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Wash and prepare lettuce leaves\n2. Sauté mixed vegetables\n3. Fill lettuce leaves\n4. Serve with sauce',
          'category': 'Low Carb'
        },
        {
          'title': 'Mushroom Cauliflower Risotto',
          'calories': '200 kcal',
          'time': '25 min',
          'protein': '8g',
          'image': 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Rice cauliflower\n2. Sauté mushrooms\n3. Combine with herbs\n4. Add parmesan',
          'category': 'Low Carb'
        }
      ],
    },
    {
      'name': 'Keto',
      'icon': Icons.local_pizza,
      'description': 'Ketogenic diet meals',
      'meals': [
        {
          'title': 'Bacon & Eggs',
          'calories': '400 kcal',
          'time': '15 min',
          'protein': '20g',
          'image': 'https://images.unsplash.com/photo-1528607929212-2636ec44253e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Cook bacon\n2. Fry eggs\n3. Serve together',
          'category': 'Keto'
        },
        {
          'title': 'Cheese Omelette',
          'calories': '350 kcal',
          'time': '10 min',
          'protein': '25g',
          'image': 'https://images.unsplash.com/photo-1612240498936-65f5101365d2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Beat eggs\n2. Add cheese\n3. Cook in pan\n4. Fold and serve',
          'category': 'Keto'
        },
        {
          'title': 'Vegetarian Keto Bowl',
          'calories': '380 kcal',
          'time': '20 min',
          'protein': '15g',
          'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Prepare cauliflower rice\n2. Add avocado and nuts\n3. Mix in leafy greens\n4. Top with olive oil',
          'category': 'Keto'
        },
        {
          'title': 'Keto Eggplant Parmesan',
          'calories': '320 kcal',
          'time': '35 min',
          'protein': '18g',
          'image': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Slice and salt eggplant\n2. Coat with almond flour\n3. Layer with cheese\n4. Bake until golden',
          'category': 'Keto'
        }
      ],
    },
  ];

  final List<Map<String, dynamic>> _maintainNutrition = [
    {
      'name': 'Balanced',
      'icon': Icons.restaurant,
      'description': 'Balanced meals for maintenance',
      'meals': [
        {
          'title': 'Chicken Salad',
          'calories': '350 kcal',
          'time': '20 min',
          'protein': '30g',
          'image': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Grill chicken\n2. Mix with salad\n3. Add dressing and serve',
          'category': 'Balanced'
        },
        {
          'title': 'Fish & Veggies',
          'calories': '400 kcal',
          'time': '25 min',
          'protein': '35g',
          'image': 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Cook fish\n2. Steam vegetables\n3. Serve together',
          'category': 'Balanced'
        },
      ],
    },
    {
      'name': 'Mediterranean',
      'icon': Icons.local_dining,
      'description': 'Mediterranean diet meals',
      'meals': [
        {
          'title': 'Greek Salad',
          'calories': '250 kcal',
          'time': '15 min',
          'protein': '10g',
          'image': 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Mix vegetables\n2. Add feta cheese\n3. Drizzle with olive oil',
          'category': 'Mediterranean'
        },
        {
          'title': 'Lentil Soup',
          'calories': '300 kcal',
          'time': '30 min',
          'protein': '20g',
          'image': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'recipe': '1. Cook lentils\n2. Add vegetables\n3. Simmer and serve',
          'category': 'Mediterranean'
        },
      ],
    },
  ];

  List<Map<String, dynamic>> _filteredMeals(List<Map<String, dynamic>> meals) {
    if (_selectedCategory == 'All' && _searchController.text.isEmpty) {
      // Sort meals to show favorites first
      return meals.where((meal) {
        final matchesCategory = _selectedCategory == 'All' || meal['category'] == _selectedCategory;
        final matchesSearch = _searchController.text.isEmpty ||
            meal['title'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
            meal['category'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
            meal['description']?.toLowerCase().contains(_searchController.text.toLowerCase()) == true;
        return matchesCategory && matchesSearch;
      }).toList()
        ..sort((a, b) {
          final aIsFavorite = _favoriteMealIds.contains(a['id']);
          final bIsFavorite = _favoriteMealIds.contains(b['id']);
          if (aIsFavorite && !bIsFavorite) return -1;
          if (!aIsFavorite && bIsFavorite) return 1;
          return 0;
        });
    }
    return meals.where((meal) {
      final matchesCategory = _selectedCategory == 'All' || meal['category'] == _selectedCategory;
      final matchesSearch = _searchController.text.isEmpty ||
          meal['title'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          meal['category'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          meal['description']?.toLowerCase().contains(_searchController.text.toLowerCase()) == true;
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _navigateToAddMeal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMealScreen()),
    );
    
    if (result == true) {
      _loadMeals(); // Refresh the meals list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Browse Meals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddMeal,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.getMeals(),
                builder: (context, snapshot) {
                  List<Map<String, dynamic>> meals = _meals;
                  
                  if (snapshot.connectionState == ConnectionState.waiting && _meals.isEmpty) {
                    meals = _defaultMeals;
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    meals = [..._meals, ...snapshot.data!];
                  }
                  
                  final filteredMeals = _filteredMeals(meals);
                  
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: _buildSearchBar(),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: _buildMealCategories(),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildMealCard(
                              meal: filteredMeals[index],
                            ),
                            childCount: filteredMeals.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a meal...',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildMealCategories() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dietCategories.length,
        itemBuilder: (context, index) {
          final category = _dietCategories[index];
          bool isSelected = _selectedCategory == category['name'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['name'];
              });
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Colors.blue 
                        : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected 
                            ? Colors.blue.withOpacity(0.3) 
                            : Colors.grey.withOpacity(0.1),
                          spreadRadius: isSelected ? 2 : 1,
                          blurRadius: isSelected ? 8 : 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : Colors.blue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.blue : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealCard({required Map<String, dynamic> meal}) {
    final String? imagePath = meal['image'] ?? meal['imageUrl'];
    final bool hasValidImage = imagePath != null && imagePath.isNotEmpty;
    final String mealId = meal['id'] ?? meal['title'].toString().toLowerCase().replaceAll(' ', '_');
    final bool isFavorite = _favoriteMealIds.contains(mealId);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(
              mealId: mealId,
              title: meal['title'] ?? 'No title',
              calories: meal['calories'] ?? '0 kcal',
              time: meal['time'] ?? '0 minutes',
              protein: meal['protein'] ?? '0g protein',
              image: meal['imageUrl'] ?? meal['image'] ?? '',
              recipe: meal['recipe'] ?? 'No recipe provided',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    if (hasValidImage)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: _buildMealImage(imagePath!),
                        ),
                      ),
                    if (!hasValidImage)
                      const Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleFavorite(mealId),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              meal['calories'] ?? '0 kcal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal['title'] ?? 'No title',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildIconText(Icons.timer_outlined, meal['time'] ?? '0 min'),
                        _buildIconText(Icons.fitness_center, meal['protein']?.split(' ')[0] ?? '0g'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error_outline, size: 30, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.error_outline, size: 30, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // Bottom navigation bar widget
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home, false, () {
            _navigateToScreen(context, const HomeScreen());
          }),
          _buildNavBarItem(Icons.restaurant_menu, true, () {}),
          _buildNavBarItem(Icons.fitness_center, false, () {
            _navigateToScreen(context, const WorkoutScreen());
          }),
          _buildNavBarItem(Icons.person, false, () {
            _navigateToScreen(context, const ProfileScreen());
          }),
        ],
      ),
    );
  }

  // Navigation bar item widget
  Widget _buildNavBarItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  Future<void> _loadNutrition() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userGoal = await _goalService.getUserGoal(user.uid);
        if (userGoal == 'Gain Muscles') {
          _meals = _gainMuscleNutrition;
        } else if (userGoal == 'Lose Weight') {
          _meals = _loseWeightNutrition;
        } else {
          _meals = _maintainNutrition;
        }
      }
    } catch (e) {
      print('Error loading nutrition: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
}
