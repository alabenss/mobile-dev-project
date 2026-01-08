import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_project/l10n/app_localizations.dart';
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
  int? _lastLoadedUserId;

  // Mood data structure with keys for database storage
  List<Map<String, String>> _getMoods(AppLocalizations l10n) => [
    {'image': 'assets/images/happy.png', 'key': 'happy', 'label': l10n.journalMoodHappy},
    {'image': 'assets/images/good.png', 'key': 'good', 'label': l10n.journalMoodGood},
    {'image': 'assets/images/excited.png', 'key': 'excited', 'label': l10n.journalMoodExcited},
    {'image': 'assets/images/calm.png', 'key': 'calm', 'label': l10n.journalMoodCalm},
    {'image': 'assets/images/sad.png', 'key': 'sad', 'label': l10n.journalMoodSad},
    {'image': 'assets/images/tired.png', 'key': 'tired', 'label': l10n.journalMoodTired},
    {'image': 'assets/images/anxious.png', 'key': 'anxious', 'label': l10n.journalMoodAnxious},
    {'image': 'assets/images/angry.png', 'key': 'angry', 'label': l10n.journalMoodAngry},
    {'image': 'assets/images/confused.png', 'key': 'confused', 'label': l10n.journalMoodConfused},
    {'image': 'assets/images/grateful.png', 'key': 'grateful', 'label': l10n.journalMoodGrateful},
  ];

  String _getLocalizedMoodLabel(String moodKey, AppLocalizations l10n) {
    final moods = _getMoods(l10n);
    final mood = moods.firstWhere(
      (m) => m['key'] == moodKey,
      orElse: () => {'key': moodKey, 'label': moodKey},
    );
    return mood['label'] ?? moodKey;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMoodIfNeeded();
    });
  }

  Future<int?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      print('🔍 MoodCard: Getting userId from SharedPreferences: $userId');
      return userId;
    } catch (e) {
      print('❌ MoodCard: Error getting userId: $e');
      return null;
    }
  }

  void _loadMoodIfNeeded() async {
    if (!mounted) return;

    final currentUserId = await _getCurrentUserId();
    print('📱 MoodCard: Current userId: $currentUserId, Last loaded: $_lastLoadedUserId');

    if (currentUserId != null && _lastLoadedUserId != currentUserId) {
      print('🔄 MoodCard: Loading mood for user $currentUserId');
      setState(() {
        _lastLoadedUserId = currentUserId;
      });
      if (mounted) {
        context.read<DailyMoodCubit>().loadTodayMood();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) async {
            if (authState.isAuthenticated && authState.user != null) {
              final currentUserId = await _getCurrentUserId();
              if (currentUserId != null && _lastLoadedUserId != currentUserId) {
                print('👤 MoodCard: Auth changed, reloading for user $currentUserId');
                setState(() {
                  _lastLoadedUserId = currentUserId;
                });
                context.read<DailyMoodCubit>().loadTodayMood();
              }
            } else {
              print('🚪 MoodCard: User logged out');
              setState(() {
                _lastLoadedUserId = null;
              });
            }
          },
        ),
        BlocListener<DailyMoodCubit, DailyMoodState>(
          listener: (context, state) {
            if (state.error != null) {
              print('❌ MoodCard: Error - ${state.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 2),
                ),
              );
              context.read<DailyMoodCubit>().clearError();
            }
            
            // Success feedback
            if (state.status == DailyMoodStatus.loaded && state.todayMood != null) {
              print('✅ MoodCard: Mood loaded successfully');
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
    final l10n = AppLocalizations.of(context)!;
    
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
            state.error ?? l10n.journalMoodCardFailedToLoad,
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              print('🔄 Retry button pressed');
              context.read<DailyMoodCubit>().loadTodayMood();
            },
            child: Text(l10n.journalMoodCardRetry),
          ),
        ],
      );
    }

    final hasSelectedMood = state.todayMood != null;
    return hasSelectedMood ? _buildSelectedMood(state) : _buildMoodSelector();
  }

  Widget _buildSelectedMood(DailyMoodState state) {
    final l10n = AppLocalizations.of(context)!;
    final mood = state.todayMood!;
    final formattedTime = _formatDateTime(mood.updatedAt, l10n);
    final localizedLabel = _getLocalizedMoodLabel(mood.moodLabel, l10n);

    return Row(
      children: [
        Image.asset(mood.moodImage, height: 40, width: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedLabel,
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
            print('✏️ Edit mood button pressed');
            context.read<DailyMoodCubit>().clearTodayMood();
          },
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    final l10n = AppLocalizations.of(context)!;
    final moods = _getMoods(l10n);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.journalMoodCardTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () async {
                    print('😊 Mood selected: ${mood['key']} (${mood['label']})');
                    
                    // Show immediate feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saving mood: ${mood['label']}...'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    
                    // Save mood with KEY not label
                    await context.read<DailyMoodCubit>().setTodayMood(
                      mood['image']!,
                      mood['key']!, // ✅ Save the key
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

  String _formatDateTime(DateTime date, AppLocalizations l10n) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final day = date.day;
    final month = _getMonthName(date.month, l10n);

    return '${l10n.journalMoodCardToday}, $month $day, $hour:$minute $period';
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    final months = [
      l10n.journalMonthJanuary,
      l10n.journalMonthFebruary,
      l10n.journalMonthMarch,
      l10n.journalMonthApril,
      l10n.journalMonthMayFull,
      l10n.journalMonthJune,
      l10n.journalMonthJuly,
      l10n.journalMonthAugust,
      l10n.journalMonthSeptember,
      l10n.journalMonthOctober,
      l10n.journalMonthNovember,
      l10n.journalMonthDecember
    ];
    return months[month - 1];
  }
}