import 'package:flutter/material.dart';
import 'pantallas/principal_page.dart';


void main () {
  runApp(const Minithreads());
}

class Minithreads extends StatelessWidget {

  const Minithreads({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PrincipalPage(),
    );
  }
}