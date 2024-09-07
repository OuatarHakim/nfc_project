import 'package:flutter/material.dart';
import 'package:nfc_project/google_sheet_service.dart';
import 'package:nfc_project/add_student.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCReaderPage extends StatefulWidget {
  @override
  _NFCReaderPageState createState() => _NFCReaderPageState();
}

class _NFCReaderPageState extends State<NFCReaderPage> {
  Map<String, dynamic>? _tagData;
  String? id;
  late GoogleSheetService _googleSheetService;

  @override
  void initState() {
    super.initState();
    _googleSheetService = GoogleSheetService();
    _googleSheetService.init();
    _initNFC();
  }
  Future<void> _checkStudentExistence(String? id) async {
    String? title = await _googleSheetService.checkCurrentExam();
    if(title == null){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pas d\'examen'),
            content: Text('Veuillez vérifier l\'horaire de votre examen!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }else{
      bool? exists = await _googleSheetService.checkStudentExistence(id!,title);

      if (exists == true ) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Étudiant Présent '),
              content: Text('Étudiant présent dans la liste d\'examen  '+ title),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        print('Étudiant trouvé');
      } else {
        // L'étudiant n'existe pas, naviguez vers l'écran d'ajout d'étudiant.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddStudentPage(id: id ,title : title),
          ),
        );
      }
    }

  }
  Future<void> _initNFC() async {
    try {
      bool isNfcAvailable = await NfcManager.instance.isAvailable();
      if (isNfcAvailable) {
        await NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            setState(() {
              _tagData = tag.data.map((key, value) => MapEntry(key.toString(), value));
              List<int>? identifierList = tag.data['nfca']?['identifier'];
              if (identifierList != null) {
                id = identifierList.join(':');
                _checkStudentExistence(id);

              }

            });
          },
        );


      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Erreur NFC"),
              content: Text("NFC n'est pas disponible sur cet appareil."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } on PlatformException catch (ex) {
      print('Erreur NFC: $ex');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erreur NFC"),
            content: Text("Impossible de démarrer la session NFC. Veuillez réessayer."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
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
            Expanded(
              child: _buildTagInfoWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagInfoWidget() {
    if (_tagData != null && _tagData!.isNotEmpty) {
      return ListView(
        children: _tagData!.entries.map((entry) {
          if (entry.key == 'nfca') {
            return ListTile(
              title: Text('Identifier'),
              subtitle: Text(id ?? 'N/A'),
            );
          } else {
            return ListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value.toString()),
            );
          }
        }).toList(),
      );
    } else {
      return Text('Aucune donnée NFC disponible.');
    }
  }


  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
}