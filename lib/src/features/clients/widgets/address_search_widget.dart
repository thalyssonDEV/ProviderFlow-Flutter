import 'package:flutter/material.dart';
import '../../../shared/utils/input_formatters.dart';
import '../../../shared/services/geocoding_service.dart';

class AddressSearchWidget extends StatefulWidget {
  final Function(AddressResult) onAddressFound;

  const AddressSearchWidget({super.key, required this.onAddressFound});

  @override
  State<AddressSearchWidget> createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends State<AddressSearchWidget> {
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  Future<void> _searchByCep() async {
    if (_cepController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final result = await GeocodingService.searchByCep(_cepController.text);
    setState(() => _isLoading = false);

    if (result != null) {
      widget.onAddressFound(result);
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

  Future<void> _searchByAddress() async {
    if (_addressController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final result = await GeocodingService.searchByAddress(_addressController.text);
    setState(() => _isLoading = false);

    if (result != null && result.location != null) {
      widget.onAddressFound(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização encontrada!'), backgroundColor: Colors.green),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço não encontrado'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              onPressed: _isLoading ? null : _searchByCep,
              child: _isLoading
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
        const Text('OU', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço Completo',
                  hintText: 'Rua, Bairro, Cidade',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchByAddress,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
            ),
          ],
        ),
      ],
    );
  }
}
