import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({Key? key}) : super(key: key);

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _converting = false;
  String? _error;
  File? _savedFile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _error != null ? Text(_error!) : const SizedBox.shrink(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _readCsv(),
            child: const Text('Select csv file'),
          ),
          const SizedBox(height: 16),
          _converting
              ? const CircularProgressIndicator()
              : const SizedBox.shrink(),
          const SizedBox(height: 16),
          _savedFile != null
              ? ElevatedButton(
                  onPressed: () {
                    final uri = Uri.file(_savedFile!.parent.absolute.path);
                    debugPrint('uri: $uri');
                    launchUrl(uri);
                  },
                  child: const Text('Open file directory'),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Future<void> _readCsv() async {
    setState(() {
      _converting = true;
      _error = null;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final inputPath = result.files.single.path!;
      if (inputPath.split('.').last != 'csv') {
        // Error
        setState(() {
          _converting = false;
          _error = 'File is not a CSV file';
        });
      }

      // Read file
      File file = File(result.files.single.path!);
      final lines = await file.readAsLines();

      // Sanitised file
      final List<String> sanitisedLines = [];
      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          sanitisedLines.add(line);
        }
      }
      sanitisedLines.removeLast();

      sanitisedLines.removeRange(0,
          13); // <=== First 13 lines are Millenium BCP account info and not formatted for CSV

      // Modify Lines
      var buffer = StringBuffer();
      for (var line in sanitisedLines) {
        var cols = line.split(';');
        buffer.writeln([cols[0], cols[2], '', cols[3]].join(';'));
      }

      // Write to file
      final directory = (await getApplicationDocumentsDirectory()).path;
      final outputPath = '$directory/outputW.csv';
      final outputFile = File(outputPath);
      if (!await outputFile.exists()) {
        await outputFile.create();
      }

      var savedFile = await outputFile.writeAsString(buffer.toString());

      setState(() {
        _converting = false;
        _error = null;
        _savedFile = savedFile;
      });
    } else {
      setState(() {
        _converting = false;
        _error = null;
      });
    }
  }
}
