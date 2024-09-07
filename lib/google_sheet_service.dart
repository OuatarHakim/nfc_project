import 'dart:io';

import 'package:gsheets/gsheets.dart';
import 'package:permission_handler/permission_handler.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:nfc_project/pdf_generator.dart';
import 'package:pdf/pdf.dart' as pw;
import 'models/Exam.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
class GoogleSheetService {
  final String _credentials = r'''
  {
  "type": "service_account",
  "project_id": "",
  "private_key_id": "",
  "private_key": "",
  "client_email": "",
  "client_id": "",
  "auth_uri": "",
  "token_uri": "",
  "auth_provider_x509_cert_url": "",
  "client_x509_cert_url": "",
  "universe_domain": ""
}
 
  ''';

  final String _spreadsheetId = '';

  late GSheets _gsheets;
  Spreadsheet? _spreadsheet;
  late List<Worksheet> _worksheets;

  GoogleSheetService() {
    _gsheets = GSheets(_credentials);
  }

  Future<void> init() async {
    _spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheets = _spreadsheet!.sheets;
  }

  Future<bool?> checkStudentExistence(String id, String titre) async {
    try {
      if (_spreadsheet == null) throw Exception('Spreadsheet not initialized');
      final worksheet = _spreadsheet!.worksheetByTitle(titre);
      final columnValues = await worksheet?.values.column(1);

      print('Column values: $columnValues');

      return columnValues?.contains(id);
    } catch (e) {
      print('Error checking student existence: $e');
      return false;
    }
  }

  Future<void> addStudent(String id, String firstName, String lastName,
      String email, String titre) async {
    try {
      if (_spreadsheet == null) {
        throw Exception('Spreadsheet not initialized');
      }

      final worksheet = _spreadsheet!.worksheetByTitle(titre);
      final newRow = [id, firstName, lastName, email];

      await worksheet?.values.appendRow(newRow);

      print('Student added successfully');
    } catch (e) {
      print('Error adding student: $e');
    }
  }


  Future<void> updateStudent(String id, String firstName,
      String lastName) async {
    try {
      if (_spreadsheet == null) throw Exception('Spreadsheet not initialized');

      final worksheet = _spreadsheet!.worksheetByTitle('module_iwocs_1012');
      final columnValues = await worksheet?.values.column(1);
      final rowIndex = columnValues?.indexWhere((value) => value == id);
      if (rowIndex != -1) {
        final newRow = [id, firstName, lastName];
        await worksheet?.values.insertRow(rowIndex! + 1, newRow);
      }
    } catch (e) {
      print('Error updating student: $e');
    }
  }

  Future<void> addExam(String moduleName, String formation, String heuredebut,
      String heurefin) async {
    try {
      if (_spreadsheet == null) {
        throw Exception('Spreadsheet not initialized');
      }

      // Construction du nom de la feuille en remplaçant les espaces par des underscores
      String sheetName = moduleName + '_' + formation + '_' + heuredebut + '_' +
          heurefin;

      // Vérification si la feuille existe déjà
      bool sheetExists = _worksheets.any((worksheet) =>
      worksheet.title == sheetName);
      if (sheetExists) {
        print('La feuille $sheetName existe déjà.');
        return;
      }

      // Création de la feuille
      await _spreadsheet!.addWorksheet(sheetName);
      print('Feuille $sheetName créée avec succès.');
    } catch (e) {
      print('Error adding exam: $e');
    }
  }

  Future<List<Exam>> getExams() async {
    try {
      List<Exam> exams = [];

      if (_spreadsheet == null) throw Exception('Spreadsheet not initialized');

      for (var worksheet in _worksheets) {
        String title = worksheet.title;
        List<String> parts = title.split('_');

        if (parts.length == 4) {
          String moduleName = parts[0];
          String formation = parts[1];
          String heure_debut = parts[2];
          String heure_fin = parts[3];

          exams.add(Exam(moduleName, formation, heure_debut, heure_fin));
        }
      }

      return exams;
    } catch (e) {
      print('Error getting exams: $e');
      return [];
    }
  }

  Future<String?> checkCurrentExam() async {
    try {
      if (_spreadsheet == null) throw Exception('Spreadsheet not initialized');

      // Obtenir l'heure actuelle au format HH:mm (ex: 08:28)
      String currentTime = DateFormat('HH:mm').format(DateTime.now());

      // Parcourir les feuilles de calcul pour vérifier si l'heure actuelle est dans la plage horaire
      for (Worksheet worksheet in _worksheets) {
        String title = worksheet.title!;
        if (title.contains('_')) {
          List<String> parts = title.split('_');
          if (parts.length == 4) {
            String horaireStart = parts[2]; // Heure de début de la plage horaire
            String horaireEnd = parts[3]; // Heure de fin de la plage horaire

            // Vérifier si l'heure actuelle est dans la plage horaire de cette feuille avec une marge de 15 minutes
            if (isWithinMargin(currentTime, horaireStart, horaireEnd, 15)) {
              return title;
            }
          }
        }
      }
      return null; // Aucun examen actuel dans la plage horaire
    } catch (e) {
      print('Error checking current exam: $e');
      return null;
    }
  }

  bool isWithinMargin(String currentTime, String horaireStart,
      String horaireEnd, int margin) {
    int startMinutes = int.parse(horaireStart.substring(0, 2)) * 60 +
        int.parse(horaireStart.substring(3));
    int endMinutes = int.parse(horaireEnd.substring(0, 2)) * 60 +
        int.parse(horaireEnd.substring(3));

    int currentMinutes = int.parse(currentTime.substring(0, 2)) * 60 +
        int.parse(currentTime.substring(3));

    return currentMinutes >= (startMinutes - margin) &&
        currentMinutes <= (endMinutes + margin);
  }






  Future<void> generateExamPdf(String title) async {
    try {
      // Demander la permission d'accéder au stockage externe
      var status = await pw.Permission.storage.request();
      if (!status.isGranted) {
        // La permission a été refusée, affichez un message à l'utilisateur
        print('Permission to access storage denied');
        return;
      }

      // Récupérer le répertoire de stockage externe
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        // Le répertoire est null, gérer l'erreur
        print('Error getting external storage directory');
        return;
      }

      String path = directory.path;

      // Créer un nouveau document PDF
      final pdf = pw.Document();

      // Ajouter une nouvelle page au document PDF
      pdf.addPage(
        pw.Page(
          // Définir le contenu de la page
          build: (pw.Context context) {
            // Ajouter le titre de l'examen
            return pw.Center(
              child: pw.Text(
                'Liste des étudiants pour l\'examen: $title',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            );
          },
        ),
      );

      // Enregistrer le document PDF sous forme de fichier
      final pdfFile = File('$path/$title.pdf');
      await pdfFile.writeAsBytes(await pdf.save());

      print('PDF saved at: ${pdfFile.path}');
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

}


