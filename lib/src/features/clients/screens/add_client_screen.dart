import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/utils/session_manager.dart';
import '../../../shared/utils/input_formatters.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/services/geocoding_service.dart';
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
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  String? _selectedPlan;
  LatLng? _selectedLocation;
  bool _isSearchingAddress = false;

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

  Future<void> _searchByCep() async {
    if (_cepController.text.isEmpty) return;

    setState(() => _isSearchingAddress = true);
    final result = await GeocodingService.searchByCep(_cepController.text);
    setState(() => _isSearchingAddress = false);

    if (result != null) {
      setState(() {
        _streetController.text = result.street;
        _neighborhoodController.text = result.neighborhood;
        _cityController.text = result.city;
        _stateController.text = result.state;
        
        if (result.location != null) {
          _selectedLocation = result.location;
        }
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço encontrado!'), backgroundColor: Colors.green),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP não encontrado'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _searchCoordinatesByAddress() async {
    if (_cityController.text.isEmpty || _stateController.text.isEmpty) return;
    
    final fullAddress = '${_streetController.text}, ${_numberController.text}, ${_cityController.text} - ${_stateController.text}';
    final result = await GeocodingService.searchByAddress(fullAddress);
    
    if (!mounted) return;
    
    if (result != null && result.location != null) {
      setState(() {
        _selectedLocation = result.location;
      });
    }
  }

  Future<void> _pickLocation() async {
    // Se já tem endereço, busca coordenadas antes de abrir o mapa
    if (_selectedLocation == null && _streetController.text.isNotEmpty) {
      final fullAddress = '${_streetController.text}, ${_numberController.text}, ${_cityController.text} - ${_stateController.text}';
      final result = await GeocodingService.searchByAddress(fullAddress);
      if (result != null && result.location != null) {
        _selectedLocation = result.location;
      }
    }

    if (!mounted) return;
    
    final LatLng? picked = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _selectedLocation,
          addressPreview: _streetController.text.isNotEmpty
              ? '${_streetController.text}, ${_numberController.text}\n${_neighborhoodController.text}, ${_cityController.text} - ${_stateController.text}'
              : null,
        ),
      ),
    );

    if (!mounted) return;
    
    if (picked != null) {
      setState(() {
        _selectedLocation = picked;
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
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
        street: _streetController.text.isNotEmpty ? _streetController.text : null,
        number: _numberController.text.isNotEmpty ? _numberController.text : null,
        neighborhood: _neighborhoodController.text.isNotEmpty ? _neighborhoodController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        state: _stateController.text.isNotEmpty ? _stateController.text : null,
        zipCode: _cepController.text.isNotEmpty ? _cepController.text : null,
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
              const Text(
                'Dados do Cliente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Endereço',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        hintText: '00000-000',
                        prefixIcon: Icon(Icons.location_searching),
                      ),
                      inputFormatters: [CepInputFormatter()],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSearchingAddress ? null : _searchByCep,
                    child: _isSearchingAddress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Rua/Logradouro',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(
                        labelText: 'Bairro',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      onChanged: (value) {
                        if (value.length >= 3) _searchCoordinatesByAddress();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'UF',
                        hintText: 'PI',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 2,
                      onChanged: (value) {
                        if (value.length == 2) _searchCoordinatesByAddress();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Localização no Mapa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.map),
                label: Text(_selectedLocation == null ? 'Selecionar/Confirmar no Mapa' : 'Localização Confirmada ✓'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
