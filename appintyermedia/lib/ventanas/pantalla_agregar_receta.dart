import 'package:flutter/material.dart';

import '../models/comida.dart';
import '../db/database_helper.dart';

class PantallaAgregarReceta extends StatefulWidget {
  const PantallaAgregarReceta({super.key});

  @override
  State<PantallaAgregarReceta> createState() => _PantallaAgregarRecetaState();
}

class _PantallaAgregarRecetaState extends State<PantallaAgregarReceta> {
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();

  Future<void> _guardarReceta() async {
    if (_tituloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El nombre no puede estar vacío")),
      );
      return;
    }

    final nuevaReceta = Comida(
      title: _tituloController.text,
      descripcion: _descController.text,
      time: "00:00",        // campo requerido pero no usado
      diaSemana: "Receta",   // categoría genérica
      imagePath: null,       // sin imágenes
    );

    await DatabaseHelper.instance.create(nuevaReceta);

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar receta"),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _etiqueta("Nombre"),
            TextField(
              controller: _tituloController,
              decoration: _decoracionInput("Nombre del platillo"),
            ),
            SizedBox(height: 20),

            _etiqueta("Descripción"),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: _decoracionInput("Descripción del platillo"),
            ),
            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _guardarReceta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
                ),
                child: Text(
                  "Guardar",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _etiqueta(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  InputDecoration _decoracionInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }

  
}
