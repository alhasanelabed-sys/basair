import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'library_store.dart';
import 'snapshot.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BasairApp());
}

class BasairApp extends StatelessWidget {
  const BasairApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'بصائر',
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff234f41))),
    home: const BasairHome(),
  );
}

class BasairHome extends StatefulWidget {
  const BasairHome({super.key});
  @override
  State<BasairHome> createState() => _BasairHomeState();
}

class _BasairHomeState extends State<BasairHome> {
  WebViewController? _web;
  LibraryStore? _store;
  String? _error;
  bool _busy = true;
  bool _bridgeLoaded = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final store = await LibraryStore.open();
      _store = store;
      if (!mounted) { await store.close(); return; }
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xfff6f5ef))
        ..addJavaScriptChannel('NativeBasair', onMessageReceived: (message) => _message(message.message))
        ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && _trustedLocal(uri)) return NavigationDecision.navigate;
            // No remote document is ever allowed to acquire the native bridge.
            if (uri != null && uri.scheme == 'https' && ['tanzil.net', 'github.com'].contains(uri.host)) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            return NavigationDecision.prevent;
          },
          onPageStarted: (_) { _bridgeLoaded = false; },
          onPageFinished: (_) async {
            try {
              // Read the latest persisted value on EVERY local page load.
              // Pass raw JSON so corrupt snapshots can still be backed up.
              final latest = await store.readRaw();
              if (!mounted) return;
              _bridgeLoaded = true;
              await _web?.runJavaScript('window.basairNativeReady(${jsonEncode(latest)});');
              setState(() => _busy = false);
            } catch (_) {
              _bridgeLoaded = false;
              if (mounted) setState(() { _busy = false; _error = 'تعذر قراءة المكتبة؛ لم تُحذف بياناتك.'; });
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() { _busy = false; _error = 'تعذر فتح الواجهة المحلية. أعد تشغيل التطبيق.'; });
            }
          },
        ));
      _web = controller;
      setState(() {});
      await controller.loadFlutterAsset('assets/web/index.html');
    } catch (_) {
      if (mounted) setState(() {
        _busy = false;
        _error = 'تعذر فتح مكتبتك المحلية. بياناتك لم تُحذف. أعد تشغيل التطبيق أو احتفظ بنسخة قاعدة البيانات قبل إعادة التثبيت.';
      });
    }
  }

  bool _trustedLocal(Uri uri) => uri.scheme == 'file' && uri.path.endsWith('/assets/web/index.html');

  Future<void> _reply(String id, bool ok, [String? error]) async {
    await _web?.runJavaScript('window.basairNativeReply(${jsonEncode(id)}, $ok, ${jsonEncode(error)});');
  }

  Future<void> _message(String raw) async {
    if (!_bridgeLoaded || raw.length > 28 * 1024 * 1024) return;
    String? id;
    try {
      final msg = jsonDecode(raw) as Map<String, dynamic>;
      id = msg['id'] as String;
      if (id.length > 100) return;
      if (msg['type'] == 'persist') {
        await _store!.save(msg['payload']);
      } else if (msg['type'] == 'import') {
        final chosen = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json'], withData: false);
        if (chosen != null) {
          final entry = chosen.files.single;
          if (entry.size > 5 * 1024 * 1024) throw const FormatException('الملف أكبر من الحد المسموح');
          final bytes = entry.bytes ?? await File(entry.path!).readAsBytes();
          final snapshot = validateSnapshot(jsonDecode(utf8.decode(bytes)));
          await _web?.runJavaScript('window.basairImportLibrary(${jsonEncode(snapshot)});');
        }
      } else if (msg['type'] == 'export') {
        final payload = msg['payload'] as Map<String, dynamic>;
        final filename = payload['filename'];
        final mime = payload['mime'];
        if (!['basair-discovery.png', 'basair-library.json'].contains(filename) || !['image/png', 'application/json'].contains(mime)) {
          throw const FormatException('نوع الملف غير مسموح');
        }
        final bytes = base64Decode(payload['base64'] as String);
        if (bytes.length > 20 * 1024 * 1024) throw const FormatException('حجم الملف كبير');
        final directory = await getTemporaryDirectory();
        final file = File(p.join(directory.path, filename as String));
        await file.writeAsBytes(bytes, flush: true);
        if (!mounted) return;
        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles(
          [XFile(file.path, mimeType: mime as String)],
          sharePositionOrigin: box == null ? const Rect.fromLTWH(0, 0, 1, 1) : box.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        throw const FormatException('عملية غير معروفة');
      }
      await _reply(id, true);
    } catch (_) {
      if (id != null) await _reply(id, false, 'تعذر الحفظ أو المشاركة. بقيت البيانات السابقة محفوظة.');
    }
  }

  @override
  void dispose() {
    _store?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff6f5ef),
    body: SafeArea(
      child: _error != null
        ? Center(child: Padding(padding: const EdgeInsets.all(28), child: Text(_error!, textAlign: TextAlign.center)))
        : Stack(children: [
            if (_web != null) WebViewWidget(controller: _web!),
            if (_busy) const Center(child: CircularProgressIndicator()),
          ]),
    ),
  );
}
