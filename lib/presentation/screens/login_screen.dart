import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../blocs/auth/auth_cubit.dart';

/// Текст ошибки авторизации на языке интерфейса.
String authErrorMessage(AppLocalizations l10n, AuthErrorCode code) =>
    switch (code) {
      AuthErrorCode.invalidEmail => l10n.authErrorInvalidEmail,
      AuthErrorCode.wrongCredentials => l10n.authErrorWrongCredentials,
      AuthErrorCode.emailInUse => l10n.authErrorEmailInUse,
      AuthErrorCode.weakPassword => l10n.authErrorWeakPassword,
      AuthErrorCode.network => l10n.errorNetwork,
      AuthErrorCode.cancelled => l10n.authErrorCancelled,
      AuthErrorCode.tooManyRequests => l10n.authErrorTooManyRequests,
      AuthErrorCode.unavailable => l10n.authErrorUnavailable,
      AuthErrorCode.unknown => l10n.errorUnknown,
    };

/// Вход и регистрация: email + пароль, Google или гостевой режим.
///
/// После успешного входа никуда переходить не нужно: GoRouter получает
/// событие от репозитория авторизации и сам перенаправляет (`redirect`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthCubit>();
    if (_register) {
      await auth.register(_email.text, _password.text, name: _name.text);
    } else {
      await auth.signIn(_email.text, _password.text);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!_email.text.contains('@')) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.authEnterEmail)));
      return;
    }
    final ok = await context.read<AuthCubit>().sendPasswordReset(_email.text);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.authResetSent)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = context.watch<AuthCubit>();
    final state = auth.state;
    final accounts = auth.supportsAccounts;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Gaps.l),
            child: ConstrainedBox(
              // На планшете и в альбомной ориентации форма не растягивается.
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: Gaps.s),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    Text(
                      l10n.authSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Gaps.l),
                    if (!accounts)
                      Card(
                        color: theme.colorScheme.tertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(Gaps.m),
                          child: Text(
                            l10n.authFirebaseNotConfigured,
                            style: TextStyle(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ),
                    if (accounts) ...[
                      SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: false,
                            label: Text(l10n.authSignIn),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text(l10n.authRegister),
                          ),
                        ],
                        selected: {_register},
                        onSelectionChanged: (s) =>
                            setState(() => _register = s.first),
                      ),
                      const SizedBox(height: Gaps.m),
                      if (_register) ...[
                        TextFormField(
                          key: const Key('nameField'),
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.authName,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: Gaps.m),
                      ],
                      TextFormField(
                        key: const Key('emailField'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: l10n.authEmail,
                          prefixIcon: const Icon(Icons.alternate_email),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? l10n.authErrorInvalidEmail
                            : null,
                      ),
                      const SizedBox(height: Gaps.m),
                      TextFormField(
                        key: const Key('passwordField'),
                        controller: _password,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: l10n.authPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? l10n.authErrorWeakPassword
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (!_register)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: state.busy ? null : _resetPassword,
                            child: Text(l10n.authForgotPassword),
                          ),
                        ),
                    ],
                    if (state.error != null) ...[
                      const SizedBox(height: Gaps.s),
                      Text(
                        authErrorMessage(l10n, state.error!),
                        key: const Key('authError'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: Gaps.m),
                    if (accounts) ...[
                      FilledButton(
                        key: const Key('submitButton'),
                        onPressed: state.busy ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: state.busy
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _register ? l10n.authRegister : l10n.authSignIn,
                              ),
                      ),
                      const SizedBox(height: Gaps.s),
                      OutlinedButton.icon(
                        key: const Key('googleButton'),
                        onPressed: state.busy
                            ? null
                            : () =>
                                  context.read<AuthCubit>().signInWithGoogle(),
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: Text(l10n.authGoogle),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                      const SizedBox(height: Gaps.m),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Gaps.s,
                            ),
                            child: Text(l10n.authOr),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: Gaps.m),
                    ],
                    TextButton.icon(
                      key: const Key('guestButton'),
                      onPressed: state.busy
                          ? null
                          : () => context.read<AuthCubit>().continueAsGuest(),
                      icon: const Icon(Icons.offline_bolt_outlined),
                      label: Text(l10n.authGuest),
                    ),
                    Text(
                      l10n.authGuestHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
