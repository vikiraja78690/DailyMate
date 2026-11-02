
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api_service.dart';

import '../task/tasks_screen.dart';
import '../calendar/calendar_screen.dart';
import '../shopping/shopping_screen.dart';
import '../notes/notes_screen.dart';
import '../reminders/reminders_screen.dart';
import '../activity/activity_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../help_support/help_support_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _shoppingItems = [];
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _reminders = [];
  List<Map<String, dynamic>> _recentActivities = [];

  bool _isLoading = true;
  String? _loadError;

  int get _completedTasks =>
      _tasks.where((task) => task['isCompleted'] == true).length;

  int get _pendingTasks => _tasks.length - _completedTasks;

  double get _progress =>
      _tasks.isEmpty ? 0 : _completedTasks / _tasks.length;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getTasks(),
        ApiService.getShoppingItems(),
        ApiService.getNotes(),
        ApiService.getReminders(),
        ApiService.getActivities(),
      ]);

      List<Map<String, dynamic>> convertList(dynamic data) {
        return (data as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      if (!mounted) return;

      setState(() {
        _tasks = convertList(results[0]);
        _shoppingItems = convertList(results[1]);
        _notes = convertList(results[2]);
        _reminders = convertList(results[3]);
        _recentActivities = convertList(results[4]);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  String _todayDate() {
    final now = DateTime.now();

    const weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${weekdays[now.weekday - 1]}, '
        '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) {
      if (mounted) {
        _loadDashboardData();
      }
    });
  }

  void _openSection(int index) {
    Navigator.pop(context);

    if (index == 0) {
      setState(() => _selectedIndex = 0);
      _loadDashboardData();
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
      case 6:
        page = const ActivityScreen();
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

    if (page != null) {
      _openScreen(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            const TasksScreen(),
            const CalendarScreen(),
            const ShoppingScreen(),
            const NotesScreen(),
            const RemindersScreen(),
            const ActivityScreen(),
            const AiAssistantScreen(),
            const SettingsScreen(),
          ],
        ),
      ),
    );
  }

  // HOME CONTENT

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_loadError != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTopBar(),
                const SizedBox(height: 16),
                _buildHeroBanner(),
                const SizedBox(height: 16),
                _buildTopStatsCards(),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildUpcomingTasksCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTodayProgressCard()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildAiAssistantCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildQuickActionsCard()),
                  ],
                ),
                const SizedBox(height: 16),
                _buildNextUpCalendarCard(),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMakeEveryDayCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRecentActivityCard()),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
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
              Icons.cloud_off_rounded,
              size: 50,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _loadError ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // TOP BAR

  Widget _buildTopBar() {
    return Row(
      children: [
        Builder(
          builder: (context) => InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.menu_rounded,
                color: AppColors.textDark,
                size: 24,
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Color(0xFF304CEB),
              ),
              const SizedBox(width: 6),
              Text(
                _todayDate(),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          children: [
            _headerIcon(
              Icons.notifications_none_rounded,
              () => _showMessage(
                '${_reminders.length} reminders in your account.',
              ),
              showBadge: _reminders.isNotEmpty,
            ),
            const SizedBox(width: 8),
            _headerIcon(
              Icons.settings_outlined,
              () => _openScreen(const SettingsScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerIcon(
    IconData icon,
    VoidCallback onTap, {
    bool showBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textDark, size: 20),
            if (showBadge)
              Positioned(
                right: 9,
                top: 8,
                child: Container(
                  height: 7,
                  width: 7,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // HERO BANNER

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7048E8).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DailyMate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Plan • Organize • Achieve',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Small steps,\nBig goals 🚀',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // TOP STATS CARDS

  Widget _buildTopStatsCards() {
    final stats = [
      _StatMiniData(
        'Total Tasks',
        '${_tasks.length}',
        Icons.task_alt_rounded,
        const Color(0xFF304CEB),
        const Color(0xFFE6EAFE),
        const TasksScreen(),
      ),
      _StatMiniData(
        'Shopping Items',
        '${_shoppingItems.length}',
        Icons.shopping_bag_outlined,
        const Color(0xFFE84D76),
        const Color(0xFFFFEEF2),
        const ShoppingScreen(),
      ),
      _StatMiniData(
        'Notes',
        '${_notes.length}',
        Icons.description_outlined,
        const Color(0xFF13A89E),
        const Color(0xFFE1F7F3),
        const NotesScreen(),
      ),
      _StatMiniData(
        'Reminders',
        '${_reminders.length}',
        Icons.notifications_active_outlined,
        const Color(0xFFFF922E),
        const Color(0xFFFFEFE0),
        const RemindersScreen(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;

        return Row(
          children: stats.map((stat) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: stat == stats.last ? 0 : 8,
                ),
                child: _AnimatedCardWrapper(
                  onTap: () => _openScreen(stat.targetScreen),
                  child: Container(
                    padding: EdgeInsets.all(compact ? 7 : 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          stat.bgColor.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: stat.color.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: stat.color.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: stat.bgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                stat.icon,
                                color: stat.color,
                                size: 14,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: stat.color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stat.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stat.value,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // UPCOMING TASKS

  Widget _buildUpcomingTasksCard() {
    final upcoming = _tasks
        .where((task) => task['isCompleted'] != true)
        .take(4)
        .toList();

    return _AnimatedCardWrapper(
      onTap: () => _openScreen(const TasksScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF4F7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF304CEB).withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF304CEB),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Upcoming Tasks',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'View All →',
                  style: TextStyle(
                    color: Color(0xFF304CEB),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (upcoming.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'No pending tasks.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              )
            else
              ...upcoming.map((task) {
                final title =
                    task['title']?.toString() ?? 'Untitled task';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.radio_button_unchecked_rounded,
                        color: Color(0xFF304CEB),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // TODAY'S PROGRESS

  Widget _buildTodayProgressCard() {
    return _AnimatedCardWrapper(
      onTap: () => _openScreen(const ActivityScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF7F4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7048E8).withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: Color(0xFF7048E8),
                  size: 16,
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "Today's Progress",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                height: 65,
                width: 65,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFFE6EAFE),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF304CEB),
                      ),
                    ),
                    Text(
                      '$_completedTasks/${_tasks.length}',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '$_pendingTasks tasks pending',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Keep up the good work.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AI ASSISTANT CARD

  Widget _buildAiAssistantCard() {
    return _AnimatedCardWrapper(
      onTap: () => _openScreen(const AiAssistantScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE6EAFE), Color(0xFFF0E8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7048E8).withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7048E8).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Assistant',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Image.asset(
                'assets/images/ai_assistant.png',
                height: 75,
                width: 85,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.smart_toy_rounded,
                    color: Color(0xFF304CEB),
                    size: 35,
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'AI Assistant',
                style: TextStyle(
                  color: Color(0xFF253CC5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Your smart companion',
                style: TextStyle(
                  color: Color(0xFF7048E8),
                  fontSize: 9,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                onPressed: () => _openScreen(
                  const AiAssistantScreen(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF304CEB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Chat Now →',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // QUICK ACTIONS

  Widget _buildQuickActionsCard() {
    final actions = [
      _QuickActionItem(
        'Add Task',
        Icons.add_task_rounded,
        const Color(0xFF304CEB),
        const Color(0xFFE6EAFE),
        () => _openScreen(const TasksScreen()),
      ),
      _QuickActionItem(
        'Add Note',
        Icons.note_add_rounded,
        const Color(0xFF7545F5),
        const Color(0xFFF0E8FF),
        () => _openScreen(const NotesScreen()),
      ),
      _QuickActionItem(
        'Reminder',
        Icons.notification_add_rounded,
        const Color(0xFFFF922E),
        const Color(0xFFFFEFE0),
        () => _openScreen(const RemindersScreen()),
      ),
      _QuickActionItem(
        'Shopping',
        Icons.shopping_cart_rounded,
        const Color(0xFF13A89E),
        const Color(0xFFE1F7F3),
        () => _openScreen(const ShoppingScreen()),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFAFBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            itemCount: actions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final act = actions[index];

              return _AnimatedCardWrapper(
                onTap: act.onTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: act.bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: act.color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(act.icon, color: act.color, size: 18),
                      const SizedBox(height: 4),
                      Text(
                        act.title,
                        style: TextStyle(
                          color: act.color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // NEXT UP CALENDAR

  Widget _buildNextUpCalendarCard() {
    final now = DateTime.now();

    final days = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return _CalendarDay(
        _weekdayName(date.weekday),
        '${date.day}',
        index == 0,
      );
    });

    return _AnimatedCardWrapper(
      onTap: () => _openScreen(const CalendarScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF7F5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7048E8).withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF304CEB),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Next Up',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'View Calendar →',
                  style: TextStyle(
                    color: Color(0xFF304CEB),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: day.isSelected
                        ? const Color(0xFF7048E8)
                        : const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day.dayName,
                        style: TextStyle(
                          color: day.isSelected
                              ? Colors.white70
                              : AppColors.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.dateNum,
                        style: TextStyle(
                          color: day.isSelected
                              ? Colors.white
                              : AppColors.textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (day.isSelected) ...[
                        const SizedBox(height: 3),
                        const ContainerDot(),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayName(int weekday) {
    const names = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];
    return names[weekday - 1];
  }

  // MAKE EVERY DAY COUNT

  Widget _buildMakeEveryDayCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6EAFE), Color(0xFFD4E0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF304CEB).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF304CEB).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFF304CEB),
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Make every\nday count!',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 65,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF304CEB).withValues(alpha: 0.15),
                  const Color(0xFF7048E8).withValues(alpha: 0.25),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Icon(
                    Icons.landscape_rounded,
                    color: const Color(0xFF304CEB)
                        .withValues(alpha: 0.5),
                    size: 48,
                  ),
                ),
                const Positioned(
                  top: 8,
                  right: 12,
                  child: Icon(
                    Icons.flag_rounded,
                    color: Color(0xFFE84D76),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RECENT ACTIVITY

  Widget _buildRecentActivityCard() {
    final sorted = [..._recentActivities];

    sorted.sort((a, b) {
      final dateA = DateTime.tryParse(
        a['createdAt']?.toString() ?? '',
      );
      final dateB = DateTime.tryParse(
        b['createdAt']?.toString() ?? '',
      );

      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    final recent = sorted.take(3).toList();

    return _AnimatedCardWrapper(
      onTap: () => _openScreen(const ActivityScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFFAFBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: Color(0xFF304CEB),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'View All →',
                  style: TextStyle(
                    color: Color(0xFF304CEB),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No recent activity yet.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              )
            else
              ...recent.map(_buildActivityItem),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type =
        activity['activityType']?.toString() ?? 'Activity';

    final description =
        activity['description']?.toString() ?? '';

    final date = DateTime.tryParse(
      activity['createdAt']?.toString() ?? '',
    )?.toLocal();

    final lowerType = type.toLowerCase();

    final icon = lowerType.contains('task')
        ? Icons.task_alt_rounded
        : lowerType.contains('note')
            ? Icons.note_alt_outlined
            : lowerType.contains('shopping')
                ? Icons.shopping_cart_outlined
                : lowerType.contains('reminder')
                    ? Icons.notifications_active_outlined
                    : Icons.history_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EAFE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF304CEB),
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          if (date != null)
            Text(
              '${date.hour.toString().padLeft(2, '0')}:'
              '${date.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 8,
              ),
            ),
        ],
      ),
    );
  }

  // DRAWER

 
Widget _buildDrawer() {
  return Drawer(
    backgroundColor: Colors.white,
    child: SafeArea(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF253CC5),
                  Color(0xFF7048E8),
                  Color(0xFF9A45E8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 65,
                  width: 65,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      'assets/images/dailymate_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.spa_rounded,
                          color: Color(0xFF304CEB),
                          size: 38,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'DailyMate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Your personal productivity space',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Drawer Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              children: [
                _drawerItem(Icons.home_rounded, 'Home', 0),
                _drawerItem(Icons.task_alt_rounded, 'Tasks', 1),
                _drawerItem(Icons.calendar_month_rounded, 'Calendar', 2),
                _drawerItem(
                  Icons.shopping_bag_rounded,
                  'Shopping Lists',
                  3,
                ),
                _drawerItem(Icons.note_alt_rounded, 'Notes', 4),
                _drawerItem(
                  Icons.notifications_active_rounded,
                  'Reminders',
                  5,
                ),
                _drawerItem(
                  Icons.insights_rounded,
                  'Activity & Progress',
                  6,
                ),
                _drawerItem(
                  Icons.auto_awesome_rounded,
                  'AI Assistant',
                  7,
                ),
                _drawerItem(Icons.settings_rounded, 'Settings', 8),

                const Divider(height: 20),

                ListTile(
                  onTap: () => _openSection(9),
                  leading: const Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.textMuted,
                  ),
                  title: const Text(
                    'Help & Support',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                    ),
                  ),
                  dense: true,
                ),
              ],
            ),
          ),

          // Fixed Footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'DailyMate • Stay organized',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _drawerItem(
    IconData icon,
    String title,
    int index,
  ) {
    final selected = _selectedIndex == index;

    return ListTile(
      onTap: () => _openSection(index),
      selected: selected,
      selectedTileColor:
          AppColors.primary.withValues(alpha: 0.08),
      leading: Icon(
        icon,
        color: selected
            ? AppColors.primary
            : AppColors.textMuted,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected
              ? AppColors.primary
              : AppColors.textDark,
          fontSize: 12,
          fontWeight:
              selected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20),
      dense: true,
    );
  }
}

// ANIMATED PRESSABLE CARD

class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedCardWrapper({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedCardWrapper> createState() =>
      _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState
    extends State<_AnimatedCardWrapper> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

// HELPER CLASSES

class ContainerDot extends StatelessWidget {
  const ContainerDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatMiniData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Widget targetScreen;

  _StatMiniData(
    this.title,
    this.value,
    this.icon,
    this.color,
    this.bgColor,
    this.targetScreen,
  );
}

class _QuickActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  _QuickActionItem(
    this.title,
    this.icon,
    this.color,
    this.bgColor,
    this.onTap,
  );
}

class _CalendarDay {
  final String dayName;
  final String dateNum;
  final bool isSelected;

  _CalendarDay(
    this.dayName,
    this.dateNum,
    this.isSelected,
  );
}
