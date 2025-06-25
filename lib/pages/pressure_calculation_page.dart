import 'package:flutter/material.dart';
import 'dart:math';

class PressureCalculationPage extends StatefulWidget {
  const PressureCalculationPage({super.key});

  @override
  PressureCalculationPageState createState() =>
      PressureCalculationPageState();
}

class PressureCalculationPageState extends State<PressureCalculationPage> {
  // Controllers for inputs
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _insulationResistanceController = TextEditingController();
  final TextEditingController _outerDiameterController = TextEditingController();
  final TextEditingController _innerDiameterController = TextEditingController();

  // State variables for dropdowns
  String _selectedlengthUnit = 'cm';
  String _selectedIRUnit = 'MΩ';
  String _selectedOuterDiameterUnit = 'mm';
  String _selectedInnerDiameterUnit = 'mm';

  // State variables for results
  String? _calculatedResultVolumeResistivity; // Stores "X nF/km"
  String? _calculatedResultKi; // Stores "Y µs"
  String? _calculationError; // Stores error messages
  bool _showResultTab = false;

  @override
  void dispose() {
    _lengthController.dispose();
    _insulationResistanceController.dispose();
    _outerDiameterController.dispose();
    _innerDiameterController.dispose();
    super.dispose();
  }

  // Calculation Logic
  void _performCalculations() {
    // Clear previous errors/results first
    setState(() {
       _calculationError = null;
       _calculatedResultVolumeResistivity = null;
       _calculatedResultKi = null;
       _showResultTab = false;
    });

    // Parse inputs
    double? lengthInput = double.tryParse(_lengthController.text);
    double? insulationResistanceInput = double.tryParse(_insulationResistanceController.text);
    double? outerDiameterInput = double.tryParse(_outerDiameterController.text);
    double? innerDiameterInput = double.tryParse(_innerDiameterController.text);

    // Validate ALL required inputs
    String? errorMsg;
    if (lengthInput == null) {errorMsg = 'Invalid Length input.';}
    else if (insulationResistanceInput == null) {errorMsg = 'Invalid Insulation Resistance input.';}
    else if (outerDiameterInput == null) {errorMsg = 'Invalid Outer Diameter input.';}
    else if (innerDiameterInput == null) {errorMsg = 'Invalid Inner Diameter input.';}
    else if (outerDiameterInput <= 0) {errorMsg = 'Outer Diameter must be positive.';}
    else if (innerDiameterInput <= 0) {errorMsg = 'Inner Diameter must be positive.';}
    else if (lengthInput < 0) {errorMsg = 'Length cannot be negative.';}
    else if (insulationResistanceInput < 0) {errorMsg = 'Insulation Resistance cannot be negative.';}


    if (errorMsg != null) {
      setState(() { _calculationError = errorMsg; _showResultTab = true; });
      FocusScope.of(context).unfocus();
      return;
    }


    // Unit Conversions (safe ! because null checks passed)
    double innerDiameter = innerDiameterInput!;
    double length = lengthInput!;
    double insulationResistance = (_selectedIRUnit == 'GΩ') ? insulationResistanceInput! * 1e9 : (insulationResistanceInput!) * 1e6; // Convert MΩ to Ω or GΩ to Ω
    double outerDiameter = outerDiameterInput!;

    // Calculations
    double volumeResistivity = (2 * 3.1416 * length * insulationResistance) / log(outerDiameter/innerDiameter); 
    double ki = (1e-11 * 0.367 * volumeResistivity); 

    setState(() {
      // First, convert the number to exponential notation (e.g., 1e+9)
      String exponentialNotation = volumeResistivity.toStringAsExponential(3); // 0 for precision

      // Then, replace 'e+' with 'x 10^' to get the desired format
      String formattedResult = exponentialNotation.replaceAll('e+', ' x 10^');

      // Finally, assign it to your variable with the unit
      _calculatedResultVolumeResistivity = '$formattedResult Ω.cm';
      
      // For Ki, format to 3 decimal places with unit
      _calculatedResultKi = '${ki.toStringAsFixed(3)} MΩ.km';
      _showResultTab = true;
    });
     FocusScope.of(context).unfocus();
  }

  // Reset Logic
  void _resetFields() {
    setState(() {
      _lengthController.clear();
      _insulationResistanceController.clear();
      _outerDiameterController.clear();
      _innerDiameterController.clear();
      _selectedIRUnit = 'MΩ';
      _calculatedResultVolumeResistivity = null;
      _calculatedResultKi = null;
      _calculationError = null;
      _showResultTab = false;
    });
  }

  // Helper to build input rows
  Widget _buildInputRow({
      required String label,
      required TextEditingController controller,
      required String selectedUnit,
      required List<String> unitOptions,
      required ValueChanged<String?> onUnitChanged,
      double fieldWidth = 150,
      double unitWidth = 80,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: fieldWidth,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 15.0),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontSize: 15.0),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              onChanged: (value) => setState(() => _showResultTab = false),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: unitWidth,
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                 border: OutlineInputBorder(),
                 isDense: true,
                 contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
               ),
              value: selectedUnit,
              onChanged: (val) {
                  onUnitChanged(val);
                  setState(() => _showResultTab = false);
              },
              items: unitOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 15.0)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

   // Helper to build input rows
  Widget _buildInputRowNoDropbox({
      required String label,
      required TextEditingController controller,
      required String selectedUnit,
      required ValueChanged<String?> onUnitChanged,
      double fieldWidth = 150,
      double unitWidth = 80,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: fieldWidth,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 15.0),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontSize: 15.0),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              onChanged: (value) => setState(() => _showResultTab = false),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: unitWidth,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Define styles for reuse
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    const normalStyle = TextStyle(fontSize: 15, color: Colors.black87);
    final errorStyle = boldStyle.copyWith(color: Colors.red, fontSize: 16);
    final resultValueStyle = normalStyle.copyWith(fontSize: 14);


    return Scaffold(
      appBar: AppBar(title: const Text('Constant Ki')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Input Fields
                _buildInputRowNoDropbox(label: 'Cable length:', controller: _lengthController, selectedUnit: _selectedlengthUnit, onUnitChanged: (val) => _selectedlengthUnit = val!),
                _buildInputRow(label: 'Resistance:', controller: _insulationResistanceController, selectedUnit: _selectedIRUnit, unitOptions: const ['MΩ', 'GΩ'], onUnitChanged: (val) => _selectedIRUnit = val!),
                _buildInputRowNoDropbox(label: 'Outer Diameter:', controller: _outerDiameterController, selectedUnit: _selectedOuterDiameterUnit, onUnitChanged: (val) => _selectedOuterDiameterUnit = val!),
                _buildInputRowNoDropbox(label: 'Inner Diameter:', controller: _innerDiameterController, selectedUnit: _selectedInnerDiameterUnit, onUnitChanged: (val) => _selectedInnerDiameterUnit = val!),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(onPressed: _performCalculations, icon: const Icon(Icons.calculate), label: const Text('Calculate'), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Theme.of(context).colorScheme.onPrimary, minimumSize: const Size(120, 45))),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(onPressed: _resetFields, icon: const Icon(Icons.refresh), label: const Text('Reset'), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400], minimumSize: const Size(120, 45))),
                  ],
                ),
                const SizedBox(height: 30),

                // --- MODIFIED Result Section with Formulas (using Text widgets) ---
                AnimatedOpacity(
                  opacity: _showResultTab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showResultTab
                      ? Container(
                          constraints: const BoxConstraints(maxWidth: 380),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _calculationError != null ? Colors.red[50] : Colors.blue[50], // Error or neutral background
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: _calculationError != null ? Colors.red.shade300 : Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Show Error if present
                              if (_calculationError != null)
                                Text(_calculationError!, style: errorStyle)
                              // Show Results if no error
                              else ...[
                                // Capacitance Result Block
                                const Text('P, Volume resistivity', style: boldStyle),
                                Text('  Formula: 2 * 3.1416 * L * IR', style: resultValueStyle),
                                Text('  Calculated: ${_calculatedResultVolumeResistivity ?? '...'}', style: resultValueStyle),
                                const SizedBox(height: 10),
                                const Divider(height: 25, thickness: 1),

                                // L/R Result Block
                                const Text('Ki', style: boldStyle),
                                Text('  Formula: 10⁻¹¹ * 0.367 * P', style: resultValueStyle),
                                Text('  Calculated: ${_calculatedResultKi ?? '...'}', style: resultValueStyle),
                                const SizedBox(height: 10),
                              ]
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                 const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
