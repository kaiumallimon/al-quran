import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

/// Inline error banner for authentication failures.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.errorMessage == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: MaterialBanner(
        content: Text(auth.errorMessage!),
        leading: Icon(Icons.error_outline, color: colorScheme.error),
        actions: [
          TextButton(
            onPressed: auth.clearError,
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}

/// Shared sign-in actions for login and registration screens.
class AuthSignInOptions extends StatelessWidget {
  const AuthSignInOptions({
    super.key,
    required this.showGuestOption,
  });

  final bool showGuestOption;

  bool get _showAppleSignIn =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final signingIn = auth.status == AuthStatus.signingIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showGuestOption)
          OutlinedButton.icon(
            onPressed: signingIn ? null : auth.signInAnonymously,
            icon: const Icon(Icons.person_outline),
            label: const Text('Continue as guest'),
          ),
        if (showGuestOption) const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: signingIn ? null : auth.signInWithGoogle,
          icon: const Icon(Icons.g_mobiledata, size: 28),
          label: const Text('Continue with Google'),
        ),
        if (_showAppleSignIn) ...[
          const SizedBox(height: AppSpacing.sm),
          FilledButton.tonalIcon(
            onPressed: signingIn ? null : auth.signInWithApple,
            icon: const Icon(Icons.apple),
            label: const Text('Continue with Apple'),
          ),
        ],
        if (signingIn) ...[
          const SizedBox(height: AppSpacing.lg),
          const Center(child: LinearProgressIndicator()),
        ],
      ],
    );
  }
}

/// Brand header shown on authentication screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            size: 44,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: AppTypography.headline(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: AppTypography.body(context).copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
