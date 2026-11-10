import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const AliChatApp());
}

// -----------------------------------------------------------------------------
// Ali Chat - واجهة دردشة محلية تجريبية، بدون مكتبات خارجية.
// جميع أزرار الواجهة لها استجابة داخل التطبيق. الرسائل والمرفقات تجريبية محلياً.
// -----------------------------------------------------------------------------

const Color kGreen = Color(0xFF258A61);
const Color kGreenDark = Color(0xFF176447);
const Color kMint = Color(0xFFE9F5EF);
const Color kBackground = Color(0xFFF5F8F6);
const Color kInk = Color(0xFF1D2B24);

class AliChatApp extends StatefulWidget {
  const AliChatApp({super.key});

  @override
  State<AliChatApp> createState() => _AliChatAppState();
}

class _AliChatAppState extends State<AliChatApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ali Chat',
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kGreen,
          brightness: Brightness.light,
          primary: kGreen,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: kBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackground,
          foregroundColor: kInk,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: kInk,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kGreen,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101814),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101814),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF24332B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: MainScreen(
        darkMode: _darkMode,
        onDarkModeChanged: (value) => setState(() => _darkMode = value),
      ),
    );
  }
}

enum MessageKind { text, image, video, file, location, contact, voice }

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.kind = MessageKind.text,
    this.detail = '',
  });

  final String text;
  final bool isMe;
  final DateTime time;
  final MessageKind kind;
  final String detail;
}

class ChatContact {
  ChatContact({
    required this.name,
    required this.color,
    this.online = false,
    this.isGroup = false,
    this.unread = 0,
    this.favorite = false,
    required this.messages,
  });

  final String name;
  final Color color;
  final bool online;
  final bool isGroup;
  int unread;
  bool favorite;
  final List<ChatMessage> messages;

  String get lastMessage => messages.isEmpty ? 'ابدأ المحادثة الآن' : messages.last.text;
  DateTime get lastTime => messages.isEmpty ? DateTime.now() : messages.last.time;
}

DateTime _minutesAgo(int value) => DateTime.now().subtract(Duration(minutes: value));

String _timeText(DateTime date) {
  final int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final String minute = date.minute.toString().padLeft(2, '0');
  final String period = date.hour >= 12 ? 'م' : 'ص';
  return '$hour:$minute $period';
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;
  bool _searching = false;
  String _query = '';
  String _filter = 'الكل';
  bool _notifications = true;
  bool _sounds = true;

  final TextEditingController _searchController = TextEditingController();

  late final List<ChatContact> _chats = [
    ChatContact(
      name: 'أحمد', color: const Color(0xFF70A9E8), online: true, unread: 2,
      messages: [
        ChatMessage(text: 'السلام عليكم، كيف حالك؟', isMe: false, time: _minutesAgo(90)),
        ChatMessage(text: 'وعليكم السلام، الحمد لله بخير 🌿', isMe: true, time: _minutesAgo(86)),
        ChatMessage(text: 'متى نبدأ المشروع الجديد؟', isMe: false, time: _minutesAgo(8)),
      ],
    ),
    ChatContact(
      name: 'محمد', color: const Color(0xFFB18AE0), online: true, unread: 0,
      messages: [
        ChatMessage(text: 'التصميم جميل جداً 👏', isMe: false, time: _minutesAgo(35)),
        ChatMessage(text: 'تسلم يا غالي', isMe: true, time: _minutesAgo(30)),
      ],
    ),
    ChatContact(
      name: 'فريق التصميم', color: const Color(0xFFE4A56B), isGroup: true, unread: 5,
      messages: [
        ChatMessage(text: 'علي: تم إرسال الملفات', isMe: false, time: _minutesAgo(120)),
        ChatMessage(text: 'سأراجعها الآن', isMe: true, time: _minutesAgo(42)),
      ],
    ),
    ChatContact(
      name: 'خالد', color: const Color(0xFF65B9A0), online: false,
      messages: [
        ChatMessage(text: 'أرسل لي النسخة النهائية متى تجهز', isMe: false, time: _minutesAgo(180)),
      ],
    ),
    ChatContact(
      name: 'سالم', color: const Color(0xFFE28C9A), online: true, favorite: true,
      messages: [
        ChatMessage(text: 'شكراً لك، وصلت الصورة', isMe: false, time: _minutesAgo(360)),
      ],
    ),
  ];

  final List<Map<String, dynamic>> _callHistory = [
    {'name': 'أحمد', 'video': false, 'missed': false, 'time': '10:42 ص'},
    {'name': 'محمد', 'video': true, 'missed': true, 'time': 'أمس'},
    {'name': 'خالد', 'video': false, 'missed': false, 'time': 'الأحد'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatContact> get _visibleChats {
    Iterable<ChatContact> result = _chats;
    if (_filter == 'غير مقروءة') {
      result = result.where((chat) => chat.unread > 0);
    } else if (_filter == 'المفضلة') {
      result = result.where((chat) => chat.favorite);
    }
    final String query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((chat) => chat.name.toLowerCase().contains(query));
    }
    return result.toList()
      ..sort((a, b) => b.lastTime.compareTo(a.lastTime));
  }

  void _openChat(ChatContact chat) {
    setState(() => chat.unread = 0);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chat: chat,
          onMessageAdded: (message) {
            setState(() {
              chat.unread = 0;
            });
          },
        ),
      ),
    );
  }

  void _startSearch() {
    setState(() {
      _searching = true;
      _tab = 0;
    });
  }

  void _stopSearch() {
    setState(() {
      _searching = false;
      _query = '';
      _searchController.clear();
    });
  }

  void _showMainMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetAction(Icons.mark_chat_read_rounded, 'تحديد كل الدردشات كمقروءة', () {
              setState(() {
                for (final chat in _chats) {
                  chat.unread = 0;
                }
              });
              Navigator.pop(sheetContext);
              _snack('تم تحديد جميع المحادثات كمقروءة');
            }),
            _sheetAction(Icons.group_add_rounded, 'إنشاء مجموعة جديدة', () {
              Navigator.pop(sheetContext);
              _createGroup();
            }),
            _sheetAction(Icons.info_outline_rounded, 'حول Ali Chat', () {
              Navigator.pop(sheetContext);
              _showAbout();
            }),
          ],
        ),
      ),
    );
  }

  Widget _sheetAction(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: kGreen),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  void _createGroup() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مجموعة جديدة'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'اسم المجموعة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final group = ChatContact(
                name: name,
                color: const Color(0xFFDBA65C),
                isGroup: true,
                messages: [
                  ChatMessage(text: 'تم إنشاء المجموعة بنجاح', isMe: true, time: DateTime.now()),
                ],
              );
              setState(() => _chats.insert(0, group));
              Navigator.pop(dialogContext);
              _openChat(group);
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _newChat() {
    const contacts = [
      {'name': 'عبدالله', 'color': Color(0xFF6DB89A)},
      {'name': 'إبراهيم', 'color': Color(0xFF8E9FE3)},
      {'name': 'فهد', 'color': Color(0xFFE5A36D)},
      {'name': 'ياسر', 'color': Color(0xFFC28DD6)},
      {'name': 'نور', 'color': Color(0xFFDC8794)},
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: 390,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text('محادثة جديدة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              Expanded(
                child: ListView(
                  children: contacts.map((entry) {
                    final String contactName = entry['name'] as String;
                    final Color contactColor = entry['color'] as Color;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: contactColor.withOpacity(.18),
                        child: Text(contactName.substring(0, 1), style: TextStyle(color: contactColor, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(contactName),
                      subtitle: const Text('ابدأ محادثة جديدة'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ChatContact? existing;
                        for (final item in _chats) {
                          if (item.name == contactName) existing = item;
                        }
                        if (existing == null) {
                          existing = ChatContact(
                            name: contactName,
                            color: contactColor,
                            online: true,
                            messages: [],
                          );
                          setState(() => _chats.insert(0, existing!));
                        }
                        _openChat(existing!);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const CircleAvatar(
          radius: 28,
          backgroundColor: kMint,
          child: Icon(Icons.forum_rounded, color: kGreen, size: 30),
        ),
        title: const Text('Ali Chat'),
        content: const Text('تطبيق دردشة بتصميم أخضر هادئ.\nتطوير: علي النجار'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = dark ? Colors.white : kInk;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'ابحث عن محادثة...',
                  filled: false,
                  border: InputBorder.none,
                ),
              )
            : Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kGreen, Color(0xFF65B88E)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.forum_rounded, color: Colors.white, size: 23),
                  ),
                  const SizedBox(width: 11),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_tab == 0 ? 'Ali Chat' : _tab == 1 ? 'المكالمات' : 'الإعدادات', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900)),
                      Text(_tab == 0 ? 'تواصل بكل بساطة' : _tab == 1 ? 'ابقَ على اتصال' : 'تحكم بتجربتك', style: TextStyle(color: dark ? Colors.white60 : Colors.black45, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
        actions: [
          if (_tab == 0)
            IconButton(
              tooltip: _searching ? 'إغلاق البحث' : 'بحث',
              onPressed: _searching ? _stopSearch : _startSearch,
              icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            ),
          if (_tab == 0)
            IconButton(
              tooltip: 'المزيد',
              onPressed: _showMainMenu,
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          if (_tab == 1)
            IconButton(
              tooltip: 'اتصال جديد',
              onPressed: _newChat,
              icon: const Icon(Icons.add_call_rounded),
            ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _buildChatsBody(dark),
          CallsScreen(
            calls: _callHistory,
            onCall: (name, video) => _showCallDialog(name, video),
          ),
          SettingsScreen(
            darkMode: widget.darkMode,
            notifications: _notifications,
            sounds: _sounds,
            onDarkModeChanged: widget.onDarkModeChanged,
            onNotificationsChanged: (value) => setState(() => _notifications = value),
            onSoundsChanged: (value) => setState(() => _sounds = value),
            onAbout: _showAbout,
            onSnack: _snack,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _newChat,
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
              elevation: 3,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('محادثة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          setState(() {
            _tab = index;
            _searching = false;
            _query = '';
            _searchController.clear();
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'الدردشات'),
          NavigationDestination(icon: Icon(Icons.call_outlined), selectedIcon: Icon(Icons.call_rounded), label: 'المكالمات'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'الإعدادات'),
        ],
      ),
    );
  }

  Widget _buildChatsBody(bool dark) {
    final chats = _visibleChats;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF1B7653), Color(0xFF42A879)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: kGreen.withOpacity(.18), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('أهلاً بك في Ali Chat 👋', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                      SizedBox(height: 6),
                      Text('رسائلك ومحادثاتك في مكان واحد', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.16), shape: BoxShape.circle),
                  child: const Icon(Icons.forum_rounded, color: Colors.white, size: 29),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 43,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['الكل', 'غير مقروءة', 'المفضلة'].map((label) {
              final selected = _filter == label;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = label),
                  showCheckmark: false,
                  selectedColor: kGreen,
                  backgroundColor: dark ? const Color(0xFF1A2520) : Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : (dark ? Colors.white70 : Colors.black54),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: selected ? kGreen : (dark ? Colors.white12 : const Color(0xFFE7EDE9))),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: chats.isEmpty
              ? _emptyChats()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 3, 16, 100),
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) => _chatTile(chats[index], dark),
                ),
        ),
      ],
    );
  }

  Widget _emptyChats() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mark_chat_unread_outlined, size: 58, color: kGreen.withOpacity(.55)),
            const SizedBox(height: 14),
            const Text('لا توجد محادثات هنا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('جرّب تغيير التصفية أو ابدأ محادثة جديدة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _newChat, icon: const Icon(Icons.add), label: const Text('محادثة جديدة')),
          ],
        ),
      ),
    );
  }

  Widget _chatTile(ChatContact chat, bool dark) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openChat(chat),
        onLongPress: () => _showChatOptions(chat),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: chat.color.withOpacity(.17),
                    child: chat.isGroup
                        ? Icon(Icons.groups_rounded, color: chat.color, size: 27)
                        : Text(chat.name.substring(0, 1), style: TextStyle(color: chat.color, fontSize: 21, fontWeight: FontWeight.w900)),
                  ),
                  if (chat.online && !chat.isGroup)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: const Color(0xFF39B779), shape: BoxShape.circle, border: Border.all(color: Theme.of(context).cardColor, width: 2)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(chat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                        if (chat.favorite) const Padding(padding: EdgeInsets.only(left: 5), child: Icon(Icons.star_rounded, color: Color(0xFFE5AF43), size: 16)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_timeText(chat.lastTime), style: TextStyle(fontSize: 10, color: chat.unread > 0 ? kGreen : (dark ? Colors.white38 : Colors.black38), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (chat.unread > 0)
                    Container(
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${chat.unread}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  else
                    const Icon(Icons.done_all_rounded, color: Color(0xFF8AB8A0), size: 17),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatOptions(ChatContact chat) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetAction(chat.favorite ? Icons.star_border_rounded : Icons.star_rounded, chat.favorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة', () {
              setState(() => chat.favorite = !chat.favorite);
              Navigator.pop(sheetContext);
            }),
            _sheetAction(Icons.mark_chat_read_outlined, 'تحديد كمقروءة', () {
              setState(() => chat.unread = 0);
              Navigator.pop(sheetContext);
            }),
            _sheetAction(Icons.delete_outline_rounded, 'حذف المحادثة من القائمة', () {
              Navigator.pop(sheetContext);
              showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('حذف المحادثة؟'),
                  content: Text('سيتم حذف محادثة ${chat.name} من القائمة الحالية.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                    FilledButton.tonal(
                      onPressed: () {
                        setState(() => _chats.remove(chat));
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('حذف'),
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

  void _showCallDialog(String name, bool video) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: CircleAvatar(
          radius: 28,
          backgroundColor: kMint,
          child: Icon(video ? Icons.videocam_rounded : Icons.call_rounded, color: kGreen, size: 28),
        ),
        title: Text(video ? 'مكالمة فيديو' : 'مكالمة صوتية'),
        content: Text('هذه معاينة للمكالمة مع $name. الاتصال الحقيقي يحتاج إلى خدمة اتصال وربط شبكي.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق')),
          FilledButton(
            onPressed: () {
              setState(() => _callHistory.insert(0, {'name': name, 'video': video, 'missed': false, 'time': 'الآن'}));
              Navigator.pop(dialogContext);
              _snack('تمت إضافة المكالمة إلى السجل التجريبي');
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat, required this.onMessageAdded});

  final ChatContact chat;
  final ValueChanged<ChatMessage> onMessageAdded;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _recordTimer;
  int _recordSeconds = 0;
  bool _recording = false;

  List<ChatMessage> get _messages => widget.chat.messages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _addMessage(ChatMessage(text: text, isMe: true, time: DateTime.now()));
    _messageController.clear();
  }

  void _addMessage(ChatMessage message) {
    setState(() => _messages.add(message));
    widget.onMessageAdded(message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleRecording() {
    if (!_recording) {
      setState(() {
        _recording = true;
        _recordSeconds = 0;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordSeconds++);
      });
      _snack('بدأ مؤقت الرسالة الصوتية التجريبية. اضغط مرة أخرى للإيقاف.');
    } else {
      _recordTimer?.cancel();
      final seconds = _recordSeconds;
      setState(() => _recording = false);
      _addMessage(ChatMessage(
        text: 'رسالة صوتية تجريبية • ${seconds}s',
        isMe: true,
        time: DateTime.now(),
        kind: MessageKind.voice,
        detail: '$seconds ثانية',
      ));
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  void _showEmojiPicker() {
    const emojis = ['😀', '😁', '😂', '🥰', '😍', '😉', '😊', '🤔', '😎', '😭', '🙏', '👏', '👍', '❤️', '🔥', '🌹', '🎉', '✨', '💚', '🌿', '👌', '💯', '🙌', '🤝'];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 13,
            runSpacing: 15,
            children: emojis.map((emoji) => InkWell(
              onTap: () {
                final old = _messageController.text;
                _messageController.text = '$old$emoji';
                _messageController.selection = TextSelection.collapsed(offset: _messageController.text.length);
                Navigator.pop(sheetContext);
              },
              child: Text(emoji, style: const TextStyle(fontSize: 29)),
            )).toList(),
          ),
        ),
      ),
    );
  }

  void _showAttachments() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.only(right: 8, bottom: 10), child: Text('إرفاق وإرسال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)))),
              Row(
                children: [
                  _attachmentOption(sheetContext, Icons.photo_rounded, 'صورة', const Color(0xFF4D9BDF), MessageKind.image),
                  _attachmentOption(sheetContext, Icons.videocam_rounded, 'فيديو', const Color(0xFFE16D76), MessageKind.video),
                  _attachmentOption(sheetContext, Icons.insert_drive_file_rounded, 'ملف', const Color(0xFFE3A34F), MessageKind.file),
                  _attachmentOption(sheetContext, Icons.location_on_rounded, 'موقع', const Color(0xFF49A77B), MessageKind.location),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFEDE8F8), child: Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF8B70C9))),
                title: const Text('جهة اتصال'),
                subtitle: const Text('إرسال بطاقة جهة اتصال تجريبية'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _addMessage(ChatMessage(text: 'بطاقة جهة اتصال', isMe: true, time: DateTime.now(), kind: MessageKind.contact, detail: 'جهة اتصال تجريبية'));
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('هذه النسخة لا تختار ملفات الجهاز بعد؛ المرفقات المعروضة معاينات داخلية.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentOption(BuildContext sheetContext, IconData icon, String label, Color color, MessageKind kind) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pop(sheetContext);
          final titles = {
            MessageKind.image: 'صورة مرفقة (معاينة)',
            MessageKind.video: 'فيديو مرفق (معاينة)',
            MessageKind.file: 'مستند مرفق (معاينة)',
            MessageKind.location: 'موقع مشترك (معاينة)',
          };
          if (kind == MessageKind.location) {
            _askForLocation();
          } else {
            _addMessage(ChatMessage(text: titles[kind] ?? label, isMe: true, time: DateTime.now(), kind: kind, detail: 'عنصر تجريبي'));
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withOpacity(.13), borderRadius: BorderRadius.circular(17)), child: Icon(icon, color: color, size: 25)),
              const SizedBox(height: 7),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _askForLocation() {
    final controller = TextEditingController(text: 'صنعاء، اليمن');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مشاركة موقع'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'اكتب اسم المدينة أو الموقع')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(dialogContext);
              _addMessage(ChatMessage(text: value, isMe: true, time: DateTime.now(), kind: MessageKind.location, detail: 'موقع مكتوب يدوياً'));
            },
            child: const Text('إرسال الموقع'),
          ),
        ],
      ),
    );
  }

  void _showChatMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: kGreen),
              title: const Text('معلومات المحادثة'),
              onTap: () {
                Navigator.pop(sheetContext);
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(widget.chat.name),
                    content: Text(widget.chat.isGroup ? 'مجموعة دردشة محلية تجريبية.' : (widget.chat.online ? 'متصل الآن • جهة اتصال تجريبية' : 'غير متصل • جهة اتصال تجريبية')),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded, color: kGreen),
              title: const Text('البحث في المحادثة'),
              onTap: () {
                Navigator.pop(sheetContext);
                _searchInChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('مسح الرسائل'),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmClearChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _searchInChat() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('البحث في المحادثة'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'اكتب كلمة للبحث')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final query = controller.text.trim();
              final count = _messages.where((message) => message.text.contains(query)).length;
              Navigator.pop(dialogContext);
              _snack(query.isEmpty ? 'اكتب كلمة للبحث' : 'وجدنا $count نتيجة مطابقة');
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _confirmClearChat() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح الرسائل؟'),
        content: const Text('سيتم حذف الرسائل من هذه المحادثة على هذه النسخة التجريبية.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton.tonal(
            onPressed: () {
              setState(() => _messages.clear());
              Navigator.pop(dialogContext);
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _call(bool video) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(video ? Icons.video_call_rounded : Icons.call_rounded, color: kGreen, size: 34),
        title: Text(video ? 'مكالمة فيديو' : 'مكالمة صوتية'),
        content: Text('واجهة اتصال تجريبية مع ${widget.chat.name}. الاتصال الفعلي يحتاج خادم اتصال.'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: widget.chat.color.withOpacity(.18),
              child: widget.chat.isGroup
                  ? Icon(Icons.groups_rounded, color: widget.chat.color)
                  : Text(widget.chat.name.substring(0, 1), style: TextStyle(color: widget.chat.color, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(widget.chat.isGroup ? 'مجموعة' : (widget.chat.online ? 'متصل الآن' : 'آخر ظهور مؤخراً'), style: TextStyle(fontSize: 10, color: widget.chat.online ? kGreen : Colors.grey, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(tooltip: 'مكالمة صوتية', onPressed: () => _call(false), icon: const Icon(Icons.call_rounded, size: 21)),
          IconButton(tooltip: 'مكالمة فيديو', onPressed: () => _call(true), icon: const Icon(Icons.videocam_rounded, size: 23)),
          IconButton(tooltip: 'المزيد', onPressed: _showChatMenu, icon: const Icon(Icons.more_vert_rounded)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF121D17) : const Color(0xFFEDF3EF),
              ),
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.waving_hand_rounded, size: 45, color: kGreen.withOpacity(.65)),
                          const SizedBox(height: 10),
                          const Text('ابدأ المحادثة برسالة لطيفة', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => _messageBubble(_messages[index], dark),
                    ),
            ),
          ),
          if (_recording)
            Container(
              color: dark ? const Color(0xFF1B2B22) : const Color(0xFFE6F3EB),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, color: Colors.red, size: 13),
                  const SizedBox(width: 8),
                  Text('تسجيل تجريبي • $_recordSeconds ثانية', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(onPressed: _toggleRecording, child: const Text('إرسال')),
                ],
              ),
            ),
          _buildComposer(dark),
        ],
      ),
    );
  }

  Widget _messageBubble(ChatMessage message, bool dark) {
    final bool mine = message.isMe;
    final Color bubbleColor = mine
        ? (dark ? const Color(0xFF245C43) : const Color(0xFFDDF2E5))
        : (dark ? const Color(0xFF25322B) : Colors.white);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .79),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 5),
            bottomRight: Radius.circular(mine ? 5 : 18),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 7, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _messageContent(message),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_timeText(message.time), style: TextStyle(fontSize: 9, color: dark ? Colors.white54 : Colors.black45)),
                if (mine) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all_rounded, size: 13, color: Color(0xFF4E9A75)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageContent(ChatMessage message) {
    switch (message.kind) {
      case MessageKind.image:
        return _attachmentBubble(Icons.image_rounded, 'صورة', message.detail, const Color(0xFF4D9BDF));
      case MessageKind.video:
        return _attachmentBubble(Icons.play_circle_fill_rounded, 'فيديو', message.detail, const Color(0xFFE16D76));
      case MessageKind.file:
        return _attachmentBubble(Icons.insert_drive_file_rounded, 'مستند', message.detail, const Color(0xFFE3A34F));
      case MessageKind.location:
        return _attachmentBubble(Icons.location_on_rounded, 'موقع', message.text, const Color(0xFF49A77B));
      case MessageKind.contact:
        return _attachmentBubble(Icons.contact_page_rounded, 'جهة اتصال', message.detail, const Color(0xFF8B70C9));
      case MessageKind.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_fill_rounded, color: kGreen, size: 30),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('رسالة صوتية تجريبية', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(message.detail, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ],
        );
      case MessageKind.text:
        return Text(message.text, style: const TextStyle(fontSize: 14, height: 1.45));
    }
  }

  Widget _attachmentBubble(IconData icon, String title, String detail, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 155),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(bool dark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 9, 9, 9),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 14, offset: const Offset(0, -4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'إرفاق',
              visualDensity: VisualDensity.compact,
              onPressed: _showAttachments,
              icon: const Icon(Icons.add_circle_outline_rounded, color: kGreen, size: 27),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: dark ? const Color(0xFF24332B) : const Color(0xFFF1F5F2), borderRadius: BorderRadius.circular(23)),
                child: Row(
                  children: [
                    IconButton(tooltip: 'الرموز التعبيرية', onPressed: _showEmojiPicker, icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.grey, size: 22)),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _sendText(),
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالة...',
                          filled: false,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle),
              child: IconButton(
                tooltip: _messageController.text.trim().isEmpty ? 'رسالة صوتية تجريبية' : 'إرسال الرسالة',
                onPressed: () {
                  if (_messageController.text.trim().isNotEmpty) {
                    _sendText();
                  } else {
           