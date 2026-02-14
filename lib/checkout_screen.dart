
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

enum PaymentMethod { airtel, moov }

class CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod? _selectedPaymentMethod = PaymentMethod.airtel;
  bool _isProcessing = false; // To track loading state

  void _processPayment() {
    if (_isProcessing) return; // Prevent multiple clicks

    setState(() {
      _isProcessing = true;
    });

    // Simulate network request
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      // Navigate to success screen
      context.go('/success');
    });
  }

  // Function to show the ticket options sheet
  void _showTicketOptions(BuildContext context, String ticketTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ticketTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Retirer du ticket', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  // Add logic to remove the ticket here
                  Navigator.pop(context);
                  // You might want to show a confirmation or update the state
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Annuler'),
                onTap: () {
                  Navigator.pop(context); // Dismiss the sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E90FF);
    final textColor = Colors.black87;
    final secondaryTextColor = Colors.grey[600];
    final cardBackgroundColor = Colors.grey[100];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Paiement',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        // The actions property has been removed to delete the three-dot icon
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventHeader(textColor, secondaryTextColor!),
              const SizedBox(height: 24),
              _buildInfoCards(textColor, secondaryTextColor, cardBackgroundColor!),
              const SizedBox(height: 24),
              Text(
                'Billets sélectionnés 3',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTicketCard(
                title: 'Admission Générale (+18)',
                price: '2500 FCFA',
                fee: 'incl. 100 FCFA de frais',
                gate: '12',
                row: '06',
                seat: '56',
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                cardBackgroundColor: cardBackgroundColor,
              ),
              _buildTicketCard(
                title: 'Pass Ultra Premium (+18)',
                price: '12000 FCFA',
                fee: 'incl. 500 FCFA de frais',
                gate: '02',
                row: '01',
                seat: '15',
                 textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                cardBackgroundColor: cardBackgroundColor,
              ),
              _buildTicketCard(
                title: 'Pass VIP, Vue Premium (+18)',
                price: '5000 FCFA',
                fee: 'incl. 200 FCFA de frais',
                gate: '07',
                row: '08',
                seat: '25',
                 textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                cardBackgroundColor: cardBackgroundColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Informations de contact',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(label: 'Nom complet', textColor: textColor, cardBackgroundColor: cardBackgroundColor),
              const SizedBox(height: 16),
              _buildTextField(label: 'Numéro de téléphone', textColor: textColor, cardBackgroundColor: cardBackgroundColor),
              const SizedBox(height: 24),
              Text(
                'Moyen de paiement',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentMethodSelector(primaryColor, textColor, cardBackgroundColor),
              const SizedBox(height: 24),
              _buildPriceDetails(textColor, secondaryTextColor, cardBackgroundColor),
              const SizedBox(height: 24),
              _buildCancellationInfo(cardBackgroundColor),
              const SizedBox(height: 24),
              _buildKeepUpdatedCheckbox(primaryColor, secondaryTextColor),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildPurchaseButton(primaryColor),
    );
  }

  Widget _buildEventHeader(Color textColor, Color secondaryTextColor) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            'assets/images/enb.jpg',
            width: 100,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Concert sous les étoiles',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: secondaryTextColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Libreville',
                    style: TextStyle(color: secondaryTextColor, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(Color textColor, Color secondaryTextColor, Color cardBackgroundColor) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
              title: 'Date', value: '14:00', subValue: '25 Nov, 2025', textColor: textColor, secondaryTextColor: secondaryTextColor, cardBackgroundColor: cardBackgroundColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
              title: 'Lieu', value: 'Libreville', subValue: 'Stade de l\'amitié', textColor: textColor, secondaryTextColor: secondaryTextColor, cardBackgroundColor: cardBackgroundColor),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String value, required String subValue, required Color textColor, required Color secondaryTextColor, required Color cardBackgroundColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: secondaryTextColor, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subValue, style: TextStyle(color: secondaryTextColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTicketCard({
    required String title,
    required String price,
    required String fee,
    required String gate,
    required String row,
    required String seat,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardBackgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(price, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(fee, style: TextStyle(color: secondaryTextColor, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _buildTicketDetail('Porte', gate, textColor, secondaryTextColor),
              _buildTicketDetail('Rang', row, textColor, secondaryTextColor),
              _buildTicketDetail('Siège', seat, textColor, secondaryTextColor, isLast: true),
            ],
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: secondaryTextColor),
            onPressed: () => _showTicketOptions(context, title),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetail(String label, String value, Color textColor, Color secondaryTextColor, {bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(right: isLast ? 0 : 16),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: secondaryTextColor, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required Color textColor, required Color cardBackgroundColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: textColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(Color primaryColor, Color textColor, Color cardBackgroundColor) {
    return Column(
      children: [
        _buildPaymentOption(
          method: PaymentMethod.airtel,
          logo: 'assets/images/am.png',
          name: 'Airtel Money',
          primaryColor: primaryColor,
          textColor: textColor,
          cardBackgroundColor: cardBackgroundColor,
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          method: PaymentMethod.moov,
          logo: 'assets/images/mm.jpg',
          name: 'Moov Money',
          primaryColor: primaryColor,
          textColor: textColor,
          cardBackgroundColor: cardBackgroundColor,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
      {required PaymentMethod method, required String logo, required String name, required Color primaryColor, required Color textColor, required Color cardBackgroundColor}) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        if (_isProcessing) return; // Prevent changing method during processing
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(logo, width: 40, height: 40),
                const SizedBox(width: 16),
                Text(name, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetails(Color textColor, Color secondaryTextColor, Color cardBackgroundColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPriceRow('Montant', '19500 FCFA', textColor, secondaryTextColor),
          const SizedBox(height: 12),
          _buildPriceRow('Frais', '800 FCFA', textColor, secondaryTextColor),
          const SizedBox(height: 12),
          _buildPriceRow('Réduction', '-1000 FCFA', textColor, secondaryTextColor, color: Colors.green),
          const Divider(height: 24, color: Colors.grey),
          _buildPriceRow('Total', '19300 FCFA', textColor, secondaryTextColor, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Color textColor, Color secondaryTextColor, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: secondaryTextColor, fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            color: color ?? (isTotal ? textColor : secondaryTextColor),
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationInfo(Color cardBackgroundColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Annulation Gratuite Disponible',
                  style: TextStyle(color: Colors.orange.shade900, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Profitez de la tranquillité d\'esprit avec une annulation gratuite jusqu\'à 48 heures avant l\'événement. Aucune pénalité, remboursement complet garanti !',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeepUpdatedCheckbox(Color primaryColor, Color secondaryTextColor) {
    return Row(
      children: [
        Checkbox(
          value: true,
          onChanged: (bool? value) {},
          activeColor: primaryColor,
          side: BorderSide(color: Colors.grey[400]!),
        ),
        Expanded(
          child: Text(
            'Tenez-moi au courant des autres événements et des actualités de cet organisateur.',
            style: TextStyle(color: secondaryTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(Color primaryColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment, // Updated onPressed
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[400], // Visual feedback when disabled
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                'Acheter maintenant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}
