import 'dart:io';
import 'package:flutter/material.dart';
import '../models/comida.dart';
import '../db/database_helper.dart';
import 'pantalla_editar_comida.dart';

class PantallaInfoComida extends StatelessWidget {
  final Comida comida;

  const PantallaInfoComida({super.key, required this.comida});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles del platillo"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Imagen
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: comida.imagePath != null
                    ? Image.file(File(comida.imagePath!), height: 200, fit: BoxFit.cover)
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(Icons.fastfood, size: 80, color: Colors.grey[700]),
                      ),
              ),
            ),

            SizedBox(height: 20),

            // Hora
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                comida.time,
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Título
            Text(
              comida.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            // Descripción
            Text(
              comida.descripcion.isEmpty ? "Sin descripción" : comida.descripcion,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            Spacer(),

            // Botones Editar / Eliminar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BOTÓN ELIMINAR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.red,
                  ),
                  child: Text("Eliminar"),
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Eliminar comida"),
                        content: Text("¿Estás seguro de eliminar este platillo?"),
                        actions: [
                          TextButton(
                            child: Text("No"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          TextButton(
                            child: Text("Sí"),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      await DatabaseHelper.instance.delete(comida.id!);
                      Navigator.pop(context, true); // Para refrescar lista
                    }
                  },
                ),

                // BOTÓN EDITAR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Editar"),
                  onPressed: () async {
                    final actualizado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaEditarComida(comida: comida),
                      ),
                    );

                    if (actualizado == true) {
                      Navigator.pop(context, true); // Vuelve y refresca
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
