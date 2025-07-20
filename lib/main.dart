import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pig_lifecycle_crm/app/router/app_router.dart';
import 'package:pig_lifecycle_crm/features/auth/presentation/providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/theme/app_theme.dart'; // <-- Import your new theme file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return MaterialApp.router(
      title: 'Pig Lifecycle CRM',
      theme: AppTheme.lightTheme,
      routerConfig: createRouter(authProvider),
    );
  }
}
