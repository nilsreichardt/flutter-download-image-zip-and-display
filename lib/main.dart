import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart' as syspaths;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<File> files = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          return Image.file(
            files[index],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: TextButton(
          onPressed: () async {
            final response = await http.get(
              Uri.parse('YOUR-IMAGE-URL'),
            );
            final tempDir = await syspaths.getTemporaryDirectory();
            final zipFile = File('${tempDir.path}/images.zip');
            await zipFile.writeAsBytes(response.bodyBytes);

            print("Downloaded zip file");

            final destinationDir = Directory("${tempDir.path}/images");

            // Making sure the folder is empty, so prevent conflicts with old files.
            if (await destinationDir.exists()) {
              print("Deleting destination");
              await destinationDir.delete(recursive: true);
            }

            try {
              await ZipFile.extractToDirectory(
                zipFile: zipFile,
                destinationDir: destinationDir,
              );
            } catch (e) {
              print(e);
            }

            print("Extracted zip file");

            final filesEntities = destinationDir.listSync();
            setState(() {
              final images = filesEntities.where(
                (f) {
                  final length = f.path.length;
                  final extension = f.path.substring(length - 4, length);
                  print("Extension: $extension");

                  return extension == 'jpeg' ||
                      extension == '.png' ||
                      extension == '.jpg';
                },
              );
              this.files = images.map((f) => File(f.path)).toList();
            });
          },
          child: const Text("Download"),
        ),
      ),
    );
  }
}
