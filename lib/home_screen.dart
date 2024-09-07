import 'package:flutter/material.dart';
import 'package:nfc_project/examen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenue dans l\'application NFC!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Ajouter ici l'image
            Image.asset('assets/images/logo.jpg'),
            SizedBox(height: 20), // Espace entre l'image et le bouton
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {}, // Pas d'action pour le bouton d'accueil
                icon: Icon(Icons.home), // Icône de la maison
                label: Text('Accueil'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigation vers l'écran de lecture NFC
                  Navigator.pushNamed(context, '/nfc_reader');
                },
                icon: Icon(Icons.credit_card), // Icône de carte NFC
                label: Text('NFC'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigation vers l'écran d'affichage des examens
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamenScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.library_books), // Icône de livre pour les examens
                label: Text('Liste'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
