import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _selectedDate = DateTime.now(); // Keep track of the current week
  final ScrollController _timeColumnController = ScrollController();
  final ScrollController _eventGridController = ScrollController();

  @override
  void dispose() {
    _timeColumnController.dispose();
    _eventGridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDays = _getWeekDays(_selectedDate); // Get the days for the selected week
    List<String> timeSlots = _getTimeSlots(); // Get 24-hour time slots

    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Schedule'),
      ),
      body: Column(
        children: [
          _buildWeekNavigation(), // Add navigation buttons
          _buildWeekHeader(weekDays), // Display the days of the week
          Expanded(
            child: Row(
              children: [
                _buildTimeColumn(timeSlots), // Time column on the left (24 hours)
                Expanded(
                  child: _buildScrollableEventGrid(weekDays, timeSlots), // Display events for each day
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get the week days (Sunday to Saturday)
  List<DateTime> _getWeekDays(DateTime date) {
    DateTime firstDayOfWeek = date.subtract(Duration(days: date.weekday % 7)); // Start from Sunday
    return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  // Helper function to get 24-hour time slots (e.g., 12:00 AM, 1:00 AM ... 11:00 PM)
  List<String> _getTimeSlots() {
    return List.generate(24, (index) {
      return DateFormat.jm().format(DateTime(0, 1, 1, index)); // Format to 12:00 AM, 1:00 AM, etc.
    });
  }

  // Widget for building navigation buttons for previous/next week
  Widget _buildWeekNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _goToPreviousWeek,
            child: Text('Previous Week'),
          ),
          Text(
            '${DateFormat('d MMM').format(_getWeekDays(_selectedDate).first)} - '
            '${DateFormat('d MMM').format(_getWeekDays(_selectedDate).last)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: _goToNextWeek,
            child: Text('Next Week'),
          ),
        ],
      ),
    );
  }

  // Function to navigate to the previous week
  void _goToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 7)); // Move back one week
    });
  }

  // Function to navigate to the next week
  void _goToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 7)); // Move forward one week
    });
  }

  // Widget for displaying the time column on the left (24-hour format) and make it scrollable
  Widget _buildTimeColumn(List<String> timeSlots) {
    return SingleChildScrollView(
      controller: _timeColumnController,
      child: Column(
        children: timeSlots.map((time) {
          return Container(
            height: 60, // Set the height of each time slot row
            alignment: Alignment.center,
            child: Text(time),
          );
        }).toList(),
      ),
    );
  }

  // Widget for displaying the days of the week in the header
  Widget _buildWeekHeader(List<DateTime> weekDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekDays.map((day) {
        return Expanded(
          child: Column(
            children: [
              Text(DateFormat('EEE').format(day)), // Day of the week (e.g., Mon)
              Text(DateFormat('d MMM').format(day)), // Date (e.g., 10 Oct)
            ],
          ),
        );
      }).toList(),
    );
  }

  // Widget for making the event grid scrollable and synchronized with the time column
  Widget _buildScrollableEventGrid(List<DateTime> weekDays, List<String> timeSlots) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          // Sync the scroll position of the event grid with the time column
          _timeColumnController.jumpTo(_eventGridController.offset);
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _eventGridController,
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 days in a week
            childAspectRatio: 1.0, // Set aspect ratio for cells
          ),
          itemCount: 7 * timeSlots.length, // Number of days * number of time slots
          itemBuilder: (context, index) {
            int dayIndex = index % 7; // Calculate the current day
            int timeSlotIndex = index ~/ 7; // Calculate the current time slot

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), // Border for grid cells
              ),
            );
          },
        ),
      ),
    );
  }
}

