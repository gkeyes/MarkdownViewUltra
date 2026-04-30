import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _channel = MethodChannel('com.gkeyes.markdownviewultra/intent');

  String _content = '';
  String _fileName = 'No file';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
      if (e is MissingPluginException) {
        debugPrint('MethodChannel not ready (native side not initialized yet)');
      } else {
        debugPrint('Intent check error: $e');
      }
      setState(() {
        _fileName = 'Welcome!';
      });
    }
  }

  Future<void> _loadFile(String? path) async {
    if (path == null || path.isEmpty) {
      setState(() {
        _errorMessage = 'No file path provided';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _content = content;
          _fileName = file.path.split('/').last;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'File not found: $path';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading file: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _fileName,
          style: const TextStyle(fontSize: 16),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _checkForIntent,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
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
              Icon(
                Icons.description,
                size: 80,
                color: theme.colorScheme.primary.withAlpha(100),
              ),
              const SizedBox(height: 24),
              Text(
                'Markdown View',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Open a .md file from any file manager\nor share it to this app to preview',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Icon(
                Icons.open_in_new,
                size: 32,
                color: theme.colorScheme.primary.withAlpha(150),
              ),
              const SizedBox(height: 8),
              Text(
                'Use "Open with" from file manager',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Markdown(
      data: _content,
      selectable: true,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet(
        h1: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        h2: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        h3: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        p: theme.textTheme.bodyLarge,
        code: TextStyle(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.primary,
              width: 4,
            ),
          ),
          color: theme.colorScheme.surfaceContainerLow,
        ),
        listBullet: theme.textTheme.bodyLarge,
        tableHead: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        tableBody: theme.textTheme.bodyMedium,
        tableBorder: TableBorder.all(
          color: theme.colorScheme.outlineVariant,
        ),
        tableCellsDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        checkbox: theme.textTheme.bodyMedium,
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
        }
      },
    );
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