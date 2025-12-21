import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/hotel_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/review_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/home/home_page.dart';
import 'screens/admin/admin_dashboard.dart';
import 'utils/app_theme.dart';

import 'dart:async';
import 'dart:developer' as developer;

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MaterialApp(
        title: 'HotelKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) {
            final auth = Provider.of<AuthProvider>(context);
            if (auth.isLoggedIn && auth.isAdmin) {
              return const AdminDashboardPage();
            }
            return const HomePage();
          },
          '/admin_dashboard': (context) => const AdminDashboardPage(),
        },
      ),
    );
  }
}
