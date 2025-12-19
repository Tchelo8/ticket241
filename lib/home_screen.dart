
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showCitySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: const Center(
            child: Text(
              'Sélection de la ville (Design à venir)',
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 24),
              // Upcoming Events
              _buildSectionHeader("Événements à venir"),
              _buildUpcomingEventsList(),
              const SizedBox(height: 24),
              // Popular Now
              _buildSectionHeader("Populaire actuellement", showSeeAll: true),
              _buildPopularEventsList(imagePath: "assets/images/enb.jpg", title: "Entre Nous Bar"),
              const SizedBox(height: 24),
              // "Pour vous" section
              _buildSectionHeader("Pour vous", showSeeAll: true),
              _buildPopularEventsList(imagePath: "assets/images/enb.jpg", title: "Entre Nous Bar"),
               const SizedBox(height: 24),
              // "Sport" section
              _buildSectionHeader("Sport", showSeeAll: true),
               _buildPopularEventsList(imagePath: "assets/images/sibang.jpg", title: "CMS vs US Bitam"),
               const SizedBox(height: 24),
              // "Culture" section
              _buildSectionHeader("Culture", showSeeAll: true),
              _buildPopularEventsList(imagePath: "assets/images/oiseau.jpg", title: "Concert L'oiseau rare"),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Header Widget
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showCitySelection(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trouver des événements près de',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Text(
                      'LBV',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '∨',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                )
              ]
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // Search Bar Widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher des événements...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title, {bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0, 8.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: () {},
              child: const Text(
                'Voir tout',
                style: TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  // Upcoming Events List Widget
  Widget _buildUpcomingEventsList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 5, // Duplicated elements
        itemBuilder: (context, index) {
          return _buildUpcomingEventCard(
            image: 'assets/images/enb.jpg',
            title: 'ENB',
            location: 'LBV',
            date: '29',
            month: 'Mar'
          );
        },
        padding: const EdgeInsets.only(left: 24, top: 12),
      ),
    );
  }
  
  // Upcoming Event Card
  Widget _buildUpcomingEventCard({required String image, required String title, required String location, required String date, required String month}) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(image, width: 80, height: 96, fit: BoxFit.cover),
                ),
                Container(
                     width: 45,
                     height: 45,
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.85),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E90FF))),
                         Text(month.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E90FF))),
                       ]
                     ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                       ElevatedButton(
                         onPressed: () {},
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFF1E90FF).withOpacity(0.1),
                           foregroundColor: const Color(0xFF1E90FF),
                           elevation: 0,
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         ),
                         child: const Text('Précommander', style: TextStyle(fontSize: 12)),
                       )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Popular Events List Widget
  Widget _buildPopularEventsList({required String imagePath, required String title}) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 5, // Duplicated elements
        itemBuilder: (context, index) {
          return _buildPopularEventCard(
            image: imagePath,
            date: '29 Mar, 2024 - 22:00',
            title: title,
            location: 'LBV',
            price: 'À partir de 2000 FCFA'
          );
        },
        padding: const EdgeInsets.only(left: 24, top: 12),
      ),
    );
  }
  
  // Popular Event Card
  Widget _buildPopularEventCard({required String image, required String date, required String title, required String location, required String price}) {
     return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(image, height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF1E90FF), fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E90FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(price, style: const TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.bold, fontSize: 11)),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}
