import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//Importamos el modelo de Publicación
import '../modelos/publicacion.dart';

//Creamos la clase para la base de datos
class BaseDatosService {
  //Variable para conservar la conexión a la bd.
  Database? _baseDatos;

  //Método para obtener una conexión a la base de datos
  Future<Database> obtenerBaseDatos() async {
    //async: Un método que no se ejecuta inmediatamente

    //Si ya existe una conexión, la reutilizamos
    // _baseDatos!: ! significa que estoy asegurando que existe información en _baseDatos
    if(_baseDatos != null) {
      return _baseDatos!;
    }
    //Si no existe, esperamos mientras se crea o se abre
    _baseDatos = await _crearBaseDatos();
    return _baseDatos!;
  }

  //Creamos el método para crear la base de datos
  Future<Database> _crearBaseDatos() async {
    //Obtenemos la carpeta privada para bases de datos.
    String carpeta = await getDatabasesPath();

    String ruta = join(carpeta, 'minithreads.db');

    Database baseDatos = await openDatabase(
      ruta,
      version: 1,
      //onCreate: solo se ejecuta cuando el archivo minithreads.db no existe
      onCreate:(Database db, int version) async {
        await db.execute(
          '''CREATE TABLE publicaciones(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contenido TEXT NOT NULL,
          favorita INTEGER NOT NULL,
          imagen_ruta TEXT
          )'''
        );
      }
    );
    return baseDatos;
  }

  //CREATE: Guarda una publicación y devuelve el ID generado.
  Future<int> insertarPublicacion(Publicacion publicacion) async {

    //1. Abrimos o recuperamos la conexión.
    Database db = await obtenerBaseDatos();

    //2. Insertamos la información en la tabla de publicaciones.
    int idCreado = await db.insert(
      'publicaciones',
      publicacion.toMap(),
    );

    //3. Devolvemos el ID para confirmar que si se guardó
    return idCreado;
  }

  //READ: Consulta las publicaciones
  Future<List<Publicacion>> consultarPublicaciones() async {

    //1. Abrimos u obtenemos la conexión con la base de datos
    Database db = await obtenerBaseDatos();

    //2. Obtenemos las filas, la más reciente primero
    List<Map<String, Object?>> filas = await db.query(
      'publicaciones',
      orderBy: 'id DESC',
    );

    //3. Creamos una lista para dar formato a las filas
    List<Publicacion> publicaciones = [];

    //4. Convertimos cada fila en un objeto
    for(Map<String, Object?> fila in filas) {
      Publicacion publicacion = Publicacion.fromMap(fila);
      publicaciones.add(publicacion);
    }

    return publicaciones;
  }


  //UPDATE: Cambia/actualiza la columna de favorita
  Future<void> actualizarPublicacion(Publicacion publicacion) async {

    //Obtenemos la conexion con la base de datos
    Database db = await obtenerBaseDatos();

    //actualizamos la tabla con el nuevo dato de favorita
    await db.update(
     'publicaciones',
     {'favorita': publicacion.favorita},
     where: 'id = ?',
     whereArgs: [publicacion.id],
    );
  }
  
  //DELETE: Elimina una publicación mediante su id
  Future<void> eliminarPublicacion(int id) async {

    //Obtenemos la conexión con la base de datos
    Database db = await obtenerBaseDatos();

    //Eliminamos la publicación
    await db.delete(
      'publicaciones',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

}