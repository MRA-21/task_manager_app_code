import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      // This forces the virtual smartphone layout to only show up on Web builds
      enabled: kIsWeb,
      builder: (context) => const MinimalistTaskApp(),
    ),
  );
}

class MinimalistTaskApp extends StatelessWidget {
  const MinimalistTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        // FIXED: Replaced standard provider with a ProxyProvider that watches the active user state
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (context) => TaskProvider(null),
          update: (context, authProvider, previousTaskProvider) => TaskProvider(authProvider.currentUser),
        ),
      ],
      child: MaterialApp(
        // These 3 properties link your App layout context variables to the device preview frame frame parameters
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,

        debugShowCheckedModeBanner: false,
        title: 'Studio Desk Tasks',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: const Color(0xFF2E3A8C),
          textTheme: GoogleFonts.interTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF1A1A1A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
            iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            labelStyle: GoogleFonts.inter(color: const Color(0xFF6C757D), fontSize: 13),
            floatingLabelStyle: GoogleFonts.inter(color: const Color(0xFF2E3A8C), fontWeight: FontWeight.w600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: const Color(0xFF2E3A8C), width: 1.5),
            ),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFFF8F9FA),
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
