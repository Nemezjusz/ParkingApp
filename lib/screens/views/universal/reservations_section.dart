import 'package:flutter/material.dart';
import 'package:smart_parking/widgets/reservation_item.dart';
import 'package:smart_parking/models/reservation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_parking/screens/views/universal/section_header.dart';
import 'package:smart_parking/services/api_service.dart';

class ReservationsSection extends StatefulWidget {
  final List<Reservation> reservations;
  final bool forAll;
  final bool canCancelHere;
  final VoidCallback onReservationChanged;

  const ReservationsSection({
    Key? key,
    required this.reservations,
    required this.forAll,
    required this.canCancelHere,
    required this.onReservationChanged,
  }) : super(key: key);

  @override
  ReservationsSectionState createState() => ReservationsSectionState();
}

class ReservationsSectionState extends State<ReservationsSection> {
  DateTime? _selectedDate;
  List<Reservation> reservations = [];
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      final fetchedReservations = widget.forAll
          ? await ApiService.fetchAllReservations()
          : await ApiService.fetchUserReservations();

      // Filtrowanie rezerwacji tylko z aktywnym statusem
      final activeReservations = fetchedReservations
          .where((r) => r.status.toLowerCase() != 'cancelled')
          .toList();

      setState(() {
        reservations = activeReservations;
      });
    } catch (e) {
      debugPrint('Error fetching reservations: $e');
      // Wyświetlenie błędu użytkownikowi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reservations: $e')),
      );
    } finally {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  List<Reservation> _filterReservations() {
    if (_selectedDate == null) return reservations;

    return reservations.where((reservation) {
      try {
        final reservationDate = DateTime.parse(reservation.reservationDate);
        return reservationDate.year == _selectedDate!.year &&
            reservationDate.month == _selectedDate!.month &&
            reservationDate.day == _selectedDate!.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<void> _pickDate() async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime firstDate =
        DateTime.now().subtract(const Duration(days: 365));
    final DateTime lastDate = DateTime.now().add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredReservations = _filterReservations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.list,
          title: widget.forAll ? 'All Reservations' : 'My Reservations',
          trailing: widget.forAll
              ? IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                  tooltip: 'Select Date',
                )
              : null,
        ),
        if (_selectedDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 10),
        _isRetrying
            ? const Center(child: CircularProgressIndicator())
            : Expanded(
                child: filteredReservations.isEmpty
                    ? Center(
                        child: Text(
                          'No reservations available.',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredReservations.length,
                        itemBuilder: (context, index) {
                          final reservation = filteredReservations[index];
                          return ReservationItem(
                            reservation: reservation,
                            canCancelHere: widget.canCancelHere,
                            onActionCompleted: widget.onReservationChanged,
                          );
                        },
                      ),
              ),
      ],
    );
  }
}
