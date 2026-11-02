import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../task/tasks_screen.dart';
import '../calendar/calendar_screen.dart';
import '../shopping/shopping_screen.dart';
import '../reminders/reminders_screen.dart';
import '../activity/activity_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../help_support/help_support_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();

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

  List<Map<String, dynamic>> _notes = [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isDesktop => MediaQuery.sizeOf(context).width >= 900;

  List<Map<String, dynamic>> get _filteredNotes {
    final query = _searchQuery.toLowerCase();

    return _notes.where((note) {
      final title = (note['title'] ?? '').toString().toLowerCase();
      final content = (note['content'] ?? '').toString().toLowerCase();

      return title.contains(query) || content.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getNotes();

      if (!mounted) return;

      setState(() {
        _notes = result
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  String _displayDate(dynamic value) {
    if (value == null) return 'Recently';

    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return 'Recently';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDay = DateTime(date.year, date.month, date.day);

    if (noteDay == today) return 'Today';
    if (noteDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = _filteredNotes;

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
              SizedBox(width: 260, child: _buildSidebar()),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSearchField(),
                  ),
                  const SizedBox(height: 22),
                  Expanded(child: _buildNotesBody(notes)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'notes-screen-add-button',
        onPressed: _isSaving ? null : () => _showNoteDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
      ),
    );
  }

  Widget _buildNotesBody(List<Map<String, dynamic>> notes) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 55, color: muted),
              const SizedBox(height: 12),
              const Text(
                'Could not load notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadNotes,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (notes.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(notes[index], index);
      },
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
                final selected = item['title'] == 'Notes';

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
                Icon(Icons.auto_awesome_rounded, color: Colors.white),
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

    if (index == 4) return;

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  // HEADER

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          if (!_isDesktop) ...[
            Builder(
              builder: (context) => _headerIconButton(
                Icons.menu_rounded,
                () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            width: 48,
            height: 48,
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
              Icons.sticky_note_2_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Notes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${_notes.length} notes saved',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
              ],
            ),
          ),
          _headerIconButton(
            Icons.add_rounded,
            () => _showNoteDialog(),
            filled: true,
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton(
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

  // SEARCH FIELD

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
      decoration: InputDecoration(
        hintText: 'Search your notes...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.primary,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // NOTE CARD

  Widget _buildNoteCard(Map<String, dynamic> note, int index) {
    final colors = [
      const Color(0xFFE8EDFF),
      const Color(0xFFE1F7EF),
      const Color(0xFFFFE9F0),
      const Color(0xFFFFF0DB),
    ];

    final iconColors = [
      const Color(0xFF304CEB),
      const Color(0xFF008F80),
      const Color(0xFFE84378),
      const Color(0xFFD88B24),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors[index % colors.length],
                        colors[index % colors.length].withValues(
                          alpha: 0.65,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: iconColors[index % iconColors.length],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    (note['title'] ?? '').toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showNoteDialog(note: note);
                    } else if (value == 'delete') {
                      _deleteNote(note);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              (note['content'] ?? '').toString(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textDark.withValues(alpha: 0.75),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: muted,
                ),
                const SizedBox(width: 5),
                Text(
                  _displayDate(note['updatedAt'] ?? note['createdAt']),
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
                const Spacer(),
                Icon(
                  Icons.push_pin_outlined,
                  size: 16,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // EMPTY STATE

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 70,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No notes yet' : 'No notes found',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Create your first note and keep your ideas organized.'
                  : 'Try searching with another word.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _showNoteDialog(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Note'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // CREATE / EDIT NOTE DIALOG

  Future<void> _showNoteDialog({Map<String, dynamic>? note}) async {
    final titleController = TextEditingController(
      text: note?['title']?.toString() ?? '',
    );

    final descriptionController = TextEditingController(
      text: note?['content']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
            note == null ? 'Create Note' : 'Edit Note',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Note title',
                    hintText: 'Enter title',
                    prefixIcon: const Icon(Icons.title_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Write your note here...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      final title = titleController.text.trim();
                      final content = descriptionController.text.trim();

                      if (title.isEmpty || content.isEmpty) {
                        _showMessage('Enter a title and description.');
                        return;
                      }

                      setState(() => _isSaving = true);
                      setDialogState(() {});

                      try {
                        final payload = {
                          'title': title,
                          'content': content,
                        };

                        if (note == null) {
                          await ApiService.addNote(payload);
                        } else {
                          final id = (note['id'] as num).toInt();
                          await ApiService.updateNote(id, payload);
                        }

                        if (!mounted) return;

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        await _loadNotes();
                        if (!mounted) return;
                        _showMessage(
                          note == null ? 'Note saved' : 'Note updated',
                        );
                      } catch (error) {
                        if (!mounted) return;
                        setState(() => _isSaving = false);
                        setDialogState(() {});
                        _showMessage('Could not save note: $error');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(note == null ? 'Save Note' : 'Update Note'),
            ),
          ],
        ),
      ),
    );

    titleController.dispose();
    descriptionController.dispose();

    if (mounted && _isSaving) {
      setState(() => _isSaving = false);
    }
  }

  // DELETE NOTE

  Future<void> _deleteNote(Map<String, dynamic> note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final id = (note['id'] as num).toInt();
      await ApiService.deleteNote(id);

      if (!mounted) return;

      setState(() {
        _notes.removeWhere((item) => item['id'] == id);
      });

      _showMessage('Note deleted');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not delete note: $error');
    }
  }
}