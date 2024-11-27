class Reservation {
  final String id;
  final String parkingSpotId;
  final String prettyId;
  final String reservationDate;
  final String status;
  final String? reservedBy;

  Reservation({
    required this.id,
    required this.parkingSpotId,
    required this.prettyId,
    required this.reservationDate,
    required this.status,
    this.reservedBy,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      parkingSpotId: json['parking_spot_id'],
      prettyId: json['pretty_id'],
      reservationDate: json['reservation_date'],
      status: json['status'],
      reservedBy: json['reserved_by'],
    );
  }
}
