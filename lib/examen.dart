import 'package:flutter/material.dart';
import 'package:nfc_project/google_sheet_service.dart';
import 'models/Exam.dart';

class ExamenScreen extends StatefulWidget {
  @override
  _ExamenScreenState createState() => _ExamenScreenState();
}

class _ExamenScreenState extends State<ExamenScreen> {
  late GoogleSheetService _googleSheetService;
  late Future<List<Exam>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _googleSheetService = GoogleSheetService();
    _examsFuture = _initializeAndGetExams();
  }

  Future<List<Exam>> _initializeAndGetExams() async {
    await _googleSheetService.init();
    return _googleSheetService.getExams();
  }

  Widget _buildExamList(List<Exam> exams) {
    return ListView.builder(
      itemCount: exams.length,
      itemBuilder: (BuildContext context, int index) {
        Exam exam = exams[index];
        String formattedHoraire = formatHoraire(exam.heure_debut, exam.heure_fin);
        return Card(
          margin: EdgeInsets.all(8.0),
          elevation: 4.0,
          child: ListTile(
            leading: Icon(Icons.book, color: Theme.of(context).primaryColor),
            title: Text(
              'Module: ${exam.moduleName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Formation: ${exam.formation}, Horaire: $formattedHoraire',
              style: TextStyle(fontSize: 16),
            ),
            trailing: IconButton(
              icon: Icon(Icons.download),
              onPressed: () {
                String sheetName = exam.moduleName + '_' + exam.formation + '_' + exam.heure_debut + '_' + exam.heure_fin;
                _generateExamPdf(sheetName); // Appel de la méthode pour générer le PDF
              },
            ),
          ),
        );
      },
    );
  }

  String formatHoraire(String heureDebut, String heureFin) {
    if (heureDebut.length != 4 || heureFin.length != 4) return '';
    String debut = heureDebut.substring(0, 2) + ":" + heureDebut.substring(2);
    String fin = heureFin.substring(0, 2) + ":" + heureFin.substring(2);
    return '$debut - $fin';
  }

  void _generateExamPdf(String title) {
    _googleSheetService.generateExamPdf(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Examens'),
      ),
      body: FutureBuilder<List<Exam>>(
        future: _examsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            List<Exam> exams = snapshot.data ?? [];
            return _buildExamList(exams);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExamDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showAddExamDialog(BuildContext context) {
    // Les contrôleurs pour les champs du formulaire
    TextEditingController moduleNameController = TextEditingController();
    TextEditingController formationController = TextEditingController();
    TextEditingController heureDebutController = TextEditingController();
    TextEditingController heureFinController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un examen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: moduleNameController,
                  decoration: InputDecoration(labelText: 'Nom du module'),
                ),
                TextField(
                  controller: formationController,
                  decoration: InputDecoration(labelText: 'Formation'),
                ),
                TextField(
                  controller: heureDebutController,
                  decoration: InputDecoration(labelText: 'Heure de début (HHmm)'),
                ),
                TextField(
                  controller: heureFinController,
                  decoration: InputDecoration(labelText: 'Heure de fin (HHmm)'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Placeholder pour l'ajout de l'examen
                String moduleName = moduleNameController.text;
                String formation = formationController.text;
                String heureDebut = heureDebutController.text;
                String heureFin = heureFinController.text;
                String examName = '$moduleName - $formation - $heureDebut à $heureFin';
                print('Nouvel examen: $examName');

                // Appeler la méthode pour ajouter l'examen dans Google Sheets
                _googleSheetService.addExam(moduleName, formation, heureDebut,heureFin); // Appel de la méthode addExam
                Navigator.of(context).pop();
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
