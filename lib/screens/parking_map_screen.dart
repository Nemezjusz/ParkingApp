import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/parking_spot_bloc.dart';
import '../blocs/theme_bloc.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/reservations_section.dart';
import '../widgets/parking_spot_tile.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'reservation_screen.dart';
import '../models/parking_spot.dart';

class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({Key? key}) : super(key: key);

  @override
  _ParkingMapScreenState createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  int _selectedIndex = 0;
  String currentFloor = 'A';

  List<String> availableFloors = [];

  void refreshReservations() {
    context.read<ParkingSpotBloc>().add(FetchParkingSpots());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuthenticated || authState.token == null) {
          // Jeśli użytkownik nie jest uwierzytelniony, przekieruj na ekran logowania
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final String token = (authState as Authenticated).token!;

        final List<Widget> _screens = [
          BlocProvider<ParkingSpotBloc>(
            create: (context) =>
                ParkingSpotBloc(token: token)..add(FetchParkingSpots()),
            child: ParkingMapView(
              currentFloor: currentFloor,
              availableFloors: availableFloors,
              onFloorChanged: (newFloor) {
                setState(() {
                  currentFloor = newFloor;
                });
              },
              onFloorsUpdated: (floors) {
                setState(() {
                  availableFloors = floors;
                  if (!availableFloors.contains(currentFloor)) {
                    if (availableFloors.isNotEmpty) {
                      currentFloor = availableFloors.first;
                      context.read<ParkingSpotBloc>().add(FetchParkingSpots());
                    }
                  }
                });
              },
            ),
          ),
          const ReservationScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          appBar: CustomAppBar(
            title: "Smart Parking",
            actions: [
              IconButton(
                icon: Icon(
                  context.read<ThemeBloc>().state.isDarkMode
                      ? Icons.wb_sunny
                      : Icons.nights_stay,
                ),
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleTheme());
                },
              ),
            ],
          ),
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            selectedItemColor:
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor:
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car), label: 'Reservation'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}

class ParkingMapView extends StatefulWidget {
  final String currentFloor;
  final Function(String) onFloorChanged;
  final List<String> availableFloors;
  final Function(List<String>) onFloorsUpdated;

  const ParkingMapView({
    Key? key,
    required this.currentFloor,
    required this.onFloorChanged,
    required this.availableFloors,
    required this.onFloorsUpdated,
  }) : super(key: key);

  @override
  _ParkingMapViewState createState() => _ParkingMapViewState();
}

class _ParkingMapViewState extends State<ParkingMapView> {
  late String currentFloor;

  @override
  void initState() {
    super.initState();
    currentFloor = widget.currentFloor;
  }

  @override
  void didUpdateWidget(covariant ParkingMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableFloors != widget.availableFloors) {
      // Jeśli aktualne piętro nie jest już dostępne, ustaw na pierwsze dostępne
      if (!widget.availableFloors.contains(currentFloor)) {
        if (widget.availableFloors.isNotEmpty) {
          setState(() {
            currentFloor = widget.availableFloors.first;
          });
          widget.onFloorChanged(currentFloor);
          context.read<ParkingSpotBloc>().add(FetchParkingSpots());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double roadWidth = 60;

    final authState = context.read<AuthBloc>().state;
    final String token = (authState as Authenticated).token!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Górna część z nazwą piętra i przyciskami zmiany piętra
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
                    onPressed:
                        _canMoveUp() ? () => _changeFloor(up: true) : null,
                    color: _canMoveUp()
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed:
                        _canMoveDown() ? () => _changeFloor(up: false) : null,
                    color: _canMoveDown()
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mapa parkingu z drogą centralną
          Expanded(
            child: BlocListener<ParkingSpotBloc, ParkingSpotState>(
              listener: (context, state) {
                if (state is ParkingSpotLoaded) {
                  final uniqueFloors = state.parkingSpots
                      .map((spot) {
                        if (spot.prettyId.isNotEmpty) {
                          return spot.prettyId[0].toUpperCase();
                        } else {
                          return 'A'; // Domyślne piętro, jeśli prettyId jest puste
                        }
                      })
                      .toSet()
                      .toList();

                  uniqueFloors.sort();

                  logger.d('Available Floors: $uniqueFloors');

                  widget.onFloorsUpdated(uniqueFloors);
                }
              },
              child: BlocBuilder<ParkingSpotBloc, ParkingSpotState>(
                builder: (context, state) {
                  if (state is ParkingSpotLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ParkingSpotLoaded) {
                    final parkingSpots = state.parkingSpots;
                    parkingSpots
                        .sort((a, b) => a.spotNumber.compareTo(b.spotNumber));

                    final filteredSpots = parkingSpots.where((spot) {
                      String floorLetter = spot.prettyId.isNotEmpty
                          ? spot.prettyId[0].toUpperCase()
                          : 'A'; // Domyślne piętro, jeśli prettyId jest puste
                      return floorLetter == currentFloor;
                    }).toList();

                    // Dla celów testowych ograniczenie liczby miejsc parkingowych na piętrze
                    final testSpots = filteredSpots.take(20).toList();

                    logger.d(
                        'Filtered Spots for Floor $currentFloor: ${testSpots.length}');

                    // Tworzenie wierszy z miejscami parkingowymi po lewej i prawej stronie drogi
                    List<Row> spotRows = [];
                    for (int i = 0; i < testSpots.length; i += 2) {
                      ParkingSpot leftSpot = testSpots[i];
                      ParkingSpot? rightSpot =
                          (i + 1 < testSpots.length) ? testSpots[i + 1] : null;

                      spotRows.add(Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Lewa strona parkingu
                          ParkingSpotTile(
                            id: leftSpot.prettyId,
                            status: leftSpot.status,
                            onTap: () {
                              if (leftSpot.status.toLowerCase() != 'reserved') {
                                _showReservationDialog(
                                    context, leftSpot.prettyId);
                              }
                            },
                          ),
                          // Droga centralna z przerywaną linią
                          SizedBox(
                            width: roadWidth,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(1, 1),
                                  painter: DashedLinePainter(),
                                ),
                              ],
                            ),
                          ),
                          // Prawa strona parkingu
                          rightSpot != null
                              ? ParkingSpotTile(
                                  id: rightSpot.prettyId,
                                  status: rightSpot.status,
                                  onTap: () {
                                    if (rightSpot.status.toLowerCase() !=
                                        'reserved') {
                                      _showReservationDialog(
                                          context, rightSpot.prettyId);
                                    }
                                  },
                                )
                              : SizedBox(width: 60),
                        ],
                      ));
                    }

                    return ListView(
                      children: [
                        const SizedBox(height: 10),
                        ...spotRows,
                        const SizedBox(height: 10),
                      ],
                    );
                  } else if (state is ParkingSpotError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Lista rezerwacji
          Expanded(
            child: SingleChildScrollView(
              child: ReservationsSection(
                fetchReservations: () => ApiService.fetchAllReservations(token),
                title: 'All Reservations',
                icon: Icons.list,
                onRefresh: () {
                  context.read<ParkingSpotBloc>().add(FetchParkingSpots());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeFloor({required bool up}) {
    final currentIndex = widget.availableFloors.indexOf(currentFloor);
    if (up) {
      if (currentIndex > 0) {
        setState(() {
          currentFloor = widget.availableFloors[currentIndex - 1];
        });
        widget.onFloorChanged(currentFloor);
        context.read<ParkingSpotBloc>().add(FetchParkingSpots());
      }
    } else {
      if (currentIndex < widget.availableFloors.length - 1) {
        setState(() {
          currentFloor = widget.availableFloors[currentIndex + 1];
        });
        widget.onFloorChanged(currentFloor);
        context.read<ParkingSpotBloc>().add(FetchParkingSpots());
      }
    }
  }

  bool _canMoveUp() {
    return widget.availableFloors.indexOf(currentFloor) > 0;
  }

  bool _canMoveDown() {
    return widget.availableFloors.indexOf(currentFloor) <
        (widget.availableFloors.length - 1);
  }

  void _showReservationDialog(BuildContext context, String spotId) {
    DateTime selectedDate = DateTime.now();
    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    ).then((date) {
      if (date != null) {
        // Logika rezerwacji
        _reserveSpot(context, spotId, date);
      }
    });
  }

  void _reserveSpot(BuildContext context, String spotId, DateTime date) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final token = authState.token!;
      ApiService.reserveParkingSpot(
        parkingSpotId: spotId,
        action: 'reserve',
        date: date,
        token: token,
      ).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezerwacja udana')),
        );
        context.read<ParkingSpotBloc>().add(FetchParkingSpots());
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd rezerwacji: $error')),
        );
      });
    }
  }

  void _showFloorSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return FloorSelectionDialog(
          onFloorSelected: (selectedFloor) {
            setState(() {
              currentFloor = selectedFloor;
            });
            widget.onFloorChanged(selectedFloor);
          },
        );
      },
    );
  }
}

class FloorSelectionDialog extends StatefulWidget {
  final Function(String) onFloorSelected;

  const FloorSelectionDialog({Key? key, required this.onFloorSelected})
      : super(key: key);

  @override
  _FloorSelectionDialogState createState() => _FloorSelectionDialogState();
}

class _FloorSelectionDialogState extends State<FloorSelectionDialog> {
  String? selectedFloor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Floor'),
      content: BlocBuilder<ParkingSpotBloc, ParkingSpotState>(
        builder: (context, state) {
          if (state is ParkingSpotLoaded) {
            // Wyodrębnij unikalne piętra z miejsc parkingowych
            final uniqueFloors = state.parkingSpots
                .map((spot) {
                  if (spot.prettyId.isNotEmpty) {
                    return spot.prettyId[0].toUpperCase();
                  } else {
                    return 'A'; // Domyślne piętro, jeśli prettyId jest puste
                  }
                })
                .toSet()
                .toList();

            uniqueFloors.sort(); // Sortuj piętra alfabetycznie

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: uniqueFloors.map((floor) {
                return RadioListTile<String>(
                  title: Text('Floor $floor'),
                  value: floor,
                  groupValue: selectedFloor,
                  onChanged: (value) {
                    setState(() {
                      selectedFloor = value;
                    });
                  },
                );
              }).toList(),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedFloor != null
              ? () {
                  widget.onFloorSelected(selectedFloor!);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Paint _paint;

  DashedLinePainter({this.dashWidth = 20, this.dashSpace = 20})
      : _paint = Paint()
          ..color = Colors.grey
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    double startY = 0;
    final double endY = size.height;
    while (startY < endY) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), _paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => false;
}
