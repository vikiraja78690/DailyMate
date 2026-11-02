
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../task/tasks_screen.dart';
import '../calendar/calendar_screen.dart';
import '../shopping/shopping_screen.dart';
import '../notes/notes_screen.dart';
import '../activity/activity_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../help_support/help_support_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
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

  final List<Map<String, dynamic>> _reminders = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isDesktop => MediaQuery.sizeOf(context).width >= 900;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  // LOAD REMINDERS FROM API

  Future<void> _loadReminders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getReminders();

      final loadedReminders = response.map((item) {
        final reminder = Map<String, dynamic>.from(item as Map);

        final reminderDate = DateTime.tryParse(
          reminder['reminderDate']?.toString() ?? '',
        );

        return <String, dynamic>{
          'id': reminder['id'],
          'title': reminder['title'] ?? '',
          'description': reminder['description'] ?? '',
          'date': reminderDate ?? DateTime.now(),
          'completed': reminder['isCompleted'] ?? false,
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        _reminders
          ..clear()
          ..addAll(loadedReminders);
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

  // ADD OR EDIT REMINDER

  Future<void> _addOrEditReminder({int? index}) async {
    final isEditing = index != null;
    final existing = isEditing ? _reminders[index] : null;

    final titleController = TextEditingController(
      text: existing?['title']?.toString() ?? '',
    );

    final descriptionController = TextEditingController(
      text: existing?['description']?.toString() ?? '',
    );

    final existingDate = existing?['date'] as DateTime?;

    DateTime selectedDate = existingDate ?? DateTime.now().add(
      const Duration(days: 1),
    );

    TimeOfDay selectedTime = existingDate == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay.fromDateTime(existingDate);

    bool dialogSaving = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                isEditing ? 'Edit Reminder' : 'New Reminder',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Reminder title',
                        hintText: 'e.g. Pay electricity bill',
                        prefixIcon: const Icon(
                          Icons.notifications_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text('Date'),
                      subtitle: Text(_formatDate(selectedDate)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.access_time_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text('Time'),
                      subtitle: Text(selectedTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: selectedTime,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogSaving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: dialogSaving
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a reminder title.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            dialogSaving = true;
                          });

                          final reminderDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );

                          final payload = <String, dynamic>{
                            'title': titleController.text.trim(),
                            'description':
                                descriptionController.text.trim(),
                            'reminderDate':
                                reminderDateTime.toIso8601String(),
                            'isCompleted':
                                existing?['completed'] ?? false,
                          };

                          try {
                            if (isEditing) {
                              final id = existing?['id'];

                              if (id == null) {
                                throw Exception(
                                  'Reminder ID not found.',
                                );
                              }

                              await ApiService.updateReminder(
                                id as int,
                                payload,
                              );
                            } else {
                              await ApiService.addReminder(payload);
                            }

                            if (!mounted) return;

                            Navigator.pop(dialogContext, true);
                          } catch (e) {
                            setDialogState(() {
                              dialogSaving = false;
                            });

                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  child: dialogSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Update' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

    if (result == true && mounted) {
      await _loadReminders();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Reminder updated successfully'
                : 'Reminder added successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // DELETE REMINDER

  Future<void> _deleteReminder(int index) async {
    final reminder = _reminders[index];
    final id = reminder['id'];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Reminder?'),
          content: const Text(
            'Are you sure you want to delete this reminder?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      if (id == null) {
        throw Exception('Reminder ID not found.');
      }

      await ApiService.deleteReminder(id as int);

      if (!mounted) return;

      setState(() {
        _reminders.removeWhere((item) => item['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete reminder: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // TOGGLE COMPLETED STATUS

  Future<void> _toggleCompleted(int index, bool? value) async {
    final reminder = _reminders[index];
    final id = reminder['id'];

    if (id == null) return;

    final oldValue = reminder['completed'] as bool;
    final newValue = value ?? false;

    setState(() {
      _reminders[index]['completed'] = newValue;
    });

    final date = reminder['date'] as DateTime;

    final payload = <String, dynamic>{
      'title': reminder['title'],
      'description': reminder['description'],
      'reminderDate': date.toIso8601String(),
      'isCompleted': newValue,
    };

    try {
      await ApiService.updateReminder(id as int, payload);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _reminders[index]['completed'] = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update reminder: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // DATE FORMAT

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final reminderDay = DateTime(date.year, date.month, date.day);

    if (reminderDay == today) return 'Today';

    if (reminderDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pending = _reminders
        .where((reminder) => reminder['completed'] == false)
        .toList();

    final completed = _reminders
        .where((reminder) => reminder['completed'] == true)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _isDesktop
          ? null
          : Drawer(
              width: 280,
              backgroundColor: Colors.white,
              child: SafeArea(child: _buildSidebar()),
            ),
      body: SafeArea(
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
                  _buildHeader(),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _errorMessage != null
                            ? _buildErrorState()
                            : _reminders.isEmpty
                                ? _buildEmptyState()
                                : RefreshIndicator(
                                    onRefresh: _loadReminders,
                                    child: ListView(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        8,
                                        20,
                                        100,
                                      ),
                                      children: [
                                        _buildSummaryCard(
                                          pending.length,
                                          completed.length,
                                        ),
                                        const SizedBox(height: 25),
                                        _buildSectionTitle(
                                          'Upcoming',
                                          pending.length,
                                        ),
                                        const SizedBox(height: 12),
                                        if (pending.isEmpty)
                                          _buildSectionEmpty(
                                            'No upcoming reminders',
                                          )
                                        else
                                          ...pending.map((reminder) {
                                            final index =
                                                _reminders.indexOf(reminder);
                                            return _buildReminderCard(
                                              reminder,
                                              index,
                                            );
                                          }),
                                        if (completed.isNotEmpty) ...[
                                          const SizedBox(height: 25),
                                          _buildSectionTitle(
                                            'Completed',
                                            completed.length,
                                          ),
                                          const SizedBox(height: 12),
                                          ...completed.map((reminder) {
                                            final index =
                                                _reminders.indexOf(reminder);
                                            return _buildReminderCard(
                                              reminder,
                                              index,
                                            );
                                          }),
                                        ],
                                      ],
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'reminders-screen-add-button',
        onPressed: _isLoading ? null : () => _addOrEditReminder(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Reminder'),
      ),
    );
  }

  // ERROR STATE

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
            const SizedBox(height: 15),
            const Text(
              'Unable to load reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
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
              onPressed: _loadReminders,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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
                final selected = item['title'] == 'Reminders';

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
    if (!_isDesktop && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (index == 5) return;

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

    if (page != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  // HEADER

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        children: [
          if (!_isDesktop) ...[
            Builder(
              builder: (context) => _headerButton(
                Icons.menu_rounded,
                () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF304CEB),
                  Color(0xFF7545F5),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Never miss an important moment',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          _headerButton(
            Icons.add_rounded,
            () => _addOrEditReminder(),
            filled: true,
          ),
        ],
      ),
    );
  }

  Widget _headerButton(
    IconData icon,
    VoidCallback onTap, {
    bool filled = false,
  }) {
    return Material(
      color: filled ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(
            icon,
            color: filled ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  // SUMMARY CARD

  Widget _buildSummaryCard(int pending, int completed) {
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
                const Text(
                  'Stay on track!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$pending pending  •  $completed completed',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  '${_reminders.length} total reminders',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }

  // SECTION TITLE

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 9),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // REMINDER CARD

  Widget _buildReminderCard(
    Map<String, dynamic> reminder,
    int index,
  ) {
    final completed = reminder['completed'] as bool;
    final date = reminder['date'] as DateTime;
    final time = TimeOfDay.fromDateTime(date);

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
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: completed,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (value) => _toggleCompleted(index, value),
          ),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFFE1F7EF)
                  : AppColors.primary.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              completed
                  ? Icons.check_circle_rounded
                  : Icons.notifications_active_outlined,
              color: completed
                  ? const Color(0xFF008F80)
                  : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: completed ? muted : AppColors.textDark,
                    decoration:
                        completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                if ((reminder['description'] as String).isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    reminder['description'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 5,
                  children: [
                    _dateTimeLabel(
                      Icons.calendar_today_outlined,
                      _formatDate(date),
                    ),
                    _dateTimeLabel(
                      Icons.access_time_rounded,
                      time.format(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _addOrEditReminder(index: index);
              } else if (value == 'delete') {
                _deleteReminder(index);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 9),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
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

  Widget _dateTimeLabel(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: muted),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: muted,
          ),
        ),
      ],
    );
  }

  // EMPTY SECTION

  Widget _buildSectionEmpty(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(color: muted),
      ),
    );
  }

  // EMPTY SCREEN

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.13),
                    AppColors.purple.withValues(alpha: 0.13),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 58,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No reminders yet',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Add a reminder to keep track of important things.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () => _addOrEditReminder(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
