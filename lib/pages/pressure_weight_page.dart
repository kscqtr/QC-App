import 'package:flutter/material.dart';

class PressureWeightPage extends StatefulWidget {
  const PressureWeightPage({super.key});

  @override
  PressureWeightPageState createState() =>
      PressureWeightPageState();
}

class PressureWeightPageState extends State<PressureWeightPage> {
  // Controllers for inputs
  final TextEditingController _overallDiameterController = TextEditingController();
  final TextEditingController _thicknessController = TextEditingController();


  // State variables for dropdowns
  String _selectedODUnit = 'mm';
  String _selectedThicknessUnit = 'mm';
  String? _selectedKValueUnit;


  // State variables for results
  String? _calculatedResultNewton; // Stores "X N"
  String? _calculatedResultGram; // Stores "Y g"
  String? _calculationError; // Stores error messages
  bool _showResultTab = false;

  @override
  void dispose() {
    _overallDiameterController.dispose();
    _thicknessController.dispose();
    super.dispose();
  }

  // Calculation Logic
  void _performCalculations() {
    // Clear previous errors/results first
    setState(() {
       _calculationError = null;
       _calculatedResultNewton = null;
       _calculatedResultGram = null;
       _showResultTab = false;
    });

    // Parse inputs
    double? odInput = double.tryParse(_overallDiameterController.text);
    double? thicknessInput = double.tryParse(_thicknessController.text);

    // Validate ALL required inputs
    String? errorMsg;
    if (odInput == null) {errorMsg = 'Invalid Length input.';}
    else if (thicknessInput == null) {errorMsg = 'Invalid Insulation Resistance input.';}
    else if (odInput < 0) {errorMsg = 'Length cannot be negative.';}
    else if (thicknessInput < 0) {errorMsg = 'Insulation Resistance cannot be negative.';}


    if (errorMsg != null) {
      setState(() { _calculationError = errorMsg; _showResultTab = true; });
      FocusScope.of(context).unfocus();
      return;
    }


    // Unit Conversions (safe ! because null checks passed)
    double diameter = odInput!;
    double thickness = (_selectedThicknessUnit == 'GΩ') ? thicknessInput! * 1e9 : (thicknessInput!) * 1e6; // Convert MΩ to Ω or GΩ to Ω

    // Calculations
    double newton = (2 * 3.1416 * diameter * thickness);
    double gram = (1e-11 * 0.367 * newton); 
    _calculatedResultGram = '${gram.toStringAsFixed(3)} MΩ.km';

    setState(() {
      _showResultTab = true;
    });
     FocusScope.of(context).unfocus();
  }

  // Reset Logic
  void _resetFields() {
    setState(() {
      _overallDiameterController.clear();
      _thicknessController.clear();
      _selectedThicknessUnit = 'MΩ';
      _calculatedResultNewton = null;
      _calculatedResultGram = null;
      _calculationError = null;
      _showResultTab = false;
      _selectedKValueUnit = null;
    });
  }

  Widget _buildDropdownRow({
      required String hint,
      required String? selectedValue,
      required List<String> options,
      required ValueChanged<String?> onChanged,
      double width = 240,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: width,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: hint,
                    labelStyle: const TextStyle(fontSize: 15.0),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                value: selectedValue,
                hint: Text(hint, style: const TextStyle(fontSize: 15.0, color: Colors.grey)),
                isExpanded: true,
                onChanged: (val) {
                    onChanged(val);
                    setState(() => _showResultTab = false);
                },
                items: options.map<DropdownMenuItem<String>>((String value) {
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
      double fieldWidth = 200,
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
      appBar: AppBar(title: const Text('Pressure: Weight')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Input Fields
                _buildInputRowNoDropbox(label: 'Overall Diameter (mm):', controller: _overallDiameterController, selectedUnit: _selectedODUnit, onUnitChanged: (val) => _selectedODUnit = val!),
                _buildInputRowNoDropbox(label: 'Thickness (mm):', controller: _thicknessController, selectedUnit: _selectedThicknessUnit, onUnitChanged: (val) => _selectedThicknessUnit = val!),
                _buildDropdownRow(hint: 'Select K Value', selectedValue: _selectedKValueUnit, options: const ['0.6 (< 15mm)', '0.7 (≥ 15mm)', '1.0 (Ei5)'], onChanged: (val) => _selectedKValueUnit = val!, width: 200),

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
                                Text('  Calculated: ${_calculatedResultNewton ?? '...'}', style: resultValueStyle),
                                const SizedBox(height: 10),
                                const Divider(height: 25, thickness: 1),

                                // L/R Result Block
                                const Text('Ki', style: boldStyle),
                                Text('  Formula: 10⁻¹¹ * 0.367 * P', style: resultValueStyle),
                                Text('  Calculated: ${_calculatedResultGram ?? '...'}', style: resultValueStyle),
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
