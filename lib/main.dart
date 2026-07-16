import 'package:budgets/core/theme.dart';
import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Kept as a compatibility bridge for the hidden legacy features. The new app
// shell does not initialize or access Supabase until its backend is redesigned.
final supabase = Supabase.instance.client;

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Drala',
        theme: AppTheme.lightTheme.copyWith(
          scaffoldBackgroundColor: const Color(0xFFFEFEFE),
        ),
        home: const ChatHomePage(),
      ),
    );
  }
}
