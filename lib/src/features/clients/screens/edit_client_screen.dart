import '../../../shared/utils/phone_input_formatter.dart';
import 'package:flutter/material.dart';
import '../../../shared/database/database_helper.dart';

class EditClientScreen extends StatefulWidget {
  final Map<String, dynamic> client;
  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cpfController;
  late TextEditingController _phoneController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  String? _selectedPlan;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    _nameController = TextEditingController(text: c['name'] ?? '');
    _cpfController = TextEditingController(text: c['cpf'] ?? '');
    _phoneController = TextEditingController(text: c['phone'] ?? '');
    _latController = TextEditingController(text: (c['latitude']?.toString() ?? ''));
    _lngController = TextEditingController(text: (c['longitude']?.toString() ?? ''));
    _selectedPlan = c['plan_type'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.client['id'] as int;
    await DatabaseHelper.instance.updateClient(
      id: id,
      name: _nameController.text.trim(),
      cpf: _cpfController.text.trim(),
      phone: _phoneController.text.trim(),
      planType: _selectedPlan ?? widget.client['plan_type'] as String,
      latitude: double.tryParse(_latController.text.trim()),
      longitude: double.tryParse(_lngController.text.trim()),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                inputFormatters: [PhoneInputFormatter()],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Obrigatório';
                  final digits = PhoneInputFormatter.extractDigits(v);
                  if (digits.length < 10 || digits.length > 11) {
                    return 'Telefone deve ter 10 ou 11 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedPlan,
                decoration: const InputDecoration(labelText: 'Plano de Internet'),
                items: <String>['50 Mega','100 Mega','300 Mega','500 Mega','1 Giga']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPlan = v),
                validator: (v) => v == null ? 'Selecione um plano' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Salvar Alterações'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
