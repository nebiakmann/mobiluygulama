import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spor_salonu/core/constants/app_strings.dart';
import 'package:spor_salonu/core/themes/app_theme.dart';
import 'package:spor_salonu/presentation/blocs/auth/auth_bloc.dart';
import 'package:spor_salonu/presentation/pages/auth/signup_page.dart';
import 'package:spor_salonu/presentation/widgets/custom_button.dart';
import 'package:spor_salonu/presentation/widgets/custom_text_field.dart';
import 'package:spor_salonu/presentation/widgets/loading_indicator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleRememberMe(bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is Authenticated) {
            // Navigate to home page after successful login
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const LoadingIndicator();
                  }
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and app name
                        Image.asset(
                          'assets/images/bartin.png',
                          height: 80,
                          width: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Eğer resim yüklenemezse fallback icon göster
                            return const Icon(
                              Icons.fitness_center,
                              size: 80,
                              color: AppColors.primaryColor,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.appName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Login form
                        Text(
                          'Giriş Yap',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        CustomTextField(
                          controller: _emailController,
                          labelText: 'E-posta',
                          hintText: 'E-posta adresinizi girin',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'E-posta adresi gereklidir';
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Geçerli bir e-posta adresi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Şifre',
                          hintText: 'Şifrenizi girin',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre gereklidir';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Remember me and forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: _toggleRememberMe,
                                    activeColor: AppColors.primaryColor,
                                  ),
                                  const Flexible(
                                    child: Text('Beni hatırla'),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Navigate to forgot password page
                                },
                                child: const Text('Şifremi Unuttum'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        CustomButton(
                          text: 'Giriş Yap',
                          backgroundColor: Colors.tealAccent,
                          onPressed: _login,
                        ),
                        const SizedBox(height: 24),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Hesabınız yok mu?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupPage(),
                                  ),
                                );
                              },
                              child: const Text('Kayıt Ol'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}