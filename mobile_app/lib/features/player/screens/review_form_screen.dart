import 'package:flutter/material.dart';

import 'home_screen.dart';

class ReviewFormScreen extends StatefulWidget {
  final CanchaFeed cancha; 

  const ReviewFormScreen({super.key, required this.cancha});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _comentarioController = TextEditingController();
  int rating = 5; 

  Future<void> _guardarResena() async {
    if (!_formKey.currentState!.validate()) return;

    
    print('Reseña guardada para: ${widget.cancha.nombre}');
    print('Estrellas: $rating');
    print('Comentario: ${_comentarioController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Reseña enviada con éxito!'), backgroundColor: Colors.green),
    );

    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dejar Reseña'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info de la cancha
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sports_soccer, color: Colors.green, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.cancha.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(widget.cancha.ubicacion, style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Estrellitas
              const Text('¿Qué tal estuvo la cancha?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Slider(
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: Colors.amber,
                label: rating.toString(),
                value: rating.toDouble(),
                onChanged: (value) {
                  setState(() => rating = value.toInt());
                },
              ),
              Center(child: Text('$rating ⭐', style: const TextStyle(fontSize: 24, color: Colors.amber))),
              
              const SizedBox(height: 30),

              // Comentario
              TextFormField(
                controller: _comentarioController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Escribí tu comentario',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresá un comentario';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 40),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _guardarResena,
                  child: const Text('ENVIAR RESEÑA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}