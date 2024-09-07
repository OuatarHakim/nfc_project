import 'package:flutter/material.dart';
import 'package:nfc_project/google_sheet_service.dart';
class AddStudentPage extends StatefulWidget {
  final String id;
  final String title;
  const AddStudentPage({Key? key, required this.id,required this.title}) : super(key: key);
  @override
  _AddStudentPageState createState() => _AddStudentPageState();

}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late GoogleSheetService _googleSheetService;

  @override
  void initState() {
    super.initState();
    _googleSheetService = GoogleSheetService();
    _googleSheetService.init();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un étudiant'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Appeler une fonction pour ajouter l'étudiant avec les données saisies
                _addStudent();
              },
              child: Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _addStudent() {

    String id = widget.id;
    String title = widget.title;
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;
    print(id + firstName + lastName + email);
    // Vérifier si les champs sont vides
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Veuillez remplir tous les champs'),
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
      return;
    }


    _googleSheetService.addStudent(id, firstName, lastName,email,title);

    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();

    // Afficher une confirmation à l'utilisateur
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text('L\'étudiant a été ajouté avec succès'),
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
  }
}
