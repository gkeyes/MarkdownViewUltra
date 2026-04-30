import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _channel = MethodChannel('com.gkeyes.markdownviewultra/intent');

  static const _textExtensions = {'.md', '.markdown', '.txt', '.text'};

  String _content = '';
  String _fileName = 'No file';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDark = false;

  WebViewController? _webController;

  @override
  void initState() {
    super.initState();
    _isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    _checkForIntent();
  }

  Future<void> _checkForIntent() async {
    try {
      final String? filePath;
      if (Platform.isAndroid) {
        filePath = await _channel.invokeMethod<String>('getIntentFile');
      } else {
        filePath = null;
      }
      if (filePath != null && filePath.isNotEmpty) {
        await _loadFile(filePath);
      }
    } catch (e) {
      if (e is! MissingPluginException) {
        debugPrint('Intent check error: $e');
      }
    }
  }

  bool _isAllowedFile(String path) {
    final ext = path.toLowerCase();
    return _textExtensions.any((e) => ext.endsWith(e));
  }

  Future<void> _loadFile(String? path) async {
    if (path == null || path.isEmpty) {
      setState(() => _errorMessage = 'No file path provided');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 1️⃣ Extension whitelist check
    if (!_isAllowedFile(path)) {
      final ext = path.split('.').last;
      setState(() {
        _errorMessage =
            'Unsupported file format ".$ext".\n\n'
            'Markdown View can only preview:\n'
            '\u2022 .md / .markdown  (Markdown files)\n'
            '\u2022 .txt / .text     (plain text files)\n\n'
            'This file appears to be a ".$ext" document.\n'
            'Please open it with an appropriate app.';
        _isLoading = false;
      });
      return;
    }

    try {
      final file = File(path);
      if (!await file.exists()) {
        setState(() {
          _errorMessage = 'File not found: ${path.split('/').last}';
          _isLoading = false;
        });
        return;
      }

      // 2️⃣ Try UTF-8 decode — will fail on binary files like .docx
      String content;
      try {
        content = await file.readAsString(encoding: utf8);
      } on FileSystemException {
        setState(() {
          _errorMessage =
              'Cannot preview this file.\n\n'
              'This doesn\'t appear to be a valid text file. '
              'Markdown View can only read plain text and Markdown (.md) files.\n\n'
              'Binary files like .docx, .pdf, or images cannot be displayed.';
          _isLoading = false;
        });
        return;
      }

      // 3️⃣ Sanity check the content for binary patterns
      final nonTextCount = content.runes
          .where((r) => r == 0xFFFD || (r < 0x09 && r != 0x0A && r != 0x0D))
          .length;
      if (content.length > 20 && nonTextCount / content.length > 0.3) {
        setState(() {
          _errorMessage =
              'This file appears to be a binary document, not plain text.\n\n'
              'Markdown View can only preview:\n'
              '\u2022 .md / .markdown  (Markdown files)\n'
              '\u2022 .txt / .text     (plain text files)';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _content = content;
        _fileName = file.path.split('/').last;
        _isLoading = false;
      });
      _renderMarkdown(content);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString().split('\n').first}';
        _isLoading = false;
      });
    }
  }

  void _renderMarkdown(String markdownContent) {
    final htmlBody = md.markdownToHtml(
      markdownContent,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    final isDark = _isDark;
    final bg = isDark ? '#1a1a2e' : '#ffffff';
    final text = isDark ? '#e0e0e0' : '#1a1a1a';
    final codeBg = isDark ? '#2d2d44' : '#f5f5f5';
    final link = isDark ? '#82b1ff' : '#1565c0';
    final border = isDark ? '#333355' : '#e0e0e0';
    final blockquoteBg = isDark ? '#252540' : '#f8f9fa';
    final heading = isDark ? '#ffffff' : '#111111';

    final html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans SC", sans-serif;
    font-size: 16px; line-height: 1.7;
    color: $text; background: $bg;
    padding: 16px; word-wrap: break-word;
    -webkit-font-smoothing: antialiased;
    -webkit-overflow-scrolling: touch;
  }
  h1,h2,h3,h4 { color: $heading; margin: 1.2em 0 0.5em; font-weight: 600; line-height: 1.3; }
  h1 { font-size: 1.8em; border-bottom: 1px solid $border; padding-bottom: 0.3em; }
  h2 { font-size: 1.5em; border-bottom: 1px solid $border; padding-bottom: 0.25em; }
  h3 { font-size: 1.25em; }
  p { margin: 0.8em 0; }
  a { color: $link; text-decoration: none; }
  code { font-family: "SF Mono","Fira Code","Consolas",monospace; font-size: 0.9em; padding: 0.2em 0.4em; background: $codeBg; border-radius: 4px; }
  pre { background: $codeBg; border-radius: 8px; padding: 14px 16px; overflow-x: auto; margin: 1em 0; -webkit-overflow-scrolling: touch; }
  pre code { padding: 0; background: none; font-size: 0.85em; }
  blockquote { border-left: 4px solid ${isDark ? '#82b1ff' : '#1976d2'}; background: $blockquoteBg; padding: 0.5em 1em; margin: 1em 0; border-radius: 0 8px 8px 0; }
  ul,ol { padding-left: 2em; margin: 0.6em 0; }
  li { margin: 0.3em 0; }
  table { border-collapse: collapse; width: 100%; margin: 1em 0; }
  th,td { border: 1px solid $border; padding: 8px 12px; text-align: left; }
  th { background: ${isDark ? '#2d2d44' : '#f0f0f0'}; font-weight: 600; }
  tr:nth-child(even) { background: ${isDark ? '#222238' : '#fafafa'}; }
  hr { border: none; border-top: 1px solid $border; margin: 1.5em 0; }
  img { max-width: 100%; height: auto; border-radius: 4px; }
  ::selection { background: ${isDark ? '#3d5afe66' : '#bbdefb'}; }
</style>
</head>
<body>$htmlBody</body>
</html>''';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (request.url.startsWith('http') || request.url.startsWith('mailto:')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadHtmlString(html);

    setState(() => _webController = controller);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_fileName, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_content.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showFileInfo(context),
            ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file_outlined, size: 64,
                color: theme.colorScheme.error.withAlpha(180)),
              const SizedBox(height: 16),
              Text('Unable to Preview',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                )),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => setState(() { _errorMessage = null; _fileName = 'No file'; }),
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    if (_content.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 80,
                color: theme.colorScheme.primary.withAlpha(100)),
              const SizedBox(height: 24),
              Text('Markdown View',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Open a .md file from any file manager\nor share it to this app to preview',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 32),
              Icon(Icons.open_in_new, size: 32,
                color: theme.colorScheme.primary.withAlpha(150)),
              const SizedBox(height: 8),
              Text('Use "Open with" from file manager',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    if (_webController != null) {
      return WebViewWidget(controller: _webController!);
    }

    return const Center(child: CircularProgressIndicator());
  }

  void _showFileInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Markdown View',
      applicationVersion: '1.0.0',
      applicationLegalese: 'A lightweight Markdown previewer',
    );
  }
}