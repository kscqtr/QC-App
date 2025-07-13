import 'package:flutter/material.dart';
import 'iec60332_3_22_24_page2.dart'; // Import the next page

// Enum for IEC Test Types
enum IECTestType { iEC60332_3_22, iEC60332_3_24 }

// Helper class to hold controllers for each material's inputs
class IECSampleControllers {
  String? selectedMaterialKey; // To store the key of the selected material (e.g., "PVC")
  final TextEditingController weightController; // For weight input

  IECSampleControllers()
      : weightController = TextEditingController(),
        selectedMaterialKey = null; // Initialize with no material selected

  void dispose() {
    weightController.dispose();
  }

  void clear() {
    selectedMaterialKey = null; // Reset selected material
    weightController.clear();
  }
}

// Helper class to store initial calculations before adjustments
class _InitialCalculationResult {
  final String materialKey;
  final double weight;
  final double originalDensity;
  final double initialVolumeLM;

  _InitialCalculationResult({
    required this.materialKey,
    required this.weight,
    required this.originalDensity,
    required this.initialVolumeLM,
  });
}


// Result class for IEC60332-3-22 
class IEC22Results { 
  final String material;
  final String weight;
  final String density;
  final String volume;
  final double rawVolumeLM;
  final double totalTestPieces;
  final bool isAdjusted; 

  IEC22Results({
    required this.material,
    required this.weight,
    required this.density,
    required this.volume,
    required this.rawVolumeLM,
    required this.totalTestPieces,
    required this.isAdjusted, 
  });

  @override
  String toString() {
    return 'Material: $material, Weight: $weight, Density: $density, Volume: $volume, RawVolume: $rawVolumeLM';
  }
}

// Result class for IEC60332-3-24 
class IEC24Results { 
  final String material;
  final String weight;
  final String density;
  final String volume;
  final double rawVolumeLM;
  final double totalTestPieces;
  final bool isAdjusted; 

  IEC24Results({
    required this.material,
    required this.weight,
    required this.density,
    required this.volume,
    required this.rawVolumeLM,
    required this.totalTestPieces,
    required this.isAdjusted, 
  });

  @override
  String toString() {
    return 'Material: $material, Weight: $weight, Density: $density, Volume: $volume, RawVolume: $rawVolumeLM, TestPieces: $totalTestPieces';
  }
}

class IEC60332Page extends StatefulWidget {
  const IEC60332Page({super.key});

  @override
  IEC60332PageState createState() => IEC60332PageState();
}

class IEC60332PageState extends State<IEC60332Page> {
  IECTestType _selectedIECType = IECTestType.iEC60332_3_22;
  List<IECSampleControllers> _sampleControllers = [IECSampleControllers()];
  List<dynamic> _calculatedResults = [];
  String? _calculationError;
  bool _showResultTab = false;
  final int _maxSamples = 10;
  final ScrollController _scrollController = ScrollController();
  double _calculatedTestPiecesPage2 = 0.0;

  final Map<String, double> _materialDensityData = {
    'Mica Tape': 1.6,
    'XLPE': 0.94,
    'PP Yarn': 1.47,
    'FRT Tape': 1.4,
    'LSZH': 1.47,
  };

  String _totalVolumeDisplay = "";
  double _rawTotalVolumeLM = 0.0; 
  String _testPiecesPerTotalVolumeDisplay = "";
  
  @override
  void initState() {
    super.initState();
    _initializeSamplesAndResults();
  }

  void _initializeSamplesAndResults() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _sampleControllers = [IECSampleControllers()];
    _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
    _totalVolumeDisplay = "";
    _rawTotalVolumeLM = 0.0;
    _testPiecesPerTotalVolumeDisplay = "";
    _calculatedTestPiecesPage2 = 0.0;
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (_scrollController.hasClients) {
            _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            );
        }
      });
    }
  }

  void _addMaterial() { 
    if (_sampleControllers.length < _maxSamples) {
      setState(() {
        _sampleControllers.add(IECSampleControllers());
        _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
        _showResultTab = false;
        _calculationError = null;
        _totalVolumeDisplay = "";
        _rawTotalVolumeLM = 0.0;
        _testPiecesPerTotalVolumeDisplay = "";
        _calculatedTestPiecesPage2 = 0.0;
      });
      Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum of $_maxSamples material entries reached.')),
      );
    }
  }

  void _removeMaterial(int index) { 
    if (_sampleControllers.length > 1) { 
      setState(() {
        _sampleControllers[index].dispose();
        _sampleControllers.removeAt(index);
        _performCalculations(); 
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one material is required.')),
      );
    }
  }

  void _performCalculations() {
    FocusScope.of(context).unfocus();
    setState(() {
      _calculationError = null;
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _showResultTab = false;
      _totalVolumeDisplay = "";
      _rawTotalVolumeLM = 0.0;
      _testPiecesPerTotalVolumeDisplay = "";
      _calculatedTestPiecesPage2 = 0.0;
    });
    _calculateNewValues(); 
  }

void _navigateToNextPage() {
    // A calculation is considered valid if the results tab is shown 
    // and there is at least one actual result object (not null or "SKIPPED").
    final bool hasValidResults = _showResultTab && 
                                 _calculatedResults.any((r) => r is IEC22Results || r is IEC24Results);

    // If the calculation is not valid, show an error and stop.
    if (!hasValidResults) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please perform a valid calculation on this page first.')),
      );
      return; // This stops the navigation.
    }

    // If the check passes, proceed to the next page.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IEC60332Page2(
          calculatedTestPiecesFromPage1: _calculatedTestPiecesPage2,
          selectedIECType: _selectedIECType,
          page1Results: _calculatedResults,
          page1TotalVolume: _totalVolumeDisplay,
          page1TestPieces: _testPiecesPerTotalVolumeDisplay,
        ),
      ),
    );
  }

  void _calculateNewValues() {
    String? firstErrorMsg;
    List<_InitialCalculationResult?> initialResults = [];
    double initialTotalVolumeLM = 0.0;

    // --- PASS 1: Calculate initial volumes and total volume ---
    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String? materialKey = controllers.selectedMaterialKey;
      final String weightText = controllers.weightController.text;

      if (materialKey == null && weightText.isEmpty) {
        initialResults.add(null); // Placeholder for skipped/empty rows
        continue;
      }

      double? weight = double.tryParse(weightText);
      
      if (materialKey == null || weight == null || weight <= 0) {
        firstErrorMsg ??= 'Invalid or incomplete data for Entry ${i+1}.';
        initialResults.add(null);
        continue;
      }
      
      double? density = _materialDensityData[materialKey];
      if (density == null || density <= 0) {
        firstErrorMsg ??= 'Invalid density for $materialKey (Entry ${i+1}).';
        initialResults.add(null);
        continue;
      }

      double volumeLM = (weight / density) / 1000;
      initialTotalVolumeLM += volumeLM;
      initialResults.add(_InitialCalculationResult(
        materialKey: materialKey,
        weight: weight,
        originalDensity: density,
        initialVolumeLM: volumeLM,
      ));
    }

    // --- PASS 2: Adjust values based on percentage of initial total ---
    List<dynamic> finalResults = List.filled(_sampleControllers.length, null, growable: true);
    double finalTotalVolumeLM = 0.0;

    for (int i = 0; i < initialResults.length; i++) {
      final initialData = initialResults[i];

      if (initialData == null) {
          // If the original entry was skipped or invalid, reflect that.
          if (_sampleControllers[i].selectedMaterialKey == null && _sampleControllers[i].weightController.text.isEmpty) {
             if (_sampleControllers.length > 1) finalResults[i] = "SKIPPED";
          }
          continue;
      }

      double percentage = 0;
      if (initialTotalVolumeLM > 1e-9) {
        percentage = (initialData.initialVolumeLM / initialTotalVolumeLM) * 100;
      }

      double finalDensity = initialData.originalDensity;
      double finalVolumeLM = initialData.initialVolumeLM;
      bool isAdjusted = false;

      if (percentage < 5.0) {
        isAdjusted = true;
        finalDensity = 1.0; // Change density to 1
        finalVolumeLM = (initialData.weight / finalDensity) / 1000; // Recalculate volume
      }

      finalTotalVolumeLM += finalVolumeLM; // Add the final (possibly adjusted) volume to the new total

      double individualTestPieces = (_selectedIECType == IECTestType.iEC60332_3_22) ? 7.0 : 1.5;

      if (_selectedIECType == IECTestType.iEC60332_3_22) {
        finalResults[i] = IEC22Results(
          material: initialData.materialKey,
          weight: '${initialData.weight.toStringAsFixed(2)} g',
          density: '${finalDensity.toStringAsFixed(2)} g/cm³', // Use final density
          volume: '${finalVolumeLM.toStringAsFixed(4)} l/m',   // Use final volume
          rawVolumeLM: finalVolumeLM, // Store final raw volume
          totalTestPieces: individualTestPieces,
          isAdjusted: isAdjusted, // Pass the flag
        );
      } else {
        finalResults[i] = IEC24Results(
          material: initialData.materialKey,
          weight: '${initialData.weight.toStringAsFixed(2)} g',
          density: '${finalDensity.toStringAsFixed(2)} g/cm³',
          volume: '${finalVolumeLM.toStringAsFixed(4)} l/m',
          rawVolumeLM: finalVolumeLM,
          totalTestPieces: individualTestPieces,
          isAdjusted: isAdjusted,
        );
      }
    }

    // --- Final state update ---
    setState(() {
      _calculatedResults = finalResults;
      _rawTotalVolumeLM = finalTotalVolumeLM; // Use the final, adjusted total
      
      if (firstErrorMsg != null) {
        _calculationError = firstErrorMsg;
        _totalVolumeDisplay = ""; 
        _testPiecesPerTotalVolumeDisplay = "";
        _calculatedTestPiecesPage2 = 0.0;
      } else if (_rawTotalVolumeLM > 0) { 
        _totalVolumeDisplay = "Total Volume: ${finalTotalVolumeLM.toStringAsFixed(4)} l/m";
        if (_rawTotalVolumeLM > 1e-9) { 
          double numerator = (_selectedIECType == IECTestType.iEC60332_3_22) ? 7.0 : 1.5;
          _calculatedTestPiecesPage2 = (numerator / _rawTotalVolumeLM).ceilToDouble();
          _testPiecesPerTotalVolumeDisplay = "Test Pieces: ${_calculatedTestPiecesPage2.toStringAsFixed(0)}"; 
        }
      } else {
          bool anyInput = _sampleControllers.any((c) => c.selectedMaterialKey != null || c.weightController.text.isNotEmpty);
          if (anyInput) {
             _calculationError = "No valid data entered for calculation.";
          }
      }

      _showResultTab = _calculatedResults.any((r) => r != null) || _calculationError != null;
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
      _totalVolumeDisplay = "";
      _rawTotalVolumeLM = 0.0;
      _testPiecesPerTotalVolumeDisplay = "";
      _calculatedTestPiecesPage2 = 0.0;
      if (resetType) {
        _selectedIECType = IECTestType.iEC60332_3_22;
      }
    });
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
            _totalVolumeDisplay = ""; 
            _rawTotalVolumeLM = 0.0;
            _testPiecesPerTotalVolumeDisplay = "";
            _calculatedTestPiecesPage2 = 0.0;
        }),
      ),
    );
  }

  Widget _buildMaterialInputRow(int index) {
    final controllers = _sampleControllers[index];
    final String materialFieldLabel = 'Material ${index + 1}';
    const String weightFieldLabel = 'Weight (g)';

    return Padding( 
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Expanded( 
            flex: 2, 
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: materialFieldLabel,
                labelStyle: const TextStyle(fontSize: 14.0),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              value: controllers.selectedMaterialKey,
              items: _materialDensityData.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key, style: const TextStyle(fontSize: 14.0), overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  controllers.selectedMaterialKey = newValue;
                  _showResultTab = false;
                  _calculationError = null;
                  _totalVolumeDisplay = ""; 
                  _rawTotalVolumeLM = 0.0;
                  _testPiecesPerTotalVolumeDisplay = "";
                  _calculatedTestPiecesPage2 = 0.0;
                });
              },
              isExpanded: true, 
            ),
          ),
          const SizedBox(width: 10.0), 
          Expanded( 
            flex: 2, 
            child: _buildTextField(
              label: weightFieldLabel, 
              controller: controllers.weightController,
              fieldWidth: null, 
            ),
          ),
          if (_sampleControllers.length > 1)
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade700),
              tooltip: 'Remove Material ${index + 1}', 
              padding: const EdgeInsets.only(left: 8.0), 
              constraints: const BoxConstraints(),
              onPressed: () => _removeMaterial(index),
            )
          else 
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
      appBar: AppBar(title: const Text('IEC 60332-3 Non-Metallic Volume')),
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
                      labelText: 'Select IEC Test Category:',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                    value: _selectedIECType,
                    items: IECTestType.values.map((IECTestType type) {
                      String typeName = type.toString().split('.').last;
                      if (type == IECTestType.iEC60332_3_22) typeName = "Category A (IEC 60332-3-22)";
                      if (type == IECTestType.iEC60332_3_24) typeName = "Category C (IEC 60332-3-24)";
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
                  color: const Color(0xFFFFEBEB), 
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80), 
                     ElevatedButton.icon(
                        onPressed: _addMaterial, 
                        icon: const Icon(Icons.add),
                        label: const Text('Add Material'), 
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade300,
                            minimumSize: const Size(140, 45))), 
                    
                    const SizedBox(width: 8),

                     ElevatedButton.icon(
                        onPressed: _navigateToNextPage,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next Page'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, 
                            foregroundColor: Colors.white,
                            minimumSize: const Size(140, 45),
                        ),
                        ),
                  ],
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
                            color: _calculationError != null && !(_calculatedResults.any((r) => r is IEC22Results || r is IEC24Results))
                                ? Colors.red[50]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: _calculationError != null && !(_calculatedResults.any((r) => r is IEC22Results || r is IEC24Results))
                                    ? Colors.red.shade300
                                    : Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_calculationError != null && !(_calculatedResults.any((r) => r is IEC22Results || r is IEC24Results)))
                                Text(_calculationError!, style: errorStyle)
                              else ...[
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
                                        child: Text('Material ${index + 1}: Skipped', style: normalStyle.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[700])),
                                      );
                                    }
                                    
                                    String materialRes = "", weightRes = "", densityRes = "", volumeDisplayStr = "";
                                    double individualRawVolume = 0.0;
                                    bool isAdjusted = false; // Flag to check if density was adjusted

                                    if (result is IEC22Results) { 
                                        materialRes = result.material;
                                        weightRes = result.weight;
                                        densityRes = result.density;
                                        volumeDisplayStr = result.volume;
                                        individualRawVolume = result.rawVolumeLM;
                                        isAdjusted = result.isAdjusted;
                                    } else if (result is IEC24Results) { 
                                        materialRes = result.material;
                                        weightRes = result.weight;
                                        densityRes = result.density;
                                        volumeDisplayStr = result.volume;
                                        individualRawVolume = result.rawVolumeLM;
                                        isAdjusted = result.isAdjusted;
                                    }

                                    if (materialRes.isNotEmpty) { 
                                      String percentageText = "";
                                      if (_rawTotalVolumeLM > 1e-9 && individualRawVolume > 0) { 
                                        double percentage = (individualRawVolume / _rawTotalVolumeLM) * 100;
                                        percentageText = " (${percentage.toStringAsFixed(2)}%)"; 
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Material ${index + 1}: $materialRes', style: boldStyle.copyWith(fontSize: 15)), 
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Weight: $weightRes', style: resultValueStyle),
                                                  Row( // Use a row to display density and adjustment note
                                                    children: [
                                                      Text('Density: $densityRes', style: resultValueStyle),
                                                      if (isAdjusted)
                                                        Text(' (Adjusted)', style: resultValueStyle.copyWith(color: Colors.deepOrange, fontStyle: FontStyle.italic)),
                                                    ],
                                                  ),
                                                  Text('Volume: $volumeDisplayStr$percentageText', style: resultValueStyle), 
                                                ],
                                              ),
                                            ),
                                           if (index < _calculatedResults.length -1 && _calculatedResults.skip(index+1).any((r) => r != null && r != "SKIPPED"))
                                                const Divider(height: 10, thickness: 0.5),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink(); 
                                  },
                                ),

                                // Total Volume Display
                                if (_totalVolumeDisplay.isNotEmpty && _calculationError == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0), 
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, 
                                      children: [
                                        const Divider(height: 10, thickness: 0.8, color: Colors.blueGrey),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text( 
                                            _totalVolumeDisplay,
                                            style: boldStyle.copyWith(fontSize: 15, color: Theme.of(context).primaryColorDark), 
                                            textAlign: TextAlign.start, 
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                // Test Pieces per Total Volume Display
                                if (_testPiecesPerTotalVolumeDisplay.isNotEmpty && _calculationError == null)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: _totalVolumeDisplay.isNotEmpty ? 4.0 : 16.0, 
                                      bottom: 8.0
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, 
                                      children: [
                                        if (_totalVolumeDisplay.isEmpty && _calculatedResults.any((r) => r != null && r != "SKIPPED"))
                                          const Divider(height: 10, thickness: 0.8, color: Colors.blueGrey),
                                        Text( 
                                          '$_testPiecesPerTotalVolumeDisplay pcs x 3.5m',
                                          style: boldStyle.copyWith(fontSize: 15, color: Theme.of(context).primaryColorDark), 
                                          textAlign: TextAlign.start, 
                                        ),
                                      ],
                                    ),
                                  ),
                              ] 
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
