import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_sign_in_options.dart';
import '../widgets/email_auth_form.dart';

enum _AuthMode { login, register }

/// Combined login and registration flow without nested navigation.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  _AuthMode _mode = _AuthMode.login;

  @override
  Widget build(BuildContext context) {
    final isLogin = _mode == _AuthMode.login;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthHeader(
                    title: isLogin ? 'Welcome back' : 'Join Quran Companion',
                    subtitle: isLogin
                        ? 'Sign in to sync your reading progress across devices.'
                        : 'Create an account to back up bookmarks, notes, and reading progress.',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AuthErrorBanner(),
                  EmailAuthForm(isLogin: isLogin),
                  const AuthMethodDivider(),
                  const AuthSignInOptions(showGuestOption: true),
                  if (!isLogin) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Guest accounts are anonymous and can be upgraded later by signing in with email, Google, or Apple.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? 'New here?' : 'Already have an account?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthProvider>().clearError();
                          setState(() {
                            _mode = isLogin
                                ? _AuthMode.register
                                : _AuthMode.login;
                          });
                        },
                        child: Text(
                          isLogin ? 'Create an account' : 'Sign in',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
