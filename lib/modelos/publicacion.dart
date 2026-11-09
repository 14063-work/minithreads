//El modelo representa una fila de la tabla de publicaciones.
class Publicacion {
  int? id;
  String contenido;
  int favorita;
  String? imagenRuta;

//Constructor para crear objetos Publicacion
Publicacion({
  this.id,
  required this.contenido,
  this.favorita = 0,
  this.imagenRuta
});

//Método para convertir el objeto Publicación en colummas y valores que entiende SQLite (base de datos).
Map<String, Object?> toMap() {

  Map<String, Object?> datos = {
    'contenido': contenido,
    'favorita': favorita,
    'imagen_ruta': imagenRuta,

  };

  //solo enviamos el ID cuando ya existe
  if(id != null) {
    datos['id'] = id;
  }

  return datos;

 }

 //Convierte una fila consultada desde la BD (base de Datos) en un objeto Publicación
 static Publicacion fromMap(Map<String, Object?> datos) {

  return Publicacion(
    id: datos['id'] as int,
    contenido: datos['contenido'] as String,
    favorita: datos['favorita'] as int,
    imagenRuta: datos['imagen_ruta'] as String?,
  );

 }

}