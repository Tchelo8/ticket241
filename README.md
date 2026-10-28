# Ticket241 — application mobile

Billetterie d'événements au Gabon : parcourir les événements, acheter avec ou sans compte
(Airtel Money, Moov Money), retrouver ses billets et leur QR code.

- **Technique :** Flutter, avec Provider pour l'état et go_router pour la navigation. Toutes les données viennent de l'API Ticket241 (gateway) : aucune donnée fictive.
- **Identifiant de l'application :** `ga.ticket241.app`, sur Android comme sur iOS.

## Configuration

Le fichier `.env` à la racine contient les adresses du serveur :

| Clé | Rôle |
|---|---|
| `URL_LOCAL_BASE` | Émulateur Android (`http://10.0.2.2:8080`) |
| `URL_TEST_BASE` | Téléphone physique en test (`--dart-define=ENV=test`) |
| `URL_PROD_BASE` | Version publiée : toujours utilisée en mode release |
| `URL_SITE_PUBLIC` | Site public, pour les liens de partage. Facultatif : sans lui, le partage ne contient pas de lien |

Ce fichier est intégré à l'application : il ne doit contenir **aucun secret**, seulement des adresses publiques.

## Lancer l'application

```bash
flutter run                               # émulateur Android
flutter run --dart-define=ENV=test        # téléphone branché en USB (avec adb reverse tcp:8080 tcp:8080)
```

## Vérifier

```bash
flutter analyze
flutter test
```

## Publier

La version Android est encore signée avec la clé de debug. Avant de publier sur Google Play, il faut :
1. créer une clé de signature propre au projet ;
2. la déclarer dans `android/app/build.gradle.kts`.
