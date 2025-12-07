import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/utils/session_manager.dart';
import '../../../shared/utils/input_formatters.dart';
import '../../../shared/utils/validators.dart';
import '../controllers/client_controller.dart';
import '../models/client_model.dart';
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
  String? _selectedPlan;
  LatLng? _selectedLocation;

  final _controller = ClientController();
  List<String> _planOptions = [];
  bool _isLoadingPlans = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _loadPlans() async {
    final plans = await _controller.getPlans();
    setState(() {
      _planOptions = plans;
      _isLoadingPlans = false;
    });
  }

  Future<void> _pickLocation() async {
    final LatLng? picked = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (picked != null) {
      setState(() {
        _selectedLocation = picked;
        _latController.text = picked.latitude.toStringAsFixed(6);
        _lngController.text = picked.longitude.toStringAsFixed(6);
      });
    }
  }

  void _saveClient() async {
    if (_formKey.currentState!.validate()) {
      final providerId = SessionManager().loggedProviderId;
      if (providerId == null) return;

      final newClient = ClientModel(
        providerId: providerId,
        name: _nameController.text,
        cpf: _cpfController.text,
        phone: _phoneController.text,
        planType: _selectedPlan!,
        latitude: double.tryParse(_latController.text),
        longitude: double.tryParse(_lngController.text),
      );

      final success = await _controller.addClient(newClient);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente salvo com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Ex: João Silva',
                ),
                inputFormatters: [NameInputFormatter()],
                textCapitalization: TextCapitalization.words,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  prefixIcon: Icon(Icons.badge),
                  hintText: '000.000.000-00',
                ),
                inputFormatters: [CpfInputFormatter()],
                keyboardType: TextInputType.number,
                validator: Validators.validateCpf,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '(00) 00000-0000',
                ),
                inputFormatters: [PhoneInputFormatter()],
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 12),
              _isLoadingPlans
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedPlan,
                      decoration: const InputDecoration(
                        labelText: 'Plano',
                        prefixIcon: Icon(Icons.wifi),
                      ),
                      items: _planOptions
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPlan = v),
                      validator: (v) => v == null ? 'Selecione um plano' : null,
                    ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Localização',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.map),
                label: Text(_selectedLocation == null ? 'Selecionar no Mapa' : 'Local Selecionado'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saveClient,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Cliente'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
