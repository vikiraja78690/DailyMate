
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../task/tasks_screen.dart';
import '../shopping/shopping_screen.dart';
import '../notes/notes_screen.dart';
import '../reminders/reminders_screen.dart';
import '../activity/activity_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../help_support/help_support_screen.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CalendarScreen({super.key, this.onBack});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  late DateTime displayedMonth = DateTime(
    selectedDate.year,
    selectedDate.month,
  );

  final List<Map<String, dynamic>> tasks = [
    {
      'title': 'Complete project',
      'time': '10:00 AM',
      'completed': false,
      'icon': Icons.work_outline_rounded,
    },
    {
      'title': 'Review daily goals',
      'time': '02:00 PM',
      'completed': true,
      'icon': Icons.flag_outlined,
    },
    {
      'title': 'Plan tomorrow',
      'time': '06:00 PM',
      'completed': false,
      'icon': Icons.event_note_rounded,
    },
  ];

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

  bool get _isDesktop => MediaQuery.sizeOf(context).width >= 900;

  @override
  Widget build(BuildContext context) {
    final completed =
        tasks.where((task) => task['completed'] == true).length;

    return Scaffold(
      backgroundColor: AppColors.background,

      drawer: _isDesktop
          ? null
          : Drawer(
              width: 280,
              backgroundColor: Colors.white,
              child: SafeArea(
                child: _buildSidebar(),
              ),
            ),

      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (_isDesktop)
              SizedBox(
                width: 260,
                child: _buildSidebar(),
              ),

            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        28,
                      ),
                      children: [
                        _buildHeaderCard(),
                        const SizedBox(height: 25),

                        _buildMonthHeader(),
                        const SizedBox(height: 15),

                        _buildCalendarCard(),
                        const SizedBox(height: 25),

                        _buildTaskHeading(completed),
                        const SizedBox(height: 14),

                        if (tasks.isEmpty)
                          _buildEmptyState()
                        else
                          ...tasks.map(_buildTaskCard),

                        const SizedBox(height: 18),

                        _buildAddButton(),
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
                final selected = index == 2;

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
                        color: selected ? null : Colors.transparent,
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
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Make every day count!',
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

  // NAVIGATION

  void _navigate(int index) {
    if (index == 2) {
      if (!_isDesktop) {
        Navigator.pop(context);
      }
      return;
    }

    if (index == 0 && widget.onBack != null) {
      if (!_isDesktop) {
        Navigator.pop(context);
      }
      widget.onBack!();
      return;
    }

    Widget? page;

    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = const TasksScreen();
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

    if (!_isDesktop && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (page != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => page!,
        ),
      );
    }
  }

  // TOP BAR

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          if (!_isDesktop) ...[
            Builder(
              builder: (drawerContext) {
                return _iconButton(
                  icon: Icons.menu_rounded,
                  onTap: () {
                    Scaffold.of(drawerContext).openDrawer();
                  },
                );
              },
            ),
            const SizedBox(width: 13),
          ],

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Schedule',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Plan your days with ease',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),

          _iconButton(
            icon: Icons.calendar_month_rounded,
            filled: true,
            onTap: () {
              setState(() {
                selectedDate = DateTime.now();
                displayedMonth = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Material(
      color: filled ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          width: 46,
          child: Icon(
            icon,
            size: 20,
            color: filled ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  // SELECTED DATE CARD

  Widget _buildHeaderCard() {
    return Container(
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
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECTED DATE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${selectedDate.day} ${_monthName(selectedDate.month)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_weekdayName(selectedDate.weekday)}, ${selectedDate.year}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  // MONTH NAVIGATION

  Widget _buildMonthHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Calendar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),

        _monthButton(
          Icons.chevron_left_rounded,
          () {
            setState(() {
              displayedMonth = DateTime(
                displayedMonth.year,
                displayedMonth.month - 1,
              );
            });
          },
        ),

        const SizedBox(width: 8),

        Text(
          '${_monthName(displayedMonth.month)} ${displayedMonth.year}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(width: 8),

        _monthButton(
          Icons.chevron_right_rounded,
          () {
            setState(() {
              displayedMonth = DateTime(
                displayedMonth.year,
                displayedMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _monthButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: SizedBox(
          height: 34,
          width: 34,
          child: Icon(
            icon,
            size: 21,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // CALENDAR GRID

  Widget _buildCalendarCard() {
    final firstWeekday =
        DateTime(displayedMonth.year, displayedMonth.month, 1).weekday;

    final daysInMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;

    final totalCells =
        ((firstWeekday - 1 + daysInMonth + 6) ~/ 7) * 7;

    const weekdays = [
      'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF304CEB).withValues(alpha: 0.16),
            const Color(0xFF7545F5).withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 17, 5, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              children: weekdays.map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            ...List.generate(totalCells ~/ 7, (week) {
              return Row(
                children: List.generate(7, (weekdayIndex) {
                  final cellIndex = week * 7 + weekdayIndex;
                  final dayNumber = cellIndex - firstWeekday + 2;

                  final validDay =
                      dayNumber >= 1 && dayNumber <= daysInMonth;

                  if (!validDay) {
                    return const Expanded(
                      child: SizedBox(height: 49),
                    );
                  }

                  final date = DateTime(
                    displayedMonth.year,
                    displayedMonth.month,
                    dayNumber,
                  );

                  final isSelected = _sameDay(date, selectedDate);
                  final isToday = _sameDay(date, DateTime.now());

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedDate = date);
                      },
                      child: SizedBox(
                        height: 49,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 34,
                              width: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF304CEB),
                                          Color(0xFF7545F5),
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : isToday
                                        ? AppColors.primary.withValues(
                                            alpha: 0.12,
                                          )
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isToday && !isSelected
                                    ? Border.all(
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              child: Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _hasTasks(date)
                                    ? AppColors.primary
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  // TASK HEADING

  Widget _buildTaskHeading(int completed) {
    final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

    return Row(
      children: [
        const Expanded(
          child: Text(
            "Today's Tasks",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$completed/${tasks.length} done',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),

        const SizedBox(width: 8),

        SizedBox(
          height: 35,
          width: 35,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF7545F5),
            ),
          ),
        ),
      ],
    );
  }

  // TASK CARD

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final completed = task['completed'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 47,
            width: 47,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF304CEB).withValues(alpha: 0.13),
                  const Color(0xFF7545F5).withValues(alpha: 0.13),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              task['icon'] as IconData,
              color: AppColors.primary,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] as String,
                  style: TextStyle(
                    color: completed ? muted : AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    decoration:
                        completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: muted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      task['time'] as String,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Checkbox(
            value: completed,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                task['completed'] = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  // EMPTY STATE

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 42,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Add a task to organize your day.',
            style: TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ADD TASK BUTTON

  Widget _buildAddButton() {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF304CEB),
              Color(0xFF7545F5),
            ],
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: ElevatedButton.icon(
          onPressed: _addTask,
          icon: const Icon(
            Icons.add_rounded,
            size: 23,
          ),
          label: const Text(
            'Add New Task',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        ),
      ),
    );
  }

  // DATE HELPERS

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _hasTasks(DateTime date) {
    return _sameDay(date, selectedDate) ||
        _sameDay(date, DateTime.now());
  }

  String _monthName(int month) {
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
      'December',
    ];

    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[weekday - 1];
  }

  // ADD TASK DIALOG

  void _addTask() {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Create a task',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter task title',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              controller.dispose();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final title = controller.text.trim();

              if (title.isNotEmpty) {
                setState(() {
                  tasks.add({
                    'title': title,
                    'time': 'All day',
                    'completed': false,
                    'icon': Icons.task_alt_rounded,
                  });
                });
              }  

              Navigator.pop(dialogContext);
              controller.dispose();
            }, 
            child: const Text('Save Task'),
          ),
        ], 
      ),
    );
  }
}
