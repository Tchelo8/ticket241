
import 'package:flutter/material.dart';
import 'package:myapp/models/event_model.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  _ExplorerScreenState createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final List<Event> _events = [
    Event(
      imagePath: 'assets/images/enb.jpg',
      organizer: 'Entre Nous Bar',
      title: 'Concert Live',
      date: 'Mar 29, 2024',
      price: '10,000 XAF',
    ),
    Event(
      imagePath: 'assets/images/oiseau.jpg',
      organizer: 'L-Oiseau Rare',
      title: 'Showcase Exclusif',
      date: 'Avr 05, 2024',
      price: '25,000 XAF',
    ),
    Event(
      imagePath: 'assets/images/sibang.jpg',
      organizer: 'US Bitam',
      title: 'CMS vs US Bitam',
      date: 'Avr 12, 2024',
      price: '5,000 XAF',
    ),
  ];

  String _selectedCategory = "Toutes";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Text(
          'Explorer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildCategoryFilters(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Événements, concerts...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: const Icon(Icons.filter_list, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ["Toutes", "Sport", "Culture", "Éducatif", "Pour vous"];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 20.0 : 10.0, right: index == categories.length - 1 ? 20.0 : 0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF1E90FF),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.transparent)
              ),
               elevation: 3,
            ),
          );
        },
      ),
    );
  }


  Widget _buildEventsList() {
    return ListView.builder(
      itemCount: _events.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        return _buildEventCard(_events[index]);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              event.imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.organizer,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[500], size: 16),
                        const SizedBox(width: 5),
                        Text(event.date, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                      'À partir de ${event.price}',
                       style: const TextStyle(color:  Color(0xFF1E90FF), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
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
