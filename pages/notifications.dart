import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package
import '../colors.dart';

class NotificationPage extends StatefulWidget {
  final String nurseId;

  const NotificationPage({Key? key, required this.nurseId}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // List to store notifications
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // Function to fetch notifications from the HelioHost API
  Future<void> fetchNotifications() async {
    final url = Uri.parse('https://careshift.helioho.st/mobile/serve/notifications/read.php?nurse_id=${widget.nurseId}');

    try {
      final response = await http.get(url);

      // Print the response body for debugging
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode the JSON response as a List
        final List<dynamic> decoded = json.decode(response.body);

        // Update the state with the fetched notifications
        if (mounted) {
          setState(() {
            notifications = decoded.map((item) {
              return {
                'title': item['notif_title'] ?? 'No Title',
                'msg': item['notif_msg'] ?? 'No Message',
                'date': item['notif_date'] ?? 'No Date',
                'time': item['notif_time'] ?? 'No Time',
                'type': item['notif_type'] ?? 'No Type',
              };
            }).toList();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No notifications as of the moment. ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notifications: $e')),
      );
    }
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> notification) {
  final date = notification['date'];
  final time = notification['time'];

  final formattedDate = _formatDate(date, time);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.mainLightColor,
      title: Text(notification['title']!),
      content: SingleChildScrollView(  // Make the content scrollable
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 100),  // Limit the maximum height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['msg']!),
                const SizedBox(height: 18),
                Text(
                  '$formattedDate',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
      contentPadding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

String _formatDate(String date, String time) {
  final parsedDate = DateTime.parse('$date $time');
  return '${DateFormat('MMMM d, yyyy').format(parsedDate)} at ${DateFormat('hh:mm a').format(parsedDate)}';
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
              left: 10.0, // Padding for the left side
              top: 20.0, // Padding for the top side
              bottom: 35.0, // Padding for the bottom side
            ),
            child: Align(
              alignment: Alignment.centerLeft, // Aligns text to the left
              child: const Text(
                'Notifications', // Title text
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
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final date = DateTime.parse(notification['date']); // Parse date

                // Format the date to "Month Day, Year"
                final formattedDate = DateFormat('MMM d, yyyy').format(date);

                // Format the time to 12-hour format with AM/PM
                final timeString = notification['time']; // Extract time string
                final time = DateFormat("HH:mm:ss").parse(timeString); // Parse time
                final formattedTime = DateFormat("hh:mm a").format(time); // Format time to 12hr format

                return InkWell(
                  onTap: () => _showNotificationDetails(context, notification),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'] ?? 'No Title',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                                child: Text(
                                  '${notification['msg'] ?? 'No Message'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                                child: Text(
                                  '$formattedDate - $formattedTime', // Formatted date and time
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
    );
  }
}
