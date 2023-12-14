import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../add_image_widget.dart';
import '../announcements/announcement_form.dart';
import '../edit_image_widget.dart';

class EventsForm extends StatefulWidget {
  const EventsForm({Key? key}) : super(key: key);

  @override
  State<EventsForm> createState() => _EventsFormState();
}

class _EventsFormState extends State<EventsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  bool isLoading = false;
  bool isPostSuccess = false;
  bool showAlert = false; // Added to control the visibility of the alert
  String title = '';
  String description = '';

  DateTime dateOfEvent = DateTime.now();
  TimeOfDay timeOfEvent = TimeOfDay.now();

  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imagePermanent = await saveImagePermanently(image.path);
      setState(() => this.image = imagePermanent);
    } on PlatformException catch (e) {
      logger.e("Failed to pick image: $e");
    }
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final title = basename(imagePath);
    final image = File("${directory.path}/$title");

    return File(imagePath).copy(image.path);
  }

  Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref().child('events_images');

      final originalExtension = imageFile.path.split('.').last;
      final imageName =
          '${DateTime.now().millisecondsSinceEpoch}.$originalExtension';

      final uploadTask = storageRef.child(imageName).putFile(imageFile);

      await uploadTask.whenComplete(() => null);
      return await storageRef.child(imageName).getDownloadURL();
    } catch (e) {
      logger.e("Error uploading image to Firebase Storage: $e");
      return null;
    }
  }

  Future<void> uploadDataToFirebase() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
        isPostSuccess = false;
        showAlert = false; // Reset the showAlert state
      });

      _formKey.currentState?.save();

      final duplicateQuery = await FirebaseFirestore.instance
          .collection('events')
          .where('title', isEqualTo: title)
          .where('description', isEqualTo: description)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        setState(() {
          isLoading = false;
        });

        logger.d("Duplicate document found. Please enter unique values");
        return;
      }

      String? imageUrl;

      if (image != null) {
        imageUrl = await uploadImageToFirebaseStorage(image!);
        if (imageUrl == null) {
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      await FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'dateOfEvent': DateTime(dateOfEvent.year, dateOfEvent.month,
            dateOfEvent.day, timeOfEvent.hour, timeOfEvent.minute),
      });

      _formKey.currentState?.reset();

      setState(() {
        isLoading = false;
        isPostSuccess = true;
        showAlert = true; // Set showAlert to true to display the alert
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    image != null
                        ? EditImageWidget(
                            image: image!,
                            onClicked: (source) => pickImage(source),
                          )
                        : AddImageWidget(
                            image: File('images/image-outline-filled.png'),
                            onClicked: (source) => pickImage(source),
                          ),
                    const Text(
                      "(Image upload is optional)",
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter event title',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          title = value ?? '';
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter the description',
                        ),
                        maxLines: null,
                        minLines: 6,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          description = value ?? '';
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select Event Date',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select the event date';
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );

                          if (selectedDate != null &&
                              selectedDate != dateOfEvent) {
                            setState(() {
                              dateOfEvent = selectedDate;
                              dateController.text = formattedDate(dateOfEvent);
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: timeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select Event Time',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select the event time';
                          }
                          return null;
                        },
                        onTap: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (selectedTime != null &&
                              selectedTime != timeOfEvent) {
                            setState(() {
                              timeOfEvent = selectedTime;
                              timeController.text = formattedTime(timeOfEvent);
                            });
                          }
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : uploadDataToFirebase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        minimumSize: Size(
                          200.w,
                          50.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              'Post',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Ubuntu",
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showAlert)
            Center(
              child: AlertDialog(
                title: const Text('Success'),
                content: const Text('Announcement Posted Successfully!'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showAlert = false; // Close the alert
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String formattedDate(DateTime date) {
    return DateFormat('d MMM y').format(date);
  }

  String formattedTime(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }
}
