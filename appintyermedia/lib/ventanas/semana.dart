import 'dart:io'; // IMPORTANTE: Para poder mostrar la imagen del archivo
import 'package:flutter/material.dart';
import '../db/database_helper.dart'; // Tu base de datos
import '../models/comida.dart'; // Tu modelo (Asegúrate de que la clase Meal ahora se llame Comida)
import 'dia.dart' hide Comida; // Importamos el archivo dia.dart
import 'pantalla_recetario.dart'; // Importamos la pantalla del recetario

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final List<String> diasSemana = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
    "Domingo",
  ];

  // Función para refrescar la lista cuando volvemos de editar
  void _refrescar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Organizador de comidas")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: diasSemana.length,
              itemBuilder: (context, index) {
                final nombreDia = diasSemana[index];
                final numeroDia = index + 1;

                return FutureBuilder<List<Comida>>(
                  future: DatabaseHelper.instance.readMealsByDay(nombreDia),

                  builder: (context, snapshot) {
                    Widget widgetDerecha = Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[300],
                    );

                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final comida = snapshot.data!.first;

                      if (comida.imagePath != null) {
                        widgetDerecha = CircleAvatar(
                          radius: 20,
                          backgroundImage: FileImage(File(comida.imagePath!)),
                        );
                      } else {
                        widgetDerecha = CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.orange[100],
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.orange,
                            size: 20,
                          ),
                        );
                      }
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PantallaDetalleDia(nombreDia: nombreDia),
                            ),
                          );
                          _refrescar();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      snapshot.hasData &&
                                          snapshot.data!.isNotEmpty
                                      ? Colors.purple
                                      : Colors.purple[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    "$numeroDia",
                                    style: TextStyle(
                                      color:
                                          snapshot.hasData &&
                                              snapshot.data!.isNotEmpty
                                          ? Colors.white
                                          : Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombreDia,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (snapshot.hasData &&
                                        snapshot.data!.isNotEmpty)
                                      Text(
                                        snapshot.data!.first.title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),

                              widgetDerecha,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // BOTÓN NUEVO
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PantallaRecetario()),
                );
              },
              child: Text("Ver recetario", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
