import 'dart:io'; // Para manejar archivos (File)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Para abrir galería
import 'package:path_provider/path_provider.dart'; // Para encontrar la carpeta segura
import 'package:path/path.dart' as path; // Para manipular rutas

// Importa tus archivos locales
import '../models/comida.dart';
import '../db/database_helper.dart';

class PantallaAgregarComida extends StatefulWidget {
  final String diaSeleccionado; // Recibimos "Lunes", "Martes", etc.

  const PantallaAgregarComida({super.key, required this.diaSeleccionado});

  @override
  State<PantallaAgregarComida> createState() => _PantallaAgregarComidaState();
}

class _PantallaAgregarComidaState extends State<PantallaAgregarComida> {
  // Controladores de Texto
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  final _horaController = TextEditingController();

  // Variable para la imagen temporal
  File? _imagenSeleccionada;

  // --- LÓGICA 1: SELECCIONAR IMAGEN ---
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    // Cambia a ImageSource.camera si prefieres usar la cámara
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  // --- LÓGICA 2: GUARDAR EN BASE DE DATOS ---
  Future<void> _guardarComida() async {
    // 1. Validaciones básicas
    if (_tituloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, escribe el nombre del platillo')),
      );
      return;
    }

    String? rutaImagenFinal;

    // 2. Si hay imagen, la guardamos permanentemente
    if (_imagenSeleccionada != null) {
      // Obtenemos la carpeta de documentos de la app (segura y privada)
      final directory = await getApplicationDocumentsDirectory();

      // Creamos un nombre único (ej: "1698234234.jpg")
      final nombreArchivo = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Copiamos la imagen de la caché a nuestra carpeta
      final imagenGuardada = await _imagenSeleccionada!.copy(path.join(directory.path, nombreArchivo));

      // Guardamos esa ruta
      rutaImagenFinal = imagenGuardada.path;
    }

    // 3. Creamos el objeto Modelo
    final nuevaComida = Comida(
      title: _tituloController.text,
      descripcion: _descController.text,
      time: _horaController.text.isEmpty ? "00:00" : _horaController.text,
      diaSemana: widget.diaSeleccionado, // Usamos el día que nos pasaron
      imagePath: rutaImagenFinal, // La ruta permanente (o null)
    );

    // 4. Insertamos en SQL
    await DatabaseHelper.instance.create(nuevaComida);

    // 5. Cerramos la pantalla y devolvemos "true" para avisar que refresquen
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    // Limpiamos controladores para liberar memoria
    _tituloController.dispose();
    _descController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  // --- LÓGICA 3: DISEÑO VISUAL (UI) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar detalles"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView( // Permite scroll si el teclado tapa la pantalla
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CAMPO: NOMBRE
            _crearEtiqueta("Nombre"),
            TextField(
              controller: _tituloController,
              decoration: _inputDecoracion("Agregar nombre del platillo"),
            ),
            SizedBox(height: 20),

            // CAMPO: DESCRIPCIÓN
            _crearEtiqueta("Descripción"),
            TextField(
              controller: _descController,
              maxLines: 3, // Permite varias líneas
              decoration: _inputDecoracion("Agregar descripción"),
            ),
            SizedBox(height: 20),

            // CAMPO: HORA
            _crearEtiqueta("Hora"),
            TextField(
              controller: _horaController,
              keyboardType: TextInputType.datetime,
              decoration: _inputDecoracion("Agregar hora (ej. 14:00)"),
            ),
            SizedBox(height: 20),

            // CAMPO: IMAGEN
            _crearEtiqueta("Imagen"),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _seleccionarImagen,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _imagenSeleccionada != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    _imagenSeleccionada!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Agregar imagen desde dispositivo", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            // BOTÓN GUARDAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _guardarComida,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Guardar",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para estilos de texto
  Widget _crearEtiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        texto,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // Estilo común para los inputs
  InputDecoration _inputDecoracion(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
    );
  }
}