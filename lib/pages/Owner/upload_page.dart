import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPage extends StatefulWidget {
  final String user;
  const UploadPage({super.key, required this.user});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;
  bool _isUploading = false; // To track upload progress

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true; // Show loading indicator
    });

    final fileName = widget.user; // Fixed file name
    final path = 'uploads/$fileName';

    try {
      final storage = Supabase.instance.client.storage.from('image');

      // Check if the file already exists
      final existingFiles = await storage.list(path: 'uploads');
      final fileExists = existingFiles.any((file) => file.name == fileName);

      // If the file exists, delete it
      if (fileExists) {
        await storage.remove([path]);
        print('Existing file deleted: $path');
      }

      // Upload the new image
      await storage.upload(path, _imageFile!);

      // Get the public URL
      final imageUrl = storage.getPublicUrl(path);

      // Print the URL to the console
      print('Image URL: $imageUrl');

      // Show a snackbar to notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle errors (e.g., bucket not found, upload failed)
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Images',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display selected image or placeholder
              _imageFile == null
                  ? Column(
                      children: [
                        Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No image selected.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
              SizedBox(height: 32),

              // Select Image Button
              ElevatedButton(
                onPressed: _isUploading ? null : pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Select Image',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 16),

              // Upload Image Button with Progress Indicator
              _isUploading
                  ? CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    )
                  : ElevatedButton(
                      onPressed: _imageFile == null || _isUploading
                          ? null
                          : uploadImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Upload Image',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}