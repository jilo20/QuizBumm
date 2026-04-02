import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_scaffold.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF2563EB);
    const darkSlate = Color(0xFF1E293B);
    const offWhite = Color(0xFFF8FAFC);

    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: offWhite,
        useMaterial3: true,
      ),
      home: isAuthenticated
          ? const MainScaffold(
              primaryColor: primaryColor,
              darkSlate: darkSlate,
            )
          : const LoginScreen(),
    );
  }
}
