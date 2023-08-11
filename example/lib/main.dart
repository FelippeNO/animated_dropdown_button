import 'package:animated_dropdown_button/animated_dropdown_button.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Dropdown Button Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ANIMATED DROPDOWN BUTTON DEMO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class AnimalModel extends AnimatedDropdownItem {
  final String name;

  AnimalModel(this.name);

  @override
  String get text => name;

  @override
  String get value => name;
}

class _MyHomePageState extends State<MyHomePage> {
  late final AnimatedSearchBoxController animatedSearchController;

  final AnimatedDropdownButtonController animalsController = AnimatedDropdownButtonController(
    items: [
      'Cat',
      'Dog',
      'Bird',
      'Cat',
      'Dog',
    ],
    initialValue: 'Dog',
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animatedSearchController = AnimatedSearchBoxController(
      items: animals,
      initialValue: AnimalModel(
        'Cat',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        color: const Color.fromARGB(255, 165, 149, 149),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 50),
                AnimatedSearchBox(
                  width: 336,
                  controller: animatedSearchController,
                  backgroundColor: Colors.white,
                  hintText: 'Type an animal name',
                ),
                const SizedBox(
                  height: 50,
                ),
                AnimatedDropdownButton(
                  controller: animalsController,
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final List<AnimalModel> animals = [
  AnimalModel(
    'Cat',
  ),
  AnimalModel(
    'Dog',
  ),
  AnimalModel(
    'Bird',
  ),
  AnimalModel(
    'Donkey',
  ),
  AnimalModel(
    'Moneky',
  ),
  AnimalModel(
    'Cabra',
  ),
  AnimalModel(
    'Cavalo',
  ),
  AnimalModel(
    'Leão',
  ),
];
