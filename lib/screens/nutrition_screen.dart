import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'workout_screen.dart';
import 'meal_detail_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _currentPage = 0;
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _dietCategories = [
    {
      'name': 'All',
      'icon': Icons.all_inclusive,
      'description': 'All Meal Types'
    },
    {
      'name': 'Vegetarian',
      'icon': Icons.grass,
      'description': 'Plant-Based Meals'
    },
    {
      'name': 'Protein',
      'icon': Icons.fitness_center,
      'description': 'High Protein Diets'
    },
    {
      'name': 'Low Carb',
      'icon': Icons.food_bank,
      'description': 'Low Carbohydrate Meals'
    },
    {
      'name': 'Keto',
      'icon': Icons.local_pizza,
      'description': 'Ketogenic Diet Meals'
    },
    {
      'name': 'Vegan',
      'icon': Icons.eco,
      'description': 'Plant-Based No Animal Products'
    },
  ];

  final List<Map<String, String>> _allMeals = [
    // Vegetarian Meals
    {
      "title": "Quinoa Salad with Roasted Veggies",
      "calories": "430 kcal",
      "time": "30 minutes",
      "protein": "18g protein",
      "image": "assets/quinoa-salad.png",
      "recipe": "1. Cook the quinoa.\n2. Roast the veggies.\n3. Mix them together with dressing.",
      "category": "Vegetarian"
    },
    {
      "title": "Spinach and Mushroom Frittata",
      "calories": "320 kcal",
      "time": "25 minutes",
      "protein": "22g protein",
      "image": "assets/vegetarian-frittata.png",
      "recipe": "1. Whisk eggs.\n2. Sauté spinach and mushrooms.\n3. Bake in the oven until set.",
      "category": "Vegetarian"
    },
    {
      "title": "Vegetable Stir-Fry with Tofu",
      "calories": "380 kcal",
      "time": "20 minutes",
      "protein": "20g protein",
      "image": "assets/tofu-stir-fry.png",
      "recipe": "1. Press tofu.\n2. Chop vegetables.\n3. Stir-fry with soy sauce.",
      "category": "Vegetarian"
    },
    {
      "title": "Greek Salad with Feta",
      "calories": "290 kcal",
      "time": "15 minutes",
      "protein": "12g protein",
      "image": "assets/greek-salad.png",
      "recipe": "1. Chop cucumbers, tomatoes, and onions.\n2. Add olives and feta.\n3. Dress with olive oil and herbs.",
      "category": "Vegetarian"
    },
    {
      "title": "Vegetable Lasagna",
      "calories": "450 kcal",
      "time": "45 minutes",
      "protein": "25g protein",
      "image": "assets/vegetable-lasagna.png",
      "recipe": "1. Layer lasagna sheets.\n2. Add vegetable sauce.\n3. Top with cheese.\n4. Bake until golden.",
      "category": "Vegetarian"
    },

    // Protein Meals
    {
      "title": "Grilled Chicken with Brown Rice",
      "calories": "620 kcal",
      "time": "40 minutes",
      "protein": "55g protein",
      "image": "assets/grilled-chicken.png",
      "recipe": "1. Grill the chicken.\n2. Cook the brown rice.\n3. Serve with steamed vegetables.",
      "category": "Protein"
    },
    {
      "title": "Salmon with Quinoa",
      "calories": "500 kcal",
      "time": "35 minutes",
      "protein": "45g protein",
      "image": "assets/salmon-quinoa.png",
      "recipe": "1. Bake salmon.\n2. Cook quinoa.\n3. Serve with lemon and herbs.",
      "category": "Protein"
    },
    {
      "title": "Beef Stir-Fry",
      "calories": "550 kcal",
      "time": "25 minutes",
      "protein": "50g protein",
      "image": "assets/beef-stir-fry.png",
      "recipe": "1. Slice beef.\n2. Stir-fry with vegetables.\n3. Add soy sauce and spices.",
      "category": "Protein"
    },
    {
      "title": "Turkey Meatballs",
      "calories": "400 kcal",
      "time": "30 minutes",
      "protein": "40g protein",
      "image": "assets/turkey-meatballs.png",
      "recipe": "1. Mix ground turkey.\n2. Form meatballs.\n3. Bake or pan-fry.\n4. Serve with sauce.",
      "category": "Protein"
    },
    {
      "title": "Shrimp and Egg White Scramble",
      "calories": "350 kcal",
      "time": "20 minutes",
      "protein": "45g protein",
      "image": "assets/shrimp-scramble.png",
      "recipe": "1. Scramble egg whites.\n2. Sauté shrimp.\n3. Combine and season.",
      "category": "Protein"
    },

    // Low Carb Meals
    {
      "title": "Cauliflower Rice Bowl",
      "calories": "320 kcal",
      "time": "25 minutes",
      "protein": "20g protein",
      "image": "assets/cauliflower-rice.png",
      "recipe": "1. Rice cauliflower.\n2. Sauté with vegetables.\n3. Top with protein.",
      "category": "Low Carb"
    },
    {
      "title": "Zucchini Noodle Carbonara",
      "calories": "380 kcal",
      "time": "30 minutes",
      "protein": "25g protein",
      "image": "assets/zucchini-noodles.png",
      "recipe": "1. Spiralize zucchini.\n2. Make carbonara sauce.\n3. Combine and serve.",
      "category": "Low Carb"
    },
    {
      "title": "Lettuce Wrap Tacos",
      "calories": "300 kcal",
      "time": "20 minutes",
      "protein": "30g protein",
      "image": "assets/lettuce-tacos.png",
      "recipe": "1. Cook seasoned meat.\n2. Wrap in lettuce leaves.\n3. Add toppings.",
      "category": "Low Carb"
    },
    {
      "title": "Egg and Avocado Cups",
      "calories": "250 kcal",
      "time": "15 minutes",
      "protein": "15g protein",
      "image": "assets/egg-avocado-cups.png",
      "recipe": "1. Halve avocados.\n2. Crack eggs into avocado.\n3. Bake until set.",
      "category": "Low Carb"
    },
    {
      "title": "Stuffed Bell Peppers",
      "calories": "350 kcal",
      "time": "35 minutes",
      "protein": "25g protein",
      "image": "assets/stuffed-peppers.png",
      "recipe": "1. Hollow bell peppers.\n2. Fill with low-carb mixture.\n3. Bake until tender.",
      "category": "Low Carb"
    },

    // Keto Meals
    {
      "title": "Avocado Keto Toast",
      "calories": "450 kcal",
      "time": "15 minutes",
      "protein": "15g protein",
      "image": "assets/keto-toast.png",
      "recipe": "1. Prepare low-carb bread.\n2. Mash avocado.\n3. Top with eggs.",
      "category": "Keto"
    },
    {
      "title": "Keto Chicken Alfredo",
      "calories": "500 kcal",
      "time": "30 minutes",
      "protein": "40g protein",
      "image": "assets/keto-chicken-alfredo.png",
      "recipe": "1. Cook chicken.\n2. Make low-carb alfredo sauce.\n3. Serve over zucchini noodles.",
      "category": "Keto"
    },
    {
      "title": "Salmon with Cream Cheese",
      "calories": "480 kcal",
      "time": "25 minutes",
      "protein": "35g protein",
      "image": "assets/salmon-cream-cheese.png",
      "recipe": "1. Bake salmon.\n2. Top with cream cheese.\n3. Serve with asparagus.",
      "category": "Keto"
    },
    {
      "title": "Keto Pizza Cups",
      "calories": "400 kcal",
      "time": "20 minutes",
      "protein": "25g protein",
      "image": "assets/keto-pizza-cups.png",
      "recipe": "1. Make low-carb pizza base.\n2. Fill with toppings.\n3. Bake until crispy.",
      "category": "Keto"
    },
    {
      "title": "Bacon and Egg Cups",
      "calories": "350 kcal",
      "time": "20 minutes",
      "protein": "20g protein",
      "image": "assets/bacon-egg-cups.png",
      "recipe": "1. Line muffin tin with bacon.\n2. Crack eggs inside.\n3. Bake until set.",
      "category": "Keto"
    },

    // Vegan Meals
    {
      "title": "Tofu Stir Fry",
      "calories": "380 kcal",
      "time": "20 minutes",
      "protein": "22g protein",
      "image": "assets/tofu-stir-fry.png",
      "recipe": "1. Press tofu.\n2. Stir fry with vegetables.\n3. Add soy sauce.",
      "category": "Vegan"
    },
    {
      "title": "Chickpea Curry",
      "calories": "420 kcal",
      "time": "35 minutes",
      "protein": "20g protein",
      "image": "assets/chickpea-curry.png",
      "recipe": "1. Sauté onions and spices.\n2. Add chickpeas.\n3. Simmer in coconut milk.",
      "category": "Vegan"
    },
    {
      "title": "Lentil Bolognese",
      "calories": "350 kcal",
      "time": "40 minutes",
      "protein": "25g protein",
      "image": "assets/lentil-bolognese.png",
      "recipe": "1. Cook lentils.\n2. Make tomato sauce.\n3. Serve over zucchini noodles.",
      "category": "Vegan"
    },
    {
      "title": "Buddha Bowl",
      "calories": "400 kcal",
      "time": "25 minutes",
      "protein": "18g protein",
      "image": "assets/buddha-bowl.png",
      "recipe": "1. Roast vegetables.\n2. Cook quinoa.\n3. Add tahini dressing.",
      "category": "Vegan"
    },
    {
      "title": "Vegan Sushi Rolls",
      "calories": "320 kcal",
      "time": "30 minutes",
      "protein": "15g protein",
      "image": "assets/vegan-sushi.png",
      "recipe": "1. Prepare sushi rice.\n2. Fill with vegetables.\n3. Roll and slice.",
      "category": "Vegan"
    },
  ];

  List<Map<String, String>> _filteredMeals() {
    if (_selectedCategory == 'All') return _allMeals;
    return _allMeals.where((meal) => meal['category'] == _selectedCategory).toList();
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredMeals = _filteredMeals();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildMealCategories(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedCategory Meals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${filteredMeals.length} recipes',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMeals.length,
                itemBuilder: (context, index) {
                  final meal = filteredMeals[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: _buildMealCard(
                      title: meal["title"]!,
                      calories: meal["calories"]!,
                      time: meal["time"]!,
                      protein: meal["protein"]!,
                      image: meal["image"]!,
                      recipe: meal["recipe"]!,
                    ),
                  );
                },
              ),
            ),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Browse Meals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore and log curated meals from us',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for a meal...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: Icon(Icons.tune, color: Colors.grey),
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildMealCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _dietCategories.map((category) {
          bool isSelected = _selectedCategory == category['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
                });
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isSelected 
                      ? Colors.green.withOpacity(0.4) 
                      : Colors.green.withOpacity(0.2),
                    child: Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : Colors.green,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.green : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealCard({
    required String title,
    required String calories,
    required String time,
    required String protein,
    required String image,
    required String recipe,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(
              title: title,
              calories: calories,
              time: time,
              protein: protein,
              image: image,
              recipe: recipe,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                image,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildNutritionChip(Icons.local_fire_department, calories),
                        const SizedBox(width: 5),
                        _buildNutritionChip(Icons.timer, time),
                        const SizedBox(width: 5),
                        _buildNutritionChip(Icons.fitness_center, protein),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home, false, () {
            _navigateToScreen(context, const HomeScreen());
          }),
          _buildNavBarItem(Icons.list, true, () {}),
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

  Widget _buildNavBarItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: isActive ? Colors.black : Colors.grey,
      ),
    );
  }
}