import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';
import '../../widgets/error_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
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
    
    if (error.toLowerCase().contains('network') || 
        error.toLowerCase().contains('connection') ||
        error.toLowerCase().contains('internet') ||
        error.toLowerCase().contains('socket') ||
        error.toLowerCase().contains('host lookup')) {
      return l10n.noInternetConnection;
    }
    
    if (error.toLowerCase().contains('invalid') || 
        error.toLowerCase().contains('incorrect') ||
        error.toLowerCase().contains('wrong')) {
      return l10n.invalidCredentials;
    }
    
    if (error.toLowerCase().contains('session') || 
        error.toLowerCase().contains('expired')) {
      return l10n.sessionExpired;
    }
    
    return l10n.loginFailed;
  }

  String _getErrorMessage(String error) {
    final l10n = AppLocalizations.of(context)!;
    
    if (error.toLowerCase().contains('network') || 
        error.toLowerCase().contains('connection') ||
        error.toLowerCase().contains('internet') ||
        error.toLowerCase().contains('socket') ||
        error.toLowerCase().contains('host lookup')) {
      return l10n.errorMessageNoInternet;
    }
    
    if (error.toLowerCase().contains('invalid') || 
        error.toLowerCase().contains('incorrect') ||
        error.toLowerCase().contains('wrong')) {
      return l10n.errorMessageInvalidCredentials;
    }
    
    if (error.toLowerCase().contains('session') || 
        error.toLowerCase().contains('expired')) {
      return l10n.errorMessageSessionExpired;
    }
    
    return l10n.errorMessageLoginFailed;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final success = await context.read<AuthCubit>().login(
              _identifierController.text.trim(),
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
                        const Icon(
                          Icons.self_improvement,
                          size: 80,
                          color: AppColors.icon,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.welcomeBack,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginSubtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 48),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _identifierController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: l10n.usernameOrEmail,
                              prefixIcon: const Icon(Icons.person_outline),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.enterUsernameOrEmail;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.enterPassword;
                              }
                              if (value.length < 6) {
                                return l10n.passwordTooShort;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.icon,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: state.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    l10n.login,
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
                              l10n.noAccount,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushReplacementNamed('/signup');
                              },
                              child: Text(
                                l10n.signUp,
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
}