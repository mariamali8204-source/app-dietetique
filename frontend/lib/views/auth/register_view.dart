import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_view_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() {
    return _RegisterViewState();
  }
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.register(
      nom: _nomController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);

      return;
    }

    final message =
        authViewModel.errorMessage ?? 'Impossible de créer le compte.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_outlined,
                          size: 52,
                          color: Theme.of(context).colorScheme.primary,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Créer votre compte',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Inscrivez-vous pour accéder à votre espace diététicien.',
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        TextFormField(
                          controller: _nomController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nom complet',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez saisir votre nom.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Adresse e-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Veuillez saisir votre adresse e-mail.';
                            }

                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Veuillez saisir une adresse e-mail valide.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un mot de passe.';
                            }

                            if (value.length < 8) {
                              return 'Le mot de passe doit contenir au moins 8 caractères.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _confirmationController,
                          obscureText: _obscureConfirmation,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            _register();
                          },
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmation = !_obscureConfirmation;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmation
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer votre mot de passe.';
                            }

                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        Consumer<AuthViewModel>(
                          builder: (context, authViewModel, child) {
                            return FilledButton(
                              onPressed: authViewModel.isLoading
                                  ? null
                                  : _register,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: authViewModel.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Créer le compte'),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('J’ai déjà un compte'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
