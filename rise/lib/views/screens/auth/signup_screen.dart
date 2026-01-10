import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';
import '../../widgets/error_dialog.dart';

bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AppErrorDialog(
        title: title,
        message: message,
      ),
    );
  }

  String _getErrorTitle(String error) {
    final l10n = AppLocalizations.of(context)!;
    
    if (error.toLowerCase().contains('username') && 
        (error.toLowerCase().contains('taken') || 
         error.toLowerCase().contains('exists') ||
         error.toLowerCase().contains('already'))) {
      return l10n.usernameTaken;
    }
    
    if (error.toLowerCase().contains('email') && 
        (error.toLowerCase().contains('taken') || 
         error.toLowerCase().contains('exists') ||
         error.toLowerCase().contains('already') ||
         error.toLowerCase().contains('registered'))) {
      return l10n.emailAlreadyExists;
    }
    
    if (error.toLowerCase().contains('network') || 
        error.toLowerCase().contains('connection') ||
        error.toLowerCase().contains('internet') ||
        error.toLowerCase().contains('socket') ||
        error.toLowerCase().contains('host lookup')) {
      return l10n.noInternetConnection;
    }
    
    if (error.toLowerCase().contains('session') || 
        error.toLowerCase().contains('expired')) {
      return l10n.sessionExpired;
    }
    
    if (error.toLowerCase().contains('confirm') && 
        error.toLowerCase().contains('email')) {
      return l10n.emailConfirmationRequired;
    }
    
    return l10n.signUpFailed;
  }

  String _getErrorMessage(String error) {
    final l10n = AppLocalizations.of(context)!;
    
    if (error.toLowerCase().contains('username') && 
        (error.toLowerCase().contains('taken') || 
         error.toLowerCase().contains('exists') ||
         error.toLowerCase().contains('already'))) {
      return l10n.errorMessageUsernameTaken;
    }
    
    if (error.toLowerCase().contains('email') && 
        (error.toLowerCase().contains('taken') || 
         error.toLowerCase().contains('exists') ||
         error.toLowerCase().contains('already') ||
         error.toLowerCase().contains('registered'))) {
      return l10n.errorMessageEmailExists;
    }
    
    if (error.toLowerCase().contains('network') || 
        error.toLowerCase().contains('connection') ||
        error.toLowerCase().contains('internet') ||
        error.toLowerCase().contains('socket') ||
        error.toLowerCase().contains('host lookup')) {
      return l10n.errorMessageNoInternet;
    }
    
    if (error.toLowerCase().contains('session') || 
        error.toLowerCase().contains('expired')) {
      return l10n.errorMessageSessionExpired;
    }
    
    if (error.toLowerCase().contains('confirm') && 
        error.toLowerCase().contains('email')) {
      return l10n.errorMessageEmailConfirmation;
    }
    
    return l10n.errorMessageSignUpFailed;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final success = await context.read<AuthCubit>().signUp(
              _firstNameController.text.trim(),
              _lastNameController.text.trim(),
              _usernameController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text,
            );

        if (success && mounted) {
          // Navigation is handled by BlocListener in main.dart
          // No need to manually navigate or call markUserLoggedIn
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(
            _getErrorTitle(e.toString()),
            e.toString(),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.error != null) {
                _showErrorDialog(
                  _getErrorTitle(state.error!),
                  _getErrorMessage(state.error!),
                );
                context.read<AuthCubit>().clearError();
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          l10n.createAccount,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.signUpSubtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildTextField(
                          controller: _firstNameController,
                          label: l10n.firstName,
                          icon: Icons.person_outline,
                          validatorMessage: l10n.enterFirstName,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _lastNameController,
                          label: l10n.lastName,
                          icon: Icons.person_outline,
                          validatorMessage: l10n.enterLastName,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _usernameController,
                          label: l10n.username,
                          icon: Icons.alternate_email,
                          validatorMessage: l10n.enterUsername,
                          customValidator: (value) {
                            if (value!.length < 3) return l10n.usernameTooShort;
                            if (value.contains(' ')) return l10n.usernameNoSpaces;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _emailController,
                          label: l10n.email,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          customValidator: (value) {
                            if (!isValidEmail(value!)) return l10n.invalidEmail;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildPasswordField(
                          controller: _passwordController,
                          label: l10n.password,
                          obscure: _obscurePassword,
                          onToggle: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                          validatorMessage: l10n.enterPassword,
                          minLengthMessage: l10n.passwordTooShort,
                        ),
                        const SizedBox(height: 16),

                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: l10n.confirmPassword,
                          obscure: _obscureConfirmPassword,
                          onToggle: () {
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                          },
                          validatorMessage: l10n.enterConfirmPassword,
                          customValidator: (value) {
                            if (value != _passwordController.text) return l10n.passwordsDoNotMatch;
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.icon,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: state.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    l10n.signUp,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.alreadyHaveAccount,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed('/login');
                              },
                              child: Text(
                                l10n.login,
                                style: const TextStyle(
                                  color: AppColors.icon,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validatorMessage,
    String? Function(String?)? customValidator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: customValidator ?? (value) {
          if (value == null || value.isEmpty) return validatorMessage;
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? validatorMessage,
    String? minLengthMessage,
    String? Function(String?)? customValidator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: customValidator ??
            (value) {
              if (value == null || value.isEmpty) return validatorMessage;
              if (minLengthMessage != null && value.length < 6) return minLengthMessage;
              return null;
            },
      ),
    );
  }
}