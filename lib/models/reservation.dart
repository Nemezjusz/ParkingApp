class Reservation {
  final String parkingSpotId;
  final String parkingPrettyId;
  final String status;
  final String date;

  Reservation({
    required this.parkingSpotId,
    required this.parkingPrettyId,
    required this.status,
    required this.date,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      parkingSpotId: json['parking_spot_id'] as String,
      parkingPrettyId: json['pretty_id'] as String,
      status: json['status'] as String,
      date: json['reservation_date'] as String,
    );
  }
}
