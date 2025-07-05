import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Processing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: OperationSelectScreen(),
    );
  }
}

class OperationSelectScreen extends StatelessWidget {
  final List<String> operations = [
    'Histogram Equalization',
    'Noise Removal',
    'Thresholding',
    'Edge Detection',
    'Erosion',
    'Dilation',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Processing Operations'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: operations.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  operations[index],
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UploadScreen(operation: operations[index]),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class UploadScreen extends StatefulWidget {
  final String operation;

  UploadScreen({required this.operation});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? _imageBytes;
  Uint8List? _processedImage;

  Future<void> pickImage() async {
    final bytesFromPicker = await ImagePickerWeb.getImageAsBytes();
    if (bytesFromPicker != null) {
      setState(() {
        _imageBytes = bytesFromPicker;
        _processedImage = null;
      });
    }
  }

  void downloadImage(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<Uint8List?> processImage(
      String operation, Uint8List imageBytes) async {
    var uri = Uri.parse('http://localhost:5000/process');

    var request = http.MultipartRequest('POST', uri)
      ..fields['operation'] = operation
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'upload.jpg',
      ));

    var response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      print('Failed with ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.operation),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.file_upload),
                label: Text('Pick Image'),
              ),
              SizedBox(height: 30),
              if (_imageBytes != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Original Image',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Image.memory(_imageBytes!, width: 300),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            var result = await processImage(
                                widget.operation, _imageBytes!);
                            if (result != null) {
                              setState(() {
                                _processedImage = result;
                              });
                            } else {
                              print('Processing failed.');
                            }
                          },
                          icon: Icon(Icons.settings),
                          label: Text('Process Image'),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 30),
              if (_processedImage != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Processed Image',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Image.memory(_processedImage!, width: 300),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            downloadImage(
                                _processedImage!, 'processed_image.png');
                          },
                          icon: Icon(Icons.download),
                          label: Text('Download Image'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_imageBytes == null)
                Text(
                  'No image selected.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
