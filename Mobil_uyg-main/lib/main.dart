import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spor_salonu/core/constants/app_strings.dart';
import 'package:spor_salonu/core/themes/app_theme.dart';
import 'package:spor_salonu/data/repositories/auth_repository.dart';
import 'package:spor_salonu/data/repositories/facility_repository.dart';
import 'package:spor_salonu/data/repositories/reservation_repository.dart';
import 'package:spor_salonu/presentation/blocs/auth/auth_bloc.dart';
import 'package:spor_salonu/presentation/blocs/facility/facility_bloc.dart';
import 'package:spor_salonu/presentation/blocs/facility/facility_event.dart';
import 'package:spor_salonu/presentation/blocs/reservation/reservation_bloc.dart';
import 'package:spor_salonu/presentation/pages/auth/login_page.dart';
import 'package:spor_salonu/routes/app_router.dart';
import 'package:spor_salonu/utils/firebase_initializer.dart';
import 'package:spor_salonu/utils/error_boundary.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  // First try to initialize with default options
  bool isFirebaseInitialized;
  try {
    debugPrint('Attempting to initialize Firebase...');
    isFirebaseInitialized = await FirebaseInitializer.initializeAppWithData();
    
    if (isFirebaseInitialized) {
      debugPrint('Firebase initialized successfully in main.dart');
    } else {
      debugPrint('Firebase initialization failed in main.dart');
    }
  } catch (e) {
    debugPrint('Exception during Firebase initialization: $e');
    isFirebaseInitialized = false;
  }
  
  runApp(ErrorBoundary(child: MyApp(isFirebaseInitialized: isFirebaseInitialized)));
}

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();
  final bool isFirebaseInitialized;

  MyApp({super.key, this.isFirebaseInitialized = false});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<FacilityRepository>(
          create: (context) => FacilityRepository(),
        ),
        RepositoryProvider<ReservationRepository>(
          create: (context) => ReservationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(CheckAuthState()),
          ),
          BlocProvider<FacilityBloc>(
            create: (context) => FacilityBloc(
              facilityRepository: context.read<FacilityRepository>(),
            )..add(const LoadFacilities()),
          ),
          BlocProvider<ReservationBloc>(
            create: (context) => ReservationBloc(
              reservationRepository: context.read<ReservationRepository>(),
              facilityRepository: context.read<FacilityRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          onGenerateRoute: (settings) {
            debugPrint('Attempting to navigate to: ${settings.name}');
            return _appRouter.onGenerateRoute(settings);
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('tr', ''),
          ],
          home: const LoginPage(),
        ),
      ),
    );
  }
}