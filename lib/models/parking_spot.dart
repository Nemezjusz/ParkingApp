class ParkingSpot {
  final String id;
  final String prettyId;
  final String status;
  final String color;
  final int floor;
  final int spotNumber;
  final bool waitingConfirmation;

  ParkingSpot({
    required this.id,
    required this.prettyId,
    required this.status,
    required this.color,
    required this.floor,
    required this.spotNumber,
    required this.waitingConfirmation,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: json['id'],
      prettyId: json['pretty_id'],
      status: json['status'],
      color: json['color'] ?? 'GREEN',
      floor: json['floor'],
      spotNumber: json['spot_number'],
      waitingConfirmation: json['waiting_confirmation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pretty_id': prettyId,
      'status': status,
      'color': color,
      'floor': floor,
      'spot_number': spotNumber,
      'waiting_confirmation': waitingConfirmation,
    };
  }
}
