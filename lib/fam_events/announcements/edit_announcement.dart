import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:must_fam_songs/fam_events/add_image_widget.dart';
import 'package:must_fam_songs/fam_events/edit_image_widget.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class EditAnnouncementForm extends StatefulWidget {
  final String documentId;
  final String title;
  final String description;
  final String? imageUrl;

  const EditAnnouncementForm({
    Key? key,
    required this.documentId,
    required this.title,
    required this.description,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<EditAnnouncementForm> createState() => _EditAnnouncementFormState();
}

class _EditAnnouncementFormState extends State<EditAnnouncementForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  bool isEditSuccess = false;
  bool showAlert = false;
  File? image;
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imagePermanent = await saveImagePermanently(image.path);
      setState(() => this.image = imagePermanent);
    } on PlatformException catch (e) {
      logger.e("Failed to pick image : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Set initial values for controllers
    titleController.text = widget.title;
    descriptionController.text = widget.description;
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
      final storageRef = storage.ref().child('announcement_images');

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

  Future<void> editDataInFirebase() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
        isEditSuccess = false;
        showAlert = false; // Reset the showAlert state
      });

      _formKey.currentState?.save();

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

      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.documentId)
          .update({
        'title': titleController.text,
        'description': descriptionController.text,
        'imageUrl': imageUrl,
      });

      setState(() {
        isLoading = false;
        isEditSuccess = true;
        showAlert = true; // Set showAlert to true to display the alert
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Announcement'),
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
                        controller: titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter announcement title',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the title';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: descriptionController,
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
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : editDataInFirebase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
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
                content: const Text('Announcement Edited Successfully!'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showAlert = false;
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
}
