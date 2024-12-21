import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const IsolateExampleScreen(),
    );
  }
}

class IsolateExampleScreen extends StatefulWidget {
  const IsolateExampleScreen({Key? key}) : super(key: key);

  @override
  _IsolateExampleScreenState createState() => _IsolateExampleScreenState();
}  

class _IsolateExampleScreenState extends State<IsolateExampleScreen> {
  bool _isLoading = false;
  String _parsedData = '';

  Future<void> _parseJsonWithIsolate() async {
    setState(() {
      _isLoading = true;
    });

    // Load the JSON string from assets
     final String jsonString = await _simulateLargeJsonString();
    // await rootBundle.loadString('assets/large_data.json');

    // Create a ReceivePort to communicate with the isolate
    final receivePort = ReceivePort();

    // Spawn an isolate and pass the JSON string and SendPort
    await Isolate.spawn(_parseJsonInIsolate,
        [jsonString, receivePort.sendPort]);

    // Listen for the parsed data from the isolate
    final result = await receivePort.first as List<dynamic>;

    // jsonDecode(jsonString) as List<dynamic>;

    setState(() {
      _parsedData = '$result'; // Show only the first 5 items
      _isLoading = false;
    });
  }

  static void _parseJsonInIsolate(List<dynamic> args) {
    final jsonString = args[0] as String;
    final sendPort = args[1] as SendPort;

    // Parse the JSON string into a Dart object
    final parsedData = jsonDecode(jsonString) as List<dynamic>;

    // Send the parsed data back to the main isolate
    sendPort.send(parsedData);
  }

  // Function to simulate a large JSON string
  Future<String> _simulateLargeJsonString() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading delay
    final largeJson = List.generate(
      2000,
      (index) => {"id": index, "value": "Item $index"},
    );
    print('Large JSON created $largeJson');
    return jsonEncode(largeJson);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isolate Example'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _parsedData.isNotEmpty
                          ? 'Parsed Data: $_parsedData'
                          : 'Press the button to parse JSON',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _parseJsonWithIsolate,
                      child: const Text('Parse JSON'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
