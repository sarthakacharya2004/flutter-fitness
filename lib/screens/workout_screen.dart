import 'package:fitness_hub/services/streak_service.dart';
import 'package:fitness_hub/services/goal_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'nutrition_screen.dart';
import 'profile_screen.dart';
import 'workout_detail_screen.dart';


class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  // Static method to update streak - now using the streak service
  static Future<void> updateStreak() async {
    // Create instance of streak service and update streak
    final streakService = StreakService();
    await streakService.updateStreak(incrementBy: 10);
  }

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final GoalService _goalService = GoalService();
  List<Map<String, dynamic>> _workoutCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
    _loadStreakInfo();
    _initializeWorkoutCategories();
  }

  Future<void> _initializeWorkoutCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userGoal = await _goalService.getUserGoal(user.uid);
      setState(() {
        if (userGoal == 'Gain Muscles') {
          _workoutCategories = _gainMuscleCategories;
        } else if (userGoal == 'Lose Weight') {
          _workoutCategories = _loseWeightCategories;
        } else {
          _workoutCategories = _defaultWorkoutCategories;
        }
        isLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> _gainMuscleCategories = [
    {
      'name': 'Hypertrophy',
      'icon': Icons.fitness_center,
      'color': Colors.orange[100],
      'iconColor': Colors.orange,
      'description': 'Increase muscle size and strength',
      'workouts': [
        {
          'title': 'Chest & Back',
          'duration': '45 mins',
          'difficulty': 'Advanced',
          'image': 'assets/chest-back.png',
          'calories': 400,
          'exercises': 10,
        },
        {
          'title': 'Leg Day',
          'duration': '50 mins',
          'difficulty': 'Advanced',
          'image': 'assets/leg-day.png',
          'calories': 450,
          'exercises': 9,
        },
      ],
    },
    {
      'name': 'Strength',
      'icon': Icons.fitness_center,
      'color': Colors.red[100],
      'iconColor': Colors.red,
      'description': 'Build muscle and increase strength',
      'workouts': [
        {
          'title': 'Upper Body',
          'duration': '35 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/upper-body.png',
          'calories': 300,
          'exercises': 8,
        },
        {
          'title': 'Lower Body',
          'duration': '40 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/lower-body.png',
          'calories': 320,
          'exercises': 7,
        },
      ],
    },
    {
      'name': 'Powerlifting',
      'icon': Icons.fitness_center,
      'color': Colors.brown[100],
      'iconColor': Colors.brown,
      'description': 'Focus on heavy lifting',
      'workouts': [
        {
          'title': 'Squat & Deadlift',
          'duration': '60 mins',
          'difficulty': 'Advanced',
          'image': 'assets/squat-deadlift.png',
          'calories': 500,
          'exercises': 6,
        },
        {
          'title': 'Bench Press',
          'duration': '30 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/bench-press.png',
          'calories': 250,
          'exercises': 5,
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _loseWeightCategories = [
    {
      'name': 'Cardio',
      'icon': Icons.directions_run,
      'color': Colors.blue[100],
      'iconColor': Colors.blue,
      'description': 'Improve heart health and burn calories',
      'workouts': [
        {
          'title': 'Interval Running',
          'duration': '25 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/interval-running.png',
          'calories': 280,
          'exercises': 5,
        },
        {
          'title': 'Jump Rope',
          'duration': '20 mins',
          'difficulty': 'Beginner',
          'image': 'assets/jump-rope.png',
          'calories': 240,
          'exercises': 4,
        },
      ],
    },
    {
      'name': 'HIIT',
      'icon': Icons.timeline,
      'color': Colors.purple[100],
      'iconColor': Colors.purple,
      'description': 'Maximum results in minimum time',
      'workouts': [
        {
          'title': 'Tabata',
          'duration': '20 mins',
          'difficulty': 'Advanced',
          'image': 'assets/tabata.png',
          'calories': 300,
          'exercises': 8,
        },
        {
          'title': 'Full Body HIIT',
          'duration': '30 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/full-body-hiit.png',
          'calories': 350,
          'exercises': 10,
        },
      ],
    },
    {
      'name': 'Circuit Training',
      'icon': Icons.fitness_center,
      'color': Colors.green[100],
      'iconColor': Colors.green,
      'description': 'Combine strength and cardio',
      'workouts': [
        {
          'title': 'Full Body Circuit',
          'duration': '40 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/full-body-circuit.png',
          'calories': 400,
          'exercises': 12,
        },
        {
          'title': 'Core Circuit',
          'duration': '30 mins',
          'difficulty': 'Beginner',
          'image': 'assets/core-circuit.png',
          'calories': 200,
          'exercises': 10,
        },
      ],
    },
  ];

  // Update _loadWorkouts method to handle new categories
  Future<void> _loadWorkouts() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ensure the workout categories are correctly loaded based on user goals
        final userGoal = await _goalService.getUserGoal(user.uid);
        if (userGoal == 'Gain Muscles') {
          _workoutCategories = _gainMuscleCategories;
        } else if (userGoal == 'Lose Weight') {
          _workoutCategories = _loseWeightCategories;
        } else {
          _workoutCategories = _defaultWorkoutCategories;
        }
      }
    } catch (e) {
      print('Error loading workouts: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Legacy workout categories as fallback
  final List<Map<String, dynamic>> _defaultWorkoutCategories = [
    {
      'name': 'Strength',
      'icon': Icons.fitness_center,
      'color': Colors.red[100],
      'iconColor': Colors.red,
      'description': 'Build muscle and increase strength',
      'workouts': [
        {
          'title': 'Upper Body',
          'duration': '35 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/upper-body.png',
          'calories': 300,
          'exercises': 8,
        },
        {
          'title': 'Lower Body',
          'duration': '40 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/lower-body.png',
          'calories': 320,
          'exercises': 7,
        },
      ],
    },
    {
      'name': 'Cardio',
      'icon': Icons.directions_run,
      'color': Colors.blue[100],
      'iconColor': Colors.blue,
      'description': 'Improve heart health and burn calories',
      'workouts': [
        {
          'title': 'Interval Running',
          'duration': '25 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/interval-running.png',
          'calories': 280,
          'exercises': 5,
        },
        {
          'title': 'Jump Rope',
          'duration': '20 mins',
          'difficulty': 'Beginner',
          'image': 'assets/jump-rope.png',
          'calories': 240,
          'exercises': 4,
        },
      ],
    },
    {
      'name': 'Yoga',
      'icon': Icons.self_improvement,
      'color': Colors.green[100],
      'iconColor': Colors.green,
      'description': 'Improve flexibility and reduce stress',
      'workouts': [
        {
          'title': 'Morning Flow',
          'duration': '30 mins',
          'difficulty': 'Beginner',
          'image': 'assets/morning-flow.png',
          'calories': 150,
          'exercises': 12,
        },
        {
          'title': 'Power Yoga',
          'duration': '45 mins',
          'difficulty': 'Advanced',
          'image': 'assets/power-yoga.png',
          'calories': 220,
          'exercises': 15,
        },
      ],
    },
    {
      'name': 'HIIT',
      'icon': Icons.timeline,
      'color': Colors.purple[100],
      'iconColor': Colors.purple,
      'description': 'Maximum results in minimum time',
      'workouts': [
        {
          'title': 'Tabata',
          'duration': '20 mins',
          'difficulty': 'Advanced',
          'image': 'assets/tabata.png',
          'calories': 300,
          'exercises': 8,
        },
        {
          'title': 'Full Body HIIT',
          'duration': '30 mins',
          'difficulty': 'Intermediate',
          'image': 'assets/full-body-hiit.png',
          'calories': 350,
          'exercises': 10,
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _recommendedWorkouts = [
    {
      'title': 'Full Body Workout',
      'duration': '45 mins',
      'difficulty': 'Intermediate',
      'image': 'assets/full-body.png',
      'calories': 350,
      'exercises': 12,
    },
    {
      'title': 'Core Strength',
      'duration': '30 mins',
      'difficulty': 'Beginner',
      'image': 'assets/core-workout.png',
      'calories': 250,
      'exercises': 8,
    },
    {
      'title': 'High Intensity Interval',
      'duration': '25 mins',
      'difficulty': 'Advanced',
      'image': 'assets/hiit-workout.png',
      'calories': 400,
      'exercises': 10,
    },
  ];

  int _selectedCategoryIndex = -1;
  int _currentStreak = 0;
  int _totalStreak = 0; // Total accumulated streak points
  int _streakGoal = 20; // Setting streak goal to 20
  double _streakProgress = 0.0; // Progress toward goal
  
  // Instance of streak service
  final StreakService _streakService = StreakService();
  
  
  Future<void> _loadStreakInfo() async {
    try {
      // Get streak info using the service
      final streakInfo = await _streakService.getStreakInfo();
      
      setState(() {
        _currentStreak = streakInfo['current_streak'];
        _totalStreak = streakInfo['total_streak'];
        _streakGoal = streakInfo['streak_goal'];
        
        // FIX: Keep progress at 100% if goal is reached, otherwise calculate normally
        if (_currentStreak >= _streakGoal) {
          _streakProgress = 1.0; // 100% progress
        } else {
          _streakProgress = _currentStreak / _streakGoal;
        }
      });
    } catch (e) {
      debugPrint('Error loading streak info: $e');
    }
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _openWorkoutDetail(BuildContext context, Map<String, dynamic> workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(
          workout: workout,
        ),
      ),
    ).then((_) {
      // Refresh streak data when returning from workout detail
      _loadStreakInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildWorkoutHeader(),
                  // Removed the orange streak banner here
                  _buildWorkoutCategories(),
                  _selectedCategoryIndex != -1
                      ? _buildCategoryWorkouts()
                      : _buildRecommendedWorkouts(),
                ],
              ),
            ),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Workouts',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStreakInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_fire_department, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout Streak',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Current Streak: $_currentStreak points',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Total Streak: $_totalStreak points',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress to Next Goal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '${(_streakProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _streakProgress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentStreak >= _streakGoal 
                      ? 'Goal achieved! $_streakGoal points'
                      : 'Next milestone: $_streakGoal points',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Removed the _buildStreakBanner() widget completely

  Widget _buildWorkoutCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Workout Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_workoutCategories.length, (index) {
                return _buildCategoryItem(_workoutCategories[index], index);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category, int index) {
    final bool isSelected = _selectedCategoryIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedCategoryIndex == index) {
            _selectedCategoryIndex = -1;
          } else {
            _selectedCategoryIndex = index;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isSelected 
                    ? category['iconColor'].withOpacity(0.9) 
                    : category['color'],
                shape: BoxShape.circle,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: category['iconColor'].withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ] : [],
              ),
              child: Icon(
                category['icon'],
                color: isSelected ? Colors.white : category['iconColor'],
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category['name'],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? category['iconColor'] : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryWorkouts() {
    final selectedCategory = _workoutCategories[_selectedCategoryIndex];
    final workouts = selectedCategory['workouts'];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedCategory['name']} Workouts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategoryIndex = -1;
                  });
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: selectedCategory['iconColor'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            selectedCategory['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ...workouts.map((workout) => _buildWorkoutCard(workout)).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendedWorkouts() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Workouts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...(_recommendedWorkouts.map((workout) {
            return _buildWorkoutCard(workout);
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
              workout['image'],
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
                  workout['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildWorkoutInfoChip(
                      Icons.timer_outlined, 
                      workout['duration']
                    ),
                    const SizedBox(width: 8),
                    _buildWorkoutInfoChip(
                      Icons.flash_on_outlined, 
                      workout['difficulty']
                    ),
                    const SizedBox(width: 8),
                    _buildWorkoutInfoChip(
                      Icons.local_fire_department_outlined, 
                      '${workout['calories']} Cal'
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Connect to the workout detail screen
                    _openWorkoutDetail(context, workout);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Start Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
          _buildNavBarItem(Icons.list, false, () {
            _navigateToScreen(context, const NutritionScreen());
          }),
          _buildNavBarItem(Icons.fitness_center, true, () {}),
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