import 'dart:io'; // IMPORTANTE: Para poder mostrar la imagen del archivo
import 'package:flutter/material.dart';
import '../db/database_helper.dart'; // Tu base de datos
import '../models/comida.dart';        // Tu modelo (Asegúrate de que la clase Meal ahora se llame Comida)
import 'dia.dart' hide Comida;  // Importamos el archivo dia.dart

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final List<String> diasSemana = [
    "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"
  ];

  // Función para refrescar la lista cuando volvemos de editar
  void _refrescar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Organizador de comidas")),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: diasSemana.length,
        itemBuilder: (context, index) {
          final nombreDia = diasSemana[index];
          final numeroDia = index + 1;

          // --- AQUÍ EMPIEZA LA MAGIA ---
          // Envolvemos la tarjeta en un FutureBuilder para consultar la BD por cada día
          return FutureBuilder<List<Comida>>(
            // Preguntamos: "¿Qué hay de comer este día?"
            future: DatabaseHelper.instance.readMealsByDay(nombreDia),

            builder: (context, snapshot) {
              // 1. Preparamos el widget que irá a la derecha (por defecto una flecha gris)
              Widget widgetDerecha = Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]);

              // 2. Si la base de datos responde y tiene datos...
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final comida = snapshot.data!.first; // Tomamos la primera comida del día

                // ¿Tiene imagen guardada?
                if (comida.imagePath != null) {
                  widgetDerecha = CircleAvatar(
                    radius: 20, // Tamaño del círculo
                    backgroundImage: FileImage(File(comida.imagePath!)), // Cargamos la foto
                  );
                } else {
                  // Si hay comida pero no tiene foto, mostramos un icono de plato
                  widgetDerecha = CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.orange[100],
                    child: Icon(Icons.restaurant, color: Colors.orange, size: 20),
                  );
                }
              }

              // 3. Dibujamos la Tarjeta
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () async {
                    // Usamos await para esperar a que el usuario vuelva
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        // CORRECCIÓN AQUÍ: Usamos PantallaDetalleDia en lugar de Dia
                        // Si tu clase en dia.dart se llama "Dia", cambia esto a Dia.
                        // Si se llama "PantallaDetalleDia", déjalo así.
                        builder: (context) => PantallaDetalleDia(nombreDia: nombreDia),
                      ),
                    );
                    // Cuando vuelve, refrescamos la pantalla para actualizar las fotos nuevas
                    _refrescar();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Número del día
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: snapshot.hasData && snapshot.data!.isNotEmpty
                                ? Colors.purple // Si hay comida, círculo oscuro
                                : Colors.purple[50], // Si no, clarito
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "$numeroDia",
                              style: TextStyle(
                                  color: snapshot.hasData && snapshot.data!.isNotEmpty
                                      ? Colors.white
                                      : Colors.purple,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),

                        // Nombre del día
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombreDia, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                              // Opcional: Mostrar el nombre del plato debajo del día
                              if (snapshot.hasData && snapshot.data!.isNotEmpty)
                                Text(
                                  snapshot.data!.first.title, // "Arroz a la valenciana"
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                            ],
                          ),
                        ),

                        // Aquí ponemos la foto o el icono que calculamos arriba
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
    );
  }
}