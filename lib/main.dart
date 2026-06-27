import 'package:flutter/material.dart';
import 'package:smart_street_light/theme_and_store.dart';
import 'screens/splash_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_wrapper.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Initialize
  await Supabase.initialize(
    url: 'https://kewebmnmqrylxkggrkua.supabase.co',       
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtld2VibW5tcXJ5bHhrZ2dya3VhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxMDAxNDEsImV4cCI6MjA5NzY3NjE0MX0.JtjqxplRIpN9pF_5KJhf9q5OTKyagc2APe90wwkuvrk', 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumen Smart Streetlight',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.bg,
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => Builder( 
              builder: (routingContext) {
                return SplashScreen(
                  onDone: () {
                    final session = Supabase.instance.client.auth.currentSession;
                    if (session != null) {
                      Navigator.pushReplacementNamed(routingContext, '/home');
                    } else {
                      Navigator.pushReplacementNamed(routingContext, '/signin');
                    }
                  },
                );
              },
            ),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeWrapper(), 
      },
    );
  }
}