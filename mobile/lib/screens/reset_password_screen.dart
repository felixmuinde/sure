import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/sure_colors.dart';
import '../theme/sure_spacing.dart';
import '../widgets/password_reset_error_message.dart';
import '../widgets/sure_button.dart';
import '../widgets/sure_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.token,
    this.authService,
  });

  final String token;
  final AuthService? authService;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  late final AuthService _authService = widget.authService ?? AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.resetPassword(
      token: widget.token,
      password: _passwordController.text,
      passwordConfirmation: _confirmationController.text,
    );
    if (!mounted) return;

    if (result['success'] == true) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) await authProvider.logout();
      if (!mounted) return;

      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.resetPasswordSuccess)),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _isLoading = false;
      _errorMessage = _localizedResetError(result['code'] as String?);
    });
  }

  // Map the service's semantic failure category to a localized message, rather
  // than surfacing the server's English prose (which ignores the app locale).
  String _localizedResetError(String? code) {
    final l = AppLocalizations.of(context);
    switch (code) {
      case 'disabled':
        return l.resetPasswordDisabledError;
      case 'network':
        return l.resetPasswordNetworkError;
      default:
        return l.resetPasswordGenericError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = SureColors.of(context).palette;

    return Scaffold(
      appBar: AppBar(title: Text(l.resetPasswordTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SureSpacing.xxxl),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: SureSpacing.xl),
                  Text(
                    l.resetPasswordInstructions,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: palette.textSecondary,
                        ),
                  ),
                  const SizedBox(height: SureSpacing.huge),
                  if (_errorMessage != null) ...[
                    PasswordResetErrorMessage(message: _errorMessage!),
                    const SizedBox(height: SureSpacing.xl),
                  ],
                  SureTextField(
                    controller: _passwordController,
                    label: l.resetPasswordNewPasswordLabel,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l.resetPasswordPasswordRequired;
                      }
                      if (value.length < 8) {
                        return l.resetPasswordPasswordMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: SureSpacing.xl),
                  SureTextField(
                    controller: _confirmationController,
                    label: l.resetPasswordConfirmationLabel,
                    obscureText: _obscureConfirmation,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmation
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmation = !_obscureConfirmation,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l.resetPasswordConfirmationRequired;
                      }
                      if (value != _passwordController.text) {
                        return l.resetPasswordPasswordsDoNotMatch;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: SureSpacing.xxxl),
                  SureButton(
                    label: l.resetPasswordUpdateButton,
                    size: SureButtonSize.lg,
                    fullWidth: true,
                    loading: _isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
