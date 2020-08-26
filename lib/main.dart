import 'package:flutter/material.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:audioplayers/audio_cache.dart';
import 'dart:math';

// copy from https://elixirforum.com/t/how-to-integrate-flutter-with-phoenix/29819/8

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mimitos!',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Mimitos!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final socket = PhoenixSocket("ws://192.168.1.106:4000/socket/websocket");
  final AudioCache player = new AudioCache();
  final purrAudioPath = "purr.mp3";
  final faces = ["😫", "😩", "😣", "😔", "😑", "😌", "😊"];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PhoenixChannel _channel;
  int _happyness;

  void initState() {
    _happyness = 0;
    _connectSocket();
    super.initState();
  }

  Future<void> _connectSocket() async {
    await widget.socket.connect();

    _channel = widget.socket.channel("room:mimitos");
    _channel.on("mimitos!", _incrementHappyness);

    _channel.join();
  }

  void _incrementHappyness(_payload, _ref, _joinRef) {
    widget.player.play(widget.purrAudioPath);

    if (_happyness < 26) {
      setState(() {
        _happyness = _happyness + 1;
      });
    } else {
      setState(() {
        var rng = new Random();
        _happyness = rng.nextInt(10) + 5;
      });
    }
  }

  void _sendMimitos() {
    _channel.push(event: "send_mimitos!", payload: {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Container(
              alignment: Alignment.center,
              color: Colors.deepPurple,
              child: Text(widget.faces[_happyness ~/ 4],
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 156,
                      decoration: TextDecoration.none,
                      color: Colors.white)))),
      floatingActionButton: new FloatingActionButton(
        onPressed: _sendMimitos,
        tooltip: 'Send Mimitos!',
        child: new Icon(Icons.pets),
      ),
    );
  }
}
