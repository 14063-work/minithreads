import 'package:flutter/material.dart';
//importamos las pantallas
import 'inicio_page.dart';
import 'explorar_page.dart';
import 'publicar_page.dart';
import 'perfil_page.dart';

class PrincipalPage extends StatefulWidget {

  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() {
    return _PrincipalPageState();
  }
}

class _PrincipalPageState extends State<PrincipalPage> {
  //Creamos una variable guardar la posición seleccionada del menu. La primera posición es 0.
  int indiceSeleccionado = 0;

  //Creamos una lista con las pantallas, Deben estar en el mismo orden que los botones.
  final List<Widget> pantallas = const [
    InicioPage(),
    ExplorarPage(),
    PublicarPage(),
    PerfilPage(),
  ];

  //Creamos el método para cambiar de pantalla
  void cambiarPantalla(int nuevoIndice) {
    setState(() {
      indiceSeleccionado = nuevoIndice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pantallas[indiceSeleccionado],
      bottomNavigationBar: NavigationBar(
        selectedIndex: indiceSeleccionado,
        onDestinationSelected: (int nuevoIndice) { 
          cambiarPantalla(nuevoIndice);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio'
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Explorar'
            ),
            NavigationDestination(
              icon: Icon(Icons.add_box_outlined),
              selectedIcon: Icon(Icons.add_box),
              label: 'Publicar'
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil'
            ),
          ],
         ), 
      );
  }
}