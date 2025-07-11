// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html; // For web-specific download
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'iec60332_3_22_24_page.dart';


// Helper class to hold controllers for each material's inputs
class IECSampleControllers {
  String? selectedConductorKey; // To store the key of the selected conductor (e.g., "<= 35mm2")
  final TextEditingController diameterController; // For diameter input

  IECSampleControllers()
      : diameterController = TextEditingController(),
        selectedConductorKey = null;

  void dispose() {
    diameterController.dispose();
  }

  void clear() {
    selectedConductorKey = null;
    diameterController.clear();
  }
}

// Result class for IEC60332-3-22 
class IEC22ResultsPage2 { // Renamed to avoid conflict
  final String conductor;
  final String diameter; // Input diameter as string
  final String duration;
  final String formation;
  final String ladder;
  final String array;
  final String wireSize; // Descriptive
  final String burner;
  final double totalTestPieces; // 7 or 1.5

  IEC22ResultsPage2({
    required this.conductor,
    required this.diameter,
    required this.duration,
    required this.formation,
    required this.ladder,
    required this.array,
    required this.wireSize,
    required this.burner,
    required this.totalTestPieces,
  });

  @override
  String toString() {
    return 'Conductor: $conductor, Diameter: $diameter, Duration: $duration, Formation: $formation, Ladder: $ladder, Wire Size: $wireSize, Burner: $burner, Test Pieces: $totalTestPieces, Array: $array';
  }
}

// Result class for IEC60332-3-24
class IEC24ResultsPage2 { // Renamed to avoid conflict
  final String conductor;
  final String diameter; // Input diameter as string
  final String duration;
  final String formation;
  final String ladder;
  final String array;
  final String wireSize; // Descriptive
  final String burner;
  final double totalTestPieces; // 7 or 1.5

  IEC24ResultsPage2({
    required this.conductor,
    required this.diameter,
    required this.duration,
    required this.formation,
    required this.ladder,
    required this.array,
    required this.wireSize,
    required this.burner,
    required this.totalTestPieces,
  });

  @override
  String toString() {
    return 'Conductor: $conductor, Diameter: $diameter, Duration: $duration, Formation: $formation, Ladder: $ladder, Wire Size: $wireSize, Burner: $burner, Test Pieces: $totalTestPieces, Array: $array';
  }
}

class IEC60332Page2 extends StatefulWidget {
  final double calculatedTestPiecesFromPage1;
  final IECTestType selectedIECType;
  // --- ADDED: Receive results from Page 1 ---
  final List<dynamic> page1Results;
  final String page1TotalVolume;
  final String page1TestPieces;

  const IEC60332Page2({
    super.key, 
    required this.calculatedTestPiecesFromPage1,
    required this.selectedIECType,
    required this.page1Results,
    required this.page1TotalVolume,
    required this.page1TestPieces,
  });

  @override
  IEC60332Page2State createState() => IEC60332Page2State();
  
}

class IEC60332Page2State extends State<IEC60332Page2> {
  late IECTestType _selectedIECType;
  List<IECSampleControllers> _sampleControllers = [IECSampleControllers()];
  List<dynamic> _calculatedResults = [];
  String? _calculationError;
  bool _showResultTab = false;
  final ScrollController _scrollController = ScrollController();

  // --- MODIFIED: Replaced symbols with compatible characters ---
  final Map<String, double> _cableConductorData = {
    '<= 35mm²': 0.0, 
    '>= 50mm²': 0.0, 
  };

  @override
  void initState() {
    super.initState();
    _selectedIECType = widget.selectedIECType;
    _initializeSamplesAndResults();
  }

  void _initializeSamplesAndResults() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _sampleControllers = [IECSampleControllers()];
    _calculatedResults =
        List.filled(_sampleControllers.length, null, growable: true);
    _calculationError = null; 
    _showResultTab = false; 
  }

  @override
  void dispose() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onTestTypeChanged(IECTestType? newType) {
    if (newType != null && newType != _selectedIECType) {
      setState(() {
        _selectedIECType = newType;
        _resetFields(resetType: false); 
      });
    }
  }

  void _performCalculations() {
    FocusScope.of(context).unfocus();
    setState(() {
      _calculationError = null;
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _showResultTab = false;
    });
    _calculateNewValues(); 
  }

  void _calculateNewValues() {
    List<dynamic> tempResults = List.filled(_sampleControllers.length, null, growable: true);
    String? firstErrorMsg;

    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String? conductorKey = controllers.selectedConductorKey;
      final String diameterText = controllers.diameterController.text;
      final double calculatedTestPiecesFromPage1 = widget.calculatedTestPiecesFromPage1;
      
      String determinedFormation = "N/A"; // Default value
      String determinedLadder = "N/A";     // Default value
      String determinedArray = "N/A";      // Default value
      String determinedWireSizeDesc = "N/A"; // Default value
      String determinedBurner = "N/A";   // Default value
      double testPieces = calculatedTestPiecesFromPage1;

      if (conductorKey == null && diameterText.isEmpty) {
        if (_sampleControllers.length > 1 && (i == 0 || (tempResults.length > i - 1 && tempResults[i-1] != null))) {
          tempResults[i] = "SKIPPED";
          continue;
        } else if (_sampleControllers.length == 1) {
          firstErrorMsg ??= 'Please enter data for Entry ${i + 1}.';
        }
      }

      double? diameterOD = double.tryParse(diameterText); 
      String? errorMsg;
      double actualTestPiece;

      if (conductorKey == null && (diameterText.isNotEmpty || (i == 0 && _sampleControllers.length == 1))) {
         if (tempResults[i] != "SKIPPED") {
            errorMsg = 'Conductor not selected (Entry ${i + 1}).';
         }
      }
      else if (diameterOD == null && diameterText.isNotEmpty) {
        errorMsg = 'Invalid Overall Diameter (Entry ${i + 1}).';
      } else if (conductorKey == null || diameterText.isEmpty) {
         if (tempResults[i] != "SKIPPED") {
            errorMsg = 'Conductor and Overall Diameter required for Entry ${i + 1}.';
         }
      } else if (diameterOD != null) {
        if (diameterOD <= 0) {
          errorMsg = 'Overall Diameter must be positive (Entry ${i + 1}).';
        }
      }

      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg;
        tempResults[i] = null;
      } else if (conductorKey != null && diameterOD != null) {
        // --- MODIFIED: Updated logic to use new keys ---
        if (conductorKey == '<= 35mm²') {   // <= 35mm²
          determinedFormation = "Touching"; 
          determinedLadder = "300mm";   
          determinedArray = '';
          actualTestPiece = (300 / diameterOD).ceilToDouble(); 
          int remaining = testPieces.toInt();
          int current = actualTestPiece.toInt();

          while (remaining > 0 && current > 0) {
            if (remaining - current < 0) break;

            determinedArray += '$current, ';
            remaining -= current;
            current--;
          }

          // Add the final value to reach the exact total
          current = current + 1;
          while (remaining >= current && current > 0) {
            determinedArray += '$current, ';
            remaining -= current;
          }

          // If anything left (less than current), add it
          if (remaining > 0) {
            determinedArray += '$remaining';
          }


          determinedArray = determinedArray.endsWith(', ')
          ? determinedArray.substring(0, determinedArray.length - 2)
          : determinedArray;


          determinedWireSizeDesc = "0.5 - 1.0 mm";
          determinedBurner = "Single"; 

        } else if (conductorKey == '>= 50mm²')  {    // >= 50mm²

          if (diameterOD > 40.0) {        // >= 50mm² & > 40.0mm
            determinedFormation = "Spacing"; 
            determinedLadder = "300mm";  
            determinedWireSizeDesc = "0.5 - 1.0 mm";
            determinedBurner = "Single";

            actualTestPiece = ((300 - 20)/(diameterOD + 20)).ceilToDouble();
            determinedArray = actualTestPiece.toStringAsFixed(0);

            if (actualTestPiece < testPieces){    // When Actual Test is less than test piece value (sheet 1)
              determinedLadder = "600mm"; 
              actualTestPiece = ((600 - 20)/(diameterOD + 20)).ceilToDouble();
              determinedArray = actualTestPiece.toStringAsFixed(0);
              determinedBurner = "Double";
            }

          if (actualTestPiece > testPieces) {
            actualTestPiece = testPieces; // Ensure we don't exceed the test pieces
            determinedArray = actualTestPiece.toStringAsFixed(0);
            }   

            if (diameterOD > 50.0) {      // >= 50mm² & > 50.0mm
              determinedWireSizeDesc = "1.0 - 2.5 mm";
            }
          } else { // Diameter is <= 40.0
            determinedFormation = "Spacing"; 
            determinedLadder = "300mm";   
            determinedWireSizeDesc = "0.5 - 1.0 mm";
            determinedBurner = "Single";

            actualTestPiece = ((300 - (diameterOD * 0.5) )/ (diameterOD + diameterOD * 0.5)).ceilToDouble();
            determinedArray = actualTestPiece.toStringAsFixed(0);

            if (actualTestPiece < testPieces){    // When Actual Test is less than test piece value (sheet 1)
              determinedLadder = "600mm"; 
              actualTestPiece = ((600 - (diameterOD * 0.5)) / (diameterOD + diameterOD * 0.5)).ceilToDouble();
              determinedArray = actualTestPiece.toStringAsFixed(0);
              determinedBurner = "Double";
            }   

            if (diameterOD > 50.0) {      // >= 50mm² & > 50.0mm
              determinedWireSizeDesc = "1.0 - 2.5 mm";
            }

            if (actualTestPiece > testPieces) {
              actualTestPiece = testPieces; // Ensure we don't exceed the test pieces
              determinedArray = actualTestPiece.toStringAsFixed(0);
            }   
          }
        } else {
            firstErrorMsg ??= "Unknown conductor type: $conductorKey (Entry ${i+1})";
            tempResults[i] = null; 
            continue; 
        }
            
        String duration = (_selectedIECType == IECTestType.iEC60332_3_22) ? "40 minutes" : "20 minutes";

        if (_selectedIECType == IECTestType.iEC60332_3_22) {
          tempResults[i] = IEC22ResultsPage2( 
            conductor: conductorKey,
            diameter: '${diameterOD.toStringAsFixed(2)} mm', 
            duration: duration,
            formation: determinedFormation,
            ladder: determinedLadder,
            array: determinedArray,
            wireSize: determinedWireSizeDesc,
            burner: determinedBurner,
            totalTestPieces: testPieces,
          );
        } else { // IECTestType.iEC60332_3_24
            tempResults[i] = IEC24ResultsPage2( 
            conductor: conductorKey,
            diameter: '${diameterOD.toStringAsFixed(2)} mm', 
            duration: duration,
            formation: determinedFormation,
            ladder: determinedLadder,
            array: determinedArray,
            wireSize: determinedWireSizeDesc,
            burner: determinedBurner,
            totalTestPieces: testPieces,
          );
        }
      } else if (tempResults[i] != "SKIPPED" && (conductorKey != null || diameterText.isNotEmpty)) {
         firstErrorMsg ??= 'Incomplete or invalid data for Entry ${i+1}.'; 
         tempResults[i] = null;
      }
    }

    setState(() {
      _calculatedResults = tempResults;
      if (firstErrorMsg != null) {
        _calculationError = firstErrorMsg;
      }

      bool hasActualCalculations = _calculatedResults.any((r) => r is IEC22ResultsPage2 || r is IEC24ResultsPage2);
      bool hasSkipped = _calculatedResults.any((r) => r == "SKIPPED");

      if (hasActualCalculations || _calculationError != null || hasSkipped) {
        if (!hasActualCalculations && _calculationError == null && hasSkipped) {
          _calculationError = "All valid entries were skipped. No results to display.";
        } else if (!hasActualCalculations && _calculationError == null && !hasSkipped) {
           _calculationError = "No valid data entered for calculation.";
        }
        _showResultTab = true;
      } else {
        _calculationError = "No data to process."; // Or "Please enter data."
        _showResultTab = true; 
      }
    });
  }

  void _resetFields({bool resetType = true}) {
    FocusScope.of(context).unfocus();
    setState(() {
      for (var controllers in _sampleControllers) {
        controllers.dispose();
      }
      _sampleControllers = [IECSampleControllers()];
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _calculationError = null;
      _showResultTab = false;
      if (resetType) {
        // When resetting, it should revert to the type passed from page 1
        _selectedIECType = widget.selectedIECType; 
      }
    });
  }

  // --- MODIFIED: PDF Generation for Web Download ---
  Future<void> _generateAndOpenPdf() async {
    final pdf = pw.Document();

    // --- ADDED: Load logo from assets ---
    final logoData = await rootBundle.load('images/keystone.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    String testCategory = _selectedIECType == IECTestType.iEC60332_3_22
        ? "Category A (IEC 60332-3-22)"
        : "Category C (IEC 60332-3-24)";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // --- MODIFIED: Header now includes the logo ---
        header: (context) => pw.Header(
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('IEC 60332-3 Test Report', style: pw.Theme.of(context).defaultTextStyle.copyWith(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text(testCategory, style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey)),
                ]
              ),
              pw.SizedBox(
                height: 70, // Changed size
                width: 70,  // Changed size
                child: pw.Opacity(
                  opacity: 0.5, // Added for 50% opacity
                  child: pw.Image(logoImage),
                ),
              ),
            ],
          ),
          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5))),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey)),
        ),
        build: (context) => [
          pw.Header(level: 1, text: 'Part 1: Non-Metallic Volume Calculation'),
          pw.SizedBox(height: 10),
          _buildPage1PdfTable(),
          pw.SizedBox(height: 10),
          if (widget.page1TotalVolume.isNotEmpty)
            pw.Text(widget.page1TotalVolume, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (widget.page1TestPieces.isNotEmpty)
            pw.Text(widget.page1TestPieces, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),

          pw.Header(level: 1, text: 'Part 2: Test Setup Details'),
          pw.SizedBox(height: 10),
          _buildPage2PdfTable(),
          pw.SizedBox(height: 10),
          if (_calculationError != null && !_calculatedResults.any((r) => r is IEC22ResultsPage2 || r is IEC24ResultsPage2))
             pw.Text('Part 2 Error: $_calculationError', style: pw.TextStyle(color: PdfColors.red)),
        ],
      ),
    );

    try {
      final Uint8List bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'iec_report.pdf';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove(); // Use remove() on the element itself
      html.Url.revokeObjectUrl(url);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF download started.')),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  pw.Widget _buildPage1PdfTable() {
    final headers = ['Material', 'Weight', 'Density', 'Volume (l/m)'];
    
    final data = widget.page1Results.map((result) {
      if (result is IEC22Results) {
        return [result.material, result.weight, result.density, result.volume];
      } else if (result is IEC24Results) {
        return [result.material, result.weight, result.density, result.volume];
      } else if (result == "SKIPPED") {
        return ['Skipped', '', '', ''];
      }
      return ['', '', '', ''];
    }).where((row) => row.any((cell) => cell.isNotEmpty)).toList();

    if (data.isEmpty) {
      return pw.Text("No data calculated for Part 1.");
    }

    // --- FIXED: Replaced deprecated Table.fromTextArray ---
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildPage2PdfTable() {
    final headers = ['Conductor', 'Diameter', 'Formation', 'Ladder', 'Array / Actual #', 'Burner'];

    final data = _calculatedResults.map((result) {
      if (result is IEC22ResultsPage2) {
        return [result.conductor, result.diameter, result.formation, result.ladder, result.array, result.burner];
      } else if (result is IEC24ResultsPage2) {
        return [result.conductor, result.diameter, result.formation, result.ladder, result.array, result.burner];
      } else if (result == "SKIPPED") {
        return ['Skipped', '', '', '', '', ''];
      }
      return ['', '', '', '', '', ''];
    }).where((row) => row.any((cell) => cell.isNotEmpty)).toList();

    if (data.isEmpty) {
      return pw.Text("No data calculated for Part 2.");
    }

    // --- FIXED: Replaced deprecated Table.fromTextArray ---
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
      },
    );
  }


  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    double? fieldWidth,
  }) {
    return SizedBox(
      width: fieldWidth ?? MediaQuery.of(context).size.width * 0.35,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 14.0),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14.0),
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        onChanged: (value) => setState(() {
            _showResultTab = false;
            _calculationError = null;
        }),
      ),
    );
  }

  Widget _buildMaterialInputRow(int index) {
    final controllers = _sampleControllers[index];
    final String conductorFieldLabel = 'Conductor '; 
    const String diameterFieldLabel = 'Overall Diameter (mm)';

    return Padding( 
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Expanded( 
            flex: 2, 
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration( 
                labelText: conductorFieldLabel,
                labelStyle: const TextStyle(fontSize: 14.0),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              value: controllers.selectedConductorKey,
              items: _cableConductorData.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key, style: const TextStyle(fontSize: 14.0), overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  controllers.selectedConductorKey = newValue;
                  _showResultTab = false;
                  _calculationError = null;
                });
              },
              isExpanded: true, 
            ),
          ),
          const SizedBox(width: 10.0), 
          Expanded( 
            flex: 2, 
            child: _buildTextField(
              label: diameterFieldLabel, 
              controller: controllers.diameterController,
              fieldWidth: null, 
            ),
          ),
            const SizedBox(width: 48), 
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    const normalStyle = TextStyle(fontSize: 15, color: Colors.black87);
    final errorStyle = boldStyle.copyWith(color: Colors.red.shade700, fontSize: 16);
    final resultValueStyle = normalStyle.copyWith(fontSize: 14);

    return Scaffold(
      appBar: AppBar(title: const Text('IEC 60332-3-22/24 Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: DropdownButtonFormField<IECTestType>(
                    decoration: const InputDecoration(
                      labelText: 'Select IEC Test:',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                    value: _selectedIECType,
                    items: IECTestType.values.map((IECTestType type) {
                      String typeName = type.toString().split('.').last;
                      if (type == IECTestType.iEC60332_3_22) typeName = "IEC 60332-3-22";
                      if (type == IECTestType.iEC60332_3_24) typeName = "IEC 60332-3-24";
                      return DropdownMenuItem<IECTestType>(
                        value: type,
                        child: Text(typeName),
                      );
                    }).toList(),
                    onChanged: _onTestTypeChanged,
                  ),
                ),
                
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  elevation: 1.0,
                  color: const Color(0xFFE3F2FD), 
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sampleControllers.length,
                      itemBuilder: (context, index) {
                        return _buildMaterialInputRow(index); 
                      },
                    ),
                  )
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                        onPressed: _performCalculations,
                        icon: const Icon(Icons.calculate), 
                        label: const Text('Calculate'), 
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            minimumSize: const Size(110, 45))), 
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                        onPressed: () => _resetFields(resetType: true), 
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            minimumSize: const Size(90, 45))),
                  ],
                ),
                
                // --- ADDED: Generate PDF Button ---
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _generateAndOpenPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(208, 45),
                  ),
                ),

                const SizedBox(height: 30),

                AnimatedOpacity(
                  opacity: _showResultTab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showResultTab
                      ? Container(
                          constraints: const BoxConstraints(maxWidth: 380),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _calculationError != null && !(_calculatedResults.any((r) => r is IEC22ResultsPage2 || r is IEC24ResultsPage2))
                                ? Colors.red[50]
                                : Colors.green[50], 
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: _calculationError != null && !(_calculatedResults.any((r) => r is IEC22ResultsPage2 || r is IEC24ResultsPage2))
                                    ? Colors.red.shade300
                                    : Colors.green.shade300), 
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- MODIFIED: Refactored to use standard if/else blocks ---
                              if (_calculationError != null && !(_calculatedResults.any((r) => r is IEC22ResultsPage2 || r is IEC24ResultsPage2)))
                                Text(_calculationError!, style: errorStyle)
                              else 
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedIECType == IECTestType.iEC60332_3_22 
                                          ? 'Results (IEC 60332-3-22):' 
                                          : 'Results (IEC 60332-3-24):',
                                      style: boldStyle
                                    ),
                                    if (_calculationError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                                        child: Text(_calculationError!, style: errorStyle.copyWith(fontSize: 14)),
                                      ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _calculatedResults.length,
                                      itemBuilder: (context, index) {
                                        final result = _calculatedResults[index];
                                        if (result == "SKIPPED") {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                                            child: Text('Entry ${index + 1}: Skipped', style: normalStyle.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[700])),
                                          );
                                        }
                                        
                                        String conductor = "", diameter = "", duration = "", formation = "", ladder = "", wireSize = "", burner = "", array = "";
                                        double testPieces = 0;

                                        if (result is IEC22ResultsPage2) { 
                                            conductor = result.conductor;
                                            diameter = result.diameter;
                                            duration = result.duration;
                                            formation = result.formation;
                                            ladder = result.ladder;
                                            wireSize = result.wireSize;
                                            burner = result.burner;
                                            testPieces = result.totalTestPieces;
                                            array = result.array;
                                        } else if (result is IEC24ResultsPage2) { 
                                            conductor = result.conductor;
                                            diameter = result.diameter;
                                            duration = result.duration;
                                            formation = result.formation;
                                            ladder = result.ladder;
                                            wireSize = result.wireSize;
                                            burner = result.burner;
                                            testPieces = result.totalTestPieces;
                                            array = result.array;
                                        }

                                        if (conductor.isNotEmpty) { 
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Conductor: ($conductor, $diameter)', style: boldStyle.copyWith(fontSize: 15)), 
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Test Duration: $duration', style: resultValueStyle),
                                                      Text('# Test Pieces: ${testPieces.toStringAsFixed(1)}', style: resultValueStyle),
                                                      Text('Formation: $formation', style: resultValueStyle),
                                                      Text('Ladder: $ladder', style: resultValueStyle),
                                                      Text('Wire Size: $wireSize', style: resultValueStyle),
                                                      Text('Burner: $burner', style: resultValueStyle),
                                                      if (conductor == "<= 35mm²")
                                                        Text('Array: $array', style: resultValueStyle),

                                                      if (conductor == ">= 50mm²")     
                                                        Text('Actual # Test Pieces: $array', style: resultValueStyle),
                                                    ],
                                                  ),
                                                ),
                                               if (index < _calculatedResults.length -1 && _calculatedResults.skip(index+1).any((r) => r != null && r != "SKIPPED"))
                                                    const Divider(height: 12, thickness: 0.5, indent: 8, endIndent: 8),
                                              ],
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink(); 
                                      },
                                    ),
                                  ]
                                ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
