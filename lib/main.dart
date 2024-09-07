import 'package:flutter/material.dart';

import 'package:nfc_project/home_screen.dart';

import 'package:nfc_project/nfc_reader.dart';

void main()  async{
  runApp(MyApp());


}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: '/',
      routes:{
        '/': (context) => HomeScreen(),
        '/nfc_reader': (context) => NFCReaderPage(),

      },

    );
  }
}
