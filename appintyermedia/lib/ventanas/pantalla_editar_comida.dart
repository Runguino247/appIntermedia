import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/comida.dart';
import '../db/database_helper.dart';

class PantallaEditarComida extends StatefulWidget {
  final Comida comida;

  const PantallaEditarComida({super.key, required this.comida});

  @override
  State<PantallaEditarComida> createState() => _PantallaEditarComidaState();
}

class _PantallaEditarComidaState extends State<PantallaEditarComida> {
  late TextEditingController _tituloController;
  late TextEditingController _descController;
  late TextEditingController _horaController;

  File? _nuevaImagen;

  @override
  void initState() {
    super.initState();

    _tituloController = TextEditingController(text: widget.comida.title);
    _descController = TextEditingController(text: widget.comida.descripcion);
    _horaController = TextEditingController(text: widget.comida.time);
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _nuevaImagen = File(picked.path);
      });
    }
  }

  Future<void> _guardarCambios() async {
    String? rutaImagenFinal = widget.comida.imagePath;

    if (_nuevaImagen != null) {
      final dir = await getApplicationDocumentsDirectory();
      final nombreArchivo = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final nueva = await _nuevaImagen!.copy(path.join(dir.path, nombreArchivo));

      rutaImagenFinal = nueva.path;
    }

    final comidaActualizada = Comida(
      id: widget.comida.id,
      title: _tituloController.text,
      descripcion: _descController.text,
      time: _horaController.text,
      diaSemana: widget.comida.diaSemana,
      imagePath: rutaImagenFinal,
    );

    await DatabaseHelper.instance.update(comidaActualizada);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final imagenMostrar =
        _nuevaImagen != null ? _nuevaImagen! : (widget.comida.imagePath != null ? File(widget.comida.imagePath!) : null);

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
            SizedBox(height: 20),

            // Hora
            Text("Hora", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _horaController,
              decoration: InputDecoration(hintText: "Hora (ej. 14:00)"),
            ),
            SizedBox(height: 20),

            // Imagen
            Text("Imagen", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            GestureDetector(
              onTap: _seleccionarImagen,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: imagenMostrar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(imagenMostrar, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Icon(Icons.add_photo_alternate_outlined, size: 40),
                      ),
              ),
            ),

            SizedBox(height: 40),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Guardar", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
