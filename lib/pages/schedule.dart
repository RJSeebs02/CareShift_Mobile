import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../colors.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // To keep track of the starting date of the current week
  DateTime _currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setCurrentWeekStart();
  }

  // Set the starting date of the current week to the most recent Monday
  void _setCurrentWeekStart() {
    DateTime today = DateTime.now();
    int difference = today.weekday - 1; // Get the difference from Monday (1)
    _currentWeekStart = today.subtract(Duration(days: difference)); // Set to last Monday
  }

  // Helper function to generate the time slots from 12:00 AM to 11:00 PM (hourly)
  List<String> _generateTimeSlots() {
    List<String> timeSlots = [];
    for (int hour = 0; hour < 24; hour++) {
      String period = hour < 12 ? 'AM' : 'PM';
      int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      timeSlots.add('$displayHour $period');
    }
    return timeSlots;
  }

  // Function to get the dates of the week starting from the current week start
  List<DateTime> _getWeekDates() {
    List<DateTime> weekDates = [];
    for (int i = 0; i < 7; i++) {
      weekDates.add(_currentWeekStart.add(Duration(days: i)));
    }
    return weekDates;
  }

  // Function to go to the previous week
  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(Duration(days: 7));
    });
  }

  // Function to go to the next week
  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of days for the top row
    final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Generate time slots (every 1 hour from 12:00 AM to 11:00 PM)
    final List<String> timeSlots = _generateTimeSlots();

    // Get the actual dates of the week
    List<DateTime> weekDates = _getWeekDates();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: Column( // Use a Column to stack the buttons with the calendar
          children: [
            // Add the year display above the calendar
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '${DateFormat('y').format(weekDates[0])}', // Extract the year from the start date
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
                  // Format the start date of the current week to display
                  DateFormat('MMM d').format(weekDates[0]) + ' - ' +
                  DateFormat('MMM d').format(weekDates[6]),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextWeek,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView( // Make the entire screen scrollable
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FixedColumnWidth(50), // Fixed width for time column
                  },
                  children: [
                    // The first row with the word "Time" in the top-left corner, and the days of the week and actual dates
                    TableRow(
                      children: [
                        Container(
                          color: Colors.grey[300], // Set grey background for "Time" cell
                          height: 70,
                          child: Center(
                            child: Text(
                              'Time', // Top-left cell with "Time"
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        ...weekDates.asMap().entries.map((entry) {
                          int index = entry.key;
                          DateTime date = entry.value;

                          // Format the date (e.g., "Oct 20")
                          String formattedDate = DateFormat('MMM d').format(date);

                          // Highlight the current day by applying a different background color
                          bool isToday = DateTime.now().isSameDay(date);
                          return Container(
                            color: isToday ? const Color.fromARGB(255, 68, 255, 124).withOpacity(0.2) : Colors.grey[300], // Set grey background for days
                            height: 70, // Set consistent height for the day cells
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    daysOfWeek[index],
                                    style: TextStyle(
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      color: isToday ? AppColors.mainColor : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      color: isToday ? AppColors.mainColor : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    // Rows with time slots in the left column
                    ...timeSlots.map((time) => TableRow(
                      children: [
                        Container(
                          color: Colors.grey[300], // Set grey background for time slots
                          height: 100, // Set a fixed height to fill the entire cell
                          child: Center(
                            child: Text(
                              time,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Keep the text black
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(7, (index) => Container(
                          height: 100, // Height of each cell
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Center(
                            child: Text(''), // Add your events or data here
                          ),
                        )),
                      ],
                    )).toList(),
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

// Extension to compare dates easily
extension DateTimeComparison on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
