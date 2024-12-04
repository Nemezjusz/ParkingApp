import 'package:flutter/material.dart';
import 'package:smart_parking/models/parking_spot.dart';
import 'package:smart_parking/widgets/parking_spot_tile.dart';
import 'package:smart_parking/screens/views/universal/section_header.dart';

class ParkingGrid extends StatefulWidget {
  final List<ParkingSpot> parkingSpots;
  final String currentFloor;
  final List<String> availableFloors;
  final Function(String)? onFloorChanged;

  const ParkingGrid({
    Key? key,
    required this.parkingSpots,
    this.currentFloor = 'A', // Domyślne piętro
    this.availableFloors = const ['A', 'B'], // Domyślne piętra
    this.onFloorChanged, // Funkcja może być opcjonalna
  }) : super(key: key);

  @override
  _ParkingGridState createState() => _ParkingGridState();
}

class _ParkingGridState extends State<ParkingGrid> {
  late String currentFloor;

  @override
  void initState() {
    super.initState();
    currentFloor = widget.currentFloor;
  }

  @override
void didUpdateWidget(covariant ParkingGrid oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.parkingSpots != widget.parkingSpots) {
    setState(() {}); // Odbuduj widok po każdej zmianie miejsc parkingowych
  }
  if (oldWidget.availableFloors != widget.availableFloors) {
    if (!widget.availableFloors.contains(currentFloor) &&
        widget.availableFloors.isNotEmpty) {
      setState(() {
        currentFloor = widget.availableFloors.first;
      });
      widget.onFloorChanged?.call(currentFloor);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    const double roadWidth = 60;

    // Filtracja miejsc parkingowych dla aktualnego piętra
    final filteredSpots = widget.parkingSpots.where((spot) {
      final floorLetter = spot.prettyId.isNotEmpty
          ? spot.prettyId[0].toUpperCase()
          : 'A'; // Domyślne piętro, jeśli prettyId jest puste
      return floorLetter == currentFloor;
    }).toList();

    // Generowanie rzędów miejsc parkingowych
    final List<Row> spotRows = [];
    for (int i = 0; i < filteredSpots.length; i += 2) {
      final leftSpot = filteredSpots[i];
      final rightSpot =
          (i + 1 < filteredSpots.length) ? filteredSpots[i + 1] : null;

      spotRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lewa strona parkingu
            ParkingSpotTile(
              id: leftSpot.prettyId ?? 'Spot ${i + 1}',
              color: leftSpot.color,
              onTap: () {
                // if (leftSpot.status.toLowerCase() != 'reserved') {
                //   _showReservationDialog(context, leftSpot.prettyId ?? '');
                // }
              },
            ),
            // Droga centralna z kreskami
            SizedBox(
              width: roadWidth,
              child: CustomPaint(
                size: const Size(double.infinity, 100), // Wysokość kreski
                painter: DashedLinePainter(),
              ),
            ),
            // Prawa strona parkingu (jeśli istnieje)
            rightSpot != null
                ? ParkingSpotTile(
                    id: rightSpot.prettyId ?? 'Spot ${i + 2}',
                    color: rightSpot.color,
                    onTap: () {
                      // if (rightSpot.status.toLowerCase() != 'reserved') {
                      //   _showReservationDialog(context, rightSpot.prettyId ?? '');
                      // }
                    },
                  )
                : SizedBox(width: roadWidth), // Puste miejsce dla wyrównania
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionHeader(
                icon: Icons.map,
                title: 'Parking Map',
              ),
        // Górna sekcja z nazwą piętra i przyciskami zmiany piętra
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Floor $currentFloor',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: _canMoveUp() ? () => _changeFloor(up: true) : null,
                  color: _canMoveUp()
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: _canMoveDown() ? () => _changeFloor(up: false) : null,
                  color: _canMoveDown()
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ],
            ),
          ],
        ),
        // Wskazanie wjazdu
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Icon(Icons.arrow_downward, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Entrance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        // Lista wierszy z miejscami parkingowymi
        Expanded(
          child: ListView(
            children: [
              ...spotRows,
              // Wskazanie wyjazdu
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Exit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Funkcja zmiany piętra
  void _changeFloor({required bool up}) {
    final currentIndex = widget.availableFloors.indexOf(currentFloor);
    if (up && currentIndex > 0) {
      setState(() {
        currentFloor = widget.availableFloors[currentIndex - 1];
      });
      widget.onFloorChanged?.call(currentFloor);
    } else if (!up && currentIndex < widget.availableFloors.length - 1) {
      setState(() {
        currentFloor = widget.availableFloors[currentIndex + 1];
      });
      widget.onFloorChanged?.call(currentFloor);
    }
  }

  bool _canMoveUp() {
    return widget.availableFloors.indexOf(currentFloor) > 0;
  }

  bool _canMoveDown() {
    return widget.availableFloors.indexOf(currentFloor) <
        (widget.availableFloors.length - 1);
  }

  // Funkcja dialogu rezerwacji
  void _showReservationDialog(BuildContext context, String spotId) {
    DateTime selectedDate = DateTime.now();
    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    ).then((date) {
      if (date != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation made for spot $spotId on $date')),
        );
      }
    });
  }
}

// Painter dla przerywanej linii centralnej
class DashedLinePainter extends CustomPainter {
  final double dashHeight;
  final double dashSpace;
  final Paint _paint;

  DashedLinePainter({
    this.dashHeight = 10, // Wyższe kreski
    this.dashSpace = 40, // Większe odstępy między kreskami
  }) : _paint = Paint()
          ..color = Colors.grey
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    double startY = 0;
    final double centerX = size.width / 2; // Środek kolumny

    while (startY < size.height) {
      // Rysowanie pojedynczej kreski
      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, startY + dashHeight),
        _paint,
      );
      startY += dashHeight + dashSpace; // Przesunięcie do następnej kreski
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => false;
}
