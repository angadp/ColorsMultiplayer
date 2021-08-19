import 'package:flutter/material.dart';
import 'game.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main.dart';

Future<void> account() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "IndieFlower"
      ),
      home: MyAccount(title: 'Flutter Demo Home Page')
    );
  }
}

class MyAccount extends StatefulWidget {
  MyAccount({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState(){
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin:0.75, end:1.0).animate(_animationController);
  }

  TextEditingController controller = TextEditingController();

  void GuestLogin() async {
    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    var route = new MaterialPageRoute(
    builder: (BuildContext context){
        return new MyHomePage();
    });
    Navigator.pop(context);
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        backgroundColor: Colors.cyan,
          body: FadeTransition(
          opacity: _animation as Animation<double>,
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
                TextButton(
                onPressed: () {
                  exit(0);
                },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top:20, bottom:20),
                    child:Text(
                  "Create Account",
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
                    TextButton(
                      onPressed: () {
                        exit(0);
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(left: 85, right: 85, top:20, bottom:20),
                          child:Text(
                            "Login",
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
                TextButton(
                onPressed: () {
                  GuestLogin();
                },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top:20, bottom:20),
                    child:Text(
                  "Continue as guest",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                  ),
                )),
              )]
          ),
        ),
            // This trailing comma makes auto-formatting nicer for build methods.
          ])
        ))
    );
  }
}
