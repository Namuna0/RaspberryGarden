import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../routes/application_api.dart';
import '../routes/white_fade.dart';
import 'home_menu_page.dart';

class DatabaseSearcher extends StatefulWidget {
  const DatabaseSearcher({super.key});

  @override
  State<DatabaseSearcher> createState() => _DatabaseSearcherState();
}

class _DatabaseSearcherState extends State<DatabaseSearcher>
    with TickerProviderStateMixin {
  static const String _baseUrl = 'https://goddessutarea-production.up.railway.app';
  static const String _apiKey = 'API_TEST';
  static const double _menuWidth = 220;
  static const double _edgeThreshold = 40;

  late final AnimationController _fade;
  late final AnimationController _menuAnim;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _suggestions = [];
  String? _resultText;
  bool _loadingSuggestions = false;
  bool _loadingResult = false;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _menuAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _searchCtrl.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _fade.reverse().timeout(const Duration(milliseconds: 500));
    });
  }

  @override
  void dispose() {
    _fade.dispose();
    _menuAnim.dispose();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openMenu() => _menuAnim.forward();

  void _closeMenu() => _menuAnim.reverse();

  void _onTextChanged() {
    final query = _searchCtrl.text;
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _fetchSuggestions(query);
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _loadingSuggestions = true);
    try {
      final results = await fetchSkillSuggestions(
        baseUrl: _baseUrl,
        apiKey: _apiKey,
        query: query,
      );
      if (!mounted) return;
      if (_searchCtrl.text == query) {
        setState(() => _suggestions = results);
      }
    } catch (e) {
      debugPrint('fetchSuggestions error: $e');
    } finally {
      if (mounted) setState(() => _loadingSuggestions = false);
    }
  }

  void _onSelectSuggestion(String value) {
    _searchByQuery(value);
  }

  Future<void> _copyResult(BuildContext context) async {
    if (_resultText == null) return;
    await Clipboard.setData(ClipboardData(text: _resultText!));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('コピーしました'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _onSearch() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() => _suggestions = []);
    await _searchByQuery(query);
  }

  Future<void> _searchByQuery(String query) async {
    setState(() {
      _loadingResult = true;
      _resultText = null;
    });

    try {
      final text = await fetchSkillText(
        baseUrl: _baseUrl,
        apiKey: _apiKey,
        id: query,
      );
      if (!mounted) return;
      setState(() => _resultText = text ?? '「$query」は見つかりませんでした');
    } catch (e) {
      debugPrint('fetchSkillText error: $e');
      if (!mounted) return;
      setState(() => _resultText = 'エラーが発生しました: $e');
    } finally {
      if (mounted) setState(() => _loadingResult = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/main.png', fit: BoxFit.cover),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_loadingResult)
                          const Center(child: CircularProgressIndicator())
                        else if (_resultText != null)
                          Flexible(
                            child: GestureDetector(
                              onLongPress: () => _copyResult(context),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.70),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.copy,
                                          size: 18,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () => _copyResult(context),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          _resultText!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.6,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_resultText != null || _loadingResult)
                          const SizedBox(height: 8),
                        if (_suggestions.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.70),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: _suggestions.map((s) {
                                return GestureDetector(
                                  onTap: () => _onSelectSuggestion(s),
                                  onLongPress: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: s));
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('コピーしました'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      s,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        if (_suggestions.isNotEmpty) const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          controller: _searchCtrl,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'データを検索',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => _onSearch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _onSearch,
                        icon: const Icon(Icons.search),
                        color: const Color(0xFFFF64AA),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 右端スワイプ検知
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: _edgeThreshold,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (d) {
                if (d.delta.dx < -2) _openMenu();
              },
            ),
          ),
          // オーバーレイ背景 + メニューパネル
          AnimatedBuilder(
            animation: _menuAnim,
            builder: (_, __) {
              if (_menuAnim.value == 0) return const SizedBox.shrink();
              final slide = CurvedAnimation(
                parent: _menuAnim,
                curve: Curves.easeOut,
              );
              return Stack(
                fit: StackFit.expand,
                children: [
                  // 背景タップで閉じる
                  GestureDetector(
                    onTap: _closeMenu,
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.4 * _menuAnim.value),
                    ),
                  ),
                  // メニューパネル
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: (_menuWidth * (slide.value - 1)),
                    width: _menuWidth,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (d) {
                        if (d.delta.dx > 2) _closeMenu();
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.85),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 16,
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                'メニュー',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Divider(color: Colors.white24),
                            _MenuItem(
                              icon: Icons.chat_bubble_outline,
                              label: 'チャット',
                              onTap: () async {
                                _closeMenu();
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                if (!context.mounted) return;
                                await whiteFadeReplace(
                                  context: context,
                                  controller: _fade,
                                  nextPage: const HomeMenuPage(),
                                );
                              },
                            ),
                            _MenuItem(
                              icon: Icons.search,
                              label: '予想検索',
                              onTap: _closeMenu,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          WhiteFadeOverlay(animation: _fade, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
