
import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A), // Dark blue background
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(),
                _buildEventInfo(),
                _buildAboutSection(),
                _buildGeneralInfoSection(),
                _buildReviewsSection(),
                _buildTicketSelectionSection(),
                _buildLocationSection(),
                _buildSuggestionsSection(),
                const SizedBox(height: 100), // Space for the bottom bar
              ],
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/enb.jpg', // Using the existing image
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: const BackButton(color: Colors.white),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Concert sous les étoiles', // Translated
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '15 Mars, 2025, 22:00 • Libreville', // Translated & adapted
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/oiseau.jpg'), // Placeholder
            radius: 25,
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Festival de musique', // Translated
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '220K Abonnés', // Translated
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Suivre', style: TextStyle(color: Colors.white)), // Translated
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('À propos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), // Translated
          const SizedBox(height: 10),
          Text(
            'Le festival de musique est un événement de renommée mondiale qui a lieu chaque année dans la ville animée de Libreville. C\'est une destination incontournable pour les amateurs de musique du monde entier, attirant des dizaines de milliers de participants venus vivre son atmosphère électrisante.', // Translated & adapted
            style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Lire la suite', style: TextStyle(color: Color(0xFF1E90FF))), // Translated
          ),
        ],
      ),
    );
  }

    Widget _buildGeneralInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations générales', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), // Translated
          const SizedBox(height: 15),
          _buildInfoRow(Icons.calendar_today, 'Date: Dimanche & Jeudi (sélectionnez la date ci-dessous)'), // Translated
          _buildInfoRow(Icons.access_time, 'Heure: 15:30'), // Translated
          _buildInfoRow(Icons.hourglass_bottom, 'Durée: 3.5 heures'), // Translated
          _buildInfoRow(Icons.location_on, 'Lieu de rendez-vous: L\'horloge Suisse sur la place...'), // Translated & adapted
          _buildInfoRow(Icons.person, 'Âge requis: 18+ avec pièce d\'identité valide'), // Translated
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('4.9', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Text('Basé sur 245 avis', style: TextStyle(color: Colors.grey)), // Translated
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildReviewCard('Emma D.', 'Mars 2024', 'Cet événement était vraiment exceptionnel ! L\'organisation était parfaite et le personnel incroyablement serviable.')), // Translated
              const SizedBox(width: 15),
              Expanded(child: _buildReviewCard('James C.', 'Juillet 2023', 'J\'ai passé un excellent moment. Les performances étaient superbes et les organisateurs ont vraiment fait du bon travail.')), // Translated
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, String date, String review) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 10),
          Text(review, style: TextStyle(color: Colors.white.withOpacity(0.9)), maxLines: 4, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTicketSelectionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          _buildTicketRow('Entrée générale (+18)', '250', 1, isSelected: true), // Translated & adapted
          _buildTicketRow('Pass VIP, Vue Premium (+18)', '500', 0), // Translated & adapted
          _buildTicketRow('Package Ultra Premium (+18)', '1,200', 0), // Translated & adapted
          _buildTicketRow('Pass Un Jour (+18)', '150', 0), // Translated & adapted
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.yellow, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Dépêchez-vous ! Les billets se vendent vite et la disponibilité est limitée.', // Translated
                    style: TextStyle(color: Colors.yellow.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketRow(String title, String price, int quantity, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E90FF) : const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('$price FCFA', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), // Adapted currency
              Text('incl. 1.99 FCFA de frais', style: TextStyle(color: Colors.grey[400], fontSize: 12)), // Adapted currency
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade700 : const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.remove, color: Colors.white), onPressed: () {}),
                Text(quantity.toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () {}),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Localisation', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), // Translated
          const SizedBox(height: 10),
          Text('Parc de la Baie, Libreville', style: TextStyle(color: Colors.grey)), // Translated & adapted
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset('assets/images/map.jpg', height: 180, width: double.infinity, fit: BoxFit.cover), // Corrected path
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('Vous aimerez aussi', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), // Translated
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 250,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              children: [
                _buildSuggestionCard('assets/images/enb.jpg', 'Concert sous les pyramides', 'À partir de 50 FCFA', 'Gizeh, Caire'), // Translated & adapted
                _buildSuggestionCard('assets/images/jazz.png', 'Festival de Jazz de Mumbai', 'À partir de 40 FCFA', 'Santorin, Grèce'), // Corrected path
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String imagePath, String title, String price, String location) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(imagePath, height: 150, width: 200, fit: BoxFit.cover),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  radius: 15,
                  child: const Icon(Icons.favorite_border, color: Colors.white, size: 18),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: const Color(0xFF1E90FF),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 14),
              const SizedBox(width: 5),
              Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2A3A),
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2)))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('À partir de', style: TextStyle(color: Colors.grey, fontSize: 14)), // Translated
                Text('50 FCFA', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), // Adapted currency
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E90FF),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Acheter des billets', style: TextStyle(color: Colors.white, fontSize: 16)), // Translated
            ),
          ],
        ),
      ),
    );
  }
}
