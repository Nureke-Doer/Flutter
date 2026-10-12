import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../router/app_router.dart';
import '../widgets/empty_state.dart';

/// Экран для неизвестного адреса (например, устаревшая ссылка).
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.link_off,
        title: l10n.notFound,
        message: uri.toString(),
        action: FilledButton(
          onPressed: () => context.goNamed(AppRoutes.today),
          child: Text(l10n.navToday),
        ),
      ),
    );
  }
}
