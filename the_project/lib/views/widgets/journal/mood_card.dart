import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/journal/daily_mood_state.dart';
import '../../../logic/journal/daily_mood_cubit.dart';
import '../../themes/style_simple/colors.dart';


class MoodCard extends StatefulWidget {
  const MoodCard({super.key});

  @override
  State<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard> {
  final List<Map<String, String>> _moods = [
    {'image': 'assets/images/happy.png', 'label': 'Happy'},
    {'image': 'assets/images/good.png', 'label': 'Good'},
    {'image': 'assets/images/excited.png', 'label': 'Excited'},
    {'image': 'assets/images/calm.png', 'label': 'Calm'},
    {'image': 'assets/images/sad.png', 'label': 'Sad'},
    {'image': 'assets/images/tired.png', 'label': 'Tired'},
    {'image': 'assets/images/anxious.png', 'label': 'Anxious'},
    {'image': 'assets/images/angry.png', 'label': 'Angry'},
    {'image': 'assets/images/confused.png', 'label': 'Confused'},
    {'image': 'assets/images/grateful.png', 'label': 'Grateful'},
  ];

  int? _lastLoadedUserId;

  @override
  void initState() {
    super.initState();
    _loadMoodIfNeeded();
  }

  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  void _loadMoodIfNeeded() async {
    await Future.delayed(Duration.zero); // Wait for frame
    if (!mounted) return;
    
    final currentUserId = await _getCurrentUserId();
    print('MoodCard: Current userId from SharedPreferences: $currentUserId');
    
    if (currentUserId != null && _lastLoadedUserId != currentUserId) {
      print('MoodCard: Loading mood for NEW user: $currentUserId (previous: $_lastLoadedUserId)');
      setState(() {
        _lastLoadedUserId = currentUserId;
      });
      if (mounted) {
        context.read<DailyMoodCubit>().loadTodayMood();
      }
    } else if (currentUserId != null && _lastLoadedUserId == currentUserId) {
      print('MoodCard: User $currentUserId already loaded, skipping');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen to auth changes to reload mood when user changes
        BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) async {
            if (authState.isAuthenticated && authState.user != null) {
              final currentUserId = await _getCurrentUserId();
              print('MoodCard: Auth state changed, userId: $currentUserId, last loaded: $_lastLoadedUserId');
              
              // Reload mood if user changed
              if (currentUserId != null && _lastLoadedUserId != currentUserId) {
                print('MoodCard: User CHANGED from $_lastLoadedUserId to $currentUserId, reloading mood');
                setState(() {
                  _lastLoadedUserId = currentUserId;
                });
                context.read<DailyMoodCubit>().loadTodayMood();
              }
            } else {
              // User logged out, clear last user
              print('MoodCard: User logged out, clearing state');
              setState(() {
                _lastLoadedUserId = null;
              });
            }
          },
        ),
        // Listen to mood errors
        BlocListener<DailyMoodCubit, DailyMoodState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 2),
                ),
              );
              context.read<DailyMoodCubit>().clearError();
            }
          },
        ),
      ],
      child: BlocBuilder<DailyMoodCubit, DailyMoodState>(
        builder: (context, state) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: _buildContent(state),
          );
        },
      ),
    );
  }

  Widget _buildContent(DailyMoodState state) {
    if (state.status == DailyMoodStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == DailyMoodStatus.error && state.todayMood == null) {
      return Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 8),
          Text(
            state.error ?? 'Failed to load mood',
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<DailyMoodCubit>().loadTodayMood();
            },
            child: const Text('Retry'),
          ),
        ],
      );
    }

    final hasSelectedMood = state.todayMood != null;

    return hasSelectedMood
        ? _buildSelectedMood(state)
        : _buildMoodSelector();
  }

  Widget _buildSelectedMood(DailyMoodState state) {
    final mood = state.todayMood!;
    final formattedTime = _formatDateTime(mood.updatedAt);

    return Row(
      children: [
        Image.asset(mood.moodImage, height: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mood.moodLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formattedTime,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.textSecondary),
          onPressed: () {
            // Allow user to change mood
            context.read<DailyMoodCubit>().clearTodayMood();
          },
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How do you feel today?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _moods.length,
            itemBuilder: (context, index) {
              final mood = _moods[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    context.read<DailyMoodCubit>().setTodayMood(
                          mood['image']!,
                          mood['label']!,
                        );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        mood['image']!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final day = date.day;
    final month = _getMonthName(date.month);

    return 'Today, $month $day, $hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}