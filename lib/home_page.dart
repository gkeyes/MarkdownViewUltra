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
      if (filePath != null && filePath.isNotEmpty) await _loadFile(filePath);
    } catch (e) {
      if (e is! MissingPluginException) debugPrint('Intent check error: $e');
    }
  }

  bool _isAllowedFile(String path) {
    return _textExtensions.any((e) => path.toLowerCase().endsWith(e));
  }

  Future<void> _loadFile(String? path) async {
    if (path == null || path.isEmpty) {
      setState(() => _errorMessage = 'No file path provided');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    if (!_isAllowedFile(path)) {
      final ext = path.split('.').last;
      setState(() {
        _errorMessage = 'Unsupported file format ".$ext".\n\nMarkdown View can only preview:\n\u2022 .md / .markdown\n\u2022 .txt / .text';
        _isLoading = false;
      });
      return;
    }

    try {
      final file = File(path);
      if (!await file.exists()) {
        setState(() { _errorMessage = 'File not found'; _isLoading = false; });
        return;
      }

      String content;
      try {
        content = await file.readAsString(encoding: utf8);
      } on FileSystemException {
        setState(() {
          _errorMessage = 'Cannot preview this file.\nBinary files like .docx cannot be displayed.';
          _isLoading = false;
        });
        return;
      }

      final bad = content.runes.where((r) => r == 0xFFFD || (r < 0x09 && r != 0x0A && r != 0x0D)).length;
      if (content.length > 20 && bad / content.length > 0.3) {
        setState(() {
          _errorMessage = 'This file appears to be a binary document.\nMarkdown View only supports plain text.';
          _isLoading = false;
        });
        return;
      }

      setState(() { _content = content; _fileName = file.path.split('/').last; _isLoading = false; });
      _renderMarkdown(content);
    } catch (e) {
      setState(() { _errorMessage = 'Error: ${e.toString().split('\n').first}'; _isLoading = false; });
    }
  }

  void _renderMarkdown(String markdownContent) {
    final htmlBody = md.markdownToHtml(markdownContent, extensionSet: md.ExtensionSet.gitHubWeb);

    final isDark = _isDark;
    final fg = isDark ? '#f0f6fc' : '#1f2328';
    final fgMuted = isDark ? '#9198a1' : '#59636e';
    final bg = isDark ? '#0d1117' : '#ffffff';
    final bgMuted = isDark ? '#151b23' : '#f6f8fa';
    final border = isDark ? '#3d444d' : '#d1d9e0';
    final borderMuted = isDark ? '#3d444db3' : '#d1d9e0b3';
    final accent = isDark ? '#4493f8' : '#0969da';
    final codeBg = isDark ? '#656c7633' : '#818b981f';

    final html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
  .markdown-body {
    -ms-text-size-adjust: 100%;
    -webkit-text-size-adjust: 100%;
    margin: 0;
    color: $fg;
    background-color: $bg;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
    font-size: 16px;
    line-height: 1.5;
    word-wrap: break-word;
    padding: 0 16px 24px;
  }
  .markdown-body a { background-color: transparent; color: $accent; text-decoration: none; }
  .markdown-body a:hover { text-decoration: underline; }
  .markdown-body a:not([href]) { color: inherit; text-decoration: none; }
  .markdown-body b, .markdown-body strong { font-weight: 600; }
  .markdown-body dfn { font-style: italic; }
  .markdown-body h1 {
    margin: .67em 0;
    font-weight: 600;
    padding-bottom: .3em;
    font-size: 2em;
    border-bottom: 1px solid $borderMuted;
  }
  .markdown-body h2 {
    font-weight: 600;
    padding-bottom: .3em;
    font-size: 1.5em;
    border-bottom: 1px solid $borderMuted;
  }
  .markdown-body h3 { font-weight: 600; font-size: 1.25em; }
  .markdown-body h4 { font-weight: 600; font-size: 1em; }
  .markdown-body h5 { font-weight: 600; font-size: .875em; }
  .markdown-body h6 { font-weight: 600; font-size: .85em; color: $fgMuted; }
  .markdown-body h1, .markdown-body h2, .markdown-body h3,
  .markdown-body h4, .markdown-body h5, .markdown-body h6 {
    margin-top: 1.5rem;
    margin-bottom: 1rem;
    line-height: 1.25;
  }
  .markdown-body p { margin-top: 0; margin-bottom: 10px; }
  .markdown-body blockquote {
    margin: 0; padding: 0 1em;
    color: $fgMuted;
    border-left: .25em solid $border;
  }
  .markdown-body ul, .markdown-body ol {
    margin-top: 0; margin-bottom: 0;
    padding-left: 2em;
  }
  .markdown-body ul ul, .markdown-body ul ol,
  .markdown-body ol ol, .markdown-body ol ul {
    margin-top: 0; margin-bottom: 0;
  }
  .markdown-body li+li { margin-top: .25em; }
  .markdown-body li>p { margin-top: 1rem; }
  .markdown-body hr {
    box-sizing: content-box; overflow: hidden;
    background: transparent;
    border-bottom: 1px solid $borderMuted;
    height: .25em; padding: 0; margin: 1.5rem 0;
    background-color: $border; border: 0;
  }
  .markdown-body img {
    border-style: none; max-width: 100%;
    box-sizing: content-box;
  }
  .markdown-body code {
    font-family: "SF Mono", "Fira Code", Consolas, "Liberation Mono", monospace;
    font-size: 85%;
    padding: .2em .4em;
    margin: 0;
    white-space: break-spaces;
    background-color: $codeBg;
    border-radius: 6px;
  }
  .markdown-body pre {
    margin-top: 0; margin-bottom: 0;
    padding: 1rem;
    overflow: auto;
    font-size: 85%;
    line-height: 1.45;
    color: $fg;
    background-color: $bgMuted;
    border-radius: 6px;
  }
  .markdown-body pre code {
    padding: 0; margin: 0;
    background: transparent; border: 0;
    font-size: 100%;
    white-space: pre;
    word-break: normal;
    line-height: inherit;
  }

  /* ═══════ Tables — GitHub style, self-scrolling ═══════ */
  .markdown-body table {
    border-spacing: 0;
    border-collapse: collapse;
    display: block;
    width: max-content;
    max-width: 100%;
    overflow: auto;
    font-variant: tabular-nums;
    margin-top: 0;
    margin-bottom: 1rem;
  }
  .markdown-body table th,
  .markdown-body table td {
    padding: 6px 13px;
    border: 1px solid $border;
  }
  .markdown-body table th { font-weight: 600; }
  .markdown-body table tr {
    background-color: $bg;
    border-top: 1px solid $borderMuted;
  }
  .markdown-body table tr:nth-child(2n) {
    background-color: $bgMuted;
  }
  .markdown-body table td>:last-child { margin-bottom: 0; }

  .markdown-body .absent { color: #d1242f; }
  .markdown-body .emoji { max-width: none; vertical-align: text-top; background-color: transparent; }
  .markdown-body ::selection { background: ${isDark ? '#3d5afe66' : '#bbdefb'}; }
  .markdown-body>*:first-child { margin-top: 0 !important; }
  .markdown-body>*:last-child { margin-bottom: 0 !important; }
</style>
</head>
<body>
<div class="markdown-body">$htmlBody</div>
</body>
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file_outlined, size: 64, color: theme.colorScheme.error.withAlpha(180)),
              const SizedBox(height: 16),
              Text('Unable to Preview', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => setState(() { _errorMessage = null; _fileName = 'No file'; }),
                icon: const Icon(Icons.home), label: const Text('Back to Home'),
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
              Icon(Icons.description, size: 80, color: theme.colorScheme.primary.withAlpha(100)),
              const SizedBox(height: 24),
              Text('Markdown View', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Open a .md file from any file manager\nor share it to this app to preview',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 32),
              Icon(Icons.open_in_new, size: 32, color: theme.colorScheme.primary.withAlpha(150)),
              const SizedBox(height: 8),
              Text('Use "Open with" from file manager',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }
    if (_webController != null) return WebViewWidget(controller: _webController!);
    return const Center(child: CircularProgressIndicator());
  }

  void _showFileInfo(BuildContext context) {
    showAboutDialog(
      context: context, applicationName: 'Markdown View',
      applicationVersion: '1.0.0', applicationLegalese: 'A lightweight Markdown previewer',
    );
  }
}