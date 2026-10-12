import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/push_service.dart';
import '../../data/sync/sync_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/auth/auth_cubit.dart';
import '../providers/settings_notifier.dart';
import '../router/app_router.dart';

/// Вкладка «Профиль»: аккаунт, настройки и дополнительные разделы.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authSignOutConfirm),
        content: Text(l10n.authSignOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('confirmSignOut'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.authSignOut),
          ),
        ],
      ),
    );
    // После выхода GoRouter сам перенаправит на /login (redirect).
    if (confirmed == true) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = context.select((AuthCubit c) => c.state.user);
    final gamification = context.select(
      (SettingsNotifier s) => s.gamificationEnabled,
    );
    final name = user == null
        ? ''
        : user.isGuest
        ? l10n.authGuestName
        : (user.displayName?.isNotEmpty ?? false)
        ? user.displayName!
        : (user.email ?? '');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.all(Gaps.m),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Gaps.m),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(
                      name.isEmpty ? '?' : name[0].toUpperCase(),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: Gaps.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.titleMedium),
                        Text(
                          user?.isGuest ?? true
                              ? l10n.authGuestHint
                              : (user?.email ?? ''),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (user != null && !user.isGuest) ...[
            const SizedBox(height: Gaps.m),
            const _CloudCard(),
          ],
          const SizedBox(height: Gaps.m),
          Card(
            child: Column(
              children: [
                ListTile(
                  key: const Key('settingsTile'),
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(l10n.settingsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(AppRoutes.settings),
                ),
                if (gamification)
                  ListTile(
                    key: const Key('metricsTile'),
                    leading: const Icon(Icons.sports_esports_outlined),
                    title: Text(l10n.metricsTitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.goNamed(AppRoutes.metrics),
                  ),
                ListTile(
                  leading: const Icon(Icons.auto_stories_outlined),
                  title: Text(l10n.materialsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed(AppRoutes.materials),
                ),
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(l10n.categoriesTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(AppRoutes.categories),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gaps.m),
          Card(
            child: ListTile(
              key: const Key('signOutTile'),
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                user?.isGuest ?? false ? l10n.authLeaveGuest : l10n.authSignOut,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => _signOut(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Статус синхронизации с Firestore и токен устройства для push (FCM).
class _CloudCard extends StatelessWidget {
  const _CloudCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sync = getIt.isRegistered<SyncService>()
        ? getIt<SyncService>()
        : null;
    final push = getIt.isRegistered<PushService>()
        ? getIt<PushService>()
        : null;
    return Card(
      child: Column(
        children: [
          if (sync != null)
            ValueListenableBuilder(
              valueListenable: sync.status,
              builder: (context, status, _) => ListTile(
                key: const Key('syncStatus'),
                leading: Icon(switch (status) {
                  SyncStatus.synced => Icons.cloud_done_outlined,
                  SyncStatus.syncing => Icons.cloud_sync_outlined,
                  SyncStatus.error => Icons.cloud_off_outlined,
                  SyncStatus.localOnly => Icons.phone_android,
                }),
                title: Text(l10n.syncTitle),
                subtitle: Text(switch (status) {
                  SyncStatus.synced => l10n.syncSynced,
                  SyncStatus.syncing => l10n.syncSyncing,
                  SyncStatus.error => l10n.syncError,
                  SyncStatus.localOnly => l10n.syncLocalOnly,
                }),
              ),
            ),
          if (push != null)
            ValueListenableBuilder(
              valueListenable: push.token,
              builder: (context, token, _) => ListTile(
                leading: const Icon(Icons.vpn_key_outlined),
                title: Text(l10n.pushToken),
                subtitle: Text(
                  token ?? l10n.pushTokenMissing,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: token == null
                    ? null
                    : IconButton(
                        tooltip: l10n.copy,
                        icon: const Icon(Icons.copy),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await Clipboard.setData(ClipboardData(text: token));
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.copied)),
                          );
                        },
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
