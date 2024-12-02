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
    id: json['id'] as String,
    parkingSpotId: json['parking_spot_id'] as String,
    prettyId: json['pretty_id'] as String,
    reservationDate: json['reservation_date'] as String,
    status: json['status'] as String,
    reservedBy: json['reserved_by'] == "N/A" ? null : json['reserved_by'] as String?,
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'parking_spot_id': parkingSpotId,
    'pretty_id': prettyId,
    'reservation_date': reservationDate,
    'status': status,
    'reserved_by': reservedBy ?? "N/A",
  };
}
@override
  String toString() {
    return 'Reservation(id: $id, parkingSpotId: $parkingSpotId, prettyId: $prettyId, reservationDate: $reservationDate, status: $status, reservedBy: $reservedBy)';
  }
}
