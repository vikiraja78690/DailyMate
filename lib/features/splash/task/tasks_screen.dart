
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../calendar/calendar_screen.dart';
import '../shopping/shopping_screen.dart';
import '../notes/notes_screen.dart';
import '../reminders/reminders_screen.dart';
import '../activity/activity_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../help_support/help_support_screen.dart';
import '../../../services/api_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'All Tasks';

  final List<String> _categories = [
    'Personal',
    'Work',
    'Health',
    'Study',
  ];

  List<_TaskItem> _tasks = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final data = await ApiService.getTasks();
      if (!mounted) return;

      setState(() {
        _tasks = data.map((item) {
          final json = item as Map<String, dynamic>;
          final dueDate = json['dueDate'] == null
              ? null
              : DateTime.tryParse(json['dueDate'].toString());
          final displayTime = dueDate == null
              ? 'No time'
              : TimeOfDay.fromDateTime(dueDate).format(context);

          return _TaskItem(
            id: (json['id'] as num).toInt(),
            dueDate: dueDate,
            title: json['title']?.toString() ?? '',
            description: json['description']?.toString() ?? '',
            category: json['category']?.toString() ?? 'Personal',
            time: displayTime,
            completed: json['isCompleted'] == true,
          );
        }).toList();

        for (final task in _tasks) {
          if (!_categories.any(
            (category) => category.toLowerCase() == task.category.toLowerCase(),
          )) {
            _categories.add(task.category);
          }
        }

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<_TaskItem> get _filteredTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_filter) {
      case 'Today':
        return _tasks.where((task) {
          final date = task.dueDate;
          return date != null &&
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();

      case 'Upcoming':
        return _tasks.where((task) {
          final date = task.dueDate;
          return !task.completed &&
              date != null &&
              DateTime(date.year, date.month, date.day).isAfter(today);
        }).toList();

      case 'Completed':
        return _tasks.where((task) => task.completed).toList();

      case 'Pending':
        return _tasks.where((task) => !task.completed).toList();

      default:
        return _tasks;
    }
  }

  int get _completedCount =>
      _tasks.where((task) => task.completed).length;

  int get _pendingCount => _tasks.length - _completedCount;

  double get _progress =>
      _tasks.isEmpty ? 0 : _completedCount / _tasks.length;

  void _navigate(int index) {
    if (index == 1) return;

    final pages = <Widget>[
      const HomeScreen(),
      const TasksScreen(),
      const CalendarScreen(),
      const ShoppingScreen(),
      const NotesScreen(),
      const RemindersScreen(),
      const ActivityScreen(),
      const AiAssistantScreen(),
      const SettingsScreen(),
      const HelpSupportScreen(),
    ];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pages[index]),
    );
  }

  Future<void> _showTaskDialog({_TaskItem? task}) async {
    final result = await Navigator.push<_TaskItem>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormPage(
          task: task,
          categories: List<String>.from(_categories),
        ),
      ),
    );

    if (!mounted || result == null) return;

    // Keep newly created categories available during this app session.
    if (!_categories.any(
      (category) => category.toLowerCase() == result.category.toLowerCase(),
    )) {
      _categories.add(result.category);
    }

    try {
      final payload = <String, dynamic>{
        'title': result.title,
        'description': result.description,
        'category': result.category,
        'dueDate': result.dueDate?.toIso8601String(),
        'isCompleted': result.completed,
      };

      if (task != null) {
        await ApiService.updateTask(task.id!, payload);
      } else {
        await ApiService.addTask(payload);
      }

      if (!mounted) return;

      await _loadTasks();

      if (!mounted) return;

      setState(() {
        _filter = 'All Tasks';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            task != null
                ? 'Task updated successfully!'
                : 'Task added successfully!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save task: $e')),
      );
    }
  }

  Future<void> _deleteTask(_TaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Do you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await ApiService.deleteTask(task.id!);
      if (!mounted) return;
      setState(() => _tasks.removeWhere((item) => item.id == task.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete task: $e')),
      );
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Work':
        return const Color(0xFF304CEB);
      case 'Health':
        return const Color(0xFF13A89E);
      case 'Study':
        return const Color(0xFF7545F5);
      default:
        return const Color(0xFFFF922E);
    }
  }

  Color _categoryBackground(String category) {
    switch (category) {
      case 'Work':
        return const Color(0xFFE6EAFE);
      case 'Health':
        return const Color(0xFFE1F7F3);
      case 'Study':
        return const Color(0xFFF0E8FF);
      default:
        return const Color(0xFFFFF0E1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isDesktop ? null : _buildSidebar(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasks-screen-add-button',
        onPressed: () => _showTaskDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              SizedBox(
                width: 260,
                child: _buildSidebar(permanent: true),
              ),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(isDesktop),
                  Expanded(child: _buildTaskContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (!isDesktop) ...[
            Builder(
              builder: (context) => _headerButton(
                Icons.menu_rounded,
                () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DailyMate',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your daily tasks',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _headerButton(
            Icons.notifications_none_rounded,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You are all caught up!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _headerButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.textDark),
        ),
      ),
    );
  }

  Widget _buildTaskContent() {
    final tasks = _filteredTasks;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 44),
              const SizedBox(height: 12),
              const Text('Could not load tasks'),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadTasks();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Organize your day, one task at a time.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 22),
              _buildProgressCard(),
              const SizedBox(height: 24),
              _buildFilters(),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Task List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    '${tasks.length} tasks',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (tasks.isEmpty)
                _buildEmptyState()
              else
                ...tasks.map(_buildTaskCard),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(21),
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
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up_rounded, color: Colors.white),
              SizedBox(width: 9),
              Text(
                "Today's Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_completedCount of ${_tasks.length} tasks completed',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _progress),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 9,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(
                          Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(_progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _progressBadge('Completed', _completedCount),
              const SizedBox(width: 18),
              _progressBadge('Pending', _pendingCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressBadge(String title, int count) {
    return Row(
      children: [
        const Icon(
          Icons.circle,
          size: 7,
          color: Colors.white70,
        ),
        const SizedBox(width: 6),
        Text(
          '$title: $count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    const sections = [
      'All Tasks',
      'Today',
      'Upcoming',
      'Completed',
      'Pending',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF253CC5),
            Color(0xFF7048E8),
            Color(0xFF9A45E8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7048E8).withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filter,
          isExpanded: true,
          dropdownColor: const Color(0xFF7048E8),
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          selectedItemBuilder: (context) {
            return sections.map((section) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  section,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList();
          },
          items: sections.map((section) {
            return DropdownMenuItem<String>(
              value: section,
              child: Text(
                section,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _filter = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTaskCard(_TaskItem task) {
    final color = _categoryColor(task.category);
    final background = _categoryBackground(task.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.completed,
            activeColor: AppColors.primary,
            shape: const CircleBorder(),
            onChanged: (value) async {
              final newValue = value ?? false;
              final oldValue = task.completed;
              setState(() => task.completed = newValue);
              try {
                await ApiService.updateTask(task.id!, {
                  'title': task.title,
                  'description': task.description,
                  'category': task.category,
                  'dueDate': task.dueDate?.toIso8601String(),
                  'isCompleted': newValue,
                });
              } catch (e) {
                if (!mounted) return;
                setState(() => task.completed = oldValue);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not update task: $e')),
                );
              }
            },
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      task.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        task.category,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textMuted),
            onSelected: (value) {
              if (value == 'edit') {
                _showTaskDialog(task: task);
              } else if (value == 'delete') {
                _deleteTask(task);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 9),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 9),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks here',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Add a task or choose another filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({bool permanent = false}) {
    final content = SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 27, 18, 25),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.spa_rounded, color: Colors.white, size: 42),
                SizedBox(height: 13),
                Text(
                  'DailyMate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your personal productivity space',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              children: [
                _sideItem(Icons.home_rounded, 'Home', 0),
                _sideItem(Icons.task_alt_rounded, 'Tasks', 1,
                    selected: true),
                _sideItem(Icons.calendar_month_rounded, 'Calendar', 2),
                _sideItem(Icons.shopping_bag_rounded, 'Shopping Lists', 3),
                _sideItem(Icons.note_alt_rounded, 'Notes', 4),
                _sideItem(
                    Icons.notifications_active_rounded, 'Reminders', 5),
                _sideItem(Icons.insights_rounded, 'Activity & Progress', 6),
                _sideItem(Icons.auto_awesome_rounded, 'AI Assistant', 7),
                _sideItem(Icons.settings_rounded, 'Settings', 8),
                const Divider(height: 25),
                _sideItem(Icons.help_outline_rounded, 'Help & Support', 9),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'DailyMate • Stay organized',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );

    if (permanent) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            right: BorderSide(color: AppColors.border),
          ),
        ),
        child: content,
      );
    }

    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: content,
    );
  }

  Widget _sideItem(
    IconData icon,
    String title,
    int index, {
    bool selected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        selected: selected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.09),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        leading: Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.textMuted,
          size: 21,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textDark,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          if (!selected) {
            if (!MediaQuery.sizeOf(context).width.isNaN &&
                MediaQuery.sizeOf(context).width < 900) {
              Navigator.pop(context);
            }
            _navigate(index);
          } else if (!MediaQuery.sizeOf(context).width.isNaN &&
              MediaQuery.sizeOf(context).width < 900) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class TaskFormPage extends StatefulWidget {
  final _TaskItem? task;
  final List<String> categories;

  const TaskFormPage({
    super.key,
    this.task,
    required this.categories,
  });

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late final List<String> _categories;
  late String _selectedCategory;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();

    final task = widget.task;
    final now = DateTime.now();

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    _categories = List<String>.from(widget.categories);

    if (task != null &&
        !_categories.any(
          (category) => category.toLowerCase() == task.category.toLowerCase(),
        )) {
      _categories.add(task.category);
    }

    if (_categories.isEmpty) {
      _categories.add('Personal');
    }

    _selectedCategory = task?.category ?? _categories.first;

    final initialDate = task?.dueDate ?? now;
    _selectedDate = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
    );

    _selectedTime = task?.dueDate != null
        ? TimeOfDay.fromDateTime(task!.dueDate!)
        : const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();

    final category = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Custom Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Shopping, Family, Projects',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(dialogContext, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Add Category'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (!mounted || category == null) return;

    final cleanedCategory = category.trim();
    if (cleanedCategory.isEmpty) return;

    final existing = _categories.firstWhere(
      (item) => item.toLowerCase() == cleanedCategory.toLowerCase(),
      orElse: () => '',
    );

    if (existing.isNotEmpty) {
      setState(() => _selectedCategory = existing);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category already exists.')),
      );
      return;
    }

    setState(() {
      _categories.add(cleanedCategory);
      _selectedCategory = cleanedCategory;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final dueDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    Navigator.pop(
      context,
      _TaskItem(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        dueDate: dueDate,
        time: _selectedTime.format(context),
        completed: widget.task?.completed ?? false,
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _scheduleTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.textDark),
        title: Text(
          isEditing ? 'Edit Task' : 'Create New Task',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(21),
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
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Plan your day!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Add details, choose a category and set your schedule.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            _sectionLabel('Task Title'),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: _inputDecoration(
                hint: 'What do you need to do?',
                icon: Icons.edit_note_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title.';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            _sectionLabel('Description'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: _inputDecoration(
                hint: 'Add task details (optional)',
                icon: Icons.notes_rounded,
              ),
            ),

            const SizedBox(height: 20),
            _sectionLabel('Category'),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 9),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: IconButton(
                    tooltip: 'Add custom category',
                    onPressed: _addCategory,
                    icon: Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _sectionLabel('Schedule'),
            _scheduleTile(
              icon: Icons.calendar_month_rounded,
              label: 'Due Date',
              value:
                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            _scheduleTile(
              icon: Icons.access_time_rounded,
              label: 'Task Time',
              value: _selectedTime.format(context),
              onTap: _pickTime,
            ),

            const SizedBox(height: 30),
            SizedBox(
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF253CC5),
                      Color(0xFF7048E8),
                      Color(0xFF9A45E8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Create Task',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskItem {
  _TaskItem({
    this.id,
    this.dueDate,
    required this.title,
    this.description = '',
    required this.category,
    required this.time,
    this.completed = false,
  });

  int? id;
  DateTime? dueDate;
  String title;
  String description;
  String category;
  String time;
  bool completed;
}
