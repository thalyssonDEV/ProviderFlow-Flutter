import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maps_disp_moveis_project/src/shared/database/database_helper.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _register() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).clearSnackBars();
      
      int result = await DatabaseHelper.instance.createProvider(
        _userController.text, 
        _passwordController.text
      );

      if (!mounted) return;

      if (result != -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso!'),
            backgroundColor: Color(0xFF4E9F3D),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este usuário já existe.'),
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
      appBar: AppBar(
        title: const Text('Novo Cadastro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crie sua conta',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Preencha os dados abaixo para começar.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _userController,
                label: 'Nome de Usuário',
                icon: Icons.person_outline,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')), 
                  FilteringTextInputFormatter.deny(
                    RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])')
                  ),
                ],
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              CustomTextField(
                controller: _passwordController,
                label: 'Senha',
                icon: Icons.lock_outline,
                isSecret: true,
                inputFormatters: [
                   FilteringTextInputFormatter.deny(RegExp(r'\s')),
                   FilteringTextInputFormatter.deny(
                    RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])')
                   ),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Obrigatório';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirmar Senha',
                icon: Icons.lock_reset,
                isSecret: true,
                inputFormatters: [
                   FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                validator: (v) {
                  if (v != _passwordController.text) return 'Senhas não conferem';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _register,
                  child: const Text('CRIAR CONTA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}