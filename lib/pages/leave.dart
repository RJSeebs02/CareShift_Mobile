import 'package:flutter/material.dart';

class LeavePage extends StatelessWidget {
  const LeavePage({Key? key}) : super(key: key);

  final List<Map<String, String>> leaveRecords = const [
    {
      'dateFiled': 'October 15, 2024',
      'timeFiled': '10:30 AM',
      'status': 'For Approval',
    },
    {
      'dateFiled': 'September 20, 2024',
      'timeFiled': '03:45 PM',
      'status': 'Accepted',
    },
    {
      'dateFiled': 'August 16, 2024',
      'timeFiled': '09:15 AM',
      'status': 'Rejected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: leaveRecords.length,
          itemBuilder: (context, index) {
            final leave = leaveRecords[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Filed: ${leave['dateFiled']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Time Filed: ${leave['timeFiled']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Status: ${leave['status']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _getStatusColor(leave['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'For Approval':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
