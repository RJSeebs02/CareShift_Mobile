import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'edit_password.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Add this import for image picker
import 'dart:io'; // For handling file operations
import '../colors.dart';

class ProfilePage extends StatefulWidget {
  final String nurseId;

  const ProfilePage({Key? key, required this.nurseId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? nurseData;
  String nurseId = '';
  File? _image; // For storing the selected profile image
  String? profileImageUrl; // To store the fetched image URL

  @override
  void initState() {
    super.initState();
    _loadNurseId();
  }

  Future<void> _loadNurseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nurseId = prefs.getString('nurse_id') ?? '';
    });

    if (nurseId.isNotEmpty) {
      fetchNurseData(nurseId);
      fetchProfileImage(nurseId); // Fetch profile image URL
    } else {
      print("No nurseId found in SharedPreferences");
    }
  }

  Future<void> fetchNurseData(String nurseId) async {
    try {
      final response = await http.get(
        Uri.parse('https://careshift.helioho.st/mobile/serve/nurse/read.php?nurse_id=$nurseId'),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            if (mounted) {
              setState(() {
                nurseData = data;
              });
            }
          } else {
            print('Unexpected data format: $data');
          }
        } catch (e) {
          print('Failed to parse JSON: $e');
          print('Response body: ${response.body}');
        }
      } else {
        print('Failed to load nurse data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching nurse data: $e');
    }
  }

  // Fetch the profile image URL from the server
  Future<void> fetchProfileImage(String nurseId) async {
    try {
      final response = await http.get(
        Uri.parse('https://careshift.helioho.st/mobile/serve/nurse/get_image.php?nurse_id=$nurseId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('image_url')) {
          setState(() {
            profileImageUrl = data['image_url'];
          });
        } else {
          print('Image not found or error in response data');
        }
      } else {
        print('Failed to fetch image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  // Function to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery); // You can also use ImageSource.camera for taking photos

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to upload the selected image to the database
  Future<void> _uploadProfilePicture() async {
    if (_image == null) {
      print("No image selected.");
      return;
    }

    // Create a multipart request to upload the image
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://careshift.helioho.st/mobile/serve/nurse/upload_image.php'), // Your upload URL
    );

    // Attach the file
    request.files.add(await http.MultipartFile.fromPath('nurse_img', _image!.path));

    // Add additional fields if necessary, like nurse_id
    request.fields['nurse_id'] = nurseId;

    // Send the request
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Profile picture uploaded successfully');
        // Optionally, update the UI to show the uploaded image or show a success message
        fetchProfileImage(nurseId); // Refresh the profile image after upload
      } else {
        print('Failed to upload profile picture');
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: nurseData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Profile picture section
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage, // Open image picker when tapped
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        child: profileImageUrl == null
                            ? Icon(Icons.camera_alt, size: 50) // Default icon if no image
                            : ClipOval(
                                child: Image.network(
                                  profileImageUrl!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: ElevatedButton(
                      onPressed: _uploadProfilePicture, // Upload the selected profile picture
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightColor, // Button background color
                        foregroundColor: AppColors.mainDarkColor, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Button padding
                        elevation: 4.0, // Shadow for the button
                      ).copyWith(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const Color.fromARGB(255, 172, 172, 172); // Hover color
                            }
                            return null; // Default behavior
                          },
                        ),
                      ),
                      child: const Text(
                        'Save Profile Picture',
                        style: TextStyle(
                          fontSize: 16.0, // Font size
                          fontWeight: FontWeight.bold, // Bold text
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '${nurseData!['nurse_fname']} ${nurseData!['nurse_mname']} ${nurseData!['nurse_lname']}',
                          style: TextStyle(
                            fontSize: 36.0,  // Adjust font size
                            fontWeight: FontWeight.bold,  // Make text bold
                            color: AppColors.mainDarkColor,  // Change text color
                          ),
                        ),

                        Text('Nurse ID: ${nurseData!['nurse_id']}',
                          style: TextStyle(
                            fontSize: 20.0,  // Adjust font size
                            fontWeight: FontWeight.bold,  // Make text bold
                            color: AppColors.appBarColor,
                          ),),
                        const SizedBox(height: 30),
                        Text('${nurseData!['nurse_position']}',
                          style: TextStyle(
                            fontSize: 20.0,  // Adjust font size
                            fontWeight: FontWeight.bold,  // Make text bold
                            color: AppColors.lightDarkColor,
                            fontStyle: FontStyle.italic, 
                          ),),
                        Text('${nurseData!['department_name']}',
                          style: TextStyle(
                            fontSize: 20.0,  // Adjust font size
                            fontWeight: FontWeight.bold,  // Make text bold
                            color: AppColors.lightDarkColor,
                            fontStyle: FontStyle.italic, 
                          ),),
                        const SizedBox(height: 30),
                        Text('${nurseData!['nurse_email']}',
                          style: TextStyle(
                            fontSize: 20.0,  // Adjust font size
                            fontWeight: FontWeight.bold,  // Make text bold
                            color: AppColors.mainDarkColor,
                          ),),
                        Text('${nurseData!['nurse_contact']}',
                          style: TextStyle(
                            fontSize: 20.0,  // Adjust font size
                            fontWeight: FontWeight.bold,  // Make text bold
                            color: AppColors.mainDarkColor,
                          ),),
                          ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Edit Profile Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to the Edit Profile page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(
                                    nurseId: widget.nurseId,
                                    initialFirstName: nurseData!['nurse_fname'],
                                    initialMiddleName: nurseData!['nurse_mname'],
                                    initialLastName: nurseData!['nurse_lname'],
                                    initialEmail: nurseData!['nurse_email'],
                                    initialContact: nurseData!['nurse_contact'].toString(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.appBarColor, // Button background color
                              foregroundColor: Colors.white, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                            ).copyWith(
                              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                (states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return const Color.fromARGB(255, 104, 174, 248); // Change color on hover
                                  }
                                  return null; // Default
                                },
                              ),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to the Edit Password page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPasswordPage(nurseId: widget.nurseId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainDarkColor, // Button background color
                              foregroundColor: Colors.white, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                            ).copyWith(
                              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                (states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return const Color.fromARGB(255, 46, 49, 53); // Change color on hover
                                  }
                                  return null; // Default
                                },
                              ),
                            ),
                            child: const Text('Edit Password'),
                          ),
                        ),
                      ),
                    ],
                  ),



                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 50.0, 15.0, 50.0),
                      child: QrImageView(
                        data: jsonEncode(int.parse(nurseId)),
                        version: QrVersions.auto,
                        size: 350.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
  );
}

}