import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:developer' as developer;

void main() {
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
      home: NFCReaderPage(),
    );
  }
}

class NFCReaderPage extends StatefulWidget {
  @override
  _NFCReaderPageState createState() => _NFCReaderPageState();
}

class _NFCReaderPageState extends State<NFCReaderPage> {
  Map<String, dynamic>? _tagData;

  @override
  void initState() {
    super.initState();
    _initNFC();
  }

  Future<void> _initNFC() async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          setState(() {
            _tagData = tag.data.map((key, value) => MapEntry<String, dynamic>(key.toString(), value));
            developer.log(_tagData.toString());
          });
        },
      );
    } on PlatformException catch (ex) {
      print('Erreur NFC: $ex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenue au LECTURE NFC',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Informations de la carte NFC:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            _buildTagInfoWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTagInfoWidget() {
    if (_tagData != null && _tagData!.isNotEmpty) {
      List<String> technologies = _tagData!.keys.toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type de tag : ${technologies[0]}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Technologies disponibles : ${technologies.join(", ")}',
          ),
          SizedBox(height: 10),
          _buildNfcaInfoWidget(),
        ],
      );
    } else {
      return Text('Aucune donnée NFC disponible.');
    }
  }

  Widget _buildNfcaInfoWidget() {
    Map<String, dynamic>? nfcaInfo = _tagData!['nfca'];
    if (nfcaInfo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: nfcaInfo.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value.toString()),
          );
        }).toList(),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
}
