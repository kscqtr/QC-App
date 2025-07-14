import 'package:flutter/material.dart';
import 'dart:math';

// Helper class to hold controllers for each sample's inputs
class WaterAbsorptionSampleControllers {
  final TextEditingController thicknessController;
  final TextEditingController m1Controller;
  final TextEditingController m2Controller;
  final TextEditingController m3Controller;

  WaterAbsorptionSampleControllers()
      : thicknessController = TextEditingController(),
        m1Controller = TextEditingController(),
        m2Controller = TextEditingController(),
        m3Controller = TextEditingController();

  void dispose() {
    thicknessController.dispose();
    m1Controller.dispose();
    m2Controller.dispose();
    m3Controller.dispose();
  }

  void clear() {
    thicknessController.clear();
    m1Controller.clear();
    m2Controller.clear();
    m3Controller.clear();
  }
}

// Helper class for per-sample calculation data
class SampleCalculationData {
  final double surfaceArea;
  final double waterAbsorption;

  SampleCalculationData({
    required this.surfaceArea,
    required this.waterAbsorption,
  });
}

class WaterAbsorptionStripPage extends StatefulWidget {
  const WaterAbsorptionStripPage({super.key});

  @override
  WaterAbsorptionStripPageState createState() => WaterAbsorptionStripPageState();
}

class WaterAbsorptionStripPageState extends State<WaterAbsorptionStripPage> {
  List<WaterAbsorptionSampleControllers> _sampleControllers = [WaterAbsorptionSampleControllers()];
  // --- MODIFIED: This now stores per-sample results ---
  List<dynamic> _calculatedResults = [];
  String? _calculationError;
  bool _showResultTab = false;
  final int _maxSamples = 6;
  final ScrollController _scrollController = ScrollController();

  String _selectedWeightUnit = 'mg';


  @override
  void initState() {
    super.initState();
    _initializeSamplesAndResults();
  }

  void _initializeSamplesAndResults() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _sampleControllers = [WaterAbsorptionSampleControllers()];
    _calculatedResults = [];
    _selectedWeightUnit = 'mg';
  }

  @override
  void dispose() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _scrollController.dispose();
    super.dispose();
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

  void _addSample() {
    if (_sampleControllers.length < _maxSamples) {
      setState(() {
        _sampleControllers.add(WaterAbsorptionSampleControllers());
        _showResultTab = false;
        _calculationError = null;
        _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      });
      Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum of $_maxSamples samples reached.')),
      );
    }
  }

  void _removeSample(int index) {
    if (_sampleControllers.length > 1) {
      setState(() {
        _sampleControllers[index].dispose();
        _sampleControllers.removeAt(index);
        _calculatedResults.removeAt(index);
        
        bool hasAnyValidResult = _calculatedResults.any((r) => r != null && r != "SKIPPED");
        if (!hasAnyValidResult && _calculationError == null) {
            _showResultTab = false;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one sample is required.')),
      );
    }
  }

  void _performCalculations() {
    FocusScope.of(context).unfocus();
    setState(() {
      _calculationError = null;
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _showResultTab = false;
    });
    
    String? firstErrorMsg;
    List<dynamic> tempPerSampleResults = List.filled(_sampleControllers.length, null, growable: true);


    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String thicknessText = controllers.thicknessController.text;
      final String m1Text = controllers.m1Controller.text;
      final String m2Text = controllers.m2Controller.text;
      final String m3Text = controllers.m3Controller.text;

      if (thicknessText.isEmpty && m1Text.isEmpty && m2Text.isEmpty && m3Text.isEmpty) {
         if (_sampleControllers.length > 1) {
            tempPerSampleResults[i] = "SKIPPED";
            continue;
        } else {
            firstErrorMsg ??= 'Please enter data for Sample ${i + 1}.';
            break;
        }
      }

      double? thickness = double.tryParse(thicknessText);
      double? m1Weight = double.tryParse(m1Text);
      double? m2Weight = double.tryParse(m2Text);
      double? m3Weight = double.tryParse(m3Text);
      String? errorMsg;

      if (thickness == null) {errorMsg = 'Invalid Min. Thickness (Sample ${i+1}).';}
      else if (m1Weight == null) {errorMsg = 'Invalid M1 Weight (Sample ${i+1}).';}
      else if (m2Weight == null) {errorMsg = 'Invalid M2 Weight (Sample ${i+1}).';}
      else if (m3Weight == null) {errorMsg = 'Invalid M3 Weight (Sample ${i+1}).';}
      else if (thickness <= 0) {errorMsg = 'Thickness must be positive (Sample ${i+1}).';}
      else if (m1Weight < 0) {errorMsg = 'M1 Weight cannot be negative (Sample ${i+1}).';}
      else if (m2Weight < 0) {errorMsg = 'M2 Weight cannot be negative (Sample ${i+1}).';}
      else if (m3Weight < 0) {errorMsg = 'M3 Weight cannot be negative (Sample ${i+1}).';}

      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg;
        break;
      }

      double m1WeightMg = m1Weight!;
      if (_selectedWeightUnit == 'g') m1WeightMg *= 1000;

      double m2WeightMg = m2Weight!;
      if (_selectedWeightUnit == 'g') m2WeightMg *= 1000;

      double m3WeightMg = m3Weight!;
      if (_selectedWeightUnit == 'g') m3WeightMg *= 1000;

      const double stripLength = 100.0;
      const double stripWidth = 5.0;

      double surfaceArea = (2 * ( (stripLength * stripWidth) + (stripLength * thickness!) + (stripWidth * thickness) )) / 100;
      
      double maxWeightDiff = max(m2WeightMg - m1WeightMg, m2WeightMg - m3WeightMg);
      
      double waterAbsorption = 0;
      if (surfaceArea > 0) {
        waterAbsorption = maxWeightDiff / surfaceArea;
      } else {
        firstErrorMsg ??= 'Invalid surface area calculated for Sample ${i + 1}';
        break;
      }
      
      tempPerSampleResults[i] = SampleCalculationData(
        surfaceArea: surfaceArea,
        waterAbsorption: waterAbsorption,
      );
    }

    if (firstErrorMsg != null) {
        setState(() {
            _calculationError = firstErrorMsg;
            _showResultTab = true;
        });
        return;
    }

    setState(() {
      _calculatedResults = tempPerSampleResults;
      _showResultTab = true;
    });
  }

  void _resetFields() {
    FocusScope.of(context).unfocus();
    setState(() {
      for (var controllers in _sampleControllers) {
        controllers.dispose();
      }
      _sampleControllers = [WaterAbsorptionSampleControllers()];
      _calculatedResults = [];
      _calculationError = null;
      _showResultTab = false;
      _selectedWeightUnit = 'mg';
    });
  }


  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
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
    );
  }

  Widget _buildSampleInputCard(int index) {
    final controllers = _sampleControllers[index];
    final resultData = (_showResultTab && index < _calculatedResults.length && _calculatedResults[index] is SampleCalculationData)
        ? _calculatedResults[index] as SampleCalculationData
        : null;
    
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        elevation: 1.0,
        color: const Color(0xFFFFEBEB),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sample ${index + 1}', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    if (_sampleControllers.length > 1)
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade700),
                        tooltip: 'Remove Sample ${index + 1}',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _removeSample(index),
                      ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Thickness (mm)', 
                        controller: controllers.thicknessController
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Card(
                  color: const Color.fromARGB(255, 255, 218, 218),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Weight', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            SizedBox(
                              width: 75,
                              height: 40,
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                value: _selectedWeightUnit,
                                items: ['mg', 'g'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(fontSize: 14.0)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedWeightUnit = val!;
                                    _showResultTab = false;
                                    _calculationError = null;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(label: 'M1', controller: controllers.m1Controller)),
                            const SizedBox(width: 20.0),
                            Expanded(child: _buildTextField(label: 'M2', controller: controllers.m2Controller)),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                             Expanded(child: _buildTextField(label: 'M3', controller: controllers.m3Controller)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                // --- MODIFIED: Results display within the card ---
                if (resultData != null) ...[
                  const Divider(height: 20, thickness: 1),
                  Text('Strip Length: 100.0 mm', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Strip Width: 5.0 mm', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Surface Area: ${resultData.surfaceArea.toStringAsFixed(3)} cm²', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Water Absorption: ${resultData.waterAbsorption.toStringAsFixed(3)} mg/cm²', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    final errorStyle = boldStyle.copyWith(color: Colors.red.shade700, fontSize: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Water Absorption - Strip')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sampleControllers.length,
                  itemBuilder: (context, index) {
                    return _buildSampleInputCard(index);
                  },
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
                        onPressed: _resetFields,
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
                        onPressed: _addSample,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade300,
                            minimumSize: const Size(90, 45))),
                  ],
                ),
                const SizedBox(height: 30),

                // --- MODIFIED: This now only shows an error message if one exists ---
                AnimatedOpacity(
                  opacity: _showResultTab && _calculationError != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showResultTab && _calculationError != null
                      ? Container(
                          constraints: const BoxConstraints(maxWidth: 380),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Text(_calculationError!, style: errorStyle),
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
