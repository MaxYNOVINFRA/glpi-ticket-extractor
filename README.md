# GLPI Ticket Extractor - Script PowerShell

## Description
Ce script PowerShell permet d'automatiser l'extraction des tickets depuis l'API REST de GLPI.  
Il filtre les tickets ayant les statuts "Nouveau", "En cours" et "En attente de validation", puis exporte les informations principales dans un fichier CSV pour un reporting clair et rapide.

## Prérequis
- Windows avec PowerShell (version 5.1 ou supérieure).
- Accès réseau au serveur GLPI.
- Tokens d'authentification GLPI :
  - App Token
  - User Token
- API REST activée sur votre instance GLPI.

## Installation
1. Cloner ce dépôt ou télécharger le fichier `glpi_ticket_extraction.ps1`.
2. Ouvrir le fichier dans un éditeur de texte (ex : Visual Studio Code ou Powershell ISE).
3. Modifier les variables suivantes au début du script :
   - `$glpi_url` : URL de votre API GLPI (ex: `http://X.X.X.X/glpi/apirest.php`).
   - `$app_token` : Votre App Token.
   - `$user_token` : Votre User Token.

## Utilisation
1. Ouvrir PowerShell en tant qu'administrateur.
2. Exécuter le script à l'aide de la commande suivante :
   ```bash
   .\glpi_ticket_extraction.ps1
