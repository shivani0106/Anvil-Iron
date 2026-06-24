import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validators.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import 'auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _factoryCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _factoryCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signUpWithEmail(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          factoryName: _factoryCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AppAuthState>(
      listenWhen: (_, s) =>
          s is AppAuthAuthenticated ||
          s is AppAuthError ||
          s is AppAuthConfirmationRequired,
      listener: (ctx, state) {
        if (state is AppAuthAuthenticated) {
          // Account created and session is live — go straight to main app.
          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          return;
        }
        if (state is AppAuthError) {
          _showBar(ctx, state.message, isError: true);
          ctx.read<AuthCubit>().clearError();
        }
        if (state is AppAuthConfirmationRequired) {
          _showBar(
            ctx,
            'Account created! Check your inbox at ${state.email} '
            'to confirm, then sign in.',
            isError: false,
          );
          ctx.read<AuthCubit>().clearConfirmation();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      builder: (ctx, state) {
        final isLoading = state is AppAuthLoading;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: isLoading
                            ? AppColors.textMuted
                            : AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                    onPressed:
                        isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 16),
                  const AuthAppLogo(),
                  const SizedBox(height: 28),
                  const AuthHeadline(
                    title: 'Create account',
                    subtitle: 'Your details are stored securely.',
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthField(
                          controller: _nameCtrl,
                          label: 'Full name',
                          hint: 'Mikul Shah',
                          keyboardType: TextInputType.name,
                          validator: AppValidators.fullName,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          controller: _emailCtrl,
                          label: 'Email address',
                          hint: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidators.email,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          controller: _factoryCtrl,
                          label: 'Factory name',
                          hint: 'e.g. Shree Iron Works',
                          keyboardType: TextInputType.text,
                          validator: AppValidators.factoryName,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          controller: _passwordCtrl,
                          label: 'Password',
                          hint: 'Min. 8 characters',
                          obscureText: _obscurePassword,
                          validator: AppValidators.password,
                          enabled: !isLoading,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 14),
                        AuthField(
                          controller: _confirmCtrl,
                          label: 'Confirm password',
                          hint: 'Re-enter your password',
                          obscureText: _obscureConfirm,
                          validator: (_) => AppValidators.confirmPassword(
                              _passwordCtrl.text)(_confirmCtrl.text),
                          enabled: !isLoading,
                          suffix: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  AuthPrimaryButton(
                    label: 'Create Account',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),
                  const AuthOrDivider(),
                  const SizedBox(height: 20),
                  AuthGoogleButton(
                    isLoading: isLoading,
                    onPressed: () => ctx.read<AuthCubit>().signInWithGoogle(),
                  ),
                  const SizedBox(height: 32),
                  AuthBottomLink(
                    question: 'Already have an account?',
                    actionLabel: 'Sign in',
                    onTap:
                        isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBar(BuildContext ctx, String message, {required bool isError}) {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? AppColors.error : const Color(0xFF2E7D32),
          duration: Duration(seconds: isError ? 4 : 7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        ),
      );
  }
}
