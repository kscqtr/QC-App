import 'package:flutter/material.dart';
// Import the PDF viewer package you added to pubspec.yaml
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String pdfAssetPath; // Path to the PDF asset

  const PdfViewerPage({super.key, required this.pdfAssetPath});

  @override
  Widget build(BuildContext context) {
    // Extract filename for the title (optional)
    // Handle potential errors if path doesn't contain '/'
    final String title = pdfAssetPath.contains('/')
        ? pdfAssetPath.split('/').last
        : pdfAssetPath;

    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Show PDF filename in AppBar
      ),
      body: SfPdfViewer.asset(
        pdfAssetPath, // Load the PDF from the provided asset path
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading PDF: ${details.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}
