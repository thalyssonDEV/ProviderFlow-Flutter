import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maps_disp_moveis_project/src/shared/database/database_helper.dart';
import 'package:maps_disp_moveis_project/src/shared/utils/app_routes.dart';
import 'package:maps_disp_moveis_project/src/shared/utils/session_manager.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).clearSnackBars();

      var providerData = await DatabaseHelper.instance.getProvider(
        _userController.text,
        _passwordController.text
      );

      if (!mounted) return;

      if (providerData != null) {
        SessionManager().login(
          providerData['id'] as int, 
          providerData['username'] as String
        );

        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Bem-vindo, ${providerData['username']}!'),
             backgroundColor: const Color(0xFF4E9F3D),
             behavior: SnackBarBehavior.floating,
             duration: const Duration(seconds: 2),
           ),
        );

        Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciais inválidas.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
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
              child: Column(
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
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Bem-vindo de volta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Acesse seu painel de gestão',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    controller: _userController,
                    label: 'Usuário',
                    icon: Icons.person_outline,
                    inputFormatters: [
                       FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    validator: (v) => v!.isEmpty ? 'Informe seu usuário' : null,
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    isSecret: true,
                    inputFormatters: [
                       FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    validator: (v) => v!.isEmpty ? 'Informe sua senha' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('ENTRAR'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Não possui conta?", style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                        child: const Text('Cadastre-se', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
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