import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validators.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import 'auth_widgets.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  void _goToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AppAuthState>(
      listenWhen: (_, s) =>
          s is AppAuthError || s is AppAuthConfirmationRequired,
      listener: (ctx, state) {
        if (state is AppAuthError) {
          _showBar(ctx, state.message, isError: true);
          ctx.read<AuthCubit>().clearError();
        }
        if (state is AppAuthConfirmationRequired) {
          _showBar(
            ctx,
            'Check your inbox at ${state.email} to confirm, then sign in.',
            isError: false,
          );
          ctx.read<AuthCubit>().clearConfirmation();
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
                  const SizedBox(height: 36),
                  const AuthAppLogo(),
                  const SizedBox(height: 36),
                  const AuthHeadline(
                    title: 'Welcome back',
                    subtitle: 'Sign in to your account.',
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                          controller: _passwordCtrl,
                          label: 'Password',
                          hint: '••••••••',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  AuthPrimaryButton(
                    label: 'Sign In',
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
                  const SizedBox(height: 36),
                  AuthBottomLink(
                    question: "Don't have an account?",
                    actionLabel: 'Create one',
                    onTap: isLoading ? null : _goToSignUp,
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
