import 'dart:io';
import 'package:flutter/material.dart';
import '../modelos/publicacion.dart';
import '../servicios/base_datos_service.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() {
    return _InicioPageState();
  }
}

class _InicioPageState extends State<InicioPage> {

  //1. Creamos las variables que necesitaremos: base de datos, publicacion y cargar
  final BaseDatosService baseDatosService = BaseDatosService();
  List<Publicacion> publicaciones = [];
  bool cargando = true;

  //2. Consultamos las publicaciones al abrir el inicio
  //InitState es el metodo que se ejecuta primero al abrir una pantalla
  @override
  void initState() {
    super.initState();
    cargarPublicaciones();
  }

  //3.- Creamos el método para cargar las publicaciones (se conecta al servicio)
  Future<void> cargarPublicaciones() async {
    List<Publicacion> datos = await baseDatosService.consultarPublicaciones();

    //validamos que la pantalla exista
    if ( mounted == false ){
      return;
    }

    //Guardamos el resultado y actualizamos la vista
    setState(() {
      publicaciones = datos;
      cargando = false;
    });
  }

  //Método para cambiar la publicación a favorita
  Future<void> cambiarFavorita(Publicacion publicacion) async {

    if(publicacion.favorita == 0) {
      publicacion.favorita = 1;

    } else {
      publicacion.favorita = 0;
    }

    await baseDatosService.actualizarPublicacion(publicacion);
    await cargarPublicaciones();
  }

  //Método para eliminar una publicación
  Future<void> eliminarPublicacion(Publicacion publicacion) async {
    if(publicacion.id == null) {
      return;
    }

    await baseDatosService.eliminarPublicacion(publicacion.id!);
    await cargarPublicaciones();
  }

  //4. Creamos la pantalla con la información de las publicaciones
  @override
  Widget build(BuildContext context) {

    //Si está cargando la pantalla mostramos el icono de carga
    if (cargando == true) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    //Si no hay publicaciones que mostramos en pantalla un mensaje
    if(publicaciones.isEmpty) {
      return const Center(
        child: Text('Todavía no hay publicaciones')
      );
    }

    //Muestro las publicaciones
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: publicaciones.length,
      itemBuilder: (BuildContext context, int indice) {
        Publicacion publicacion = publicaciones[indice];

        return Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Mostramos la imagen que si existe una ruta válida
                if(publicacion.imagenRuta != null && File(publicacion.imagenRuta!).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(publicacion.imagenRuta!),
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding:EdgeInsets.zero,
                  leading: IconButton(
                    onPressed: () {
                      cambiarFavorita(publicacion);
                    },
                    icon: Icon(
                      publicacion.favorita == 1 ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                  title: Text(publicacion.contenido),
                  subtitle: Text(
                    'Publicación ${publicacion.id}'
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      bool? confirmar = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Eliminar publicación'),
                            content: Text('¿Estás seguro de que deseas eliminar esta publicación?'),
                            actions: [
                              TextButton(
                                onPressed: (){
                                  Navigator.pop(context, false);
                                }, child: Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text('Eliminar'),
                                )
                            ],
                          );
                        }
                      );
                      if(confirmar == true) {
                        eliminarPublicacion(publicacion);
                      }
                    },
                    icon: Icon(
                      Icons.delete_outline
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}