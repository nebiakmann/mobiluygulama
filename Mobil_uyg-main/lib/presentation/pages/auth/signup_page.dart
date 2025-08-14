import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spor_salonu/presentation/blocs/auth/auth_bloc.dart';
import 'package:spor_salonu/presentation/widgets/custom_button.dart';
import 'package:spor_salonu/presentation/widgets/custom_text_field.dart';
import 'package:spor_salonu/presentation/widgets/loading_indicator.dart';
import 'package:spor_salonu/data/models/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _studentOrStaffIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  Gender _selectedGender = Gender.preferNotToSay;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _studentOrStaffIdController.dispose();
    _departmentController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  String _getGenderDisplayName(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Erkek';
      case Gender.female:
        return 'Kadın';
      case Gender.other:
        return 'Diğer';
      case Gender.preferNotToSay:
        return 'Belirtmek İstemiyorum';
    }
  }

  Future<void> _saveUserDataToFirestore(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': _emailController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'studentOrStaffId': _studentOrStaffIdController.text.trim(),
        'department': _departmentController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'gender': _selectedGender.toString().split('.').last,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('User data saved to Firestore successfully');
    } catch (e) {
      debugPrint('Error saving user data to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil bilgileriniz kaydedildi, ancak bazı bilgiler eksik olabilir')),
      );
    }
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        studentOrStaffId: _studentOrStaffIdController.text.trim(),
        role: UserRole.student, // Default role
        department: _departmentController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is Authenticated) {
            // Save user data to Firestore
            _saveUserDataToFirestore(state.user.uid).then((_) {
              // Navigate to home page after successful registration and data save
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            });
          }
        },
        child: SafeArea(
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _fullNameController,
                        labelText: 'Ad Soyad',
                        hintText: 'Adınızı ve soyadınızı girin',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ad Soyad gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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

                      // Gender dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cinsiyet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<Gender>(
                                value: _selectedGender,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: Gender.values.map((Gender gender) {
                                  return DropdownMenuItem<Gender>(
                                    value: gender,
                                    child: Text(_getGenderDisplayName(gender)),
                                  );
                                }).toList(),
                                onChanged: (Gender? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _studentOrStaffIdController,
                        labelText: 'Öğrenci/Personel No',
                        hintText: 'Öğrenci veya personel numaranızı girin',
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _departmentController,
                        labelText: 'Bölüm',
                        hintText: 'Bölümünüzü girin',
                        prefixIcon: Icons.business_outlined,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneNumberController,
                        labelText: 'Telefon',
                        hintText: 'Telefon numaranızı girin',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Kayıt Ol',
                        backgroundColor: Colors.tealAccent,
                        onPressed: _signup,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}