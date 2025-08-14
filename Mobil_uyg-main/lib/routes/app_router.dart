import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spor_salonu/data/models/facility_model.dart';
import 'package:spor_salonu/presentation/blocs/auth/auth_bloc.dart';
import 'package:spor_salonu/presentation/pages/auth/login_page.dart';
import 'package:spor_salonu/presentation/pages/auth/signup_page.dart';
import 'package:spor_salonu/presentation/pages/home/home_page.dart';
import 'package:spor_salonu/presentation/pages/profile/profile_page.dart';
import 'package:spor_salonu/presentation/pages/reservation/reservation_calendar_page.dart';

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case '/signup':
        return MaterialPageRoute(
          builder: (_) => const SignupPage(),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        );
      case '/reservation_calendar':
        final facility = settings.arguments as FacilityModel;
        return MaterialPageRoute(
          builder: (_) => ReservationCalendarPage(facility: facility),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  Route generateInitialRoute(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    
    if (authState is Authenticated) {
      return MaterialPageRoute(
        builder: (_) => const HomePage(),
      );
    }
    
    return MaterialPageRoute(
      builder: (_) => const LoginPage(),
    );
  }
}