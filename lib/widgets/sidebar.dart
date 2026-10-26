import 'package:flutter/material.dart';

class SidebarDestination {
  final IconData icon;
  final String label;
  const SidebarDestination(this.icon, this.label);
}

class MiradaSidebar extends StatelessWidget {
  const MiradaSidebar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    this.width = 240,
  });

  final List<SidebarDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      color: colors.surfaceContainerLowest,
      child: SafeArea(
        right: false,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: destinations.length,
          itemBuilder: (context, i) {
            final d = destinations[i];
            final selected = i == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                type: MaterialType.transparency,
                shape: const StadiumBorder(),
                child: ListTile(
                  dense: true,
                  shape: const StadiumBorder(),
                  selected: selected,
                  selectedTileColor: colors.secondaryContainer,
                  hoverColor: colors.surfaceContainerHigh,
                  leading: Icon(
                    d.icon,
                    size: 20,
                    color: selected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
                  ),
                  title: Text(
                    d.label,
                    style: TextStyle(
                      color: selected ? colors.onSecondaryContainer : colors.onSurface,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  onTap: () => onSelect(i),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
