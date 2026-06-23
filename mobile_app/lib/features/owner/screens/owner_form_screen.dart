import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/owner/screens/owner_home_screen.dart';

class OwnerFormScreen extends StatefulWidget {
  const OwnerFormScreen({super.key});

  @override
  State<OwnerFormScreen> createState() => _OwnerFormScreenState();
}

class _OwnerFormScreenState extends State<OwnerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _nombre = '';
  String _direccion = '';
  String _latitud = '';
  String _longitud = '';
  String _precioBase = '';
  String _superficie = 'grass'; // valor por defecto

  bool _isLoading = false;

  // Opciones de superficie — coinciden con SURFACE_CHOICES del modelo
  final List<Map<String, String>> _superficies = [
    {'value': 'grass', 'label': 'Pasto Natural'},
    {'value': 'turf', 'label': 'Pasto Sintético'},
    {'value': 'concrete', 'label': 'Cemento'},
    {'value': 'dirt', 'label': 'Tierra'},
  ];

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token!;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/facilities/create/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nombre,
          'address': _direccion,
          'latitude': double.parse(_latitud),
          'longitude': double.parse(_longitud),
          'base_price': _precioBase,
          'surface_type': _superficie,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final facilityId = data['id'];

        // Actualizamos el facilityId en el AuthProvider para que quede disponible
        authProvider.user = AuthUser(
          id: authProvider.user!.id,
          name: authProvider.user!.name,
          lastname: authProvider.user!.lastname,
          email: authProvider.user!.email,
          role: authProvider.user!.role,
          facilityId: facilityId,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OwnerHomeScreen(
              token: token,
              facilityId: facilityId,
            ),
          ),
        );
      } else {
        final data = json.decode(response.body);
        _mostrarError(data['message']?.toString() ?? 'Error al crear el complejo');
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrá tu Complejo'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Completá los datos de tu complejo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Podés editarlos más adelante desde tu perfil.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // ── DATOS DEL COMPLEJO ──
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.sports_soccer, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Datos del Complejo',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                      const Divider(),
                      const SizedBox(height: 8),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Complejo',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Campo obligatorio' : null,
                        onSaved: (v) => _nombre = v!.trim(),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Campo obligatorio' : null,
                        onSaved: (v) => _direccion = v!.trim(),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Precio base por hora (\$)',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v!.trim().isEmpty) return 'Campo obligatorio';
                          if (double.tryParse(v) == null) return 'Ingresá un número válido';
                          return null;
                        },
                        onSaved: (v) => _precioBase = v!.trim(),
                      ),
                      const SizedBox(height: 12),

                      // Selector de superficie
                      DropdownButtonFormField<String>(
                        value: _superficie,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de superficie',
                          prefixIcon: Icon(Icons.grass),
                        ),
                        items: _superficies
                            .map((s) => DropdownMenuItem(
                                  value: s['value'],
                                  child: Text(s['label']!),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _superficie = v!),
                        onSaved: (v) => _superficie = v!,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── UBICACIÓN ──
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.map, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Ubicación GPS',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                      const Divider(),
                      const Text(
                        'Podés obtener las coordenadas buscando tu dirección en Google Maps y copiando los números.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 12),

                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Latitud',
                              hintText: '-24.7821',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            validator: (v) {
                              if (v!.trim().isEmpty) return 'Obligatorio';
                              if (double.tryParse(v) == null) return 'Número inválido';
                              return null;
                            },
                            onSaved: (v) => _latitud = v!.trim(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Longitud',
                              hintText: '-65.4232',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            validator: (v) {
                              if (v!.trim().isEmpty) return 'Obligatorio';
                              if (double.tryParse(v) == null) return 'Número inválido';
                              return null;
                            },
                            onSaved: (v) => _longitud = v!.trim(),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : _enviarFormulario,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Registrar Complejo',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
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