/// Documents légaux, repris tels quels du site web (ticket241_front_web_users, src/content/legal.ts).
/// Texte de démonstration, à faire valider par un juriste : toute modification se fait des deux côtés.
class LegalSection {
  final String title;
  final List<String> paragraphs;
  const LegalSection(this.title, this.paragraphs);
}

class LegalDocument {
  final String title;
  final String lead;
  final String updated;
  final List<LegalSection> sections;
  const LegalDocument({required this.title, required this.lead, required this.updated, required this.sections});
}

const cgv = LegalDocument(
  title: 'Conditions générales de vente',
  lead: "L'essentiel en une phrase : vous payez en mobile money, votre billet arrive aussitôt, et vous pouvez annuler sans frais jusqu'à 48 heures avant l'événement.",
  updated: 'Mise à jour le 1er octobre 2026',
  sections: [
    LegalSection('Objet', [
      "Les présentes conditions régissent la vente de billets d'événements par Ticket241, plateforme de billetterie exploitée au Gabon, agissant en qualité d'intermédiaire entre l'acheteur et l'organisateur.",
      'Toute commande implique l\'acceptation sans réserve des présentes conditions.',
    ]),
    LegalSection('Commande', [
      "La commande est passée sur le site ou l'application. L'acheteur choisit l'événement, le type et le nombre de billets, puis renseigne son nom et son numéro de téléphone.",
      "Le nombre de billets par commande peut être limité par l'organisateur.",
    ]),
    LegalSection('Prix et paiement', [
      'Les prix sont indiqués en francs CFA (FCFA), toutes taxes comprises. Les frais de service éventuels sont affichés avant validation.',
      "Le paiement s'effectue par Airtel Money ou Moov Money. La commande n'est définitive qu'après confirmation du paiement par l'opérateur.",
    ]),
    LegalSection('Billets', [
      'Chaque billet porte un QR code unique, valable pour une seule entrée. Toute reproduction ou revente non autorisée entraîne son annulation.',
      "Le billet est nominatif lorsque l'organisateur l'exige ; une pièce d'identité peut alors être demandée à l'entrée.",
    ]),
    LegalSection('Annulation et remboursement', [
      "L'acheteur peut annuler sa commande sans frais jusqu'à 48 heures avant le début de l'événement. Le remboursement est intégral, sur le compte mobile money utilisé, sous 72 heures.",
      "En cas d'annulation de l'événement par l'organisateur, le remboursement est automatique. En cas de report, le billet reste valable pour la nouvelle date.",
    ]),
    LegalSection('Responsabilité', [
      "L'organisateur est seul responsable du déroulement de l'événement. Ticket241 ne saurait être tenu responsable d'une modification de programme, d'horaire ou de lieu décidée par l'organisateur.",
    ]),
    LegalSection('Données personnelles', [
      'Les données collectées lors de la commande sont traitées conformément à notre politique de confidentialité.',
    ]),
    LegalSection('Droit applicable et litiges', [
      'Les présentes conditions sont soumises au droit gabonais. En cas de litige, une solution amiable sera recherchée avant toute action devant les juridictions compétentes de Libreville.',
    ]),
  ],
);

const privacy = LegalDocument(
  title: 'Politique de confidentialité',
  lead: 'Nous collectons le strict nécessaire pour vous envoyer vos billets, et rien n’est revendu.',
  updated: 'Mise à jour le 1er octobre 2026',
  sections: [
    LegalSection('Données collectées', [
      "Nom, numéro de téléphone, adresse e-mail, historique d'achats et préférences (ville, favoris). Nous ne conservons aucune donnée de paiement : celles-ci restent chez votre opérateur mobile money.",
    ]),
    LegalSection('Utilisation', [
      "Émettre et envoyer vos billets, traiter vos paiements et remboursements, vous prévenir des changements d'un événement, et — si vous l'acceptez — vous recommander des événements.",
    ]),
    LegalSection('Partage', [
      "L'organisateur d'un événement reçoit le nom des acheteurs pour le contrôle d'accès. Aucune donnée n'est vendue à des tiers.",
    ]),
    LegalSection('Conservation', [
      'Les données de compte sont conservées tant que le compte est actif, puis trois ans après la dernière activité. Les justificatifs de vente sont conservés selon les obligations légales.',
    ]),
    LegalSection('Vos droits', [
      'Vous pouvez consulter, corriger ou supprimer vos données depuis votre profil, ou en écrivant à confidentialite@ticket241.ga.',
    ]),
    LegalSection('Cookies', [
      "Le site utilise des cookies nécessaires à la connexion et au panier, et des mesures d'audience anonymes. Vous pouvez les refuser depuis le bandeau prévu à cet effet.",
    ]),
  ],
);
