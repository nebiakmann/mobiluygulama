import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A widget that catches errors in its child widget subtree
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  
  const ErrorBoundary({
    super.key,
    required this.child,
  });
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  String _errorDetails = '';
  
  @override
  void initState() {
    super.initState();
    
    // Override the default error widget builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (!kReleaseMode) {
        // In debug mode, still show the default error widget
        return ErrorWidget(details.exception);
      }
      
      // Schedule setting the error state for after this build cycle completes
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorDetails = details.exception.toString();
          });
        }
      });
      
      // Return an empty container while we wait for the state update
      return Container();
    };
  }
  
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Return the error display widget
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60.0,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(fontSize: 24.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorDetails,
                    style: const TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _errorDetails = '';
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Return the child widget
    return widget.child;
  }
} 