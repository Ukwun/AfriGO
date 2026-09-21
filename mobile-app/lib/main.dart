import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/app_router.dart';
import 'config/theme.dart';
import 'presentation/screens/onboarding/splash_screen_modern.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AfrigoBootstrapApp());
}

class AfrigoBootstrapApp extends StatefulWidget {
  const AfrigoBootstrapApp({super.key});

  @override
  State<AfrigoBootstrapApp> createState() => _AfrigoBootstrapAppState();
}

class _AfrigoBootstrapAppState extends State<AfrigoBootstrapApp> {
  late final Future<FirebaseApp> _firebaseReady;

  @override
  void initState() {
    super.initState();
    _firebaseReady = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _firebaseReady,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AfrigoTheme.lightTheme,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'AfriGO could not initialize. Check your connection and try again.',
                    textAlign: TextAlign.center,
                    style: AfrigoTypography.interBody1,
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AfrigoTheme.lightTheme,
            home: const SplashScreenModern(),
          );
        }
        return const ProviderScope(child: AfrigoApp());
      },
    );
  }
}

class AfrigoApp extends ConsumerWidget {
  const AfrigoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'AfriGo',
      debugShowCheckedModeBanner: false,
      theme: AfrigoTheme.lightTheme,
      darkTheme: AfrigoTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
