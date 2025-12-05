import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../../../shared/database/database_helper.dart';
import '../../../shared/utils/session_manager.dart';
import '../../auth/widgets/custom_text_field.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  List<String> _planOptions = [];
  String? _selectedPlan;
  bool _isLoadingPlans = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _loadPlans() async {
    final plans = await DatabaseHelper.instance.getPlans();
    setState(() {
      _planOptions = plans;
      _isLoadingPlans = false;
    });
  }

  void _saveClient() async {
    if (_formKey.currentState!.validate()) {
      final providerId = SessionManager().loggedProviderId;
      if (providerId == null) return;

      await DatabaseHelper.instance.createClient(
        providerId: providerId,
        name: _nameController.text,
        cpf: _cpfController.text,
        phone: _phoneController.text,
        planType: _selectedPlan!,
        latitude: double.parse(_latController.text),
        longitude: double.parse(_lngController.text),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente salvo com sucesso!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cliente')),
      body: _isLoadingPlans 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController, 
                      label: 'Nome Completo', 
                      icon: Icons.person, 
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null
                    ),
                    CustomTextField(
                      controller: _cpfController, 
                      label: 'CPF', 
                      icon: Icons.badge, 
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        if (!CPFValidator.isValid(v)) return 'CPF Inválido';
                        return null;
                      }
                    ),
                    CustomTextField(
                      controller: _phoneController, 
                      label: 'Telefone', 
                      icon: Icons.phone, 
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TelefoneInputFormatter(),
                      ],
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedPlan,
                        decoration: InputDecoration(
                          labelText: 'Selecione o Plano',
                          prefixIcon: const Icon(Icons.wifi),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFF2D2D44),
                        ),
                        dropdownColor: const Color(0xFF2D2D44),
                        items: _planOptions.map((String plan) {
                          return DropdownMenuItem<String>(
                            value: plan,
                            child: Text(plan),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPlan = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Selecione um plano' : null,
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 32),
                    const Text("Localização (Obrigatório)", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _latController, 
                            label: 'Latitude', 
                            icon: Icons.location_on, 
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            validator: (v) => v!.isEmpty ? 'Obrigatório' : null
                          )
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _lngController, 
                            label: 'Longitude', 
                            icon: Icons.location_on, 
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            validator: (v) => v!.isEmpty ? 'Obrigatório' : null
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveClient,
                        child: const Text('SALVAR CLIENTE'),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}