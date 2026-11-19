import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../widgets/animated_button.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: 'admin123');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    ref.read(authServiceProvider).createAdminIfMissing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OneSaveColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              OneSaveColors.primary.withOpacity(0.1),
              OneSaveColors.secondary.withOpacity(0.05),
              OneSaveColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and Title
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: OneSaveColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: OneSaveColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.save_alt,
                              size: 64,
                              color: OneSaveColors.onPrimary,
                            )
                                .animate()
                                .fadeIn(duration: 800.ms)
                                .scale(
                                  begin: const Offset(0.5, 0.5),
                                  end: const Offset(1.0, 1.0),
                                  duration: 800.ms,
                                  curve: Curves.elasticOut,
                                ),
                            const SizedBox(height: 16),
                            Text(
                              'OneSave',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: OneSaveColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 800.ms, delay: 200.ms)
                                .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 200.ms),
                            const SizedBox(height: 8),
                            Text(
                              'CNF Côte d\'Ivoire',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: OneSaveColors.onPrimary.withOpacity(0.8),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 800.ms, delay: 400.ms)
                                .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 400.ms),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Login Form
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: OneSaveColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: OneSaveColors.primary.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                'Connexion',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 600.ms)
                                  .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 600.ms),
                              
                              const SizedBox(height: 32),
                              
                              // Username Field
                              TextFormField(
                                controller: _userCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Utilisateur',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: OneSaveColors.primary,
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 800.ms)
                                  .slideX(begin: -0.3, end: 0, duration: 600.ms, delay: 800.ms),
                              
                              const SizedBox(height: 20),
                              
                              // Password Field
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: OneSaveColors.primary,
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 1000.ms)
                                  .slideX(begin: -0.3, end: 0, duration: 600.ms, delay: 1000.ms),
                              
                              const SizedBox(height: 32),
                              
                              // Login Button
                              AnimatedButton(
                                text: 'Se connecter',
                                icon: Icons.login,
                                isLoading: _loading,
                                isGlassmorphic: true,
                                onPressed: _loading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!.validate()) return;
                                        setState(() => _loading = true);
                                        final auth = ref.read(authServiceProvider);
                                        final user = await auth.authenticate(_userCtrl.text.trim(), _passCtrl.text);
                                        setState(() => _loading = false);
                                        if (!mounted) return;
                                        if (user != null) {
                                          Navigator.of(context).pushReplacementNamed('/home');
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Identifiants invalides'),
                                              backgroundColor: OneSaveColors.error,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 1200.ms)
                                  .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 1200.ms),
                              
                              const SizedBox(height: 24),
                              
                              // Demo credentials info
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: OneSaveColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: OneSaveColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: OneSaveColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Identifiants de démonstration : admin / admin123',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: OneSaveColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 1400.ms)
                                  .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 1400.ms),
                            ],
                          ),
                        ),
                      ),
                    ],
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
