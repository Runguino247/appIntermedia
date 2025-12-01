import 'dart:io';
import 'package:flutter/material.dart';

import '../models/comida.dart';
import '../db/database_helper.dart';

class PantallaEditarReceta extends StatefulWidget {
  final Comida comida;

  const PantallaEditarReceta({super.key, required this.comida});

  @override
  State<PantallaEditarReceta> createState() => _PantallaEditarComidaState();
}

class _PantallaEditarComidaState extends State<PantallaEditarReceta> {
  late TextEditingController _tituloController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.comida.title);
    _descController = TextEditingController(text: widget.comida.descripcion);
  }

  Future<void> _guardarCambios() async {
    final comidaActualizada = Comida(
      id: widget.comida.id,
      title: _tituloController.text,
      descripcion: _descController.text,
      time: widget.comida.time,
      diaSemana: widget.comida.diaSemana,
      imagePath: widget.comida.imagePath,
    );

    await DatabaseHelper.instance.update(comidaActualizada);
    Navigator.pop(context, true);
  }

  Future<void> _eliminarReceta() async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar receta"),
        content: Text("¿Está seguro de eliminar esta receta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancelar
            child: Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirmar
            child: Text("Sí", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != null && confirm) {
      // Eliminar de la base de datos
      await DatabaseHelper.instance.delete(widget.comida.id!);

      // Si la receta tiene imagen, eliminar el archivo
      if (widget.comida.imagePath != null && widget.comida.imagePath!.isNotEmpty) {
        final file = File(widget.comida.imagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      Navigator.pop(context, true); // Regresar con actualización
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar detalles"),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre
            Text("Nombre", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(hintText: "Nombre del platillo"),
            ),
            SizedBox(height: 20),

            // Descripción
            Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(hintText: "Descripción del platillo"),
            ),
            SizedBox(height: 30),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Guardar", style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 15),

            // Botón eliminar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _eliminarReceta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Eliminar esta receta", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
