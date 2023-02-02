import 'package:ajedrez/components/casilla.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          children: [
            Expanded(child: Container()),
            Expanded(
              flex: 4,

              /// Devuelve una tabla de 64 elementos ordenados por filas de 8
              child: GridView.builder(
                  itemCount: 64,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (BuildContext context, int index) {
                    /// Cada elemento es una casilla
                    return Casilla(index: index);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}