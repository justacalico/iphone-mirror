import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const LandingApp());

enum AppTheme { system, light, dark, oled }

class LandingApp extends StatefulWidget {
  const LandingApp({super.key});
  @override
  State<LandingApp> createState() => _LandingAppState();
}

class _LandingAppState extends State<LandingApp> {
  AppTheme _theme = AppTheme.system;

  ThemeData _build(bool dark, bool oled) {
    final scheme = ColorScheme.fromSeed(
        seedColor: const Color(0xFF4C5BD4), brightness: dark ? Brightness.dark : Brightness.light);
    return ThemeData(
      colorScheme: oled
          ? scheme.copyWith(surface: Colors.black, surfaceContainerLowest: Colors.black)
          : scheme,
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = _theme == AppTheme.dark || _theme == AppTheme.oled ||
        (_theme == AppTheme.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    return MaterialApp(
      title: 'Mirada',
      debugShowCheckedModeBanner: false,
      theme: _build(false, false),
      darkTheme: _build(true, _theme == AppTheme.oled),
      themeMode: _theme == AppTheme.system
          ? ThemeMode.system
          : (dark ? ThemeMode.dark : ThemeMode.light),
      home: LandingPage(theme: _theme, onTheme: (t) => setState(() => _theme = t)),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key, required this.theme, required this.onTheme});
  final AppTheme theme;
  final ValueChanged<AppTheme> onTheme;

  Future<List<Map<String, dynamic>>> _releases() async {
    try {
      final r = await http.get(Uri.parse(
          'https://gitlab.com/api/v4/projects/HttpAnimations%2Fiphone-mirror/releases?per_page=5'));
      if (r.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(r.body));
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mirada'),
        actions: [
          SegmentedButton<AppTheme>(
            segments: const [
              ButtonSegment(value: AppTheme.system, label: Text('System')),
              ButtonSegment(value: AppTheme.light, label: Text('Light')),
              ButtonSegment(value: AppTheme.dark, label: Text('Dark')),
              ButtonSegment(value: AppTheme.oled, label: Text('OLED')),
            ],
            selected: {theme},
            onSelectionChanged: (s) => onTheme(s.first),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text('Your iPhone, on your Linux desktop',
                      style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    'Mirada mirrors your iPhone screen over WiFi and sends your taps and typing back over Bluetooth. No jailbreak, no app on the phone, no account.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Wrap(spacing: 16, runSpacing: 16, children: const [
                    ShowcaseCard(kind: ShowcaseKind.phone),
                    ShowcaseCard(kind: ShowcaseKind.wave),
                    ShowcaseCard(kind: ShowcaseKind.cursor),
                  ]),
                  const SizedBox(height: 48),
                  Text('Download', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Install via Flatpak (.flatpakref)'),
                      onPressed: () => html.window.open('mirada.flatpakref', '_blank'),
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.code),
                      label: const Text('GitLab Releases'),
                      onPressed: () => html.window.open('https://gitlab.com/HttpAnimations/iphone-mirror/-/releases', '_blank'),
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open the web app'),
                      onPressed: () => html.window.open('app/', '_blank'),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  SelectableText(
                    'flatpak install https://httpanimations.gitlab.io/iphone-mirror/mirada.flatpakref',
                    style: TextStyle(color: cs.primary, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 32),
                  Text('Latest releases', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _releases(),
                    builder: (context, snap) {
                      final list = snap.data ?? [];
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator());
                      }
                      if (list.isEmpty) {
                        return const Text('First release is on the way.');
                      }
                      return Column(
                        children: [
                          for (final r in list)
                            Card(
                              child: ListTile(
                                title: Text(r['name'] ?? r['tag_name'] ?? ''),
                                subtitle: Text((r['released_at'] ?? '').toString().split('T').first),
                                trailing: Text(r['tag_name'] ?? ''),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ShowcaseKind { phone, wave, cursor }

class ShowcaseCard extends StatelessWidget {
  const ShowcaseCard({super.key, required this.kind});
  final ShowcaseKind kind;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CustomPaint(
        size: const Size(260, 160),
        painter: _ShowcasePainter(kind, cs),
      ),
    );
  }
}

class _ShowcasePainter extends CustomPainter {
  _ShowcasePainter(this.kind, this.cs);
  final ShowcaseKind kind;
  final ColorScheme cs;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = LinearGradient(
      colors: [cs.primaryContainer, cs.secondaryContainer],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    final w = size.width, h = size.height;
    switch (kind) {
      case ShowcaseKind.phone:
        final phone = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(w / 2, h / 2), width: w * 0.28, height: h * 0.8),
            const Radius.circular(12));
        canvas.drawRRect(phone, Paint()..color = cs.surface);
        canvas.drawRRect(phone, Paint()..style = PaintingStyle.stroke ..strokeWidth = 3 ..color = cs.primary);
        canvas.drawCircle(Offset(w / 2, h / 2), 14, Paint()..color = cs.primary);
      case ShowcaseKind.wave:
        final p = Paint()..style = PaintingStyle.stroke ..strokeWidth = 3 ..color = cs.primary;
        final path = Path()..moveTo(w * 0.1, h * 0.5);
        for (var i = 1; i <= 6; i++) {
          path.quadraticBezierTo(w * (0.1 + i * 0.133) - w * 0.066, h * (i.isOdd ? 0.25 : 0.75), w * (0.1 + i * 0.133), h * 0.5);
        }
        canvas.drawPath(path, p);
      case ShowcaseKind.cursor:
        final arrow = Path()
          ..moveTo(w * 0.4, h * 0.25)
          ..lineTo(w * 0.4, h * 0.75)
          ..lineTo(w * 0.51, h * 0.62)
          ..lineTo(w * 0.58, h * 0.82)
          ..lineTo(w * 0.64, h * 0.78)
          ..lineTo(w * 0.57, h * 0.58)
          ..lineTo(w * 0.7, h * 0.58)
          ..close();
        canvas.drawPath(arrow, Paint()..color = cs.primary);
    }
  }

  @override
  bool shouldRepaint(covariant _ShowcasePainter old) => false;
}
