import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

// Settings Sheet Helper Widgets
class SettingsTitle extends StatelessWidget {
  const SettingsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.settings, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class ThemeLabel extends StatelessWidget {
  const ThemeLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.theme, style: const TextStyle(fontWeight: FontWeight.bold));
  }
}

class ThemeSelector extends StatelessWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onChanged;

  const ThemeSelector({super.key, required this.themeMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<ThemeMode>(
      segments: [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text(l10n.systemMode),
          icon: const Icon(Icons.brightness_auto),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text(l10n.lightMode),
          icon: const Icon(Icons.light_mode),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text(l10n.darkMode),
          icon: const Icon(Icons.dark_mode),
        ),
      ],
      selected: {themeMode},
      onSelectionChanged: (Set<ThemeMode> newSelection) {
        onChanged(newSelection.first);
      },
    );
  }
}

class SettingsAboutTile extends StatelessWidget {
  const SettingsAboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Acerca de'),
      subtitle: const Text('To-Do App v1.0.0'),
      contentPadding: EdgeInsets.zero,
      onTap: () {},
    );
  }
}

class SettingsCloseButton extends StatelessWidget {
  const SettingsCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cerrar'),
      ),
    );
  }
}
