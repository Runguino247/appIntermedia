import 'dart:io'; // Para manejar las fotos
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/comida.dart';
import 'pantalla_agregar_comida.dart'; // Tu formulario
// import 'pantalla_info_comida.dart'; // (Opcional) La pantalla de ver detalle/borrar

class PantallaDetalleDia extends StatefulWidget {
  final String nombreDia; // "Lunes", "Martes"...

  const PantallaDetalleDia({super.key, required this.nombreDia});

  @override
  State<PantallaDetalleDia> createState() => _PantallaDetalleDiaState();
}

class _PantallaDetalleDiaState extends State<PantallaDetalleDia> {

  // Esta función fuerza a la pantalla a leer la base de datos de nuevo
  void _recargarLista() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreDia), // Título dinámico
      ),

      // USAMOS FUTUREBUILDER PARA LEER LA BD
      body: FutureBuilder<List<Comida>>(
        future: DatabaseHelper.instance.readMealsByDay(widget.nombreDia),
        builder: (context, snapshot) {

          // 1. Estado: Cargando
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // 2. Estado: Lista Vacía
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[300]),
                  Text("No hay comidas para el ${widget.nombreDia}"),
                  SizedBox(height: 10),
                  Text("¡Agrega una abajo!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // 3. Estado: Tenemos datos
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final comida = snapshot.data![index];
              return _construirTarjetaComida(comida);
            },
          );
        },
      ),

      // BOTÓN FLOTANTE PARA AGREGAR (Estilo "Píldora" como tu diseño)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navegamos al formulario esperando respuesta
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaAgregarComida(diaSeleccionado: widget.nombreDia),
            ),
          );
          // Al volver, recargamos la lista por si guardaste algo nuevo
          _recargarLista();
        },
        icon: Icon(Icons.add),
        label: Text("Agregar comida"),
        backgroundColor: Colors.purple[100],
        foregroundColor: Colors.purple,
      ),
    );
  }

  // WIDGET AUXILIAR: Diseño de cada tarjeta
  Widget _construirTarjetaComida(Comida comida) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // AQUÍ NAVEGARÍAS A "VER DETALLE / BORRAR"
          // Navigator.push(...).then((_) => _recargarLista());
          print("Tocaste ${comida.title}");
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // COLUMNA 1: Hora (Círculo morado)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  comida.time, // "13:00"
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(width: 15),

              // COLUMNA 2: Nombre del plato
              Expanded(
                child: Text(
                  comida.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // COLUMNA 3: La Imagen (Si existe)
              if (comida.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(comida.imagePath!), // Cargamos desde la ruta guardada
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              else
              // Si no hay foto, mostramos icono
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.fastfood, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}