import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animated_splash_screen/animated_splash_screen.dart';


void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(seconds: 1),
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: AnimatedSplashScreen(
            splash: Transform.rotate(
              angle: value * 2 * pi,
              child: Image.asset("assets/images/note.png"),
            ),
            nextScreen: const MyApp(),
            splashIconSize: 250,
          ),
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  List<Note> notes = [];
  FlutterTts flutterTts = FlutterTts();
  bool isPaused = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // pause the speech when the app is paused or inactive
      flutterTts.stop();
      isPaused = true;
    } else if (state == AppLifecycleState.resumed && isPaused) {
      // resume the speech when the app is resumed and was paused before
      _speak(notes.last.text);
      isPaused = false;
    }
  }


  _speak(String text) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }


  void addNote() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _textController = TextEditingController();

        return AlertDialog(
          title: const Text('note'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: 'ajouter votre note',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ANNULER'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('AJOUTER'),
              onPressed: () {
                setState(() {
                  notes.add(Note(
                    text: _textController.text,
                    date: DateTime.now(),
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void deleteNoteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Supprimer la note?"),
          content: const Text("Voulez-vous supprimer cette note?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ANNULER'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  notes.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('SUPPRIMER'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes app',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          actions: <Widget>[
            GestureDetector(
              child: const Icon(Icons.add),
              onTap: () {
                addNote();
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NoteDetailsScreen(note: notes[index])),
                );
              },
              onLongPress: () {
                deleteNoteConfirmation(index);
              },

              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: const AssetImage('assets/images/pen2.png'),
                ),
                title: const Text("Soraya"),
                subtitle: Text(notes[index].text.length > 8
                    ? '${notes[index].text.substring(0, 8)}...'
                    : notes[index].text),
                trailing: IconButton(
                  icon: Icon(Icons.volume_up),
                  onPressed: () {
                    _speak(notes[index].text);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Note {
  final String text;
  final DateTime date;

  Note({required this.text, required this.date});
}

class NoteDetailsScreen extends StatelessWidget {
  final Note note;

  const NoteDetailsScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    FlutterTts flutterTts = FlutterTts();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/pen2.png',width: 100,height: 100,),
              SizedBox(height: 20),

              Text(note.text),
              SizedBox(height: 20),
              const SizedBox(height: 16.0),
              Text('Date: ${note.date}'),
            ],
          ),
        ),
      ),
    );
  }
}
