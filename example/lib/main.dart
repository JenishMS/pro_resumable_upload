import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resumable_upload/resumable_upload.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String process = '0%';
  late UploadClient? client;
  final LocalCache _localCache = LocalCache();

  _upload_func() async {
    final filePath = await filePathPicker();
    final File file = File(filePath!);
    const String accountName = '[ACCOUNT_NAME]';
    const String containerName = '[CONTAINER_NAME]';
    final String blobName = file.path.split('/').last;
    const String sasToken = '[SAS-TOKEN]';

    try {
      client = UploadClient(
        file: file,
        cache: _localCache,
        blobConfig: BlobConfig(
            accountName: accountName,
            containerName: containerName,
            blobName: blobName,
            sasToken: sasToken),
      );
      client!.uploadBlob(
        onProgress: (count, total, response) {
          final num = ((count / total) * 100).toInt().toString();
          setState(() {
            process = '$num%';
          });
        },
        onComplete: (path, response) {
          setState(() {
            process = 'Completed';
          });
        },
      );
    } catch (e) {
      setState(() {
        process = e.toString();
      });
    }
  }

  Future<String?> filePathPicker() async {
    File? file;

    try {
      final XFile? galleryFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
      );

      if (galleryFile == null) {
        return null;
      }

      file = File(galleryFile.path);
    } catch (e) {
      return null;
    }

    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$process',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 20.0,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  process = 'Cancelled';
                });
                client!.cancel();
              },
              child: Container(
                color: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 16.0),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _upload_func,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
