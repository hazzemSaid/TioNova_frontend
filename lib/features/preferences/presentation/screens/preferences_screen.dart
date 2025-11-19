import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with SingleTickerProviderStateMixin {
  // Current step (0-5 for 6 steps)
  int _currentStep = 0;

  // Scroll controller for custom scrolling
  late ScrollController _scrollController;

  // Animation controller for step transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Step 1: Daily Chapter Goal
  double _studyPerDay = 2;

  // Step 2: Preferred Study Times
  String? _preferredStudyTime;

  // Step 3: Daily Time Commitment
  double _dailyTimeCommitmentMinutes = 30;

  // Step 4: Days Per Week
  double _daysPerWeek = 5;

  // Step 5: Learning Goals
  final Set<String> _selectedGoals = {};

  // Step 6: Content Difficulty
  String _contentDifficulty = 'medium';

  // Available goals
  final List<Map<String, dynamic>> _availableGoals = [
    {'icon': '🎯', 'label': 'Prepare for Exams', 'value': 'Prepare for Exams'},
    {'icon': '✨', 'label': 'Learn New Topics', 'value': 'Learn New Topics'},
    {'icon': '📚', 'label': 'Review Materials', 'value': 'Review Materials'},
    {'icon': '📈', 'label': 'Improve Grades', 'value': 'Improve Grades'},
    {'icon': '📅', 'label': 'Daily Practice', 'value': 'Daily Practice'},
    {
      'icon': '💼',
      'label': 'Career Development',
      'value': 'Career Development',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
        _animationController.reset();
        _animationController.forward();
        // Scroll to top when changing steps
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      _submitPreferences();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _animationController.reset();
        _animationController.forward();
        // Scroll to top when changing steps
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _skipForNow() {
    context.go('/');
  }

  void _submitPreferences() {
    final preferencesData = {
      'studyPerDay': _studyPerDay.toInt(),
      'preferredStudyTimes': _preferredStudyTime?.toLowerCase() ?? 'evening',
      'dailyTimeCommitmentMinutes': _dailyTimeCommitmentMinutes.toInt(),
      'daysPerWeek': _daysPerWeek.toInt(),
      'goals': _selectedGoals.toList(),
      'reminderEnabled': true,
      'reminderTimes': ['09:00', '19:00'],
      'contentDifficulty': _contentDifficulty,
    };

    print('Preferences to submit: $preferencesData');
    context.go('/');
  }

  double get _progress => (_currentStep + 1) / 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar Section (Fixed at top)
            _buildProgressBar(theme, isDark),

            // Scrollable Content using CustomScrollView
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Animated content for current step
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildCurrentStep(theme, isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation (Fixed at bottom)
            _buildBottomNavigation(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              tween: Tween<double>(begin: (_currentStep) / 6, end: _progress),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(ThemeData theme, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStep1DailyChapterGoal(theme, isDark);
      case 1:
        return _buildStep2PreferredStudyTimes(theme, isDark);
      case 2:
        return _buildStep3DailyTimeCommitment(theme, isDark);
      case 3:
        return _buildStep4StudySchedule(theme, isDark);
      case 4:
        return _buildStep5LearningGoals(theme, isDark);
      case 5:
        return _buildStep6ContentDifficulty(theme, isDark);
      default:
        return const SizedBox();
    }
  }

  // Step 1: Daily Chapter Goal
  Widget _buildStep1DailyChapterGoal(ThemeData theme, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        _buildStepIcon(Icons.book_outlined, isDark),
        const SizedBox(height: 24),
        Text(
          'Daily Chapter Goal',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'How many chapters do you want to study per day?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),
        Text(
          '${_studyPerDay.toInt()}',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 72,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'chapters per\nday',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildSlider(
          value: _studyPerDay,
          min: 1,
          max: 10,
          divisions: 9,
          labels: ['1', '5', '10'],
          onChanged: (value) => setState(() => _studyPerDay = value),
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 40),
        Text(
          'Perfect for steady progress',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  // Step 2: Preferred Study Times
  Widget _buildStep2PreferredStudyTimes(ThemeData theme, bool isDark) {
    final studyTimes = [
      {
        'icon': Icons.coffee,
        'label': 'Early Morning',
        'time': '5-8 AM',
        'value': 'early morning',
      },
      {
        'icon': Icons.wb_sunny,
        'label': 'Morning',
        'time': '8-12 PM',
        'value': 'morning',
      },
      {
        'icon': Icons.wb_twilight,
        'label': 'Afternoon',
        'time': '12-5 PM',
        'value': 'afternoon',
      },
      {
        'icon': Icons.nights_stay,
        'label': 'Evening',
        'time': '5-9 PM',
        'value': 'evening',
      },
      {
        'icon': Icons.bedtime,
        'label': 'Night',
        'time': '9 PM+',
        'value': 'night',
      },
    ];

    return Column(
      children: [
        const SizedBox(height: 40),
        _buildStepIcon(Icons.access_time, isDark),
        const SizedBox(height: 24),
        Text(
          'When do you study?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select your preferred study times',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ...studyTimes.map((time) => _buildTimeOption(time, theme, isDark)),
        const SizedBox(height: 40),
      ],
    );
  }

  // Step 3: Daily Time Commitment
  Widget _buildStep3DailyTimeCommitment(ThemeData theme, bool isDark) {
    final quickOptions = [15, 30, 60];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        _buildStepIcon(Icons.access_time, isDark),
        const SizedBox(height: 24),
        Text(
          'Daily Time Commitment',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'How much time will you dedicate each day?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),
        Text(
          '${_dailyTimeCommitmentMinutes.toInt()}',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 72,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'minutes per day',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildSlider(
          value: _dailyTimeCommitmentMinutes,
          min: 15,
          max: 180,
          divisions: 33,
          labels: ['15m', '90m', '180m'],
          onChanged: (value) =>
              setState(() => _dailyTimeCommitmentMinutes = value),
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 32),
        _buildQuickTimeOptions(quickOptions, theme, isDark),
        const SizedBox(height: 60),
      ],
    );
  }

  // Step 4: Study Schedule
  Widget _buildStep4StudySchedule(ThemeData theme, bool isDark) {
    final quickOptions = [3, 5, 7];
    final estimatedChapters = (_studyPerDay * _daysPerWeek).toInt();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        _buildStepIcon(Icons.calendar_month, isDark),
        const SizedBox(height: 24),
        Text(
          'Study Schedule',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'How many days per week will you study?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),
        Text(
          '${_daysPerWeek.toInt()}',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 72,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'days per\nweek',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildSlider(
          value: _daysPerWeek,
          min: 1,
          max: 7,
          divisions: 6,
          labels: ['1', '4', '7'],
          onChanged: (value) => setState(() => _daysPerWeek = value),
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 32),
        _buildQuickDaysOptions(quickOptions, theme, isDark),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Estimated: $estimatedChapters chapters/week',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  // Step 5: Learning Goals
  Widget _buildStep5LearningGoals(ThemeData theme, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 40),
        _buildStepIcon(Icons.emoji_events, isDark),
        const SizedBox(height: 24),
        Text(
          'Your Learning Goals',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'What do you want to achieve?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildGoalsGrid(theme, isDark),
        const SizedBox(height: 60),
      ],
    );
  }

  // Step 6: Content Difficulty
  Widget _buildStep6ContentDifficulty(ThemeData theme, bool isDark) {
    final difficultyOptions = [
      {
        'value': 'easy',
        'label': 'Easy',
        'description': 'Gentle pace, more explanations',
        'color': Colors.green,
      },
      {
        'value': 'medium',
        'label': 'Medium',
        'description': 'Balanced difficulty and depth',
        'color': Colors.orange,
      },
      {
        'value': 'hard',
        'label': 'Hard',
        'description': 'Challenging content, faster pace',
        'color': Colors.red,
      },
      {
        'value': 'progressive',
        'label': 'Progressive',
        'description': 'Start easy, gradually increase difficulty',
        'color': Colors.amber,
      },
    ];

    return Column(
      children: [
        const SizedBox(height: 40),
        _buildStepIcon(Icons.auto_awesome, isDark),
        const SizedBox(height: 24),
        Text(
          'Content Difficulty',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Choose your preferred difficulty level',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ...difficultyOptions.map(
          (option) => _buildDifficultyOption(option, theme, isDark),
        ),
        const SizedBox(height: 32),
        _buildSummaryCard(theme),
        const SizedBox(height: 40),
      ],
    );
  }

  // Reusable Components

  Widget _buildStepIcon(IconData icon, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 40, color: theme.colorScheme.onPrimary),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required List<String> labels,
    required ValueChanged<double> onChanged,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.surfaceVariant,
              thumbColor: theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels
                  .map(
                    (label) => Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(
    Map<String, dynamic> time,
    ThemeData theme,
    bool isDark,
  ) {
    final isSelected = _preferredStudyTime == time['value'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () =>
            setState(() => _preferredStudyTime = time['value'] as String),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? null
                : Border.all(
                    color:
                        theme.dividerTheme.color ?? theme.colorScheme.outline,
                    width: 1,
                  ),
          ),
          child: Row(
            children: [
              Icon(
                time['icon'] as IconData,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                size: 24,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time['label'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time['time'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary.withOpacity(0.6)
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTimeOptions(
    List<int> options,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((minutes) {
        final isSelected = _dailyTimeCommitmentMinutes == minutes.toDouble();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: InkWell(
            onTap: () => setState(
              () => _dailyTimeCommitmentMinutes = minutes.toDouble(),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${minutes}m',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickDaysOptions(
    List<int> options,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((days) {
        final isSelected = _daysPerWeek == days.toDouble();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: InkWell(
            onTap: () => setState(() => _daysPerWeek = days.toDouble()),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$days',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary.withOpacity(0.7)
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalsGrid(ThemeData theme, bool isDark) {
    return Builder(
      builder: (context) {
        final screenWidth =
            MediaQuery.of(context).size.width -
            48; // Account for horizontal padding
        final cardWidth =
            (screenWidth - 16) / 2; // 16 for spacing between cards

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _availableGoals.map((goal) {
            final isSelected = _selectedGoals.contains(goal['value']);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedGoals.remove(goal['value']);
                  } else {
                    _selectedGoals.add(goal['value'] as String);
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? null
                      : Border.all(
                          color:
                              theme.dividerTheme.color ??
                              theme.colorScheme.outline,
                          width: 1,
                        ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      goal['icon'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      goal['label'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDifficultyOption(
    Map<String, dynamic> option,
    ThemeData theme,
    bool isDark,
  ) {
    final isSelected = _contentDifficulty == option['value'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () =>
            setState(() => _contentDifficulty = option['value'] as String),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? null
                : Border.all(
                    color:
                        theme.dividerTheme.color ?? theme.colorScheme.outline,
                    width: 1,
                  ),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: option['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['label'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary.withOpacity(0.6)
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Study Plan Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                theme,
                '${_studyPerDay.toInt()}',
                'Chapters/day',
              ),
              _buildSummaryItem(
                theme,
                '${_dailyTimeCommitmentMinutes.toInt()}m',
                'Per day',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(theme, '${_daysPerWeek.toInt()}', 'Days/week'),
              _buildSummaryItem(theme, '${_selectedGoals.length}', 'Goals'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(ThemeData theme, bool isDark) {
    final canContinue = _canProceed();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerTheme.color ?? theme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canContinue ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: theme.colorScheme.surfaceVariant,
                disabledForegroundColor: theme.colorScheme.onSurface
                    .withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStep == 5 ? 'Get Started' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: TextButton(
                    onPressed: _previousStep,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface.withOpacity(
                        0.6,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Back', style: TextStyle(fontSize: 15)),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                child: TextButton(
                  onPressed: _skipForNow,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface.withOpacity(
                      0.6,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _preferredStudyTime != null;
      case 2:
        return true;
      case 3:
        return true;
      case 4:
        return _selectedGoals.isNotEmpty;
      case 5:
        return true;
      default:
        return false;
    }
  }
}
