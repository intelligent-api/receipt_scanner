import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'camera_screen.dart';
import 'dart:io';
import 'config.dart';
import 'dart:convert';
import 'models/receipt_response.dart';

void main() async {
  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CameraPermissionScreen());
  }
}

class CameraPermissionScreen extends StatefulWidget {
  const CameraPermissionScreen({super.key});

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen> {
  String _status = "Click the button to scan a receipt";
  String? _imagePath;
  ReceiptResponse? _receiptData;
  bool _isProcessing = false;

  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() {
        _status = "Camera permission granted ✅";
      });
    } else if (status.isDenied) {
      setState(() {
        _status = "Camera permission denied ❌";
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _status =
            "Camera permission permanently denied. Enable it in settings ⚠️";
      });
      openAppSettings(); // Open settings if permanently denied
    }
  }

  Future<void> _scanReceipt() async {
    await _requestCameraPermission();

    if (await Permission.camera.isGranted) {
      if (!mounted) return;
      final imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );

      if (imagePath != null && mounted) {
        setState(() {
          _status = "Receipt captured! Ready to send to API";
          _imagePath = imagePath;
        });
        await _sendImageToApi(imagePath);
      }
    } else {
      _requestCameraPermission();
    }
  }

  Future<void> _sendImageToApi(String imagePath) async {
    setState(() {
      _isProcessing = true;
      _status = "Processing receipt...";
    });

    try {
      // get the intelligent-api auth token from the supabase function
      final supabase = Supabase.instance.client;
      final res = await supabase.functions.invoke('receipt-scanner');
      final data = res.data;

      // send the image to the intelligent-api
      final uri = Uri.parse(Config.apiEndpoint);
      final request = http.Request('POST', uri);
      request.headers.addAll({
        'Authorization': 'Bearer ${data['token']}',
        'Content-Type': 'application/octet-stream',
      });
      request.bodyBytes = await File(imagePath).readAsBytes();

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final receiptResponse = ReceiptResponse.fromJson(
          jsonDecode(responseBody),
        );

        setState(() {
          _status =
              "Receipt processed! Total: ${receiptResponse.receipts[0].summary.total}";
          _receiptData = receiptResponse;
        });
      } else {
        setState(() {
          _status = "Failed to upload receipt ❌";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error uploading receipt: $e";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receipt Scanner")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_status, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                if (_isProcessing)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _scanReceipt,
                    child: const Text("Scan Receipt"),
                  ),
                if (_imagePath != null && !_isProcessing) ...[
                  const SizedBox(height: 20),
                  Image.file(
                    File(_imagePath!),
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ],
                if (_receiptData != null && !_isProcessing) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  Text(
                    'Receipt Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Vendor: ${_receiptData!.receipts[0].summary.vendorName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Items:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _receiptData!.receipts[0].items.length,
                    itemBuilder: (context, index) {
                      final item = _receiptData!.receipts[0].items[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.item),
                          subtitle: Text('Quantity: ${item.quantity}'),
                          trailing: Text(item.price),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total: ${_receiptData!.receipts[0].summary.total}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
