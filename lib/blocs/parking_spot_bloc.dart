import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/parking_spot.dart';
import '../services/api_service.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

// Events
abstract class ParkingSpotEvent extends Equatable {
  const ParkingSpotEvent();

  @override
  List<Object> get props => [];
}

class FetchParkingSpots extends ParkingSpotEvent {}

// States
abstract class ParkingSpotState extends Equatable {
  const ParkingSpotState();

  @override
  List<Object> get props => [];
}

class ParkingSpotInitial extends ParkingSpotState {}

class ParkingSpotLoading extends ParkingSpotState {}

class ParkingSpotLoaded extends ParkingSpotState {
  final List<ParkingSpot> parkingSpots;

  const ParkingSpotLoaded(this.parkingSpots);

  @override
  List<Object> get props => [parkingSpots];
}

class ParkingSpotError extends ParkingSpotState {
  final String message;

  const ParkingSpotError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ParkingSpotBloc extends Bloc<ParkingSpotEvent, ParkingSpotState> {
  final String token;
  final Logger logger = Logger();

  ParkingSpotBloc({required this.token}) : super(ParkingSpotInitial()) {
    on<FetchParkingSpots>(_onFetchParkingSpots);
  }

  Future<void> _onFetchParkingSpots(
      FetchParkingSpots event, Emitter<ParkingSpotState> emit) async {
    emit(ParkingSpotLoading());
    try {
      final spots = await ApiService.getParkingStatus(token);
      emit(ParkingSpotLoaded(spots));
    } catch (e) {
      logger.e('Error fetching parking spots: $e');
      emit(ParkingSpotError(e.toString()));
    }
  }
}
