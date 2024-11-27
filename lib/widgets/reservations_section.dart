import 'package:flutter/material.dart';
import 'package:smart_parking/widgets/custom_title.dart';
import 'package:smart_parking/widgets/reservation_item.dart';
import 'package:smart_parking/models/reservation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class ReservationsSection extends StatefulWidget {
  final Future<List<Reservation>> Function() fetchReservations;
  final String title;
  final IconData icon;
  final VoidCallback? onRefresh;

  const ReservationsSection({
    Key? key,
    required this.fetchReservations,
    required this.title,
    required this.icon,
    this.onRefresh,
  }) : super(key: key);

  @override
  ReservationsSectionState createState() => ReservationsSectionState();
}

class ReservationsSectionState extends State<ReservationsSection> {
  late Future<List<Reservation>> reservations;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    setState(() {
      reservations = widget.fetchReservations().then((data) {
        try {
          return data;
        } catch (e, stackTrace) {
          logger.e('🔴 Błąd podczas parsowania rezerwacji: $e\n$stackTrace');
          rethrow;
        }
      }).catchError((error) {
        logger.e('🔴 Błąd podczas pobierania rezerwacji: $error');
        throw error;
      });
    });
  }

  void refreshReservations() {
    _loadReservations();
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  Future<void> _pickDate() async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime firstDate = DateTime.now().subtract(const Duration(days: 365));
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
      refreshReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTitle(
                icon: widget.icon,
                title: widget.title,
              ),
              if (widget.title == 'All Reservations')
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                  tooltip: 'Select Date',
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (widget.title == 'All Reservations' && _selectedDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        const SizedBox(height: 10),
        FutureBuilder<List<Reservation>>(
          future: reservations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error occurred during loading reservations.',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  widget.title == 'All Reservations'
                      ? 'No reservations available.'
                      : 'You have no reservations yet.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            } else {
              List<Reservation> filteredReservations = widget.title == 'All Reservations'
                  ? snapshot.data!
                      .where((r) => r.status.toLowerCase() == 'reserved')
                      .toList()
                  : snapshot.data!;

              if (widget.title == 'All Reservations' && _selectedDate != null) {
                filteredReservations = filteredReservations.where((r) {
                  try {
                    final reservationDate = DateTime.parse(r.reservationDate);
                    return reservationDate.year == _selectedDate!.year &&
                        reservationDate.month == _selectedDate!.month &&
                        reservationDate.day == _selectedDate!.day;
                  } catch (e) {
                    logger.e('🔴 Błąd podczas parsowania daty: $e');
                    return false;
                  }
                }).toList();
              }

              if (widget.title == 'All Reservations' && filteredReservations.isEmpty) {
                return Center(
                  child: Text(
                    'No reserved reservations available for selected date.',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredReservations.length,
                itemBuilder: (context, index) {
                  final reservation = filteredReservations[index];
                  try {
                    final parsedDate = DateTime.parse(reservation.reservationDate);
                    final formattedDate =
                        DateFormat('yyyy-MM-dd').format(parsedDate);

                    return ReservationItem(
                      reservation: reservation,
                      date: formattedDate,
                      onReservationCancelled: refreshReservations,
                    );
                  } catch (e) {
                    return ReservationItem(
                      reservation: reservation,
                      date: reservation.reservationDate,
                      onReservationCancelled: refreshReservations,
                    );
                  }
                },
              );
            }
          },
        ),
      ],
    );
  }
}
