import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../l10n/app_localizations.dart';
import '../services/window_controls.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key, required this.title, this.controls});

  final String title;
  final WindowControls? controls;

  static const double barHeight = 40;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final c = controls ?? WindowManagerControls();
    return Material(
      color: colors.surfaceContainerLow,
      child: SizedBox(
        height: barHeight,
        child: Row(
          children: [
            TrafficLights(controls: c),
            Expanded(
              child: DragToMoveArea(
                child: Center(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 88),
          ],
        ),
      ),
    );
  }
}

class TrafficLights extends StatefulWidget {
  const TrafficLights({super.key, required this.controls});

  final WindowControls controls;

  @override
  State<TrafficLights> createState() => _TrafficLightsState();
}

class _TrafficLightsState extends State<TrafficLights> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Light(
              color: const Color(0xFFFF5F57),
              glyph: _hover ? Icons.close : null,
              tooltip: l.windowTitleClose,
              onTap: widget.controls.close,
            ),
            const SizedBox(width: 8),
            _Light(
              color: const Color(0xFFFEBC2E),
              glyph: _hover ? Icons.remove : null,
              tooltip: l.windowTitleMinimize,
              onTap: widget.controls.minimize,
            ),
            const SizedBox(width: 8),
            _Light(
              color: const Color(0xFF28C840),
              glyph: _hover ? Icons.add : null,
              tooltip: l.windowTitleMaximize,
              onTap: widget.controls.toggleMaximize,
            ),
          ],
        ),
      ),
    );
  }
}

class _Light extends StatelessWidget {
  const _Light({required this.color, this.glyph, required this.tooltip, required this.onTap});

  final Color color;
  final IconData? glyph;
  final String tooltip;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onTap(),
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: glyph == null
              ? null
              : Icon(glyph, size: 10, color: Colors.black.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
