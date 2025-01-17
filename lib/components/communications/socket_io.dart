/// Contains all the gamesocket data and methods.

import 'dart:async';
// import 'dart:convert';
import 'package:ajedrez/components/chessLogic/board.dart';
import 'package:ajedrez/components/chessLogic/square.dart';
import 'package:ajedrez/components/chessLogic/timer.dart';
import 'package:ajedrez/components/popups/ingame/save_dialog.dart';
import 'package:ajedrez/components/data/profile_data.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';

import '../popups/ingame/draw_dialog.dart';
import '../popups/ingame/possible_draw.dart';
import '../popups/ingame/possible_save.dart';
import '../popups/ingame/winner_dialog.dart';
import '../../pages/game_pages/game.dart';

class Arguments {
  int time = 300;
  int increment = 5;
  String hostColor = "RANDOM";
  int difficulty = 1;
  String roomID = "roomID";

  Arguments();
  Arguments.forCOMP(this.time);
  Arguments.forAI(this.time, this.increment, this.hostColor, this.difficulty);
  Arguments.forSPECTATOR(this.roomID);
  Arguments.forCREATECUSTOM(this.time, this.increment, this.hostColor);
  Arguments.forJOINCUSTOM(this.roomID);
  Arguments.forTOURNAMENT(this.roomID);
}

class GameSocket {
  static final GameSocket _singleton = GameSocket._internal();
  io.Socket socket = io.io(
      // 'http://192.168.0.249:4001',
      'http://reign-chess.duckdns.org:4001/',
      OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        'token': UserData().token
      }) // for Flutter or Dart VM SI BORRAS ESTO NO VA EL SOCKET :D
          .build());
  String room = "-1";
  List pendingMovements = [];
  bool spectatorMode = false;
  bool iAmWhite = false;
  int timer = 300;
  String type = "";
  String player1 = "";
  String player2 = "";
  factory GameSocket() {
    return _singleton;
  }

  void reset() {
    socket = io.io(
        // 'http://192.168.0.249:4001',
        'http://reign-chess.duckdns.org:4001/',
        OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'token': UserData().token})
            .enableForceNew()
            .build());
    room = "-1";
    pendingMovements = [];
    spectatorMode = false;
    iAmWhite = false;
    timer = 300;
    type = "";
    player1 = "";
    player2 = "";
  }

  GameSocket._internal();
}

void resetSocket() {
  GameSocket socket = GameSocket();
  socket.reset();
}

void cancelSearch() {
  GameSocket socket = GameSocket();
  socket.socket.emit('cancel');
}

Future<void> startGame(BuildContext context, String type, Arguments arguments) {
  GameSocket s = GameSocket();
  Completer completer = Completer<void>();
  // BoardData b = BoardData();
  s.socket.onConnect((_) {
    // print("CONEXIÓN ESTABLECIDA");
  });

  Map jsonData;

  s.type = type;
  if (type == "CREATECUSTOM" || type == "JOINCUSTOM") {
    s.type = "CUSTOM";
  }
  switch (type) {
    case "AI":
      {
        jsonData = {
          "gameType": "AI",
          "time": arguments.time,
          "increment": arguments.increment,
          "hostColor": arguments.hostColor,
          "difficulty": arguments.difficulty
        };
      }
      break;
    case "COMP":
      {
        jsonData = {"gameType": "COMPETITIVE", "time": arguments.time};
      }
      break;
    case "CREATECUSTOM":
      {
        jsonData = {
          "gameType": "CUSTOM",
          "time": arguments.time,
          "increment": arguments.increment,
          "hostColor": arguments.hostColor
        };
        s.socket.once(
          'room_created',
          (data) => {
            s.room = data[0]["roomID"],
          },
        );
        // completer.complete();
        // s.socket.emit('find_room', jsonData);
      }
      // return completer.future;
      break;
    case "JOINCUSTOM":
      {
        jsonData = {"gameType": "CUSTOM", "roomID": arguments.roomID};
      }
      break;
    case "SPECTATOR":
      {
        jsonData = {"roomID": arguments.roomID};
        s.socket.emit('join_room', jsonData);
        s.room = arguments.roomID;
        s.spectatorMode = true;
      }
      break;
    case "TOURNAMENT":
      {
        jsonData = {"gameType": "TOURNAMENT", "matchID": arguments.roomID};
      }
      break;
    default:
      {
        jsonData = {};
        // print("Animal has metido mal el tipo");
      }
  }
  var movements = [];
  s.socket.once(
      'cancelled', (data) => {Navigator.pop(context), Completer().complete()});
  s.socket.once(
      'room',
      (data) => {
            // print(data),

            s.player1 = data[0]["light"],
            s.player2 = data[0]["dark"],

            if (type != "SPECTATOR")
              {
                s.room = data[0]["roomID"],
                s.iAmWhite = data[0]["color"] == "LIGHT",
                if (data[0]["moves"].length > 0)
                  {
                    s.pendingMovements = data[0]["moves"],
                  }
              }
            else
              {
                movements = data[0]["moves"],
                s.pendingMovements = movements,
                s.iAmWhite = true
              },
            s.timer = data[0]["initialTimer"],
            // print(data),
            // print(s.room),
            if (type == "COMP" ||
                type == "CREATECUSTOM" ||
                type == "TOURNAMENT")
              Navigator.pop(context),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GamePage()),
            ),
            completer.complete()
          });
  // print("CONEXIÓN ESTABLECIDA2");
  s.socket.on(
      'error',
      (data) => {
            // print(data)
          });
  if (type != "SPECTATOR" && type != "") {
    s.socket.emit('find_room', jsonData);
  }

  return completer.future;
}

void listenGame(BuildContext context) {
  GameSocket s = GameSocket();
  bool espec = s.spectatorMode;
  BoardData b = BoardData();
  s.socket.on(
      'error',
      (data) => {
            // print("ERROR" + data)
          });
  s.socket.on(
      'moved',
      (data) => {
            // print(data),

            if (b.reversedBoard)
              {
                (b.clocks[0] as TimerState)
                    .setTimer(data[0]["timerLight"] ~/ 1000),
                (b.clocks[1] as TimerState)
                    .setTimer(data[0]["timerDark"] ~/ 1000),
              }
            else
              {
                (b.clocks[1] as TimerState)
                    .setTimer(data[0]["timerLight"] ~/ 1000),
                (b.clocks[0] as TimerState)
                    .setTimer(data[0]["timerDark"] ~/ 1000),
              },
            if (!espec)
              {
                if (data[0]["turn"] == (!s.iAmWhite ? "DARK" : "LIGHT"))
                  {
                    simulateMovement(decodeMovement(data[0]["move"])),
                  },
              }
            else
              {
                // print("funciona"),
                simulateMovement(decodeMovement(data[0]["move"])),
              }
          });
  s.socket.on(
      'game_over',
      (data) => {
            // print(data),
            if (data[0]["endState"] == "CHECKMATE" &&
                (data[0]["winner"] == (!s.iAmWhite ? "LIGHT" : "DARK")))
              {
                alertWinner(context, !s.iAmWhite,
                    "Ha ganado el jugador con las fichas "),
              },
            if (data[0]["endState"] == "SURRENDER")
              {
                alertWinner(context, !(data[0]["winner"] == "LIGHT"),
                    "Se ha rendido el jugador con las fichas "),
              },
            if (data[0]["endState"] == "TIMEOUT")
              {
                alertWinner(context, (data[0]["winner"] == "LIGHT"),
                    "Ha ganado por tiempo el jugador con las fichas "),
              },
            if (data[0]["endState"] == "DRAW")
              {
                alertDraw(context),
              },
          });
  s.socket.on(
      'voted_draw',
      (data) => {
            if (data[0]["color"] == (s.iAmWhite ? "DARK" : "LIGHT"))
              alertPossibleDraw(context)
          });
  s.socket.on(
      'voted_save',
      (data) => {
            if (data[0]["color"] == (s.iAmWhite ? "DARK" : "LIGHT"))
              alertPossibleSave(context)
          });
  s.socket.onDisconnect((_) => {
        // print('disconnect')
      });
  s.socket.on('game_saved', (data) => {alertSave(context)});
  s.socket.onDisconnect((_) => {
        // print('disconnect')
      });
  s.socket.on(
      'fromServer',
      (_) => {
            //print(_)
          });
}

void surrender() {
  GameSocket s = GameSocket();
  s.socket.emit('surrender', {});
}

void draw() {
  GameSocket s = GameSocket();
  var jsonData = {"color": s.iAmWhite ? "LIGHT" : "DARK"};
  s.socket.emit('vote_draw', jsonData);
}

void save() {
  GameSocket s = GameSocket();
  // var jsonData = {"color": s.iAmWhite ? "LIGHT" : "DARK"};
  // s.socket.emit('vote_save', jsonData);
  s.socket.emit('vote_save');
}

Future<void> resume(String roomID, BuildContext context) async {
  GameSocket s = GameSocket();
  Completer completer = Completer<void>();
  // BoardData b = BoardData();
  s.socket.on(
      'error',
      (data) => {
            // print(data)
          });
  s.socket.once(
    'room_created',
    (data) => {
      s.room = data[0]["roomID"],
    },
  );
  s.socket.once(
      'room',
      (data) => {
            s.room = data[0]["roomID"],
            s.iAmWhite = data[0]["color"] == "LIGHT",
            s.pendingMovements = data[0]["moves"],
            s.timer = data[0]["initialTimer"],
            s.type = data[0]["gameType"],

            s.player1 = data[0]["light"],
            s.player2 = data[0]["dark"],

            // print(s.room),
            Navigator.pop(context),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GamePage()),
            ),
            completer.complete()
          });
  var jsonData = {"gameID": roomID};
  s.socket.emit("resume", jsonData);
  return completer.future;
}
