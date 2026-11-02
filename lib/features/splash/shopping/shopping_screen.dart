import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../task/tasks_screen.dart';
import '../calendar/calendar_screen.dart';
import '../notes/notes_screen.dart';
import '../reminders/reminders_screen.dart';
import '../activity/activity_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../help_support/help_support_screen.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

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

  final List<Map<String, dynamic>> _items = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isDesktop => MediaQuery.sizeOf(context).width >= 900;

  int get _completedItems =>
      _items.where((item) => item['checked'] == true).length;

  double get _progress =>
      _items.isEmpty ? 0 : _completedItems / _items.length;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // LOAD ITEMS

  Future<void> _loadItems() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getShoppingItems();

      final loadedItems = response.map((rawItem) {
        final data = Map<String, dynamic>.from(rawItem as Map);
        final name = data['name']?.toString() ?? '';

        return <String, dynamic>{
          'id': data['id'],
          'name': name,
          'quantity': data['quantity'] is int
              ? data['quantity']
              : int.tryParse(data['quantity'].toString()) ?? 1,
          'checked': data['isPurchased'] == true,
          'icon': _getIconForItem(name),
          'color': _getColorForItem(name),
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        _items
          ..clear()
          ..addAll(loadedItems);
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

  // ADD ITEM

  void _showAddItemDialog() {
    _itemController.clear();
    _quantityController.text = '1';

    _isSaving = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Add shopping item',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _itemController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Item name',
                      hintText: 'e.g. Pizza, Milk, Bread',
                      prefixIcon: const Icon(
                        Icons.shopping_bag_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'e.g. 2',
                      prefixIcon: const Icon(Icons.scale_outlined),
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
                    : () => _addItem(
                          dialogContext,
                          setDialogState,
                        ),
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
                    : const Text('Add item'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addItem(
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) async {
    final name = _itemController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim());

    if (name.isEmpty || quantity == null || quantity < 1) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter item name and a valid quantity (1 or more).',
          ),
        ),
      );
      return;
    }

    setDialogState(() => _isSaving = true);

    try {
      await ApiService.addShoppingItem({
        'name': name,
        'quantity': quantity,
        'isPurchased': false,
      });

      if (!mounted) return;

      Navigator.pop(dialogContext);
      await _loadItems();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shopping item added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setDialogState(() => _isSaving = false);

      if (!dialogContext.mounted) return;

      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(content: Text('Add failed: $e')),
      );
    }
  }

  // DELETE ITEM

  Future<void> _deleteItem(int index) async {
    final item = _items[index];
    final id = item['id'];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text(
          'Are you sure you want to delete this shopping item?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      if (id == null) {
        throw Exception('Shopping item ID not found.');
      }

      await ApiService.deleteShoppingItem(id as int);

      if (!mounted) return;

      setState(() {
        _items.removeWhere((element) => element['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shopping item deleted')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  // PURCHASED STATUS

  Future<void> _toggleItem(int index, bool? value) async {
    final item = _items[index];
    final id = item['id'];

    if (id == null) return;

    final oldValue = item['checked'] as bool;
    final newValue = value ?? false;

    setState(() {
      _items[index]['checked'] = newValue;
    });

    try {
      await ApiService.updateShoppingItem(
        id as int,
        {
          'name': item['name'],
          'quantity': item['quantity'] as int,
          'isPurchased': newValue,
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _items[index]['checked'] = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  // ITEM ICON

  IconData _getIconForItem(String name) {
    final item = name.toLowerCase();

    if (item.contains('milk') ||
        item.contains('juice') ||
        item.contains('water') ||
        item.contains('drink')) {
      return Icons.local_drink_rounded;
    }

    if (item.contains('bread') ||
        item.contains('cake') ||
        item.contains('bun')) {
      return Icons.bakery_dining_rounded;
    }

    if (item.contains('egg')) return Icons.egg_alt_rounded;

    if (item.contains('fruit') ||
        item.contains('apple') ||
        item.contains('banana') ||
        item.contains('orange') ||
        item.contains('mango')) {
      return Icons.shopping_basket_rounded;
    }

    if (item.contains('vegetable') ||
        item.contains('potato') ||
        item.contains('tomato') ||
        item.contains('spinach')) {
      return Icons.eco_rounded;
    }

    if (item.contains('meat') ||
        item.contains('chicken') ||
        item.contains('fish')) {
      return Icons.set_meal_rounded;
    }

    if (item.contains('rice') ||
        item.contains('flour') ||
        item.contains('sugar') ||
        item.contains('salt')) {
      return Icons.inventory_2_rounded;
    }

    return Icons.shopping_bag_rounded;
  }

  Color _getColorForItem(String name) {
    final item = name.toLowerCase();

    if (item.contains('milk') ||
        item.contains('juice') ||
        item.contains('water')) {
      return const Color(0xFF75B9F5);
    }

    if (item.contains('bread') || item.contains('cake')) {
      return const Color(0xFFE6A15A);
    }

    if (item.contains('egg')) {
      return const Color(0xFFD7A56D);
    }

    if (item.contains('fruit') ||
        item.contains('apple') ||
        item.contains('banana') ||
        item.contains('mango')) {
      return const Color(0xFF46B982);
    }

    if (item.contains('vegetable') ||
        item.contains('potato') ||
        item.contains('tomato')) {
      return const Color(0xFF65AD67);
    }

    return AppColors.primary;
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _errorMessage != null
                            ? _buildErrorState()
                            : RefreshIndicator(
                                onRefresh: _loadItems,
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    20, 8, 20, 24,
                                  ),
                                  children: [
                                    _buildProgressCard(),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        const Text(
                                          'Shopping items',
                                          style: TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${_items.length} items',
                                          style: const TextStyle(
                                            color: muted,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    if (_items.isEmpty)
                                      _buildEmptyState()
                                    else
                                      ...List.generate(
                                        _items.length,
                                        _buildItemCard,
                                      ),
                                    const SizedBox(height: 12),
                                    _buildAddButton(),
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
            const SizedBox(height: 14),
            const Text(
              'Unable to load shopping items',
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
              onPressed: _loadItems,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
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
                final selected = item['title'] == 'Shopping';

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

    if (index == 3) return;

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
              builder: (context) => _headerIconButton(
                Icons.menu_rounded,
                () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 13),
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
              Icons.shopping_cart_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shopping List',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Everything you need in one place',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          _headerIconButton(
            Icons.add_rounded,
            _showAddItemDialog,
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

  // PROGRESS CARD

  Widget _buildProgressCard() {
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your shopping progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.shopping_basket_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_completedItems of ${_items.length} items completed',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(_progress * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ITEM CARD

  Widget _buildItemCard(int index) {
    final item = _items[index];
    final isChecked = item['checked'] as bool;
    final itemColor = item['color'] as Color;
    final itemIcon = item['icon'] as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isChecked
              ? AppColors.primary.withValues(alpha: 0.22)
              : Colors.grey.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (value) => _toggleItem(index, value),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: itemColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(itemIcon, color: itemColor, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    decoration:
                        isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Quantity: ${item['quantity']}',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete item',
            onPressed: () => _deleteItem(index),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade300,
            ),
          ),
        ],
      ),
    );
  }

  // ADD BUTTON

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
          onPressed: _showAddItemDialog,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add new item',
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

  // EMPTY STATE

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 55,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Your list is empty',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add items you need to buy.',
            style: TextStyle(color: muted),
          ),
        ],
      ),
    );
  }
}