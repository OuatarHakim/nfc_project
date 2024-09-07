# Application Flutter de Lecture des Cartes Étudiant via NFC

Cette application Flutter permet de lire les cartes NFC des étudiants lors d'examens, d'enregistrer les informations dans des feuilles Excel sur Google Sheets, et de générer un fichier PDF récapitulatif pour chaque session d'examen.

## Fonctionnalités

- **Lecture NFC des cartes d'étudiant** : Scannez les cartes NFC pour récupérer l'identifiant de l'étudiant.
- **Enregistrement des présences dans Google Sheets** : Un fichier Excel est automatiquement créé sur Google Sheets pour chaque examen.
- **Vérification des doublons** : L'application vérifie si un étudiant est déjà inscrit dans le fichier de l'examen.
- **Saisie manuelle des informations** : Si l'étudiant n'est pas trouvé, le nom et le prénom peuvent être ajoutés manuellement après la lecture de la carte.
- **Génération de PDF** : À la fin de chaque examen, un fichier PDF est généré avec la liste des présences.
- **Gestion par examen et horaire** : Chaque fichier Excel et PDF est organisé par examen et par heure.

## Prérequis

### Outils nécessaires
- **Flutter** : Installez Flutter en suivant [les instructions officielles](https://flutter.dev/docs/get-started/install).
- **Google Sheets API** : Pour stocker et gérer les données d'étudiants.
- **NFC** : L'application nécessite un appareil compatible avec la technologie NFC pour lire les cartes des étudiants.

### Configurer l'API Google Sheets
1. Allez sur [Google Cloud Console](https://console.cloud.google.com/).
2. Créez un projet et activez l'API Google Sheets.
3. Créez des identifiants OAuth 2.0 ou une clé API pour l'API.
4. Téléchargez le fichier `credentials.json` et ajoutez-le dans votre projet.
