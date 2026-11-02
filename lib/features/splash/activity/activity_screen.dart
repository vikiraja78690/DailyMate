
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../home/home_screen.dart';
import '../task/tasks_screen.dart';
import '../calendar/calendar_screen.dart';
import '../shopping/shopping_screen.dart';
import '../notes/notes_screen.dart';
import '../reminders/reminders_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../help_support/help_support_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const Color muted = Color(0xFF9693A7);

  static const List<Map<String, dynamic>> menuItems = [
    {'title': 'Home', 'icon': Icons.home_rounded},
    {'title': 'Tasks', 'icon': Icons.task_alt_rounded},
    {'title': 'Calendar', 'icon': Icons.calendar_month_rounded},
    {'title': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    {'title': 'Notes', 'icon': Icons.sticky_note_2_outlined},
    {'title': 'Reminders', 'icon': Icons.notifications_none_rounded},
    {'title': 'Activity', 'icon': Icons.insights_rounded},
    {'title': 'AI Assistant', 'icon': Icons.auto_awesome_rounded},
    {'title': 'Settings', 'icon': Icons.settings_outlined},
    {'title': 'Help Support', 'icon': Icons.help_outline_rounded},
  ];

  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> _tasks = [];

  bool _isLoading = true;
  String? _errorMessage;

  bool get _isDesktop => MediaQuery.sizeOf(context).width >= 900;

  int get _completedTasks =>
      _tasks.where((task) => task['isCompleted'] == true).length;

  int get _pendingTasks => _tasks.length - _completedTasks;

  int get _thisWeekActivities {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    return _activities.where((activity) {
      final date = _activityDate(activity);
      return date != null &&
          !date.isBefore(startOfWeek) &&
          date.isBefore(startOfWeek.add(const Duration(days: 7)));
    }).length;
  }

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  DateTime? _activityDate(Map<String, dynamic> activity) {
    final value = activity['createdAt'];
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  Future<void> _loadActivityData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getActivities(),
        ApiService.getTasks(),
      ]);

      final activities = results[0]
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      final tasks = results[1]
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      if (!mounted) return;

      setState(() {
        _activities = activities;
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _navigate(int index) {
    if (!_isDesktop && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (index == 6) return;

    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    Widget? page;

    switch (index) {
      case 1:
        page = const TasksScreen();
        break;
      case 2:
        page = const CalendarScreen();
        break;
      case 3:
        page = const ShoppingScreen();
        break;
      case 4:
        page = const NotesScreen();
        break;
      case 5:
        page = const RemindersScreen();
        break;
      case 7:
        page = const AiAssistantScreen();
        break;
      case 8:
        page = const SettingsScreen();
        break;
      case 9:
        page = const HelpSupportScreen();
        break;
    }

    if (page != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = _isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: desktop
          ? null
          : Drawer(
              width: 280,
              backgroundColor: Colors.white,
              child: SafeArea(child: _buildSidebar()),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop)
              SizedBox(width: 260, child: _buildSidebar()),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // SIDEBAR

  Widget _buildSidebar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF304CEB),
                      Color(0xFF7545F5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'DailyMate',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF253CC5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              'MENU',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: muted,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: List.generate(menuItems.length, (index) {
                final item = menuItems[index];
                final selected = index == 6;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    onTap: () => _navigate(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF304CEB),
                                  Color(0xFF7545F5),
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 21,
                            color: selected
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 13),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF253CC5),
                  Color(0xFF7048E8),
                ],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Keep moving forward!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  // MAIN CONTENT

  Widget _buildContent() {
    final desktop = _isDesktop;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              if (!desktop) ...[
                Builder(
                  builder: (context) => _headerButton(
                    Icons.menu_rounded,
                    () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 13),
              ],
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity & Progress',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'See how far you have come.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh activity',
                onPressed: _loadActivityData,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorState()
                  : RefreshIndicator(
                      onRefresh: _loadActivityData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          20, 15, 20, 30,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 1050,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildOverallCard(),
                                const SizedBox(height: 25),
                                const Text(
                                  'Your Overview',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _buildStatCards(),
                                const SizedBox(height: 26),
                                const Text(
                                  'Weekly Activity',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _buildWeeklyProgress(),
                                const SizedBox(height: 24),
                                _buildRecentActivities(),
                                const SizedBox(height: 24),
                                _buildMotivationCard(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 55,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load activity data',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadActivityData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          height: 43,
          width: 43,
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }

  // OVERALL CARD

  Widget _buildOverallCard() {
    final completion = _tasks.isEmpty
        ? 0.0
        : _completedTasks / _tasks.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF253CC5),
            Color(0xFF7048E8),
            Color(0xFF9A45E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.trending_up_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your productivity journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_completedTasks of ${_tasks.length} tasks completed',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(completion * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STAT CARDS

  Widget _buildStatCards() {
    final cards = [
      _StatCard(
        title: 'Tasks Done',
        value: '$_completedTasks',
        subtitle: 'Completed tasks',
        icon: Icons.task_alt_rounded,
        gradient: const [
          Color(0xFF304CEB),
          Color(0xFF6378FF),
        ],
      ),
      _StatCard(
        title: 'Pending',
        value: '$_pendingTasks',
        subtitle: 'Tasks remaining',
        icon: Icons.pending_actions_rounded,
        gradient: const [
          Color(0xFFFF922E),
          Color(0xFFFFB45E),
        ],
      ),
      _StatCard(
        title: 'Activities',
        value: '${_activities.length}',
        subtitle: 'Total activity logs',
        icon: Icons.insights_rounded,
        gradient: const [
          Color(0xFF7545F5),
          Color(0xFFA17BFF),
        ],
      ),
      _StatCard(
        title: 'This Week',
        value: '$_thisWeekActivities',
        subtitle: 'Activity records',
        icon: Icons.calendar_today_rounded,
        gradient: const [
          Color(0xFFE84D76),
          Color(0xFFFF829D),
        ],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 650;

        if (wide) {
          return GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children: cards,
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 12),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }

  // WEEKLY PROGRESS

  Widget _buildWeeklyProgress() {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final days = List.generate(7, (index) {
      final day = monday.add(Duration(days: index));

      final count = _activities.where((activity) {
        final date = _activityDate(activity);
        return date != null &&
            date.year == day.year &&
            date.month == day.month &&
            date.day == day.day;
      }).length;

      return {
        'name': [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ][index],
        'count': count,
      };
    });

    final maxCount = days.fold<int>(
      0,
      (maximum, day) =>
          (day['count'] as int) > maximum
              ? day['count'] as int
              : maximum,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: days.map((day) {
          final count = day['count'] as int;
          final progress = maxCount == 0
              ? 0.0
              : count / maxCount;

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _ProgressRow(
              day: day['name'] as String,
              count: count,
              progress: progress,
            ),
          );
        }).toList(),
      ),
    );
  }

  // RECENT ACTIVITIES

  Widget _buildRecentActivities() {
    final sorted = [..._activities];

    sorted.sort((a, b) {
      final dateA = _activityDate(a);
      final dateB = _activityDate(b);

      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    final recent = sorted.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Text(
              '${_activities.length} records',
              style: const TextStyle(
                fontSize: 12,
                color: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (recent.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: AppColors.primary,
                  size: 42,
                ),
                SizedBox(height: 10),
                Text(
                  'No activities yet',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your activity history will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...recent.map(_buildActivityTile),
      ],
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    final type = activity['activityType']?.toString() ?? 'Activity';
    final description =
        activity['description']?.toString() ?? '';
    final date = _activityDate(activity);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _activityIcon(type),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _activityIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('task')) return Icons.task_alt_rounded;
    if (value.contains('note')) return Icons.sticky_note_2_rounded;
    if (value.contains('reminder')) {
      return Icons.notifications_active_rounded;
    }
    if (value.contains('shopping')) {
      return Icons.shopping_bag_rounded;
    }

    return Icons.history_rounded;
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day}/${local.month}/${local.year} • $hour:$minute $period';
  }

  // MOTIVATION CARD

  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE6EAFE),
            Color(0xFFF0E8FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: AppColors.primary,
            size: 36,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are making progress!',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Stay consistent and celebrate your small wins.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// STAT CARD

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// WEEKLY PROGRESS ROW

class _ProgressRow extends StatelessWidget {
  final String day;
  final int count;
  final double progress;

  const _ProgressRow({
    required this.day,
    required this.count,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            day,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: progress,
            ),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: animatedProgress,
                  minHeight: 9,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _progressColor(progress),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _progressColor(double value) {
    if (value >= 0.8) return const Color(0xFF13A89E);
    if (value >= 0.6) return const Color(0xFF304CEB);
    if (value >= 0.4) return const Color(0xFFFF922E);
    return const Color(0xFFE84D76);
  }
}
