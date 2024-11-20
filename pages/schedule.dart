import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for JSON decoding
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import '../colors.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _currentWeekStart = DateTime.now();
  Map<String, List<Map<String, String>>> _shifts = {}; // Initialize empty shifts map
  String? nurseId; // Change to nullable to handle uninitialized state

  @override
  void initState() {
    super.initState();
    _setCurrentWeekStart();
    _fetchNurseId(); // Fetch the nurse ID on initialization
  }

  void _setCurrentWeekStart() {
    DateTime today = DateTime.now();
    int difference = today.weekday - 1; // Get the difference from Monday (1)
    _currentWeekStart = today.subtract(Duration(days: difference)); // Set to last Monday
  }

  List<DateTime> _getWeekDates() {
    return List.generate(7, (index) => _currentWeekStart.add(Duration(days: index)));
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(Duration(days: 7));
    });
    _fetchSchedules(); // Fetch new schedules for the previous week
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7));
    });
    _fetchSchedules(); // Fetch new schedules for the next week
  }

  // Function to fetch nurse ID from SharedPreferences
  Future<void> _fetchNurseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nurseId = prefs.getString('nurse_id'); // Retrieve the nurse ID

    if (nurseId != null) {
      _fetchSchedules(); // Fetch schedules only if nurse ID is found
    } else {
      // Handle the case where nurseId is not found (e.g., redirect to login)
      print('Nurse ID not found');
    }
  }

  // Function to fetch schedules from the API
  Future<void> _fetchSchedules() async {
    if (nurseId == null) return; // Return if nurseId is not set

    final weekStartDate = DateFormat('yyyy-MM-dd').format(_currentWeekStart);
    final weekEndDate = DateFormat('yyyy-MM-dd').format(_currentWeekStart.add(Duration(days: 6)));

    final response = await http.get(Uri.parse('https://careshift.helioho.st/mobile/serve/schedule/read.php?nurse_id=$nurseId'));

    if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _shifts = {}; // Clear existing shifts
        for (var shift in data) {
            String date = shift['sched_date']; // Corrected key
            String start = shift['sched_start_time']; // Corrected key
            String end = shift['sched_end_time']; // Corrected key
            
            String room = ''; // Set to an empty string or provide a value if available

            if (!_shifts.containsKey(date)) {
                _shifts[date] = [];
            }
            _shifts[date]!.add({'start': start, 'end': end, 'room': room}); // Add room as empty or with value
        }
        setState(() {}); // Update the UI with new data
    } else if (response.statusCode == 404) {
        _showAlertDialog("No Schedule Found", "No schedules found for the week.");
    } else {
        // Handle error
        print('Failed to load schedules: ${response.statusCode}');
    }
}

// Function to show an alert dialog
void _showAlertDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
            return AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                    TextButton(
                        child: Text('OK'),
                        onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                        },
                    ),
                ],
            );
        },
    );
}

  Widget _buildShiftCell(DateTime date, String timeSlot) {
    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    List<Map<String, String>>? shifts = _shifts[dateKey];

    String timeSlotPeriod = timeSlot.split(' ')[1]; // AM or PM
    int timeSlotHour = int.parse(timeSlot.split(' ')[0]);
    if (timeSlotHour == 12) timeSlotHour = 0; // Adjust for 12 AM case
    if (timeSlotPeriod == 'PM') timeSlotHour += 12; // Convert PM to 24-hour format

    bool isShiftTime = shifts != null && shifts.any((shift) {
      int startHour = _parseHour(shift['start']!);
      int endHour = _parseHour(shift['end']!);
      return timeSlotHour >= startHour && timeSlotHour < endHour; // Check if within the shift time
    });

    String room = shifts != null && shifts.isNotEmpty
        ? shifts.firstWhere(
            (shift) => _parseHour(shift['start']!) <= timeSlotHour && timeSlotHour < _parseHour(shift['end']!),
            orElse: () => {'room': ''},
          )['room']!
        : ''; // Fallback if there are no shifts available

    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: isShiftTime ? Colors.green : Colors.white,
      ),
      child: Center(
        child: Text(room, textAlign: TextAlign.center),
      ),
    );
  }

  int _parseHour(String hourString) {
    final parts = hourString.split(':'); // Split by colon to get hours, minutes, seconds
    int hour = int.parse(parts[0]); // Get the hour part
    return hour; // Return the hour (24-hour format is already suitable)
  }

  @override
  Widget build(BuildContext context) {
    final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<DateTime> weekDates = _getWeekDates();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: Column(
          children: [
            Align(
          alignment: Alignment.centerLeft, // Aligns text to the left
          child: const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '${DateFormat('y').format(weekDates[0])}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousWeek,
                ),
                Text(
                  '${DateFormat('MMM d').format(weekDates[0])} - ${DateFormat('MMM d').format(weekDates[6])}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextWeek,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FixedColumnWidth(50),
                  },
                  children: [
                    TableRow(
                      children: [
                        Container(
                          color: Colors.grey[300],
                          height: 70,
                          child: Center(
                            child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                        ),
                        ...weekDates.asMap().entries.map((entry) {
                          int index = entry.key;
                          DateTime date = entry.value;
                          String formattedDate = DateFormat('MMM d').format(date);
                          bool isToday = DateTime.now().isSameDay(date);
                          return Container(
                            color: isToday ? const Color.fromARGB(255, 68, 255, 124).withOpacity(0.2) : Colors.grey[300],
                            height: 70,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(daysOfWeek[index], style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? AppColors.mainColor : Colors.black)),
                                  Text(formattedDate, style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? AppColors.mainColor : Colors.black)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    ...List.generate(24, (hour) {
                      String period = hour < 12 ? 'AM' : 'PM';
                      int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
                      String timeSlot = '$displayHour $period';
                      
                      return TableRow(
                        children: [
                          Container(
                            color: Colors.grey[300],
                            height: 100,
                            child: Center(
                              child: Text(timeSlot, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                          ),
                          ...List.generate(7, (index) {
                            DateTime date = weekDates[index];
                            return _buildShiftCell(date, timeSlot);
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension method to check if two DateTime objects are on the same day
extension DateTimeComparison on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}