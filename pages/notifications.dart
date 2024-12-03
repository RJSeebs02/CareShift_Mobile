import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final url = Uri.parse('https://careshift.helioho.st/logs-module/fetch_logs.php?nurse_id=${widget.nurseId}');

  try {
    final response = await http.get(url);

    // Print the response for debugging
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Decode the JSON response
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> logs = decoded['records'];

      // Ensure you get the expected structure
      print('Decoded JSON: $logs');

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          notifications.clear(); // Clear the current notifications
          notifications.addAll(logs.map((item) {
            return {
              'title': item['log_action'] ?? 'No Action',
              'description': item['log_description'] ?? 'No Description',
              'timestamp': item['log_time_managed'] ?? 'No Time',
              'datestamp': item['log_date_managed'] ?? 'No Date',
            };
          }).toList());
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch notifications: ${response.reasonPhrase}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching notifications: $e')),
    );
  }
}


 void _showNotificationDetails(BuildContext context, Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']!),
        content: Text(notification['description']!),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index]; // Get notification
          return InkWell(
            onTap: () => _showNotificationDetails(context, notification), // Show details on tap
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title of notification
                    Text(
                      notification['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Timestamp of the notification
                    Text(
                      'Date Filed: ${notification['timestamp']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Date for the notification
                    Text(
                      'Date: ${notification['datestamp']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

}