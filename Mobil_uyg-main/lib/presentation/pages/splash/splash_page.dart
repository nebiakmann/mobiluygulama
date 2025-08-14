import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spor_salonu/presentation/blocs/auth/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  bool _showError = false;
  String _errorMessage = '';
  final bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // Set up animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    
    // Always attempt to check authentication state
    // The timer is a fallback in case Firebase auth fails
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndSetupFallback();
    });
    
    // Force navigation to login after 6 seconds no matter what
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAuthAndSetupFallback() {
    try {
      // Try to check auth state
      context.read<AuthBloc>().add(CheckAuthState());
      
      // Fallback timer in case Firebase auth takes too long or fails
      Timer(const Duration(seconds: 3), () {
        final currentState = context.read<AuthBloc>().state;
        debugPrint('Auth state after 3 seconds: $currentState');
        
        // If we're still in loading or initial state after 3 seconds,
        // show an error message or navigate to login page
        if (currentState is AuthInitial || currentState is AuthLoading) {
          if (mounted) {
            setState(() {
              _showError = true;
              _errorMessage = 'Could not connect to Firebase. Taking you to login page...';
            });
            
            // Give the user time to see the error then navigate to login
            Timer(const Duration(seconds: 2), () {
              if (mounted) {
                _navigateToLogin();
              }
            });
          }
        }
      });
    } catch (e) {
      debugPrint('Error in _checkAuthAndSetupFallback: $e');
      if (mounted) {
        setState(() {
          _showError = true;
          _errorMessage = 'An error occurred: $e';
        });
        
        // Navigate to login after error
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            _navigateToLogin();
          }
        });
      }
    }
  }
  
  void _navigateToLogin() {
    debugPrint('Navigating to login page');
    try {
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      debugPrint('Error navigating to login: $e');
      // Try a different navigation approach if the first fails
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint('Auth state changed: $state');
          if (state is Authenticated) {
            // Navigate to home page if authenticated
            debugPrint('User authenticated, navigating to home');
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is Unauthenticated) {
            // Navigate to login page if unauthenticated
            debugPrint('User unauthenticated, navigating to login');
            _navigateToLogin();
          } else if (state is AuthError) {
            // Show error and navigate to login page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Authentication error: ${state.message}')),
            );
            debugPrint('Auth error: ${state.message}, navigating to login');
            _navigateToLogin();
          }
          // Stay on splash screen if still loading
        },
        child: FadeTransition(
          opacity: _animation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_showError) ...[
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ] else ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      'Fitness Center',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fitness Center Reservation App',
                      style: TextStyle(fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 