import 'package:flutter/material.dart';
import 'package:food_token/tokenIssueScreen.dart';
import './qrScanner.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CESS Food Token',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Scan QR Code'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title = "Null"}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int screen = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
//        body: Center(child: QRViewExample()));
//        body: Center(child: TokenIssueScreen()));
        body: Column(children: [
            Expanded(child: (screen == 0) ? QRViewExample() : TokenIssueScreen()),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  screen = 1 - screen;
                });
              },
              child: Text("Switch Role"))
        ]));
  }
}
