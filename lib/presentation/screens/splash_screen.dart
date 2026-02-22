import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // allow initial read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAsync();
    });
  }

  Future<void> _checkAuthAsync() async {
    // Wait briefly for effects
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (!authState.isLoading) {
      if (authState.hasValue && authState.value != null) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (!next.isLoading) {
        if (next.hasValue && next.value != null) {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRouter.login);
        }
      }
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      ),
    );
  }
}
