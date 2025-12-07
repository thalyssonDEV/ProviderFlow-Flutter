import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/utils/app_routes.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = AuthController();

  void _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).clearSnackBars();

      final success = await _authController.login(
        _userController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bem-vindo!'),
            backgroundColor: Color(0xFF4E9F3D),
            behavior: SnackBarBehavior.floating,
          ),
        );

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authController.errorMessage ?? 'Erro desconhecido'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: AnimatedBuilder(
                animation: _authController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.hub,
                          size: 50,
                          color: const Color(0xFF1E88E5),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Bem-vindo de volta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 48),
                      CustomTextField(
                        controller: _userController,
                        label: 'Usuário',
                        icon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Informe seu usuário' : null,
                      ),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        icon: Icons.lock_outline,
                        isSecret: true,
                        validator: (v) => v!.isEmpty ? 'Informe sua senha' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 56,
                        child: _authController.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _handleLogin,
                                child: const Text('ENTRAR'),
                              ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Não possui conta?",
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            ),
                            child: const Text(
                              'Cadastre-se',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
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
