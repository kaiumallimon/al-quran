import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shell/pages/app_shell.dart';
import '../providers/auth_provider.dart';
import 'auth_page.dart';

/// Routes between authentication and the main app based on session state.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.checking:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.signingIn:
      case AuthStatus.authenticated:
        if (auth.status == AuthStatus.authenticated) {
          return const AppShell();
        }
        return const AuthPage();
      case AuthStatus.unauthenticated:
        return const AuthPage();
    }
  }
}
