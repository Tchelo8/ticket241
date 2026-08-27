# Passation : Redesign Ticket241

## Vue d'ensemble

Redesign complet de **Ticket241**, application Flutter de billetterie d'événements pour le marché gabonais (français, montants en FCFA, paiement Airtel Money et Moov Money).

Le design remplace l'identité actuelle — couleur unique `#1E90FF` générée automatiquement, fonds blancs plats, police système, ombres grises — par un système éditorial complet : typographie sérif à forte hiérarchie, cyan de presse comme unique accent interactif, magenta comme second ton rare, profondeur par filets et ombres encrées plutôt que par ombres floues. Trois thèmes : **Papier** (clair), **Encre** (sombre) et **Noir & Blanc**.

Dépôt cible : `Tchelo8/ticket241`, branche `main`.

---

## À propos des fichiers de design

Le fichier livré dans ce paquet, `Ticket241 Redesign.dc.html`, est une **référence de design réalisée en HTML** — un prototype navigable qui montre l'apparence et le comportement attendus. **Ce n'est pas du code à porter directement.**

La tâche consiste à **recréer ces écrans en Flutter**, dans l'environnement existant du dépôt : Material 3, `provider` pour l'état, `google_fonts`, `lottie`, `flutter_staggered_animations`, `smooth_page_indicator`, `dio`. Les widgets standards Flutter suffisent partout ; aucune dépendance nouvelle n'est requise.

Le prototype s'ouvre dans un navigateur. Le panneau de gauche permet de sauter à n'importe quel écran, de changer de thème et de basculer les états vides ; le panneau de droite documente les intentions de design.

## Fidélité

**Haute fidélité.** Couleurs, tailles de police, graisses, espacements, rayons, durées et courbes d'animation sont définitifs et listés ci-dessous. À reproduire fidèlement.

Deux écarts assumés à corriger côté Flutter :
- Le prototype dessine un faux QR code ; utiliser le vrai code du billet.
- Les visuels d'événements réutilisent les images du dépôt à titre de remplissage. Les photos réelles viendront de l'API.

---

## Jetons de design

### Couleurs — thème Papier (clair, par défaut)

| Rôle | Valeur | Usage |
| --- | --- | --- |
| `bg` | `#F3F2F2` | Fond d'écran |
| `card` | `#FDFDFC` | Surface de carte, champs de saisie |
| `surf` | `#EAE9E9` | Blocs secondaires, cadres d'états vides, boutons désactivés |
| `ink` | `#201E1D` | Texte principal, pastille de catégorie active |
| `ink2` | `#605D5D` | Texte secondaire, corps de texte |
| `ink3` | `#9B9797` | Texte tertiaire, libellés, icônes inactives |
| `line` | `rgba(32,30,29,0.13)` | Filets, bordures de carte |
| `line2` | `rgba(32,30,29,0.26)` | Bordures de champ, filets appuyés |
| `acc` | `#0088B0` | **Accent cyan** — tout l'interactif |
| `accd` | `#006786` | Cyan pressé / survolé |
| `accs` | `#E4F4FB` | Fond cyan teinté (badges, avatars) |
| `acc2` | `#D6006C` | **Magenta** — alertes rares uniquement |
| `acc2s` | `#FFEEF4` | Fond magenta teinté |
| `onAcc` | `#FFFFFF` | Texte sur aplat cyan |
| `glass` | `rgba(243,242,242,0.82)` + flou 14 px | En-têtes collants, barre de navigation |

### Couleurs — thème Encre (sombre)

| Rôle | Valeur |
| --- | --- |
| `bg` | `#1B1A19` |
| `card` | `#262423` |
| `surf` | `#302E2C` |
| `ink` | `#F5F3F1` |
| `ink2` | `#BAB6B6` |
| `ink3` | `#8A8685` |
| `line` | `rgba(243,242,242,0.14)` |
| `line2` | `rgba(243,242,242,0.28)` |
| `acc` | `#62C5EE` |
| `accd` | `#99E0FF` |
| `accs` | `rgba(98,197,238,0.15)` |
| `acc2` | `#FF90B1` |
| `acc2s` | `rgba(255,144,177,0.15)` |
| `onAcc` | `#11201F` |
| `glass` | `rgba(27,26,25,0.80)` + flou 14 px |

Les images reçoivent `brightness(0.92) saturate(0.95)` en thème Encre — en Flutter, un `ColorFiltered` avec une matrice équivalente, ou plus simplement un `Container` en surimpression à `Colors.black.withOpacity(0.06)`.

### Couleurs — thème Noir & Blanc

| Rôle | Valeur |
| --- | --- |
| `bg` | `#F4F3F2` |
| `card` | `#FFFFFF` |
| `surf` | `#E9E7E5` |
| `ink` | `#141312` |
| `ink2` | `#5C5957` |
| `ink3` | `#96918E` |
| `line` | `rgba(20,19,18,0.18)` |
| `line2` | `rgba(20,19,18,0.40)` |
| `acc` | `#141312` (l'accent devient l'encre) |
| `accd` | `#000000` |
| `accs` | `#E6E3E0` |
| `acc2` | `#4A4644` |
| `onAcc` | `#FFFFFF` |

Toutes les images passent en `grayscale(1) contrast(1.12) brightness(1.02)` — en Flutter, `ColorFiltered` avec `ColorFilter.matrix` en niveaux de gris. Ce thème sert aux tests d'accessibilité et à l'impression.

### Ombres

| Jeton | Papier / N&B | Encre |
| --- | --- | --- |
| `sh` | `0 1px 2px rgba(45,43,43,0.10)` | `0 1px 2px rgba(0,0,0,0.50)` |
| `shm` | `0 4px 14px rgba(45,43,43,0.11)` | `0 6px 18px rgba(0,0,0,0.50)` |
| `shl` | `0 14px 38px rgba(45,43,43,0.16)` | `0 16px 40px rgba(0,0,0,0.60)` |

Aucune ombre au-delà de ces trois. Une carte porte **toujours** un filet 1 px `line` en plus de son ombre — c'est le filet qui la détache, l'ombre ne fait que la soulever.

### Typographie

**Une seule famille : Source Serif 4** (variable, italique vraie). Aucune police sans empattement — le sérif *est* la chrome de l'interface.

```dart
GoogleFonts.sourceSerif4TextTheme()
```

| Usage | Taille | Graisse | Interligne | Interlettrage |
| --- | --- | --- | --- | --- |
| Titre d'écran (Accueil, Explorer, Favoris…) | 30 | 600 | 1.0 | −0.028em |
| Titre de héros (onboarding, états vides) | 40 / 29 | 600 | 1.04 / 1.08 | −0.025em |
| Titre de détail d'événement | 34 | 600 | 1.04 | −0.030em |
| Titre d'affiche (carrousel) | 27 | 600 | 1.08 | −0.024em |
| Titre de section | 23 | 600 | — | −0.020em |
| Titre de carte | 16.5 / 14.5 | 600 | 1.20 | −0.016em |
| Corps de texte | 15 – 16 | 400 | 1.5 – 1.6 | — |
| Libellé de champ | 12.5 | 500 | — | — |
| Sur-titre en capitales | 9.5 – 11 | 600 – 700 | — | +0.14 à +0.20em, majuscules |
| Prix, dates, références | 12.5 – 24 | 500 – 700 | — | chiffres tabulaires |

Les chiffres (prix, dates, compteurs, références de billet) sont **toujours** en tabulaires alignés :

```dart
TextStyle(fontFeatures: [FontFeature.tabularFigures(), FontFeature.liningFigures()])
```

Les titres en deux temps des états vides mettent leur seconde ligne en **italique 400** dans `ink2` — c'est la signature du système. Exemple : « Rien de gardé » / *« pour l'instant. »*

### Espacement et rayons

- Marge d'écran : **22 px** (30 px sur les écrans de formulaire et d'états vides)
- Écart entre cartes : **14 – 16 px**
- Rayons : **4 px** boutons et champs · **6 px** cartes · **8 px** affiches et cadres d'états vides · **16 px** haut des feuilles modales · **99 px** pastilles
- Hauteurs de contrôle : bouton principal **54 – 56 px** · champ de saisie **52 – 58 px** · pastille de filtre **38 px** · cible tactile minimale **44 px**

### Icônes

**Phosphor Icons, graisse duotone** partout, sauf les états actifs (cœur aimé, onglet de navigation actif, coches de validation) qui passent en **fill**.

Paquet Flutter : `phosphor_flutter`. `PhosphorIcons.heart(PhosphorIconsStyle.duotone)` / `.fill`.

Tailles : 15 – 17 px en ligne · 19 – 21 px dans les boutons et listes · 23 px dans la barre de navigation · 56 – 88 px dans les états vides.

---

## Écrans

Seize écrans, dans l'ordre du parcours.

### 1. Splash

**Rôle** — ouverture de l'app, 2,1 s avant l'onboarding.

Logo `logo.png` centré, largeur 196 px, apparition en `t-pop` (échelle 0.6 → 1.06 → 1, 700 ms, `cubic-bezier(.2,.8,.2,1)`). Sous le logo, « La billetterie du Gabon » en italique 15 px `ink2`. À 44 px en dessous, une barre de progression de 132 × 2 px : rail `line`, remplissage `acc` animé de 6 % à 100 % en 1,9 s. En pied d'écran, « LIBREVILLE · GABON » en 10.5 px capitales espacées 0.20em `ink3`.

### 2. Onboarding

**Rôle** — trois écrans de présentation, glissables.

**Structure** — c'est un vrai carrousel, pas trois écrans successifs : les trois volets sont posés côte à côte sur un rail unique qui se déplace sous un cadre fixe. Le bouton d'avancement, les indicateurs et « Passer » **ne bougent pas** pendant le glissement. C'est essentiel : la version précédente déplaçait tout l'écran et donnait la sensation de quitter l'app.

En Flutter : `PageView` avec les indicateurs et le bouton **en dehors** du `PageView`, dans la `Column` parente.

**Chaque volet** — image en haut sur 428 px, avec un dégradé vers le fond (`transparent` à 40 % → `bg` à 99 %) qui fond l'image dans la page. Puis, à 30 px de marge : sur-titre cyan en capitales (Découvrir / Payer / Entrer), titre 40 px, corps 16 px `ink2`.

Contenu :
1. **Découvrir** — « Tout ce qui se joue au Gabon, ce soir. » — image `jazz.png`
2. **Payer** — « Airtel Money ou Moov Money. Rien d'autre. » — image `party.png`
3. **Entrer** — « Votre billet vit dans votre poche. » — image `queue.png`, en `contain`

**Indicateurs** — trois barres de 3 px de haut, cyan. La barre active mesure 26 px, les autres 8 px à 28 % d'opacité. Leur largeur et leur opacité **s'interpolent en continu** selon la position réelle du rail : `largeur = 8 + 18 × proximité`, où `proximité = max(0, 1 − |index − position|)`. Elles se transforment donc progressivement pendant le geste au lieu de sauter à la fin.

`smooth_page_indicator` avec `WormEffect` ou `ExpandingDotsEffect` donne ce comportement.

**Geste** — glissement libre suivant le doigt, seuil de validation 58 px, résistance élastique × 0.34 aux deux extrémités, retour amorti en 420 ms `cubic-bezier(.22,1,.28,1)`. Un glissement vers la gauche depuis le troisième volet mène à la connexion. Les indicateurs sont cliquables.

**Bouton** — cercle cyan de 62 px, flèche droite 25 px, ombre `shm`. « Passer » en haut à droite : pastille `rgba(0,0,0,0.42)` avec flou d'arrière-plan.

### 3. Connexion

**Rôle** — entrée par numéro et mot de passe.

Logo 118 px en tête. Sur-titre « CONNEXION », titre « Bonsoir. » en 38 px, sous-titre « Votre numéro et votre mot de passe suffisent. »

**Champ téléphone** — hauteur 58 px, fond `card`, bordure `line2`, rayon 4 px, ombre `sh`. À gauche, l'indicatif « +241 » en 17 px 600 `ink2`, puis un filet vertical de 24 px, puis la saisie en chiffres tabulaires.

**Champ mot de passe** — même gabarit, icône `lock-key` à gauche, bouton œil (`eye` / `eye-slash`) à droite pour révéler. « Mot de passe oublié ? » aligné à droite en dessous, 13 px cyan.

**Boutons** — « Se connecter » en aplat cyan 56 px. Séparateur « OU » entre deux filets. « S'inscrire » en contour, 52 px, avec l'icône `user-plus`.

Mention légale en 12.5 px `ink3` avec les liens en cyan.

**Entrée en cascade** — tous les blocs montent de 26 px en fondu, décalés de 50 ms chacun. `flutter_staggered_animations` : `AnimationLimiter` + `SlideAnimation` + `FadeInAnimation`.

### 4. Inscription

**Rôle** — création de compte.

Retour à gauche, logo 34 px à droite. Sur-titre « INSCRIPTION », titre « Créons votre compte. »

Champs, dans l'ordre : **Prénom** et **Nom** sur une même ligne (écart 11 px), **Adresse e-mail** (icône `envelope-simple`), **Numéro de téléphone** (indicatif +241, avec la mention « Ce numéro recevra vos billets et vos demandes de paiement. »), **Mot de passe** (8 caractères minimum).

**Jauge de robustesse** — sous le mot de passe, une barre de 3 px et un libellé. Le score se calcule sur trois critères : longueur ≥ 8, présence d'une majuscule, présence d'un chiffre ou d'un symbole. Score 1 → « Trop faible » en magenta et 33 % de largeur ; score 2 → « Correct » en `ink2` et 67 % ; score 3 → « Solide » en cyan et 100 %. Transition de largeur et de couleur en 300 ms.

Case d'acceptation des conditions, puis bouton sticky en pied : **« Créer mon compte »**, désactivé (fond `surf`, texte `ink3`, curseur interdit) tant que les cinq champs et la case ne sont pas valides. En dessous, « Déjà un compte ? Se connecter ».

La validation mène à l'écran OTP en reprenant le numéro saisi.

### 5. Vérification OTP

Retour en haut. Titre « Le code, s'il vous plaît. », sous-titre rappelant le numéro.

**Quatre cases** de 74 px de haut, fond `card`, rayon 4 px. La case en attente de saisie porte une bordure **cyan** ; les autres, `line2`. Le chiffre est en 30 px 600 tabulaire.

Sous les cases : « Renvoyer dans 0:27 » à gauche, « Effacer » en cyan à droite.

**Pavé numérique** intégré — grille 3 × 4, touches de 56 px, fond `card`, filet `line`, chiffre 21 px. La dernière ligne porte une case vide, le 0, puis « ← ». À la quatrième saisie, bascule automatique vers l'Accueil après 340 ms.

### 6. Accueil

**Rôle** — feed de découverte.

**En-tête** — non collant : il défile avec le contenu et disparaît vers le haut. Sélecteur de ville en pastille (fond `card`, filet `line`, icône `map-pin` cyan, nom en 16 px 600, chevron qui pivote à 180° à l'ouverture) et cloche de notifications à droite (cercle 40 px avec un point magenta de 6 px quand il y a du nouveau).

**Ligne de date** — filet épais 3 px `ink`, puis « Mercredi 26 août » à gauche et « Estuaire · 24 events » à droite en 10 px capitales espacées, puis filet fin 1 px `ink`. C'est la « furniture » de presse du système : à conserver telle quelle.

**Barre de recherche** — pastille de 50 px, fond `card`, filet `line2`, texte d'invite « Concert, match, festival… ». Simple bouton : elle mène à Explorer.

**À l'affiche** — carrousel horizontal d'affiches de 349 px de large, avec accrochage centré (`scroll-snap-align: center`). Chaque affiche : image de 236 px sous un dégradé montant `rgba(12,11,10,0.86)` → transparent, jauge en haut à gauche (« PRESQUE COMPLET » en magenta, « NOUVEAU »), bloc de date en haut à droite (52 px, fond blanc à 94 %, jour en 21 px 700, mois en 9.5 px cyan), et en bas le sur-titre de catégorie, le titre 27 px et le lieu. Sous l'image, une bande de 13 px : trois avatars empilés (chevauchement −8 px, filet 1.5 px de la couleur de la carte), le nombre d'intéressés, et le prix « dès 15 000 FCFA » à droite.

Sous le carrousel, des indicateurs cyan identiques à ceux de l'onboarding (24 px actif, 8 px à 28 %).

En Flutter : `PageView` avec `viewportFraction ≈ 0.89` et `padEnds: false`.

**Tendances actuelles** — classement de 4 lignes filetées. Rang en 22 px 700 `ink3`, vignette de 52 px, titre 15.5 px, et sous le titre la progression sur 24 h en magenta 600 (« +186 % ») suivie de la date. Prix à droite. En-tête de section avec la mention « ↗ 24 h » en magenta.

**Cette semaine** — rangée horizontale de cartes de 214 px : image de 132 px avec le cœur en haut à droite, puis date en capitales cyan, titre 16.5 px sur une ligne tronquée, lieu et prix.

**Concerts** et **Sport** — même gabarit de rangée. Leur « Tout voir » ouvre Explorer avec le filtre de catégorie déjà appliqué.

**Le calendrier** — liste filetée : colonne de date à gauche (jour en 24 px 700, mois en 9.5 px capitales), filet vertical de 42 px, titre et heure au centre, vignette de 58 px à droite.

**Bloc organisateur** — encadré `surf` avec filet `line2` : « Vous organisez un événement ? » et le bouton contour « Créer un événement ».

**Rafraîchissement par tirage** — depuis le haut de la liste : une pastille cyan de 38 px descend, sa flèche pivote proportionnellement au tirage (jusqu'à 180°), le contenu se décale de 60 % du tirage. Seuil 62 px ; au relâchement passé le seuil, l'icône devient `circle-notch` en rotation continue pendant 1,5 s. En dessous du seuil, retour amorti sans déclenchement. En Flutter : `RefreshIndicator` avec `color: acc`.

### 7. Explorer

**Rôle** — recherche et filtrage.

**En-tête collant** (celui-ci reste en place) — titre « Explorer », champ de recherche de 46 px avec bouton d'effacement, et bouton de filtres à droite.

**Bouton de filtres** — cercle de 46 px. À l'état neutre : fond `card`, filet `line2`. Dès qu'un filtre est actif : fond `accs`, filet et icône cyan, et un **badge magenta** en haut à droite portant le nombre de filtres actifs.

**Rangée de catégories** — pastilles : Tous, Concert, Sport, Festival, Théâtre, Exposition, chacune avec son icône. Active : fond `ink`, texte `bg`. Inactive : fond `card`, texte `ink2`, filet `line2`.

**Ligne de résultats** — « 6 événements · Libreville » à gauche, tri courant en cyan à droite (ouvre la feuille de filtres).

**Pastilles de filtres actifs** — sous la ligne de résultats, une pastille effaçable par filtre (fond `accs`, filet et texte cyan, croix), plus « Tout effacer » en pointillés.

**Grille** — deux colonnes, écart 14 px. Carte : image de 118 px, cœur en haut à droite, date en capitales cyan 10 px, titre 14.5 px sur deux lignes de hauteur fixe (35 px), lieu, filet séparateur, prix. Les événements passés reçoivent un voile `rgba(12,11,10,0.5)` avec un léger flou et la jauge « PASSÉ » en magenta.

**Aucun résultat** — icône `magnifying-glass` 56 px, « Aucun événement ne correspond », « Essayez d'élargir le budget ou de retirer un filtre. », bouton « Réinitialiser les filtres ».

### 8. Feuille de filtres

**Rôle** — affiner la recherche. Feuille modale par le bas, hauteur maximale 88 %.

Voile `rgba(16,15,14,0.44)` avec flou 3 px. Feuille : fond `bg`, rayons hauts 16 px, ombre `shl`, poignée de 42 × 4 px centrée. Entrée en `t-sheet` (translation de 100 % à 0, 380 ms, `cubic-bezier(.2,.8,.2,1)`).

En-tête : sur-titre « AFFINER », titre « Filtres », bouton de fermeture, puis la paire de filets épais/fin.

**Budget maximum** — montant courant en 30 px 600 tabulaire, nombre d'événements concernés à droite, curseur de 2 000 à 20 000 FCFA par pas de 1 000, teinte cyan. Bornes affichées en dessous.

**Quand** — pastilles Tous / Ce mois-ci / Le mois prochain / Plus tard.

**Catégorie** — les mêmes pastilles qu'Explorer.

**Trier par** — liste de trois options avec un cercle de sélection : Date · les plus proches, Prix croissant, Popularité. L'option retenue passe en cyan avec sa coche pleine.

**Annulation gratuite** — interrupteur de 46 × 26 px, rail cyan quand actif, pastille blanche qui glisse de 20 px en 250 ms.

**Pied** — « Réinitialiser » en contour et le bouton cyan d'application, qui annonce le résultat : « Voir 4 événements », ou « Aucun résultat » si le filtrage est vide.

En Flutter : `showModalBottomSheet` avec `isScrollControlled: true` et un `DraggableScrollableSheet`.

### 9. Feuille de sélection de ville

Même gabarit de feuille, hauteur maximale 78 %.

Sur-titre « VOTRE VILLE », titre « Où cherchez-vous ? », puis un bouton pleine largeur « Utiliser ma position actuelle » (pastille contour, icône `crosshair`, texte cyan).

**Liste des villes** — sept lignes filetées : icône propre à la ville, nom en 16.5 px 600, et en dessous la région et le nombre d'événements. La ville courante a son icône et son nom en cyan, plus une coche cyan de 24 px qui apparaît en `t-pop`.

Libreville (Estuaire, 24) · Port-Gentil (Ogooué-Maritime, 11) · Franceville (Haut-Ogooué, 7) · Oyem (Woleu-Ntem, 4) · Lambaréné (Moyen-Ogooué, 3) · Moanda (Haut-Ogooué, 2) · Tchibanga (Nyanga, 2)

Pied : bouton cyan « Voir les événements à Libreville ».

Le choix se répercute sur l'en-tête de l'Accueil, la ligne de date et le compteur d'Explorer.

### 10. Détail d'un événement

**Rôle** — informer et vendre.

**Image hero** — 340 px, avec un dégradé montant vers `bg` qui la fond dans la page. Trois boutons flottants de 42 px en `rgba(20,19,18,0.44)` avec flou : retour à gauche, cœur et partage à droite.

**Contenu remontant sur l'image de 52 px** (`margin-top: -52px`), à 22 px de marge.

Jauges de catégorie (aplat cyan) et « TOUT PUBLIC » (contour). Titre 34 px.

**Bandeau organisateur** — entre deux filets : avatar de 40 px en `accs`, nom en 14.5 px, « Organisateur · 18 événements », bouton « Suivre » en contour.

**Deux cartes d'information** côte à côte — date et lieu, chacune avec son icône cyan de 21 px.

**À propos** — corps 15 px sur 1.6 d'interligne, tronqué à ~190 caractères avec « Lire la suite » / « Voir moins » en cyan.

**Informations générales** — lignes filetées, pas de cartes. Chaque ligne : icône cyan de 21 px, libellé en 10 px capitales espacées `ink3`, valeur en 15 px 500 `ink`. Quatre lignes visibles : **Date** (date complète), **Heure**, **Lieu** (salle et ville), **Places restantes** (« 186 sur 450 ») — cette dernière portant une jauge « BIENTÔT COMPLET » en magenta quand il reste moins de 120 places, « DISPONIBLE » en cyan sinon.

« Voir plus » déplie cinq lignes supplémentaires : **Ouverture des portes**, **Adresse**, **Remboursement** (« Jusqu'à 2 jours avant l'événement »), **Âge minimum**, **Organisateur**. Le chevron pivote à 180°.

C'est la transposition de `_buildGeneralInfoSection` de l'ancien écran, en lignes filetées plutôt qu'en `Column` de `Row` espacées.

**Le lieu** — carte de 132 px avec une épingle magenta au centre, puis le nom, l'adresse et le bouton « Y aller ».

**Billets** — deux cartes sélectionnables : Billet Standard et Pass Carré VIP (prix = standard × 2.4 arrondi au demi-millier). Chaque carte : nom en 15.5 px, prix en 19 px 600, note, et un sélecteur de quantité (bouton − en contour, chiffre en 18 px, bouton + en aplat cyan, tous de 34 px). **Dès que la quantité dépasse zéro, la carte prend une bordure cyan de 1.5 px.**

**Bloc d'annulation** — encadré pointillé, icône `shield-check` cyan, « Annulation gratuite jusqu'à 48 h avant l'événement. »

**Pied sticky** — « TOTAL » et le montant en 21 px à gauche, bouton à droite : « Choisir un billet » désactivé tant qu'aucun billet n'est sélectionné, « Continuer » en cyan dès qu'il y en a un.

**Retour par glissement** depuis le bord gauche (voir « Gestes »).

### 11. Paiement (Checkout)

**Rôle** — l'écran clé du parcours. Coordonnées et règlement.

**En-tête** — retour, « Paiement », « Étape 2 sur 3 · Coordonnées & règlement », et trois barres de progression de 20 px dont deux en cyan.

**Récapitulatif de l'événement** — vignette de 78 px, titre 19 px, date et lieu avec leurs icônes.

**Vos billets** — sur-titre en capitales avec le compte à droite, puis une ligne filetée par type : nom, « 15 000 FCFA × 2 », sélecteur de quantité (boutons de 30 px), total de ligne aligné à droite sur 82 px, et une croix `ink3` pour **retirer entièrement** la ligne. Un type à quantité nulle disparaît de la liste.

**Informations de contact** — « Nom complet » (icône `user`) et « Numéro de téléphone » (indicatif +241). **Un champ invalide porte une bordure magenta** au lieu de `line2` : nom de moins de 3 caractères, numéro de moins de 8 chiffres. Mention « La demande de paiement sera envoyée sur ce numéro. »

**Moyen de paiement** — trois cartes de 14 px de padding, rayon 6 px, fond `card`, logo de 46 px dans un carré blanc :

| Moyen | Logo | Teinte de marque | Note |
| --- | --- | --- | --- |
| Airtel Money | `am.png` | `#E52329` | 074 · 077 · Validation par code secret |
| Moov Money | `mm.jpg` | `#E8622A` | 062 · 065 · Validation par code secret |
| Carte bancaire | icône `credit-card` | `acc` | Visa · Mastercard — bientôt disponible |

**La carte sélectionnée prend une bordure de 2 px à la couleur de la marque du fournisseur, un halo `0 0 0 4px <teinte>22`, et une coche circulaire de 26 px à cette même teinte**, qui apparaît en `t-pop` (320 ms). La carte bancaire est présente mais désactivée : opacité 55 %, curseur interdit — l'emplacement est prêt pour l'extension future, au même gabarit.

**Récapitulatif du prix** — bloc `surf` avec filet : Sous-total, Frais de service (0 FCFA), Réduction · code LBV10 (−10 %, en cyan), filet `line2`, puis **Total** en 24 px 600.

**Annulation gratuite sous 48 h** — encadré avec l'icône `shield-check` cyan et le texte complet : « Annulez jusqu'à 48 heures avant l'événement : remboursement intégral sur votre compte mobile money, sans pénalité. »

**Case de conditions** — carré de 22 px, rayon 3 px, coche blanche sur aplat cyan quand cochée.

**Bouton sticky** — trois états nettement distincts :
- **Désactivé** — fond `surf`, texte `ink3`, aucune ombre, curseur interdit. Sous-titre : « Complétez vos coordonnées et acceptez les conditions ». Conditions d'activation : au moins un billet, case cochée, nom > 2 caractères, numéro ≥ 8 chiffres.
- **Actif** — aplat cyan, ombre `shm`, icône `lock-simple` et « Payer 27 000 FCFA ». Sous-titre : « Une demande sera envoyée sur votre téléphone Airtel Money ».
- **Chargement** — anneau de 19 px en rotation (bordure 2.5 px, `rgba(255,255,255,0.35)` avec le haut en blanc, 800 ms linéaire) et « Connexion à Airtel Money… ». Durée 1,4 s avant la bascule vers l'attente USSD.

### 12. Confirmation mobile money (USSD)

**Rôle** — l'attente réaliste de la validation sur le téléphone. Écran plein, sans barre de navigation.

**Composition centrale** — un carré de 174 px contenant, superposés :
- trois anneaux de pulsation à la teinte du fournisseur, animés en `t-pulse` (échelle 0.72 → 1.9, opacité 0.55 → 0, 2,6 s), **décalés de 0,85 s** l'un sur l'autre pour un effet d'onde continue ;
- un anneau pointillé de 2.5 px tournant en 9 s, opacité 50 % ;
- un anneau de progression de 3 px, `line` avec le haut à la teinte, tournant en 1,1 s ;
- au centre, un disque `card` de 88 px avec l'ombre `shm` portant le logo du fournisseur.

C'est le remplacement du `CircularProgressIndicator` générique. En Flutter, cela se construit avec un `Stack` de `AnimatedBuilder` sur un `AnimationController` en `repeat()`, ou avec un Lottie dédié si tu préfères — mais la composition en anneaux superposés est le rendu voulu.

**Texte** — nom du fournisseur en capitales à sa teinte, titre « Demande envoyée » en 31 px, puis : « Une notification de paiement de **27 000 FCFA** vient d'être envoyée au **+241 074 12 34 56**. » — montant et numéro en 600 `ink`.

**Carte d'instruction** — icône `device-mobile`, « Validez sur votre téléphone en saisissant votre code secret. Sans notification, composez **\*150#** puis suivez le menu. » Le code varie : `*150#` pour Airtel, `*555#` pour Moov, « 3-D Secure » pour la carte.

**Ligne d'attente** — un point de 7 px à la teinte pulsant en opacité (1,4 s), et « En attente de confirmation · 1:27 » en tabulaire, décompté à la seconde depuis 87 s.

**Barre de balayage** — rail de 3 px avec un segment de 34 % qui traverse en boucle (1,7 s, `cubic-bezier(.5,0,.5,1)`).

**Pied** — « Renvoyer la demande » en contour et « Annuler le paiement » en texte `ink3`. L'annulation ramène au Paiement.

Bascule automatique vers le Succès après 5,2 s dans le prototype ; en production, au retour de l'API.

### 13. Confirmation d'achat (Succès)

Cadre d'état avec l'icône `seal-check` cyan de 88 px en `t-pop` (600 ms), entourée de deux `confetti` flottants (magenta et `ink3`) en `t-bob`. Emplacement Lottie annoté « Success.json · 240×240 ».

Titre « Paiement confirmé » en 34 px, puis « 27 000 FCFA débités via Airtel Money. Un SMS de confirmation arrive dans un instant. »

**Carte de billet émis** — vignette de 62 px, sur-titre « BILLET ÉMIS » en cyan, titre, date et nombre de billets. Séparée par un filet pointillé : la référence « TK241-9F42-LBV » en tabulaire espacé et « Voir le QR code » en cyan.

Boutons : « Voir mes billets » en aplat cyan, « Retour à l'accueil » en contour.

### 14. Mes billets

**Onglets** — sélecteur segmenté de 4 px de padding sur fond `surf`, rayon 99 px. **La pastille active est un bloc `card` qui glisse** en 340 ms `cubic-bezier(.22,1,.28,1)` d'une moitié à l'autre — c'est l'animation de transition entre « À venir » et « Passés » demandée. Le libellé actif passe en cyan.

Le contenu de l'onglet se remonte en `t-in` (translation de 14 px et fondu, 420 ms) à chaque bascule. En Flutter : `AnimatedSwitcher` avec un `SlideTransition`, ou `TabBarView` avec un indicateur personnalisé.

**Carte de billet** — vignette de 74 px, jauge de statut (« PAYÉ » en `accs`/cyan, « UTILISÉ » en `surf`/`ink2`), référence à droite, titre 17 px, date et lieu. Les billets passés sont à 72 % d'opacité.

**Encoches de billet** — une bande de 15 px sépare le haut de la carte de son pied : filet pointillé horizontal, et **deux demi-cercles de 16 px découpés dans les bords gauche et droit**, remplis de la couleur du fond avec un filet sur leur face interne. C'est ce qui donne la silhouette de ticket. En Flutter : un `CustomPainter` ou un `ClipPath`.

**Pied de carte** — pastilles « 2 billets » et « J-17 » sur fond `surf`, puis le bouton d'action à droite : « Voir le QR » (icône `qr-code`) pour un billet à venir, « Laisser un avis » (icône `star`) pour un billet passé.

**État vide** — voir le gabarit commun. Le titre s'adapte à l'onglet : « Aucun billet à venir. » ou « Rien dans les archives. »

### 15. Billet en détail (QR)

Fond `surf` pour détacher le billet. En-tête : retour, « Votre billet », partage.

**Le billet** — carte `card` avec l'ombre `shm`, entrée en `t-rise`. Partie haute : sur-titre « TICKET241 · ENTRÉE » en cyan, titre 26 px, date, heure et lieu. Puis la bande d'encoches (18 px, demi-cercles de la couleur `surf`). Partie basse : le QR code sur un carré blanc de 14 px de padding, la référence « TK241-9F42-LBV » en 15 px 600 espacé 0.14em, et « Présentez ce code à l'entrée » en `ink3`.

**Pied de billet** — trois colonnes séparées par des filets : Type / Places / Payé.

Sous le billet : boutons « PDF » (aplat cyan, icône `download-simple`) et « Itinéraire » (contour, icône `map-trifold`), puis le rappel d'annulation sous 48 h.

### 16. Notifications (état vide)

Retour et titre « Notifications ». Puis le gabarit d'état vide : icône `bell-slash` cyan de 82 px avec une `moon-stars` flottante, emplacement Lottie « notif.json », titre « Tout est calme » / *« de ce côté. »*, corps « Nous vous préviendrons pour les mises en vente, les rappels d'événement et vos confirmations de paiement. », et le bouton contour « Gérer mes alertes » (icône `gear`).

### 17. Profil

Titre « Profil ». Avatar de 70 px en `accs` avec les initiales en 24 px cyan, nom en 22 px, numéro en tabulaire, bouton d'édition de 40 px.

**Statistiques** — trois colonnes entre deux filets, séparées par des filets verticaux : nombre en 24 px 700, libellé en 10 px capitales. Billets / Favoris / Villes.

**Compte** — carte de liste : Mes billets, Favoris, Moyens de paiement, Ville par défaut. Chaque ligne : icône cyan de 21 px, libellé 15.5 px, valeur `ink3` à droite, chevron.

**Préférences** — première ligne « Apparence » avec les trois pastilles de thème (Papier / Encre / N&B), la pastille active en aplat `ink`. Puis Notifications, Centre d'aide, Conditions de vente.

**Déconnexion** — bouton contour **magenta** (le seul usage de l'accent secondaire dans un bouton), icône `sign-out`. Puis « Ticket241 · version 2.0.0 » centré.

### 18. Modifier le profil

En-tête avec retour et titre. Avatar de 96 px avec un bouton caméra de 34 px en cyan sur son bord, et « Changer la photo » en dessous.

Quatre champs de 54 px : Nom complet, Numéro de téléphone (**verrouillé**, avec une icône `lock-simple` à droite), Adresse e-mail, Ville. Puis un encadré pointillé : « Le numéro de téléphone sert à recevoir vos billets et vos demandes de paiement mobile money. Sa modification demande une nouvelle vérification. »

Bouton sticky « Enregistrer » en aplat cyan.

---

## Le gabarit d'état vide

**Un seul motif réutilisable sur les trois écrans concernés** — Favoris, Mes billets, Notifications — et repris sur le Succès.

1. **Cadre de repérage** — bloc `surf` avec un filet `line2`, rayon 8 px, et **des coins de presse** : quatre équerres de 13 px en filets de 1.5 px `line2`, placées à 9 px des angles. C'est la citation typographique du système (les repères de coupe d'une plaque d'impression).
2. **L'animation, mise en valeur** — au centre du cadre, une zone de 150 – 158 px. Le prototype y compose des icônes flottantes : une icône principale de 80 – 84 px à l'accent, plus une ou deux icônes secondaires plus petites en positions décalées, animées en `t-bob` / `t-bob2` (translation verticale de 9 px et rotation de ±3°, 2,8 à 4,4 s, déphasées).
3. **Légende de l'emplacement** — sous l'animation, en 9.5 px capitales espacées `ink3` : « EMPLACEMENT LOTTIE · nofav.json · 240×240 ». **À remplacer par le vrai `Lottie.asset()`** — c'est là que viennent tes animations existantes.
4. **Titre en deux temps** — 29 px, la première ligne en 600 `ink`, la seconde en **italique 400** `ink2`. « Rien de gardé » / *« pour l'instant. »*
5. **Une phrase** — 15.5 px `ink2`, jamais deux.
6. **CTA plein** — bouton cyan de 54 px avec son icône : « Explorer les événements » (icône `compass`).
7. **Lien secondaire** — bouton contour de 48 px : « Voir ce qui se passe ce soir ».

Les trois Lottie du dépôt : `nofav.json` (Favoris), `Tickets.json` (Mes billets), `notif.json` (Notifications).

---

## Gestes natifs

### Rafraîchissement par tirage — Accueil

Actif uniquement quand la liste est en haut (`scrollTop ≤ 2`). Le tirage suit le doigt à 55 %, plafonné à 96 px. La pastille descend de −46 px à sa position, son opacité suit `min(1, tirage / 34)`, sa flèche pivote de `min(180°, tirage × 2.9)`. Le contenu se décale de 60 % du tirage. Seuil de déclenchement : 62 px. Retour en 380 ms `cubic-bezier(.2,.8,.2,1)`.

Flutter : `RefreshIndicator(color: acc, onRefresh: …)`.

### Retour par glissement depuis le bord gauche

Actif sur les écrans empilés : Détail, Paiement, Billet QR, Notifications, Inscription, Code OTP, Modifier le profil.

Le geste ne s'amorce que si le contact démarre dans les **34 premiers pixels** depuis le bord gauche — sinon les carrousels horizontaux deviendraient inutilisables. L'écran suit le doigt à 82 % et porte une ombre `-14px 0 34px rgba(20,19,18,0.28)` sur son bord pendant le glissement. Seuil de validation : 96 px. Retour amorti en 340 ms `cubic-bezier(.2,.8,.2,1)`.

Pile de retour : Détail → onglet d'origine · Paiement → Détail · Billet QR → Mes billets · Notifications → Accueil · Modifier le profil → Profil · Inscription → Connexion · OTP → Connexion.

Flutter : c'est le comportement natif de `CupertinoPageRoute`. Sur Android, `PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()})`.

### Glissement de l'onboarding

Voir l'écran 2. `PageView`, avec les indicateurs et le bouton hors du `PageView`.

---

## Animations et transitions

| Nom | Effet | Durée | Courbe | Où |
| --- | --- | --- | --- | --- |
| `t-in` | translation 14 px + fondu | 420 ms | `cubic-bezier(.2,.8,.2,1)` | Bascule des onglets de billets |
| `t-fade` | fondu simple | 250 – 400 ms | — | Changement d'écran |
| `t-rise` | translation 26 px + fondu | 500 ms | `cubic-bezier(.2,.8,.2,1)` | Entrée de contenu, états vides |
| `t-sheet` | translation 100 % → 0 | 380 – 420 ms | `cubic-bezier(.2,.8,.2,1)` | Feuilles modales |
| `t-pop` | échelle 0.6 → 1.06 → 1 | 300 – 700 ms | `cubic-bezier(.2,.8,.2,1)` | Coches, logo du splash, sceau de succès |
| `t-pulse` | échelle 0.72 → 1.9, opacité → 0 | 2,6 s en boucle | `ease-out` | Anneaux d'attente USSD |
| `t-spin` | rotation 360° | 800 ms – 9 s | linéaire | Chargements, anneaux |
| `t-bob` / `t-bob2` | flottement 9 px + rotation ±3° | 2,8 – 4,4 s | `ease-in-out` | Icônes des états vides |
| `t-sweep` | translation −120 % → 320 % | 1,7 s | `cubic-bezier(.5,0,.5,1)` | Barre de balayage USSD |
| `t-bar` | largeur 6 % → 100 % | 1,9 s | `cubic-bezier(.4,0,.2,1)` | Progression du splash |
| Cascade | `t-rise` décalé de 50 ms | — | — | Listes et formulaires |
| Pression | échelle 0.97 | 160 ms | `cubic-bezier(.2,.8,.2,1)` | Tout élément tactile |
| Survol de carte | translation −3 px, image × 1.045 | 220 / 500 ms | `cubic-bezier(.2,.8,.2,1)` | Cartes d'événement |

`flutter_staggered_animations` couvre la cascade. `InkWell` avec un `AnimatedScale` couvre la pression.

---

## État

| Variable | Type | Rôle |
| --- | --- | --- |
| `screen` | énum de 16 valeurs | Écran courant |
| `tab` | 0 – 4 | Onglet de navigation |
| `theme` | `paper` / `ink` / `mono` | Thème actif — à persister |
| `city` | chaîne | Ville sélectionnée — à persister |
| `cat`, `query` | chaînes | Filtres de catégorie et de recherche |
| `priceMax`, `when`, `sort`, `refundable` | 2000–20000 / énum / énum / booléen | Filtres de la feuille |
| `favIds` | liste d'identifiants | Favoris — déjà géré par `FavoritesProvider` |
| `ticketsTab` | `upcoming` / `past` | Onglet de billets |
| `evId`, `qty` | identifiant, `{std, vip}` | Événement courant et panier |
| `buyerName`, `buyerPhone` | chaînes | Coordonnées d'achat |
| `method` | `airtel` / `moov` / `card` | Moyen de paiement |
| `terms` | booléen | Acceptation des conditions |
| `payStage` | `idle` / `busy` / `ussd` / `done` | Étape du paiement |
| `ussdLeft` | secondes | Décompte d'attente, depuis 87 |
| `infoOpen`, `aboutOpen` | booléens | Dépliage du détail |
| `onb`, `heroIdx` | index | Position des carrousels |
| `citySheet`, `filterSheet` | booléens | Ouverture des feuilles |

Le dépôt utilise déjà `provider` : `AuthProvider` et `FavoritesProvider` existent. Ajouter un `ThemeProvider` (thème + ville, persistés via `shared_preferences`) et un `CheckoutProvider` (panier, coordonnées, moyen, étape de paiement).

### Règles de validation

- **Bouton d'achat actif** — au moins un billet, conditions acceptées, nom > 2 caractères, numéro ≥ 8 chiffres.
- **Champ en erreur** — bordure magenta au lieu de `line2`, sans message : la bordure suffit.
- **Bouton d'inscription actif** — prénom, nom, e-mail contenant `@`, numéro ≥ 8 chiffres, mot de passe ≥ 8 caractères, conditions acceptées.
- **Robustesse du mot de passe** — longueur ≥ 8, majuscule, chiffre ou symbole : un point chacun.

---

## Barre de navigation

Cinq onglets : **Accueil** (`house`), **Explorer** (`magnifying-glass`), **Favoris** (`heart`), **Billets** (`ticket`), **Profil** (`user`).

Fond `glass` avec flou 18 px, filet supérieur `line`. Chaque onglet : icône de 23 px, libellé de 10.5 px, et **une barre de soulignement de 14 × 2 px** sous le libellé — cyan sur l'onglet actif, transparente sinon (transition de 250 ms). L'onglet actif passe son icône en **fill** et son libellé en 600 cyan ; les autres restent en duotone `ink3` 400.

Masquée sur les écrans empilés et le parcours de paiement.

---

## Assets

Déjà dans le dépôt, sous `assets/images/` :

| Fichier | Usage |
| --- | --- |
| `logo.png` | Splash, Connexion, Inscription |
| `logoblanc.png` | Version sur fond sombre — à utiliser en thème Encre |
| `am.png` | Logo Airtel Money |
| `mm.jpg` | Logo Moov Money |
| `map.jpg` | Carte du lieu (à remplacer par une vraie carte) |
| `jazz.png`, `sibang.jpg`, `oiseau.jpg`, `enb.jpg`, `party.png`, `ticketHome.png`, `queue.png` | Visuels d'événements — remplissage, à remplacer par les images de l'API |

Lottie, sous `assets/lottie/` : `nofav.json`, `Tickets.json`, `notif.json`.

**Icônes** — Phosphor duotone. Ajouter `phosphor_flutter` au `pubspec.yaml`.

**Police** — Source Serif 4 via `google_fonts`, déjà présent.

---

## Contenu de démonstration

Neuf événements gabonais crédibles, utilisés dans le prototype :

| Nom | Catégorie | Lieu | Ville | Date | Prix | Places |
| --- | --- | --- | --- | --- | --- | --- |
| Nuit du Jazz de Libreville | Concert | Institut Français | Libreville | Ven. 12 sept. 20:30 | 15 000 | 186 / 450 |
| Sibang Trail 12 K | Sport | Arboretum de Sibang | Libreville | Sam. 6 sept. 06:30 | 5 000 | 312 / 600 |
| Ogooué Fest | Festival | Baie des Tortues | Port-Gentil | Sam. 20 sept. 17:00 | 20 000 | 1480 / 2500 |
| Panthères vs Étalons | Sport | Stade d'Angondjé | Libreville | Dim. 28 sept. 16:00 | 10 000 | 94 / 8500 |
| Nuit Blanche de Franceville | Concert | Place de la Rénovation | Franceville | Sam. 4 oct. 21:00 | 8 000 | 640 / 1200 |
| Marché des Créateurs | Exposition | Jardin Botanique | Libreville | Sam. 30 août 10:00 | 2 000 | 74 / 300 |
| Afrobeat Night · Diaspora Live | Concert | Complexe Bord de Mer | Libreville | Sam. 18 oct. 22:00 | 12 000 | 410 / 1500 |
| Finale Coupe du Gabon · Basket | Sport | Gymnase de Nzeng-Ayong | Libreville | Sam. 11 oct. 18:00 | 6 000 | 220 / 2200 |
| Grand Gospel de la Cathédrale | Concert | Cathédrale Sainte-Marie | Libreville | Sam. 25 oct. 19:00 | 4 000 | 520 / 900 |

Le Pass Carré VIP vaut le prix standard × 2.4 arrondi au demi-millier.

**Format des montants** — séparateur de milliers par espace insécable, suffixe « FCFA » en toutes lettres dans les libellés importants, « F » abrégé dans les listes denses. Exemple : « 15 000 FCFA », « 15 000 F ».

```dart
NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0)
```

---

## Ton de la copie

**Vouvoiement sobre.** Phrases courtes, jamais deux quand une suffit. Aucun point d'exclamation, aucun emoji. Les titres peuvent être des fragments (« Le code, s'il vous plaît. », « Rien de gardé pour l'instant. »). Les explications sont factuelles, pas promotionnelles.

---

## Correspondance avec les fichiers du dépôt

| Écran | Fichiers à reprendre |
| --- | --- |
| Splash / Onboarding | `splash_screen.dart`, `onboarding_screen.dart`, `starting_screen.dart` |
| Connexion / OTP | `login_screen.dart`, `otp_verification_screen.dart` |
| Inscription | **nouveau fichier** — `signup_screen.dart` |
| Accueil | `home_screen.dart`, `main_screen.dart`, `city_selection_popup.dart` |
| Explorer + feuille de filtres | `explorer_screen.dart`, `models/category_model.dart` |
| Favoris | `favorites_screen.dart`, `providers/favorites_provider.dart` |
| Mes billets | `tickets_screen.dart`, `models/ticket_model.dart` |
| Billet QR | `tickets_screen.dart`, `pdf_viewer_screen.dart` |
| Détail | `event_details_screen.dart`, `widgets/event_location_card.dart`, `models/event_model.dart` |
| Paiement + USSD | `checkout_screen.dart`, `bouncing_dots_indicator.dart` |
| Succès | `success_screen.dart` |
| Notifications | `notifications_screen.dart` |
| Profil | `profile_screen.dart`, `providers/auth_provider.dart` |
| Modifier le profil | `edit_profile_screen.dart` |
| Thème | `main.dart` — c'est là que se trouve le `#1E90FF` à remplacer |

---

## Ordre d'implémentation suggéré

1. **Le thème d'abord** — `main.dart` : les trois `ColorScheme`, le `TextTheme` en Source Serif 4, les thèmes de carte, de bouton et de champ. Tout le reste en découle, et le gain est immédiatement visible sur tous les écrans existants.
2. **Les composants partagés** — carte d'événement, gabarit d'état vide, en-tête de section avec ses filets, sélecteur de quantité, feuille modale. Ce sont eux qui reviennent partout.
3. **Accueil et Explorer** — les deux écrans les plus vus.
4. **Détail puis Paiement** — le parcours qui convertit ; le Paiement est l'écran à soigner le plus.
5. **USSD et Succès** — la composition d'anneaux mérite du temps.
6. **Billets, Favoris, Notifications** — avec les trois Lottie dans le nouveau gabarit.
7. **Profil, Modifier le profil, Inscription.**
8. **Les gestes en dernier** — `RefreshIndicator`, `CupertinoPageRoute`, `PageView` de l'onboarding.

---

## Fichiers de ce paquet

- `README.md` — ce document.
- `Ticket241 Redesign.dc.html` — le prototype navigable, à ouvrir dans un navigateur. Panneau de gauche : navigation entre écrans, changement de thème, bascule des états vides. Panneau de droite : notes de conception et points restant à arbitrer.
- `assets/images/` — les visuels utilisés par le prototype, tous déjà présents dans le dépôt.

Le prototype dépend du dossier `_ds/` du projet pour ses jetons de couleur. Si tu l'ouvres hors du projet et que les couleurs manquent, toutes les valeurs sont dans la section « Jetons de design » ci-dessus.

---

## Points restant à arbitrer

- **Rayon des cartes** — 4 à 8 px dans le prototype, contre 2 px dans le système Broadsheet d'origine. Le choix mobile est assumé, mais à valider.
- **Filets de 1 px sur écrans 3×** — vérifier le rendu Flutter ; un `BorderSide(width: 0.5)` peut être plus juste sur haute densité.
- **Position du sélecteur de thème** — actuellement dans Profil › Apparence. Un écran Paramètres dédié serait plus classique.
- **Seuil du bouton « Renvoyer la demande »** — inactif pendant les premières secondes de l'attente USSD ? À caler sur le comportement réel de l'API.
- **Visuels d'événements** — les images actuelles sont du remplissage. Prévoir un cadrage 16:9 pour les affiches et 4:3 pour les cartes de grille.
