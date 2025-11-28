class Comida {
  final int? id;
  final String title;
  final String descripcion;
  final String time;
  final String? imagePath;
  final String? diaSemana;

  Comida({
    this.id,
    required this.title,
    required this.descripcion,
    required this.time,
    required this.imagePath,
    required this.diaSemana
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': descripcion,
      'time': time,
      'imagePath': imagePath,
      'dayOfWeek': diaSemana,
    };
  }
  factory Comida.fromMap(Map<String, dynamic> map) {
    return Comida(
      id: map['id'],
      title: map['title'],
      descripcion: map['description'],
      time: map['time'],
      imagePath: map['imagePath'],
      diaSemana: map['dayOfWeek'],
    );
  }
}

