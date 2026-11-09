import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../modelos/publicacion.dart';
import '../servicios/base_datos_service.dart';

class PublicarPage extends StatefulWidget{
  const PublicarPage({super.key});

  @override
  State<PublicarPage> createState(){
    return _PublicarPageState();
  }
}

class _PublicarPageState extends State<PublicarPage> {
  //1. Lee y limpia el campo de texto
  final TextEditingController contenidoController = TextEditingController();

  //2. Crea un objeto que se conecta al servicio para comunicarse con SQLite
  final BaseDatosService baseDatosService = BaseDatosService();

  //3. Crea el objeto imagen para abrir la galería o la cámara.
  final ImagePicker selectorImagen = ImagePicker();

  //4. Crea una variable para guardar la imagen seleccionada
  File? imagenSeleccionada;

  //5. Abre la galería y espera una imagen
  Future<void> seleccionarImagen() async {
    try {
      //5.1 método para abrir la galeria
      XFile? imagen = await selectorImagen.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      //5.2 Si la persona cerró la galería, no continuamos
      if(imagen == null){
        return;
      }

      //5.3 Convertimos la imagen XFile en File para poderla mostrar
      File archivo = File(imagen.path);

      //5.4 Guardamos la imagen y reconstruimos la pantalla
      setState(() {
        imagenSeleccionada = archivo;
      });

    } catch(error) {
      //5.5 Detectamos si faltó reiniciar la aplicación
      if(mounted == false) {
        return;
      }

      //5.6 EN el caso de que la pantalla esté bien, pero de otro error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la galería: $error'))
      );
    }
  }

  //6. Método para validar e instertar la publicación
  Future<void> publicar() async {
    //6.1 Creamos una variable para guardar el texto de la publicación
    String texto = contenidoController.text.trim();

    //6.2 Validamos que la publicación no esté vacía
    if(texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Escribe una publicación'))
      );
      return;
    }

    //6.3 Preparamos la ruta de la imagen
    String? rutaImagen;

    if(imagenSeleccionada != null) {
      rutaImagen = imagenSeleccionada!.path;
    }

    //6.4 Creamos el objeto de publicación
    Publicacion publicacion = Publicacion(
      contenido: texto,
      imagenRuta: rutaImagen,
    );

    //6.5 Nos conectamos al servicio, ejecutamos el método para insertar la publicación y nos debe devolver un ID
    int idCreado = await baseDatosService.insertarPublicacion(publicacion);

    //6.6 Limpiamos el campo
    contenidoController.clear();

    //6.7 Quitamos la vista previa después de guardar.
    setState(() {
      imagenSeleccionada = null;
    });

    //6.8 en caso de perderse o destruirse la pantalla validamos
    if(mounted == false) {
      return;
    }

    //6.9 COnfirmamos la inserción de la aplicación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Publicación $idCreado guardada')),
    );
  }

  //7. Creamos el método para liberar recursos
  @override
  void dispose() {
    contenidoController.dispose();
    super.dispose();
  }

  //8. Creamos el método build para construir el diseño de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear publicación'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Campo para texto
              const Text(
                'Comparte una idea y agrega una imagen si lo deseas.',
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 18),
              //Campo para escribir el contenido de la publicación
              TextField(
                controller: contenidoController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Qué quieres compartir?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 12),
              //Vista previa de imagen si existe
              if(imagenSeleccionada != null) 
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imagenSeleccionada!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      await seleccionarImagen();
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Imagen')
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      publicar();
                    },
                    icon: const Icon(Icons.add),
                  label: const Text('Publicar')
                  )
                ],
              )  

            ],
          ),
        )
      ),
    );
  }
}