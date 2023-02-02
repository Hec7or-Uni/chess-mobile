abstract class Ficha {
  bool isWhite;
  String _img = "";
  int _value = 0;
  Ficha({required this.isWhite});

  bool color() {
    return isWhite;
  }

  bool esVacia() {
    return false;
  }

  int getValue() {
    return _value;
  }

  String getImg() {
    return _img;
  }

  List<List<int>> posiblesMovimientos(int x, int y);
}

class Vacia extends Ficha {
  Vacia({required super.isWhite}) {
    _value = 0;
    _img = "";
  }

  @override
  List<List<int>> posiblesMovimientos(int x, int y) {
    List<List<int>> movimientos = [];
    return movimientos;
  }

  @override
  bool esVacia() {
    return true;
  }
}

class Torre extends Ficha {
  Torre({required super.isWhite}) {
    _value = 5;
    _img = "torre${super.isWhite ? "B" : "N"}";
  }

  @override
  List<List<int>> posiblesMovimientos(int x, int y) {
    List<List<int>> movimientos = [];

    for (int i = 0; i < 8; i++) {
      if (i != x) movimientos.add([i, y]);
      if (i != y) movimientos.add([x, i]);
    }

    return movimientos;
  }
}

class Alfil extends Ficha {
  Alfil({required super.isWhite}) {
    _value = 3;
    _img = "alfil${super.isWhite ? "B" : "N"}";
  }

  @override
  List<List<int>> posiblesMovimientos(int x, int y) {
    List<List<int>> movimientos = [];

    for (int i = 1; i < 8; i++) {
      if (x + i < 8 && y + i < 8) movimientos.add([x + i, y + i]);
      if (x - i > 0 && y - i > 0) movimientos.add([x - i, y - i]);
      if (x + i < 8 && y - i > 0) movimientos.add([x + i, y - i]);
      if (x - i > 0 && y + i < 8) movimientos.add([x - i, y + i]);
    }

    return movimientos;
  }
}

class Caballo extends Ficha {
  Caballo({required super.isWhite}) {
    _value = 3;
    _img = "caballo${super.isWhite ? "B" : "N"}";
  }

  @override
  List<List<int>> posiblesMovimientos(int x, int y) {
    List<List<int>> movimientos = [];

    movimientos.add([x + 2, y + 1]);
    movimientos.add([x + 2, y - 1]);
    movimientos.add([x - 2, y + 1]);
    movimientos.add([x - 2, y - 1]);
    movimientos.add([x + 1, y + 2]);
    movimientos.add([x - 1, y + 2]);
    movimientos.add([x + 1, y - 2]);
    movimientos.add([x - 1, y - 2]);

    return movimientos;
  }
}

class Peon extends Ficha {
  Peon({required super.isWhite}) {
    _value = 1;
    _img = "peon${super.isWhite ? "B" : "N"}";
  }

  @override
  List<List<int>> posiblesMovimientos(int x, int y) {
    List<List<int>> movimientos = [];
    int aux = super.isWhite ? -1 : 1;
    movimientos.add([x, y + aux]);
    aux = super.isWhite ? -2 : 2;
    if (super.isWhite && y == 6 || !super.isWhite && y == 1) {
      movimientos.add([x, y + aux]);
    }
    return movimientos;
  }
}

class Reina extends Ficha {
  Reina({required super.isWhite}) {
    _value = 10;
    _img = "reina${super.isWhite ? "B" : "N"}";
  }

  @override
  List<List<int>> posiblesMovimientos(int x, int y) {
    List<List<int>> movimientos = [];

    for (int i = 0; i < 8; i++) {
      if (i != x) movimientos.add([i, y]);
      if (i != y) movimientos.add([x, i]);
    }
    for (int i = 1; i < 8; i++) {
      if (x + i < 8 && y + i < 8) movimientos.add([x + i, y + i]);
      if (x - i > 0 && y - i > 0) movimientos.add([x - i, y - i]);
      if (x + i < 8 && y - i > 0) movimientos.add([x + i, y - i]);
      if (x - i > 0 && y + i < 8) movimientos.add([x - i, y + i]);
    }

    return movimientos;
  }
}

class Rey extends Ficha {
  Rey({required super.isWhite}) {
    _value = 10000;
    _img = "rey${super.isWhite ? "B" : "N"}";
  }

  @override
  List<List<int>> posiblesMovimientos(int x, int y) {
    List<List<int>> movimientos = [];

    movimientos.add([x - 1, y - 1]);
    movimientos.add([x - 1, y]);
    movimientos.add([x - 1, y + 1]);
    movimientos.add([x, y - 1]);
    movimientos.add([x, y + 1]);
    movimientos.add([x + 1, y - 1]);
    movimientos.add([x + 1, y]);
    movimientos.add([x + 1, y + 1]);

    return movimientos;
  }
}

List<Ficha> piezasNegras = [
  Torre(isWhite: false),
  Caballo(isWhite: false),
  Alfil(isWhite: false),
  Reina(isWhite: false),
  Rey(isWhite: false),
  Alfil(isWhite: false),
  Caballo(isWhite: false),
  Torre(isWhite: false)
];

List<Ficha> piezasBlancas = [
  Torre(isWhite: true),
  Caballo(isWhite: true),
  Alfil(isWhite: true),
  Rey(isWhite: true),
  Reina(isWhite: true),
  Alfil(isWhite: true),
  Caballo(isWhite: true),
  Torre(isWhite: true)
];

class SharedData {
  static final SharedData _singleton = SharedData._internal();
  List<List<Ficha>> tablero = _initTablero();
  List<List<bool>> tableroMovimientos = _initEmptyMovements();
  bool whiteTurn = true;
  List<int> casillaSeleccionada = [-1, -1];
  factory SharedData() {
    return _singleton;
  }

  SharedData._internal();
}

List<List<Ficha>> _initTablero() {
  List<List<Ficha>> tab = [];
  tab.add(piezasNegras);
  var aux = <Ficha>[];
  aux = List.filled(8, Peon(isWhite: false));
  tab.add(aux);
  aux = List.filled(8, Vacia(isWhite: false));
  for (int i = 0; i < 4; i++) {
    tab.add(aux);
  }
  aux = List.filled(8, Peon(isWhite: true));
  tab.add(aux);
  tab.add(piezasBlancas);
  return tab;
}

List<List<bool>> _initEmptyMovements() {
  List<List<bool>> movements = [];
  for (int i = 0; i < 64; i++) {
    if (i % 8 == 0) movements.add([]);
    movements[i ~/ 8].add(false);
  }
  return movements;
}

List<List<int>> validateMovements(List<List<int>> movimientos) {
  List<List<int>> movimientosValidos = [];
  final SharedData sharedData = SharedData();
  int temp;
  movimientos.forEach((movimiento) {
    /// Transponemos para que encaje con la definición del tablero(y,x)
    temp = movimiento[0];
    movimiento[0] = movimiento[1];
    movimiento[1] = temp;
    if (movimiento[0] >= 0 &&
        movimiento[0] < 8 &&
        movimiento[1] >= 0 &&
        movimiento[1] < 8 &&
        (sharedData.tablero[movimiento[0]][movimiento[1]].esVacia() ||
            sharedData.tablero[movimiento[0]][movimiento[1]].color() ==
                sharedData.whiteTurn)) {
      movimientosValidos.add(movimiento);
    }
  });
  return movimientosValidos;
}