import 'package:fitness_hub/services/firestore_service.dart';
import 'package:fitness_hub/services/goal_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'workout_screen.dart';
import 'meal_detail_screen.dart';
import 'add_meal_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _initializeNutritionPlan();
  }

// Modified _initializeNutritionPlan to streamline goal-based meal selection logic.
Future<void> _initializeNutritionPlan() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userGoal = await _goalService.getUserGoal(user.uid);

    List<Map<String, dynamic>> meals;

    if (userGoal == 'Gain Muscles') {
      meals = _gainMuscleNutrition.expand((cat) => cat['meals'] as List<Map<String, dynamic>>).toList();
    } else if (userGoal == 'Lose Weight') {
      meals = _loseWeightNutrition.expand((cat) => cat['meals'] as List<Map<String, dynamic>>).toList();
    } else {
      meals = _maintainNutrition.expand((cat) => cat['meals'] as List<Map<String, dynamic>>).toList();
    }

    setState(() {
      _meals = meals;
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

  final List<Map<String, dynamic>> _dietCategories = [
    {'name': 'All', 'icon': Icons.all_inclusive, 'description': 'All Meal Types'},
    {'name': 'Vegetarian', 'icon': Icons.grass, 'description': 'Plant-Based Meals'},
    {'name': 'Protein', 'icon': Icons.fitness_center, 'description': 'High Protein Diets'},
    {'name': 'Low Carb', 'icon': Icons.food_bank, 'description': 'Low Carbohydrate Meals'},
    {'name': 'Keto', 'icon': Icons.local_pizza, 'description': 'Ketogenic Diet Meals'},
    {'name': 'Vegan', 'icon': Icons.eco, 'description': 'Plant-Based No Animal Products'},
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
    // ... rest of your _defaultMeals list (keep all existing entries)
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
          'image': 'assets/grilled-chicken.png',
          'recipe': '1. Season chicken\n2. Grill for 8 mins per side\n3. Rest and serve',
          'category': 'Protein'
        },
        {
          'title': 'Quinoa Salad',
          'calories': '250 kcal',
          'time': '15 min',
          'protein': '12g',
          'image': 'assets/quinoa-salad.png',
          'recipe': '1. Cook quinoa\n2. Mix with vegetables\n3. Add dressing and serve',
          'category': 'Protein'
        },
      ],
    },
    {
      'name': 'Balanced Diet',
      'icon': Icons.restaurant,
      'description': 'Balanced meals for muscle gain',
      'meals': [
        {
          'title': 'Steak and Veggies',
          'calories': '500 kcal',
          'time': '30 min',
          'protein': '35g',
          'image': 'assets/steak-veggies.png',
          'recipe': '1. Cook steak\n2. Steam vegetables\n3. Serve together',
          'category': 'Protein'
        },
        {
          'title': 'Omelette',
          'calories': '200 kcal',
          'time': '10 min',
          'protein': '15g',
          'image': 'assets/omelette.png',
          'recipe': '1. Beat eggs\n2. Cook in pan\n3. Add cheese and serve',
          'category': 'Protein'
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
          'image': 'assets/cauliflower-rice.png',
          'recipe': '1. Grate cauliflower\n2. Saute with oil\n3. Season and serve',
          'category': 'Low Carb'
        },
        {
          'title': 'Zucchini Noodles',
          'calories': '150 kcal',
          'time': '10 min',
          'protein': '5g',
          'image': 'assets/zucchini-noodles.png',
          'recipe': '1. Spiralize zucchini\n2. Saute briefly\n3. Add sauce and serve',
          'category': 'Low Carb'
        },
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
          'image': 'assets/bacon-eggs.png',
          'recipe': '1. Cook bacon\n2. Fry eggs\n3. Serve together',
          'category': 'Keto'
        },
        {
          'title': 'Cheese Omelette',
          'calories': '350 kcal',
          'time': '10 min',
          'protein': '25g',
          'image': 'assets/cheese-omelette.png',
          'recipe': '1. Beat eggs\n2. Add cheese\n3. Cook in pan\n4. Fold and serve',
          'category': 'Keto'
        },
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
          'image': 'assets/chicken-salad.png',
          'recipe': '1. Grill chicken\n2. Mix with salad\n3. Add dressing and serve',
          'category': 'Balanced'
        },
        {
          'title': 'Fish & Veggies',
          'calories': '400 kcal',
          'time': '25 min',
          'protein': '35g',
          'image': 'assets/fish-veggies.png',
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
          'image': 'assets/greek-salad.png',
          'recipe': '1. Mix vegetables\n2. Add feta cheese\n3. Drizzle with olive oil',
          'category': 'Mediterranean'
        },
        {
          'title': 'Lentil Soup',
          'calories': '300 kcal',
          'time': '30 min',
          'protein': '20g',
          'image': 'assets/lentil-soup.png',
          'recipe': '1. Cook lentils\n2. Add vegetables\n3. Simmer and serve',
          'category': 'Mediterranean'
        },
      ],
    },
  ];

  List<Map<String, dynamic>> _filteredMeals(List<Map<String, dynamic>> meals) {
    if (_selectedCategory == 'All') return meals;
    return meals.where((meal) => meal['category'] == _selectedCategory).toList();
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(
              mealId: meal['id'] ?? '',
              title: meal['title'] ?? 'No title',
              calories: meal['calories'] ?? '0 kcal',
              time: meal['time'] ?? '0 minutes',
              protein: meal['protein'] ?? '0g protein',
              image: meal['image'] ?? 'assets/default-meal.png',
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
            // Image container
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(
                    image: NetworkImage(meal['image'] ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                          size: 16,
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
            // Text content
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