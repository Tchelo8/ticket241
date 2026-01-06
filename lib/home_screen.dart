
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/event_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:myapp/providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dummy data - replace with your actual data source
  static final List<Event> _upcomingEvents = [
    Event(name: 'Concert Live Acoustique', imagePath: 'assets/images/enb.jpg', location: 'Entre Nous Bar, Angondjé', date: '29 Mars', price: 5000.0),
    Event(name: 'Festival International de Sibang', imagePath: 'assets/images/sibang.jpg', location: 'Jardin Botanique, Libreville', date: '15 Avril', price: 10000.0),
    Event(name: 'Concert Oiseau Rare', imagePath: 'assets/images/oiseau.jpg', location: 'Casino Croisette, LBV', date: '14 Fév', price: 15000.0),
  ];

  static final List<Event> _popularEvents = [
    Event(name: 'Entre Nous Bar', imagePath: 'assets/images/enb.jpg', location: 'Angondjé', date: 'Tous les vendredis', price: 5000.0),
    Event(name: 'Libreville Jazz Festival', imagePath: 'assets/images/jazz.png', location: 'Institut Français', date: '10 Jan', price: 20000.0),
  ];
    static final List<Event> _sportEvents = [
    Event(name: 'CMS vs US Bitam', imagePath: 'assets/images/sibang.jpg', location: 'Stade amitié', date: '05 Mai', price: 1000.0),
  ];

      static final List<Event> _cultureEvents = [
    Event(name: 'Concert oiseau rare', imagePath: 'assets/images/oiseau.jpg', location: 'Casino Croisette', date: '14 Fév', price: 15000.0),
  ];




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
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  _buildHeader(context),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Événements à venir"),
                  _buildUpcomingEventsList(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Populaire actuellement", showSeeAll: true),
                  _buildPopularEventsList(context, events: _popularEvents),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Pour vous", showSeeAll: true),
                  _buildPopularEventsList(context, events: _popularEvents.reversed.toList()),
                   const SizedBox(height: 24),
                  _buildSectionHeader("Sport", showSeeAll: true),
                  _buildPopularEventsList(context, events: _sportEvents),
                  const SizedBox(height: 24),
                   _buildSectionHeader("Culture", showSeeAll: true),
                  _buildPopularEventsList(context, events: _cultureEvents),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
                      'Libreville',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.expand_more, color: Colors.black87),
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
                  color: Colors.grey.withAlpha((255 * 0.2).round()),
                  spreadRadius: 1,
                  blurRadius: 5,
                )
              ]
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black),
              onPressed: () {
                context.push('/notifications');
              },
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildUpcomingEventsList() {
    return SizedBox(
      height: 120,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _upcomingEvents.length,
          itemBuilder: (context, index) {
            final event = _upcomingEvents[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildUpcomingEventCard(context, event: event),
                ),
              ),
            );
          },
          padding: const EdgeInsets.only(left: 24, top: 12),
        ),
      ),
    );
  }
  
  Widget _buildUpcomingEventCard(BuildContext context, {required Event event}) {
     final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(event);

    // Extract date and month
    final dateParts = event.date.split(' ');
    final date = dateParts.isNotEmpty ? dateParts[0] : '';
    final month = dateParts.length > 1 ? dateParts[1] : '';

    return GestureDetector(
       onTap: () {
         context.push('/details');
       },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((255 * 0.15).round()),
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
                children: [
                   ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(event.imagePath, width: 80, height: 96, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                     child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                       child: Container(
                         decoration: BoxDecoration(
                           color: Colors.black.withAlpha((255 * 0.2).round()),
                         ),
                       ),
                     ),
                   ),
                   Positioned(
                     top: 4,
                     right: 4,
                     child: GestureDetector(
                       onTap: () {
                         favoritesProvider.toggleFavorite(event);
                         if (!isFavorite) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(
                               content: Text('Ajouté aux favoris'),
                               duration: Duration(seconds: 2),
                             ),
                           );
                         }
                       },
                       child: Container(
                         padding: const EdgeInsets.all(4),
                         decoration: BoxDecoration(
                           color: Colors.white.withAlpha((255 * 0.8).round()),
                           shape: BoxShape.circle,
                         ),
                         child: Icon(
                           isFavorite ? Icons.favorite : Icons.favorite_border,
                           color: isFavorite ? Colors.red : Colors.black,
                           size: 20,
                         ),
                       ),
                     ),
                   ),
                   Align(
                     alignment: Alignment.center,
                     child: Container(
                       width: 45,
                       height: 45,
                       decoration: BoxDecoration(
                         color: Colors.white.withAlpha((255 * 0.85).round()),
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
                   ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(event.name.length > 20 ? '${event.name.substring(0, 20)}...' : event.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis,),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E90FF).withAlpha((255 * 0.1).round()),
                          foregroundColor: const Color(0xFF1E90FF),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Précommander', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularEventsList(BuildContext context, {required List<Event> events}) {
    return SizedBox(
      height: 250,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildPopularEventCard(context, event: event),
                ),
              ),
            );
          },
          padding: const EdgeInsets.only(left: 24, top: 12),
        ),
      ),
    );
  }
  
  Widget _buildPopularEventCard(BuildContext context, {required Event event}) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(event);

     return GestureDetector(
      onTap: () {
        context.push('/details');
      },
       child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((255 * 0.15).round()),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.asset(event.imagePath, height: 120, width: double.infinity, fit: BoxFit.cover),
                ),
                 Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      favoritesProvider.toggleFavorite(event);
                      if (!isFavorite) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ajouté aux favoris'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((255 * 0.9).round()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.date, style: const TextStyle(fontSize: 12, color: Color(0xFF1E90FF), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(event.name.length > 20 ? '${event.name.substring(0, 20)}...' : event.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(event.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E90FF).withAlpha((255 * 0.1).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${event.price.toStringAsFixed(0)} FCFA', style: const TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.bold, fontSize: 11)),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
           ),
    );
  }
}
