import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../colors.dart';

class LeaveRecord {
  final String dateFiled;
  final String timeFiled;
  final String status;
  final String leaveType;
  final String description;
  final String leaveStart;
  final String leaveEnd;

  LeaveRecord({
    required this.dateFiled,
    required this.timeFiled,
    required this.status,
    required this.leaveType,
    required this.description,
    required this.leaveStart,
    required this.leaveEnd,
  });
}

class LeavePage extends StatefulWidget {
  final String nurseId; // Add a nurseId field to pass it from ProfilePage

  const LeavePage({Key? key, required this.nurseId}) : super(key: key);

  @override
  _LeavePageState createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final List<LeaveRecord> leaveRecords = []; // Update to use LeaveRecord

  @override
  void initState() {
    super.initState();
    _fetchLeaveRecords();
  }

  Future<void> _fetchLeaveRecords() async {
    try {
      final response = await http.get(
        Uri.parse('https://careshift.helioho.st/mobile/serve/leave/read.php?nurse_id=${widget.nurseId}'),
      );

      // Print the response for debugging
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> leaves = decoded['records'];

        // Ensure you get the expected structure
        print('Decoded JSON: $leaves');

        setState(() {
          leaveRecords.clear(); // Clear the current records
          leaveRecords.addAll(leaves.map((item) {
            return LeaveRecord(
              dateFiled: item['leave_date_filed'] ?? '',
              timeFiled: item['leave_time_filed'] ?? '',
              status: item['leave_status'] ?? 'Unknown',
              leaveType: item['leave_type'] ?? '',
              description: item['leave_desc'] ?? '',
              leaveStart: item['leave_start_date'] ?? '',
              leaveEnd: item['leave_end_date'] ?? '',
            );
          }).toList());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch leave records: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching leave records: $e')),
      );
    }
  }

  Future<void> _openAddLeaveDialog(BuildContext context) async {
  await showDialog<LeaveRecord?>(
    context: context,
    builder: (BuildContext context) {
      return AddLeaveDialog(
        onCreateLeave: (leaveType, description, startDate, endDate) async {
          await _createLeave(leaveType, description, startDate, endDate, widget.nurseId);
          await _fetchLeaveRecords(); // Refresh the leave records after saving
        },
      );
    },
  );
}

  Future<LeaveRecord?> _createLeave(String leaveType, String description, DateTime startDate, DateTime endDate, String nurseId) async {
    final requestBody = json.encode({
      'leave_type': leaveType,
      'leave_desc': description,
      'leave_start': DateFormat('yyyy-MM-dd').format(startDate),
      'leave_end': DateFormat('yyyy-MM-dd').format(endDate),
      'nurse_id': nurseId,
      'leave_date_filed': DateFormat('yyyy-MM-dd').format(DateTime.now()), // Adding leave date filed
      'leave_time_filed': DateFormat('HH:mm:ss').format(DateTime.now()), // Adding leave time filed
    });

    // Log the request body for debugging
    print('Request Body: $requestBody');

    final response = await http.post(
      Uri.parse('https://careshift.helioho.st/mobile/serve/leave/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    // Log the raw response for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        return LeaveRecord(
          dateFiled: DateFormat.yMMMMd().format(DateTime.now()),
          timeFiled: DateFormat.jm().format(DateTime.now()),
          status: data['status'] ?? 'Unknown',
          leaveType: leaveType,
          description: description,
          leaveStart: DateFormat.yMMMMd().format(startDate),
          leaveEnd: DateFormat.yMMMMd().format(endDate),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error decoding response: $e')),
        );
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create leave: ${response.reasonPhrase}')),
      );
      return null;
    }
  }

  void _showLeaveDetails(BuildContext context, LeaveRecord leave) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Leave Details"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Leave Type: ${leave.leaveType}'),
                Text('Description: ${leave.description}'),
                Text('Leave Start: ${leave.leaveStart}'),
                Text('Leave End: ${leave.leaveEnd}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.lightColor,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 10.0,  // Padding for the left side
            top: 20.0,   // Padding for the top side
            bottom: 35.0, // Padding for the bottom side
          ),
          child: Align(
            alignment: Alignment.centerLeft, // Aligns text to the left
            child: const Text(
              'Leave Records', // Title text
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 1), // Add some spacing between title and list
        Expanded(
          child: ListView.builder(
            itemCount: leaveRecords.length,
            itemBuilder: (context, index) {
              final leave = leaveRecords[index];
              final date = DateTime.parse(leave.dateFiled); // Parse date to extract month and day

              return InkWell(
                onTap: () => _showLeaveDetails(context, leave),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.mainLightColor, // Background color
                    border: Border(
                      top: BorderSide(color: AppColors.borderColor, width: 1),
                      bottom: BorderSide(color: AppColors.borderColor, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Left Section - Date and Month in Rounded Square with Two Background Colors
                      Container(
                        width: 70,
                        height: 80, // Adjust height to accommodate both the month and day
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.borderColor, // Border color for the container
                            width: 1, // Border thickness
                          ),
                          borderRadius: BorderRadius.circular(8), // Rounded corners for the overall container
                        ),
                        child: Column(
                          children: [
                            // Month with grey background and rounded top corners
                            Expanded(
                              flex: 1, // Make this take half the height
                              child: Container(
                                width: double.infinity, // Ensure the container takes the full width
                                decoration: const BoxDecoration(
                                  color: AppColors.mainDarkColor, // Grey background for the month
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8), // Rounded top-left corner
                                    topRight: Radius.circular(8), // Rounded top-right corner
                                  ),
                                ),
                                child: Center( // Center the month text vertically and horizontally
                                  child: Text(
                                    DateFormat.MMM().format(date), // Month abbreviation
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // White text for the month
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Day with white background and rounded bottom corners
                            Expanded(
                              flex: 1, // Make this take the remaining half of the height
                              child: Container(
                                width: double.infinity, // Ensure the container takes the full width
                                decoration: const BoxDecoration(
                                  color: Colors.white, // White background for the day
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8), // Rounded bottom-left corner
                                    bottomRight: Radius.circular(8), // Rounded bottom-right corner
                                  ),
                                ),
                                child: Center( // Center the day text vertically and horizontally
                                  child: Text(
                                    "${date.day}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black, // Black text for the day
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16), // Space between the date and the text
                      // Right Section - Leave Record Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date Filed: ${leave.dateFiled}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Time Filed: ${leave.timeFiled}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${leave.status}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _getStatusColor(leave.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),






      ],
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddLeaveDialog(context),
        child: const Icon(
          Icons.add,
          color: AppColors.mainLightColor),
        backgroundColor: AppColors.appBarColor,
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Denied':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}

class AddLeaveDialog extends StatefulWidget {
  final Future<LeaveRecord?> Function(String leaveType, String description, DateTime startDate, DateTime endDate) onCreateLeave;

  const AddLeaveDialog({Key? key, required this.onCreateLeave}) : super(key: key);

  @override
  _AddLeaveDialogState createState() => _AddLeaveDialogState();
}

class _AddLeaveDialogState extends State<AddLeaveDialog> {
  String? _leaveType;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _leaveStartDate;
  DateTime? _leaveEndDate;
  bool isSaving = false; // Add this flag

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_leaveStartDate ?? DateTime.now()) : (_leaveEndDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.appBarColor, // Header and selected date background color
            onPrimary: Colors.white,         // Header text color
            onSurface: AppColors.mainDarkColor,         // Default text color
          ),
          dialogBackgroundColor: AppColors.mainLightColor, // Background color of the dialog
        ),
        child: child!,
      );
    },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _leaveStartDate = pickedDate;
          _startDateController.text = DateFormat.yMMMMd().format(pickedDate);
          if (_leaveEndDate != null && pickedDate.isAfter(_leaveEndDate!)) {
            _leaveEndDate = null;
            _endDateController.clear();
          }
        } else {
          _leaveEndDate = pickedDate;
          _endDateController.text = DateFormat.yMMMMd().format(pickedDate);
        }
      });
    }
  }

  void _onSave() async {
    if (_leaveType != null &&
        _descriptionController.text.isNotEmpty &&
        _leaveStartDate != null &&
        _leaveEndDate != null &&
        !isSaving) { // Check if not already saving
      setState(() {
        isSaving = true; // Set to true when saving starts
      });

      // Call the onCreateLeave method without returning the newLeaveRecord
      await widget.onCreateLeave(
        _leaveType!,
        _descriptionController.text,
        _leaveStartDate!,
        _leaveEndDate!,
      );

      // Close the dialog
      Navigator.of(context).pop(); // Just close the dialog after saving

      setState(() {
        isSaving = false; // Set to false once saving is done
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields or wait for the operation to finish')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.mainLightColor,
      title: const Text("Add Leave"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _leaveType,
              hint: const Text('Select Leave Type'),
              onChanged: (String? newValue) {
                setState(() {
                  _leaveType = newValue;
                });
              },
              items: <String>['Sick Leave', 'Vacation Leave', 'Emergency Leave']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _startDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Leave Start Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _pickDate(context, true),
            ),
            TextField(
              controller: _endDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Leave End Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _pickDate(context, false),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: AppColors.mainDarkColor),
          ),
        ),
        TextButton(
          onPressed: isSaving ? null : _onSave, // Disable button while saving
          child: const Text(
            "Save",
            style: TextStyle(color: AppColors.mainDarkColor),
          ),
        ),
      ],
    );
  }
}