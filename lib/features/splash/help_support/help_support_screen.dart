
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

import '../home/home_screen.dart';
import '../task/tasks_screen.dart';
import '../calendar/calendar_screen.dart';
import '../shopping/shopping_screen.dart';
import '../notes/notes_screen.dart';
import '../reminders/reminders_screen.dart';
import '../activity/activity_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool get _isDesktop => MediaQuery.sizeOf(context).width >= 900;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I create a task?',
      'answer':
          'Open the Tasks page and tap the Add Task button. Enter your task details and save it.',
    },
    {
      'question': 'How can I set a reminder?',
      'answer':
          'Open the Reminders page, add a reminder, choose its date and time, and save it.',
    },
    {
      'question': 'Can I use Dark Mode?',
      'answer':
          'Yes. Open Settings and turn on the Dark Mode switch to change the app appearance.',
    },
    {
      'question': 'How do I manage my shopping list?',
      'answer':
          'Open Shopping Lists to add items and manage your shopping checklist.',
    },
    {
      'question': 'Where can I view my progress?',
      'answer':
          'Open Activity & Progress to review your productivity activity and progress.',
    },
    {
      'question': 'Will my data be saved?',
      'answer':
          'Data persistence depends on the storage features currently configured in your app. Check that your changes are saved before closing the app.',
    },
  ];

  static const List<Map<String, dynamic>> _menuItems = [
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigate(int index) {
    if (!_isDesktop && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (index == 9) return;

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
      case 6:
        page = const ActivityScreen();
        break;
      case 7:
        page = const AiAssistantScreen();
        break;
      case 8:
        page = const SettingsScreen();
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
    final query = _searchController.text.toLowerCase().trim();

    final filteredFaqs = _faqs.where((faq) {
      return faq['question']!.toLowerCase().contains(query) ||
          faq['answer']!.toLowerCase().contains(query);
    }).toList();

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
                    child: _buildContent(filteredFaqs),
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
                color: Color(0xFF9693A7),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: List.generate(_menuItems.length, (index) {
                final item = _menuItems[index];
                final selected = index == 9;

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
                  Icons.support_agent_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'We are here to help!',
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

  // HEADER

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Row(
        children: [
          if (!_isDesktop) ...[
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
                  'Help & Support',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'We are here to help you.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
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

  // MAIN CONTENT

  Widget _buildContent(List<Map<String, String>> filteredFaqs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            _buildSupportBanner(),
            const SizedBox(height: 28),

            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),

            if (filteredFaqs.isEmpty)
              _infoCard()
            else
              _buildFaqCard(filteredFaqs),

            const SizedBox(height: 28),

            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),

            _contactCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'Get help by sending us an email',
              onTap: () {
                _showContactDialog(
                  'Email Support',
                  'Connect your support email address to enable this feature.',
                );
              },
            ),
            const SizedBox(height: 12),

            _contactCard(
              icon: Icons.bug_report_outlined,
              title: 'Report a Problem',
              subtitle: 'Tell us about an issue in the app',
              onTap: _showReportDialog,
            ),
            const SizedBox(height: 12),

            _contactCard(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Suggest a Feature',
              subtitle: 'Share an idea to improve DailyMate',
              onTap: _showSuggestionDialog,
            ),

            const SizedBox(height: 28),

            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 23,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thank you for using DailyMate',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Help & Support • Version 1.0.0',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // SUPPORT BANNER

  Widget _buildSupportBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
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
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'How can we help?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions about DailyMate.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search for help...',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FAQ CARD

  Widget _buildFaqCard(List<Map<String, String>> faqs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < faqs.length; i++) ...[
            ExpansionTile(
              key: PageStorageKey(faqs[i]['question']),
              leading: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE6EAFE),
                      Color(0xFFF0E8FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              title: Text(
                faqs[i]['question']!,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              iconColor: AppColors.primary,
              collapsedIconColor: AppColors.textMuted,
              childrenPadding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                18,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    faqs[i]['answer']!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      height: 1.6,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (i != faqs.length - 1)
              const Divider(
                height: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }

  // EMPTY SEARCH RESULT

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 38,
            color: AppColors.primary,
          ),
          SizedBox(height: 12),
          Text(
            'No results found',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try searching with different words.',
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

  // CONTACT CARD

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE6EAFE),
                Color(0xFFF0E8FF),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  // CONTACT DIALOG

  void _showContactDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // REPORT PROBLEM

  void _showReportDialog() {
    _showFeedbackDialog(
      title: 'Report a Problem',
      hint: 'Describe the problem you encountered...',
      submitLabel: 'Submit Report',
    );
  }

  // SUGGEST FEATURE

  void _showSuggestionDialog() {
    _showFeedbackDialog(
      title: 'Suggest a Feature',
      hint: 'Share your idea...',
      submitLabel: 'Send Suggestion',
    );
  }

  // FEEDBACK DIALOG

  void _showFeedbackDialog({
    required String title,
    required String hint,
    required String submitLabel,
  }) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final message = controller.text.trim();

                if (message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a message first.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$title saved locally for this session. '
                      'Backend submission is not connected yet.',
                    ),
                  ),
                );
              },
              child: Text(submitLabel),
            ),
          ],
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }
}
