import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/reservation_form_bloc.dart';
import 'package:smart_parking/models/reservation.dart';
import 'package:smart_parking/screens/views/universal/reservations_section.dart';
import 'package:smart_parking/widgets/reservation_form.dart';
import 'package:smart_parking/services/api_service.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  _ReservationViewState createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  late List<Reservation> _currentReservations;
  bool _isLoading = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentReservations = [];
    _fetchReservations(); // Initial fetch
    _startAutoRefresh(); // Start pooling
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateReservations();
    });
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final newReservations = await ApiService.fetchUserReservations();
      setState(() {
        _currentReservations = newReservations;
      });
    } catch (e) {
      debugPrint('Error fetching reservations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateReservations() async {
    try {
      final newReservations = await ApiService.fetchUserReservations();
      if (!_areListsEqual(_currentReservations, newReservations)) {
        setState(() {
          _currentReservations = newReservations;
        });
      }
    } catch (e) {
      debugPrint('Error updating reservations: $e');
    }
  }

  bool _areListsEqual(List<Reservation> oldList, List<Reservation> newList) {
    if (oldList.length != newList.length) return false;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i] != newList[i]) return false;
    }
    return true;
  }

  void _onReservationAdded() {
    _fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReservationFormBloc(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ReservationForm(onReservationAdded: _onReservationAdded),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _currentReservations.isEmpty
                        ? const Center(child: Text('No reservations found.'))
                        : ReservationsSection(
                            reservations: _currentReservations,
                            forAll: false,
                            canCancelHere: true,
                            onReservationChanged: _fetchReservations,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
