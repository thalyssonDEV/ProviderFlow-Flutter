import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/utils/input_formatters.dart';
import '../../../shared/utils/validators.dart';
import '../controllers/client_controller.dart';
import '../models/client_model.dart';
import 'location_picker_screen.dart';

class EditClientScreen extends StatefulWidget {
  final ClientModel client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cpfController;
  late final TextEditingController _phoneController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  String? _selectedPlan;
  LatLng? _selectedLocation;

  final _controller = ClientController();
  List<String> _planOptions = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client.name);
    _cpfController = TextEditingController(text: widget.client.cpf);
    _phoneController = TextEditingController(text: widget.client.phone);
    _latController = TextEditingController(text: widget.client.latitude?.toString() ?? '');
    _lngController = TextEditingController(text: widget.client.longitude?.toString() ?? '');
    _selectedPlan = widget.client.planType;
    
    if (widget.client.latitude != null && widget.client.longitude != null) {
      _selectedLocation = LatLng(widget.client.latitude!, widget.client.longitude!);
    }
    
    _loadPlans();
  }

  void _loadPlans() async {
    final plans = await _controller.getPlans();
    setState(() {
      _planOptions = plans;
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
      final updated = ClientModel(
        id: widget.client.id,
        providerId: widget.client.providerId,
        name: _nameController.text,
        cpf: _cpfController.text,
        phone: _phoneController.text,
        planType: _selectedPlan ?? widget.client.planType,
        latitude: double.tryParse(_latController.text),
        longitude: double.tryParse(_lngController.text),
      );

      final success = await _controller.updateClient(updated);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente atualizado!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    }
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
              DropdownButtonFormField<String>(
                value: _selectedPlan,
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
                label: Text(_selectedLocation == null ? 'Selecionar no Mapa' : 'Alterar Localização'),
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
                  label: const Text('Salvar Alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
