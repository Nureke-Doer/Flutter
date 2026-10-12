import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_info.dart';
import '../../core/di/injection.dart';
import '../../domain/repositories/materials_repository.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../providers/settings_notifier.dart';
import '../services/reminders_controller.dart';
import '../widgets/habit_visuals.dart';

/// Настройки приложения: тема, язык, геймификация (Provider).
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
          const _NotificationsCard(),
          const SizedBox(height: Gaps.l),
          Card(
            child: SwitchListTile(
              key: const Key('gamificationSwitch'),
              secondary: const Icon(Icons.sports_esports_outlined),
              title: Text(l10n.settingsGamification),
              subtitle: Text(l10n.settingsGamificationHint),
              value: settings.gamificationEnabled,
              onChanged: settings.setGamificationEnabled,
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
              subtitle: Text(l10n.settingsVersion(AppInfo.version)),
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

/// Уведомления: ежедневная сводка и проверка уведомлений.
/// Время напоминания для каждой привычки задаётся в её настройках.
class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard();

  Future<void> _pickTime(
    BuildContext context,
    SettingsNotifier settings,
  ) async {
    final current = settings.dailySummaryMinutes ?? 21 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      await settings.setDailySummaryMinutes(picked.hour * 60 + picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsNotifier>();
    final summary = settings.dailySummaryMinutes;
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            key: const Key('summarySwitch'),
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(l10n.settingsDailySummary),
            subtitle: Text(
              summary == null
                  ? l10n.settingsDailySummaryOff
                  : formatMinutes(context, summary),
            ),
            value: summary != null,
            onChanged: (on) => on
                ? _pickTime(context, settings)
                : settings.setDailySummaryMinutes(null),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            subtitle: Text(l10n.settingsRemindersHint),
          ),
          if (getIt.isRegistered<RemindersController>())
            ListTile(
              key: const Key('testNotification'),
              leading: const Icon(Icons.notification_add_outlined),
              title: Text(l10n.settingsTestNotification),
              onTap: () => getIt<RemindersController>().showTest(),
            ),
        ],
      ),
    );
  }
}
