
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../task/tasks_screen.dart';
import '../calendar/calendar_screen.dart';
import '../shopping/shopping_screen.dart';
import '../notes/notes_screen.dart';
import '../reminders/reminders_screen.dart';
import '../activity/activity_screen.dart';
import '../settings/settings_screen.dart';
import '../help_support/help_support_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
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

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! 👋 I am your DailyMate AI Assistant.',
      'isUser': false,
    },
    {
      'text':
          'I can help you plan your day and stay productive. What would you like to work on?',
      'isUser': false,
    },
  ];

  bool _isTyping = false;

  bool get _isDesktop => MediaQuery.sizeOf(context).width >= 900;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // SEND MESSAGE

  void _sendMessage([String? suggestion]) {
    final text = (suggestion ?? _messageController.text).trim();

    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
      });

      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      final lowerText = text.toLowerCase();
      String reply;

      if (lowerText.contains('plan') || lowerText.contains('day')) {
        reply = 'Here is a simple plan for your day:\n\n'
            '1. Choose your 3 most important tasks.\n'
            '2. Complete the hardest task first.\n'
            '3. Take short breaks between tasks.\n'
            '4. Review your progress in the evening.\n\n'
            'You can add these tasks in your Tasks screen.';
      } else if (lowerText.contains('productive') ||
          lowerText.contains('focus')) {
        reply = 'Try this productivity routine:\n\n'
            '• Focus on one task at a time.\n'
            '• Work for 25 minutes, then take a 5-minute break.\n'
            '• Keep your phone away while working.\n'
            '• Celebrate small achievements.\n\n'
            'Consistency matters more than perfection!';
      } else if (lowerText.contains('goal')) {
        reply = 'Start with one clear, achievable goal. '
            'Break it into smaller tasks, assign a time to each, '
            'and review your progress at the end of the day.';
      } else {
        reply = 'Thanks for your message! I am currently using demo '
            'responses. Once we connect a real AI service, I will be '
            'able to provide more personalized answers.';
      }

      setState(() {
        _messages.add({
          'text': reply,
          'isUser': false,
        });

        _isTyping = false;
      });

      _scrollToBottom();
    });
  }

  // AUTO SCROLL

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 4),
                  _buildTipCard(),
                  if (_messages.length <= 2) ...[
                    const SizedBox(height: 16),
                    _buildSuggestions(),
                  ],
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1000,
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            15,
                            20,
                            16,
                          ),
                          itemCount:
                              _messages.length + (_isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isTyping &&
                                index == _messages.length) {
                              return const Align(
                                alignment: Alignment.centerLeft,
                                child: _MessageBubble(
                                  text: 'Thinking...',
                                  isUser: false,
                                ),
                              );
                            }

                            final message = _messages[index];

                            return _MessageBubble(
                              text: message['text'] as String,
                              isUser: message['isUser'] as bool,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  _buildMessageInput(),
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
                final selected = index == 7;

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

    if (index == 7) return;

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
        MaterialPageRoute(
          builder: (_) => page!,
        ),
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
              builder: (context) => _headerButton(
                Icons.menu_rounded,
                () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF304CEB),
                  Color(0xFF7545F5),
                ],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your daily productivity companion',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.green,
                ),
                SizedBox(width: 5),
                Text(
                  'Ready',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // AI TIP CARD WITH ROBOT IMAGE

  Widget _buildTipCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDCE5FF),
            Color(0xFFECE6FF),
            Color(0xFFF5EFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF304CEB).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF304CEB).withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // ROBOT IMAGE
          SizedBox(
            height: 125,
            width: 115,
            child: Image.asset(
              'assets/images/ai_assistant.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.smart_toy_rounded,
                  size: 75,
                  color: Color(0xFF304CEB),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meet Your AI Assistant',
                  style: TextStyle(
                    color: Color(0xFF253CC5),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Your smart companion for planning, organizing and achieving your daily goals.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF304CEB),
                        Color(0xFF7545F5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AI Ready ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  // SUGGESTIONS

  Widget _buildSuggestions() {
    return SizedBox(
      height: 105,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _SuggestionCard(
            icon: Icons.calendar_month_rounded,
            title: 'Plan my day',
            onTap: () => _sendMessage('Help me plan my day'),
          ),
          _SuggestionCard(
            icon: Icons.track_changes_rounded,
            title: 'Set my goals',
            onTap: () => _sendMessage('Help me set my goals'),
          ),
          _SuggestionCard(
            icon: Icons.bolt_rounded,
            title: 'Be productive',
            onTap: () => _sendMessage(
              'How can I be productive?',
            ),
          ),
        ],
      ),
    );
  }

  // MESSAGE INPUT

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                width: 48,
                child: IconButton.filled(
                  onPressed: _isTyping
                      ? null
                      : () => _sendMessage(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MESSAGE BUBBLE

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MessageBubble({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.65,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [
                    Color(0xFF304CEB),
                    Color(0xFF7545F5),
                  ],
                )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 18),
          ),
          border: isUser
              ? null
              : Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : AppColors.textDark,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// SUGGESTION CARD

class _SuggestionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 23,
              ),
              const SizedBox(height: 9),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
