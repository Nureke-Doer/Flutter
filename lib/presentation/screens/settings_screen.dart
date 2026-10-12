import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection.dart';
import '../../domain/repositories/materials_repository.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../providers/settings_notifier.dart';

/// Настройки приложения: тема и язык (Provider).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = context.watch<SettingsNotifier>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(Gaps.m),
        children: [
          Text(
            l10n.settingsAppearance,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Gaps.s),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Gaps.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SettingLabel(
                    icon: Icons.palette_outlined,
                    text: l10n.settingsTheme,
                  ),
                  const SizedBox(height: Gaps.s),
                  SegmentedButton<ThemeMode>(
                    key: const Key('themeSelector'),
                    // Без галочки — подписи помещаются на узком экране.
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l10n.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l10n.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l10n.themeDark),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) => settings.setThemeMode(s.first),
                  ),
                  const SizedBox(height: Gaps.l),
                  _SettingLabel(
                    icon: Icons.language,
                    text: l10n.settingsLanguage,
                  ),
                  const SizedBox(height: Gaps.s),
                  SegmentedButton<String>(
                    key: const Key('languageSelector'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: 'ru',
                        label: Text(l10n.languageRussian),
                      ),
                      ButtonSegment(
                        value: 'en',
                        label: Text(l10n.languageEnglish),
                      ),
                    ],
                    selected: {settings.locale.languageCode},
                    onSelectionChanged: (s) =>
                        settings.setLocale(Locale(s.first)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gaps.l),
          Text(
            l10n.settingsData,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Gaps.s),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.offline_pin_outlined),
                  subtitle: Text(l10n.settingsOfflineHint),
                ),
                ListTile(
                  key: const Key('clearCacheTile'),
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: Text(l10n.settingsClearCache),
                  subtitle: Text(l10n.settingsClearCacheHint),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await getIt<MaterialsRepository>().clearCache();
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.cacheCleared)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Gaps.l),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.settingsAbout),
              subtitle: Text(l10n.settingsVersion('0.6.0')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: Gaps.s),
        Text(text, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
