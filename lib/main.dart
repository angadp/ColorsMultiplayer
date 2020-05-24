import 'package:flutter/material.dart';
import 'package:getflutter/getflutter.dart';
import 'game.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "IndieFlower"
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page')
    );
  }
}

enum Difficulty { Easy, Medium, Hard }

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  AnimationController _animationController;
  Animation _animation;
  Difficulty _diff = Difficulty.Easy;
  int dropdownValue = 4;

  void onChanged(Difficulty value) {
    setState((){
      _diff = value;
    });

    print('Value = $value');
    Navigator.pop(context);
    createNewGameDialog(context);
  }

  @override
  void initState(){
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin:0.75, end:1.0).animate(_animationController);
  }

  TextEditingController controller = TextEditingController();

  createNewGameDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Choose Game"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
         children: <Widget>
            [
               RadioListTile<Difficulty>(
                 title: const Text('Easy'),
                 value: Difficulty.Easy,
                 groupValue: _diff,
                 onChanged: (Difficulty value) {
                   onChanged(value);
                 },
               ),
           RadioListTile<Difficulty>(
             title: const Text('Medium'),
             value: Difficulty.Medium,
             groupValue: _diff,
             onChanged: (Difficulty value) {
               onChanged(value);
             },
           ),
           RadioListTile<Difficulty>(
             title: const Text('Hard'),
             value: Difficulty.Hard,
             groupValue: _diff,
             onChanged: (Difficulty value) {
               onChanged(value);
             },
           ),
            Row(
                children: <Widget>[
                  Container(width:15),
                  Text("No of symbols"),
                  Container(width:35),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.black,
                          style: BorderStyle.solid,
                          width: 0.80),
                      ),
                      child: DropdownButton<int>(
                      value: dropdownValue,
                      onChanged: (int newValue) {
                      setState(() {
                          dropdownValue = newValue;
                      });
                      Navigator.pop(context);
                      createNewGameDialog(context);
                    },
                    items: <int>[2,3,4,5,6,7,8,9]
                        .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                        );
                        }).toList(),
                    ),
                  ),
                ]),
           TextField(controller: controller,
                decoration: new InputDecoration(
                    hintText: "Name"
                )),
           FlatButton(
             onPressed: () {
               String name = "John Doe";
               if(controller.text != ""){
                 name = controller.text;
               }
               var route = new MaterialPageRoute(
                   builder: (BuildContext context){
                      return new GamePage(title: _diff.toString(), difficulty: _diff.index, colors: dropdownValue, name: name);
                   });
               Navigator.pop(context);
               Navigator.of(context).push(route);
             },
             child: Text(
               "Create",
             ),
           )
            ]
        ),
        backgroundColor: Colors.blueGrey[200],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        backgroundColor: Colors.cyan,
          body: FadeTransition(
          opacity: _animation,
          child: Scaffold(
          backgroundColor: Colors.blueAccent,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(top:20),
              child: Column(
              children: <Widget>[
                OutlineButton(
                onPressed: () {
                  createNewGameDialog(context);
                },
                borderSide: BorderSide(color: Colors
                    .black),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top:20, bottom:20),
                    child:Text(
                  "New Game",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                  ),
                )),
              )]
          ),
        ),
            Padding(
              padding: const EdgeInsets.only(top:20),
              child: Column(
                  children: <Widget>[
                    OutlineButton(
                      onPressed: () {
                        exit(0);
                      },
                      borderSide: BorderSide(color: Colors
                          .black),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 85, right: 85, top:20, bottom:20),
                          child:Text(
                            "Exit",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22.0,
                            ),
                          )),
                    )]
              ),
            )// This trailing comma makes auto-formatting nicer for build methods.
          ])
        ))
    );
  }
}
