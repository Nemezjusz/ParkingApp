class Reservation {
  final String parkingSpotId;
  final String parkingPrettyId;
  final String status;
  final String date;
  final String startTime;
  final String endTime;

  Reservation({
    required this.parkingSpotId,
    required this.parkingPrettyId,
    required this.status,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      parkingSpotId: json['parking_spot_id'] as String,
      parkingPrettyId: json['pretty_id'] as String,
      status: json['status'] as String,
      date: json['reservation_date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }
}
