import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tri_dechets/pages/home_page.dart';
import 'package:tri_dechets/splashes/splash_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://udgltnxkkcdopaupbxgd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkZ2x0bnhra2Nkb3BhdXBieGdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3ODcyMjgsImV4cCI6MjA3MTM2MzIyOH0.BvCHGNaWJExkRbfGNdh2LzR0iW_k-JOt38HkKr8S6I8',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DécheTri',
      debugShowCheckedModeBanner: false,
      home: const SplashApp(),
    );
  }
}
