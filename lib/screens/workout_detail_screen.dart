import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/workout_history_service.dart';
import '../services/streak_service.dart';
import 'workout_screen.dart';
import '../services/notification_service.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  
  const WorkoutDetailScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  int _currentExerciseIndex = 0;
  int _secondsRemaining = 0;
  bool _isBreak = false;
  bool _isWorkoutComplete = false;
  Timer? _timer;
  late List<Map<String, dynamic>> _exercises;
  
  // Total workout progress
  double _totalProgress = 0.0;
  int _totalWorkoutSeconds = 0;
  int _elapsedWorkoutSeconds = 0;
    
  // Streak data
  final StreakService _streakService = StreakService();
  int _currentStreak = 0;
  int _streakGoal = 20;
  bool _reachedMilestone = false;
  
  @override
  void initState() {
    super.initState();
    _loadStreakData();
    _initializeExercises();
    _startExercise();
  }
  
  Future<void> _loadStreakData() async {
    final streakInfo = await _streakService.getStreakInfo();
    setState(() {
      _currentStreak = streakInfo['current_streak'];
      _streakGoal = streakInfo['streak_goal'];
    });
  }
  
  void _initializeExercises() {
    // Generate sample exercises based on the workout
    _exercises = [
      {
        'name': 'Warm-up',
        'duration': 60,
        'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1600&q=80',
        'instructions': 'Prepare your body with light movements',
      },
    ];
    
    final workoutType = widget.workout['title'];
    
    if (workoutType.contains('Upper Body')) {
      _exercises.addAll([
        {
          'name': 'Push-ups',
          'duration': 45,
          'image': 'https://images.pexels.com/photos/2294361/pexels-photo-2294361.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 10-12 reps',
        },
        {
          'name': 'Dumbbell Rows',
          'duration': 60,
          'image': 'https://images.pexels.com/photos/2294361/pexels-photo-2294361.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 12 reps each arm',
        },
        {
          'name': 'Shoulder Press',
          'duration': 60,
          'image': 'https://images.pexels.com/photos/2294361/pexels-photo-2294361.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 10 reps',
        },
      ]);
    } else if (workoutType.contains('Lower Body')) {
      _exercises.addAll([
        {
          'name': 'Squats',
          'duration': 60,
          'image': 'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 15 reps',
        },
        {
          'name': 'Lunges',
          'duration': 60,
          'image': 'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 10 reps each leg',
        },
        {
          'name': 'Glute Bridges',
          'duration': 45,
          'image': 'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 12 reps',
        },
      ]);
    } else if (workoutType.contains('Core')) {
      _exercises.addAll([
        {
          'name': 'Planks',
          'duration': 45,
          'image': 'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 30 seconds',
        },
        {
          'name': 'Russian Twists',
          'duration': 45,
          'image': 'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 15 reps each side',
        },
        {
          'name': 'Leg Raises',
          'duration': 45,
          'image': 'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 12 reps',
        },
      ]);
    } else if (workoutType.contains('Cardio') || workoutType.contains('HIIT')) {
      _exercises.addAll([
        {
          'name': 'Jumping Jacks',
          'duration': 45,
          'image': 'https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?ixlib=rb-1.2.1&auto=format&fit=crop&w=1600&q=80',
          'instructions': '30 seconds full intensity',
        },
        {
          'name': 'High Knees',
          'duration': 30,
          'image': 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1600&q=80',
          'instructions': '30 seconds full intensity',
        },
        {
          'name': 'Mountain Climbers',
          'duration': 30,
          'image': 'https://images.unsplash.com/photo-1434596922112-19c563067271?ixlib=rb-1.2.1&auto=format&fit=crop&w=1600&q=80',
          'instructions': '30 seconds full intensity',
        },
        {
          'name': 'Burpees',
          'duration': 45,
          'image': 'https://images.unsplash.com/photo-1595078475328-1ab05d0a6a0e?ixlib=rb-1.2.1&auto=format&fit=crop&w=1600&q=80',
          'instructions': '30 seconds full intensity',
        },
      ]);
    } else {
      // Default exercises if type doesn't match specific categories
      _exercises.addAll([
        {
          'name': 'Push-ups',
          'duration': 45,
          'image': 'https://images.pexels.com/photos/2294361/pexels-photo-2294361.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 10-12 reps',
        },
        {
          'name': 'Squats',
          'duration': 60,
          'image': 'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 15 reps',
        },
        {
          'name': 'Planks',
          'duration': 45,
          'image': 'https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg?auto=compress&cs=tinysrgb&w=1600',
          'instructions': '3 sets of 30 seconds',
        },
      ]);
    }
    
    // Add cooldown at the end
    _exercises.add({
      'name': 'Cooldown',
      'duration': 60,
      'image': 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1600&q=80',
      'instructions': 'Stretch and slow your breathing',
    });
    
    // Calculate total workout time
    _totalWorkoutSeconds = _calculateTotalTime();
  }
  
  int _calculateTotalTime() {
    int total = 0;
    
    // Add all exercise durations
    for (var exercise in _exercises) {
      total += exercise['duration'] as int;
      // Add break time between exercises (except after the last one)
      if (exercise != _exercises.last) {
        total += 15; // 15 seconds break
      }
    }
    
    return total;
  }
  
  void _startExercise() {
    if (_currentExerciseIndex < _exercises.length) {
      setState(() {
        if (!_isBreak) {
          _secondsRemaining = _exercises[_currentExerciseIndex]['duration'] as int;
        } else {
          _secondsRemaining = 15; // 15 second break
        }
      });
      
      _startTimer();
    } else {
      _completeWorkout();
    }
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          _elapsedWorkoutSeconds++;
          _totalProgress = _elapsedWorkoutSeconds / _totalWorkoutSeconds;
        });
      } else {
        _timer?.cancel();
        
        if (_isBreak) {
          // After break, move to next exercise
          setState(() {
            _isBreak = false;
            _currentExerciseIndex++;
          });
        } else if (_currentExerciseIndex < _exercises.length - 1) {
          // After exercise, take a break before next (unless it's the last exercise)
          setState(() {
            _isBreak = true;
          });
        } else {
          // After last exercise, complete workout
          _currentExerciseIndex++;
        }
        
        _startExercise();
      }
    });
  }
  
  void _completeWorkout() async {
    // Stop any running timer
    _timer?.cancel();

    // Set workout as complete
    setState(() {
      _isWorkoutComplete = true;
      _totalProgress = 1.0; // 100% complete
    });

    try {
      // Save workout to history
      final workoutHistoryService = WorkoutHistoryService();
      await workoutHistoryService.saveWorkoutHistory(
        workoutName: widget.workout['title'],
        duration: _elapsedWorkoutSeconds,
        exercisesCompleted: _exercises.length,
        caloriesBurned: widget.workout['calories'],
        workoutType: widget.workout['title'].toLowerCase().contains('cardio')
            ? 'cardio'
            : widget.workout['title'].toLowerCase().contains('strength')
                ? 'strength'
                : widget.workout['title'].toLowerCase().contains('yoga')
                    ? 'yoga'
                    : 'general',
      );

      // Create workout completion notification
      final notificationService = NotificationService();
      await notificationService.createNotification(
        'Workout',
        customTitle: 'Workout Completed! 🎉',
        customMessage: 'Great job completing the ${widget.workout['title']} workout! You burned ${widget.workout['calories']} calories.',
      );

      // Update streak
      await _streakService.updateStreak(incrementBy: 10);
      await _loadStreakData(); // Refresh UI with updated streak info
      print('Streak updated and loaded again');

      // Check milestone
      final streakInfo = await _streakService.getStreakInfo();
      setState(() {
        _currentStreak = streakInfo['current_streak'];
        _reachedMilestone = streakInfo['current_streak'] % _streakGoal == 0;
      });
    } catch (e) {
      debugPrint('Error completing workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save workout progress')),
      );
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isWorkoutComplete
            ? _buildCompletionScreen()
            : _buildWorkoutScreen(),
      ),
    );
  }
  
  Widget _buildWorkoutScreen() {
    final currentExercise = _currentExerciseIndex < _exercises.length
        ? _exercises[_currentExerciseIndex]
        : _exercises.last;
    
    return Column(
      children: [
        _buildAppBar(),
        
        // Linear progress indicator for total workout
        LinearProgressIndicator(
          value: _totalProgress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          minHeight: 6,
        ),
        
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Current status
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isBreak ? 'Take a break' : 'Current Exercise',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_currentExerciseIndex + 1}/${_exercises.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Exercise image
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isBreak
                      ? Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.airline_seat_legroom_extra,
                              size: 80,
                              color: Colors.blue[300],
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(currentExercise['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                
                // Timer
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Text(
                        _isBreak ? 'Rest Time' : currentExercise['name'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _isBreak ? 'Catch your breath' : currentExercise['instructions'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: CircularProgressIndicator(
                              value: _secondsRemaining / (_isBreak ? 15 : currentExercise['duration']),
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _isBreak ? Colors.green : Colors.blue,
                              ),
                            ),
                          ),
                          Text(
                            '$_secondsRemaining',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.skip_previous,
                        onPressed: _currentExerciseIndex > 0
                            ? () {
                                _timer?.cancel();
                                setState(() {
                                  if (_isBreak) {
                                    _isBreak = false;
                                  } else if (_currentExerciseIndex > 0) {
                                    _currentExerciseIndex--;
                                  }
                                });
                                _startExercise();
                              }
                            : null,
                      ),
                      _buildControlButton(
                        icon: _timer?.isActive ?? false ? Icons.pause : Icons.play_arrow,
                        onPressed: () {
                          if (_timer?.isActive ?? false) {
                            _timer?.cancel();
                          } else {
                            _startTimer();
                          }
                          setState(() {});
                        },
                        size: 64,
                        iconSize: 32,
                      ),
                      _buildControlButton(
                        icon: Icons.skip_next,
                        onPressed: () {
                          _timer?.cancel();
                          setState(() {
                            if (_isBreak) {
                              _isBreak = false;
                              _currentExerciseIndex++;
                            } else if (_currentExerciseIndex < _exercises.length - 1) {
                              _isBreak = true;
                            } else {
                              _currentExerciseIndex++;
                            }
                          });
                          _startExercise();
                        },
                      ),
                    ],
                  ),
                ),
                
                // Next up section
                if (_currentExerciseIndex < _exercises.length - 1 || _isBreak)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coming up next:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      _isBreak
                                          ? _exercises[_currentExerciseIndex + 1]['image']
                                          : _exercises[_currentExerciseIndex < _exercises.length - 1
                                              ? _currentExerciseIndex + 1
                                              : _exercises.length - 1]['image'],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isBreak
                                        ? _exercises[_currentExerciseIndex + 1]['name']
                                        : _currentExerciseIndex < _exercises.length - 1
                                            ? _exercises[_currentExerciseIndex + 1]['name']
                                            : 'Cooldown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _isBreak
                                        ? '${_exercises[_currentExerciseIndex + 1]['duration']} seconds'
                                        : _currentExerciseIndex < _exercises.length - 1
                                            ? '${_exercises[_currentExerciseIndex + 1]['duration']} seconds'
                                            : '60 seconds',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompletionScreen() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Workout Complete!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Great job! You\'ve completed the ${widget.workout['title']} workout.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Streak information
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.orange[700], size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Current Streak: $_currentStreak points',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                        if (_reachedMilestone) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Milestone Reached! 🎉',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  // Workout stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        icon: Icons.timer,
                        value: widget.workout['duration'],
                        label: 'Duration',
                      ),
                      _buildStatItem(
                        icon: Icons.local_fire_department,
                        value: '${widget.workout['calories']} Cal',
                        label: 'Calories',
                      ),
                      _buildStatItem(
                        icon: Icons.fitness_center,
                        value: '${widget.workout['exercises']}',
                        label: 'Exercises',
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Back to Workouts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Exit Workout?'),
                  content: Text('Your progress will not be saved.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Exit'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.workout['title'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.workout['difficulty'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 48,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: onPressed == null ? Colors.grey[300] : Colors.blue,
          shape: BoxShape.circle,
          boxShadow: onPressed == null ? [] : [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: onPressed == null ? Colors.grey[500] : Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.blue[700],
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}