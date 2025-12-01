import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/comida.dart';
import 'pantalla_agregar_receta.dart'; 
import 'editar_receta.dart'; // PantallaEditarReceta

class PantallaRecetario extends StatefulWidget {
  const PantallaRecetario({super.key});

  @override
  State<PantallaRecetario> createState() => _PantallaRecetarioState();
}

class _PantallaRecetarioState extends State<PantallaRecetario> {

  void _recargar() {
    setState(() {});
  }

  // Recorta descripción a 50 chars + "..."
  String _recorte(String texto) {
    if (texto.length <= 50) return texto;
    return texto.substring(0, 50) + "...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recetario"),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: FutureBuilder<List<Comida>>(
        future: DatabaseHelper.instance.readAllMeals(), // <--- lee TODAS las recetas
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final recetas = snapshot.data!;

          if (recetas.isEmpty) {
            return Center(
              child: Text("No hay recetas aún."),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16),

            children: [

              // CUADRO SUAVE (como la imagen)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF8EEFF), // morado MUY claro
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recetas.map((receta) {
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaEditarReceta(comida: receta),
                          ),
                        );

                        if (result == true) _recargar();
                      },

                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receta.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              _recorte(receta.descripcion),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),

                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 30),

              // BOTÓN AGREGAR RECETA
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaAgregarReceta(),
                      ),
                    );

                    if (ok == true) _recargar();
                  },

                  icon: Icon(Icons.add_circle_outline, color: Colors.purple),
                  label: Text(
                    "Agregar comida",
                    style: TextStyle(color: Colors.black87),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[100],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
