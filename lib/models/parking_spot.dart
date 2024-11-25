class ParkingSpot {
  final String id;
  final String status;
  final String color;
  final bool waitingConfirmation;

  ParkingSpot({
    required this.id,
    required this.status,
    required this.color,
    required this.waitingConfirmation,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: json['id'],
      status: json['status'],
      color: json['color'] ?? 'GREEN',
      waitingConfirmation: json['waiting_confirmation'] ?? false,
    );
  }
}
