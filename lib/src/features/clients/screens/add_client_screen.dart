import '../../../shared/utils/phone_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../../../shared/database/database_helper.dart';
import '../../../shared/utils/session_manager.dart';
import '../../auth/widgets/custom_text_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker_screen.dart';

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

  // Open map picker and fill latitude/longitude
  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(),
      ),
    );

    if (result is LatLng) {
      _latController.text = result.latitude.toString();
      _lngController.text = result.longitude.toString();
      setState(() {});
    }
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
        latitude: double.tryParse(_latController.text),
        longitude: double.tryParse(_lngController.text),
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Telefone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        PhoneInputFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        final digits = PhoneInputFormatter.extractDigits(v);
                        if (digits.length < 10 || digits.length > 11) {
                          return 'Telefone deve ter 10 ou 11 dígitos';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, top: 8.0),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPlan,
                        decoration: InputDecoration(
                          labelText: 'Plano de Internet',
                          prefixIcon: const Icon(Icons.wifi),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        items: _planOptions
                            .map((String plan) => DropdownMenuItem<String>(
                                  value: plan,
                                  child: Text(
                                    plan,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPlan = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Selecione um plano' : null,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Localização", style: TextStyle(color: Colors.grey)),
                        TextButton.icon(
                          onPressed: _openMapPicker,
                          icon: const Icon(Icons.map, color: Color(0xFF1E88E5)),
                          label: const Text(
                            "Selecionar no Mapa",
                            style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                      height: 56,
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