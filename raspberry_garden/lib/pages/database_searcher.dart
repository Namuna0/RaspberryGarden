import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../routes/application_api.dart';
import '../routes/white_fade.dart';
import '../widgets/ui_helpers.dart';

class DatabaseSearcher extends StatefulWidget {
  const DatabaseSearcher({super.key});

  @override
  State<DatabaseSearcher> createState() => _DatabaseSearcherState();
}

class _DatabaseSearcherState extends State<DatabaseSearcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  List<String> _suggestions = [];
  String? _resultText;
  bool _loadingResult = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );

    _searchCtrl.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _fade.reverse().timeout(const Duration(milliseconds: 500));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _fade.dispose();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _searchCtrl.text;
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final results = await fetchSkillSuggestions(
        baseUrl: AppConfig.baseUrl,
        apiKey: AppConfig.apiKey,
        query: query,
      );
      if (!mounted) return;
      if (_searchCtrl.text == query) {
        setState(() => _suggestions = results);
      }
    } catch (e) {
      debugPrint('fetchSuggestions error: $e');
    }
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
        baseUrl: AppConfig.baseUrl,
        apiKey: AppConfig.apiKey,
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
                              onLongPress: () =>
                                  copyToClipboard(context, _resultText!),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 8, 8, 12),
                                decoration: darkRoundedBox(),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                        onPressed: () =>
                                            copyToClipboard(context, _resultText!),
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
                            decoration: darkRoundedBox(),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: _suggestions.map((s) {
                                return GestureDetector(
                                  onTap: () => _searchByQuery(s),
                                  onLongPress: () =>
                                      copyToClipboard(context, s),
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
                        if (_suggestions.isNotEmpty)
                          const SizedBox(height: 4),
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
          WhiteFadeOverlay(animation: _fade, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
