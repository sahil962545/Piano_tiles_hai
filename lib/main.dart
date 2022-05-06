import 'package:flutter/material.dart';
import 'package:piano_tiles/line.dart';
import 'package:piano_tiles/note.dart';
import 'package:piano_tiles/song_provider.dart';
import 'package:piano_tiles/line_divider.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano Tiles 2 clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Piano(),
    );
  }
}

class Piano extends StatefulWidget {
  const Piano({Key? key}) : super(key: key);

  @override
  State<Piano> createState() => _PianoState();
}

class _PianoState extends State<Piano> with SingleTickerProviderStateMixin{
  final player = AudioCache();

  List<Note> notes = initNotes();
  late AnimationController animationController;
  int currentNoteIndex = 0;
  int points = 0;
  bool hasStarted = false;
  bool isPlaying = true;

  @override
  void initState(){
    super.initState();
    animationController = AnimationController(vsync: this,duration:Duration(milliseconds: 300));
    animationController.addStatusListener((status) {
      if(status == AnimationStatus.completed && isPlaying){
        if(notes[currentNoteIndex].state != NoteState.tapped){

          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          animationController.reverse().then((_) => _showFinishDialog());
        } else if (currentNoteIndex == notes.length - 5){
          _showFinishDialog();
        }
        else{
          setState(() => ++currentNoteIndex);
          animationController.forward(from: 0);

          }
        }

    });
  }
  @override
  void dispose()
  {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Image.asset('assets/images/background.jpg',
          fit: BoxFit.cover,),

          Row(
            children: [
              _drawLine(0),
              LineDivider(),
              _drawLine(1),
              LineDivider(),
              _drawLine(2),
              LineDivider(),
              _drawLine(3),
            ],
          ),

          _drawPoints(),

        ],
      ),

    );
  }
  void _restart()
  {
   setState(() {
     hasStarted = false;
     isPlaying = true;
     notes = initNotes();
     points = 0;
     currentNoteIndex = 0;
   });
   animationController.reset();
  }
  void _showFinishDialog()
  {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Score:$points"),
        actions: [
          FlatButton(onPressed: () => Navigator.of(context).pop(),
        child: Text("RESTART"),
          )
        ],
      );
    }
    ).then((_) => _restart());
  }
  void _onTap(Note note){
    bool areAllPreviousTappped = notes
        .sublist(0,note.orderNumber)
        .every((n) => n.state == NoteState.tapped);
    print(areAllPreviousTappped);
    if(areAllPreviousTappped){
      if(!hasStarted) {
        setState(() => hasStarted = true);
        animationController.forward();
      }
      _playNote(note);
      setState(() {
        note.state = NoteState.tapped;
      });

      }
    }

    _drawLine(int lineNumber){
    return Expanded(child: Line(
      lineNumber: lineNumber,
      currentNotes: notes.sublist(currentNoteIndex,currentNoteIndex+5),
      onTileTap:_onTap,
      animation:animationController,
    ),
    );
    }

    _drawPoints()
    {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text(
            "$points",
            style: TextStyle(color: Colors.red,fontSize: 60),
          ),
        )
      );
    }
    _playNote(Note note)
    {
      switch(note.line)
      {
        case 0:
          player.play('music/a.wav');
          return;
        case 1:
          player.play('music/c.wav');
          return;
        case 2:
          player.play('music/e.wav');
          return;
        case 3:
          player.play('music/fav.wav');
          return;
      }
    }
  }




