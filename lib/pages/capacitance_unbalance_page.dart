import 'package:flutter/material.dart';

class CapacitanceUnbalancePage extends StatefulWidget {
  const CapacitanceUnbalancePage({super.key});

  @override
  CapacitanceUnbalancePageState createState() =>
      CapacitanceUnbalancePageState();
}

class CapacitanceUnbalancePageState extends State<CapacitanceUnbalancePage> {
  // Controllers for inputs
  final TextEditingController _capacitanceAGController = TextEditingController(); // Renamed
  final TextEditingController _capacitanceBGController = TextEditingController(); // Added
  final TextEditingController _lengthController = TextEditingController();

  // State variables for dropdowns
  String _selectedCapacitanceUnitAG = 'nF'; // Separate unit for AG
  String _selectedCapacitanceUnitBG = 'nF'; // Separate unit for BG
  String _selectedLengthUnit = 'm';

  // State variables for results
  String? _calculatedResultCum; // Stores "X pF/km" for Cum
  String? _calculatedResultCu;  // Stores "X pF/500m" for Cu
  String? _calculationError; // Stores error messages
  bool _showResultTab = false;
  bool _isPassCu = true; // Pass/Fail based on Cu
  double _currentSpecMax = 500.0; // Define the spec max value

  @override
  void initState() {
    super.initState();
    // Initialize spec max here if needed, or keep it fixed as 500.0
    _currentSpecMax = 500.0;
  }


  @override
  void dispose() {
    _capacitanceAGController.dispose();
    _capacitanceBGController.dispose(); // Dispose new controller
    _lengthController.dispose();
    super.dispose();
  }

  // --- Helper Function for Unit Conversion ---
  double _convertToNf(double value, String unit) {
    switch (unit) {
      case 'pF':
        return value;
      case 'µF':
        return value / 1000000.0;
      case 'nF':
        return value / 1000.0;
      default:
        return value;
    }
  }

  double _convertToKm(double value, String unit) {
     return (unit == 'm') ? value / 1000.0 : value;
  }

  double _convertToM(double value, String unit) {
     return (unit == 'km') ? value * 1000.0 : value;
  }
  // --- End Helper Functions ---


  // Calculation Logic
  void _performCalculations() {
    // Clear previous errors/results first
    setState(() {
      _calculationError = null;
      _calculatedResultCum = null;
      _calculatedResultCu = null;
      _showResultTab = false;
      _isPassCu = true; // Reset pass status
      // _currentSpecMax is fixed at 500.0
    });

    // Parse inputs
    double? capacitanceAGInput = double.tryParse(_capacitanceAGController.text);
    double? capacitanceBGInput = double.tryParse(_capacitanceBGController.text);
    double? lengthInput = double.tryParse(_lengthController.text);

    // Validate ALL required inputs
    String? errorMsg;
    if (capacitanceAGInput == null) { errorMsg = 'Invalid Capacitance C_AG input.'; }
    else if (capacitanceBGInput == null) { errorMsg = 'Invalid Capacitance C_BG input.'; }
    else if (lengthInput == null) { errorMsg = 'Invalid Length input.'; }
    else if (lengthInput <= 0) { errorMsg = 'Length must be positive.'; }
    else if (capacitanceAGInput < 0) { errorMsg = 'Capacitance C_AG cannot be negative.'; }
     else if (capacitanceBGInput < 0) { errorMsg = 'Capacitance C_BG cannot be negative.'; }


    if (errorMsg != null) {
      setState(() { _calculationError = errorMsg; _showResultTab = true; });
      FocusScope.of(context).unfocus(); // Hide keyboard
      return;
    }

    // --- Unit Conversions (safe ! because null checks passed) ---
    double lengthInKm = _convertToKm(lengthInput!, _selectedLengthUnit);
    double lengthInM = _convertToM(lengthInput, _selectedLengthUnit); // Calculate length in meters as well

    // Convert both capacitances to nF using their respective selected units
    double capacitanceAGInNf = _convertToNf(capacitanceAGInput!, _selectedCapacitanceUnitAG);
    double capacitanceBGInNf = _convertToNf(capacitanceBGInput!, _selectedCapacitanceUnitBG);

    // --- Calculations ---
    // Formula 1: Cum = (CAG - CBG) / length in km
    // Avoid division by zero if lengthInKm happens to be zero (though validation prevents <= 0)
    if (lengthInKm == 0) {
        setState(() { _calculationError = 'Length in km cannot be zero for calculation.'; _showResultTab = true; });
        FocusScope.of(context).unfocus();
        return;
    }
    double cum = (capacitanceAGInNf - capacitanceBGInNf) / lengthInKm;

    if (lengthInM == 0) {
       setState(() { _calculationError = 'Length in meters cannot be zero for Cu calculation.'; _showResultTab = true; });
       FocusScope.of(context).unfocus();
       return;
    }
    double cu = cum * 500.0 / lengthInM; // User's original formula 2

    // --- Comparisons ---
    // Compare the absolute value of Cu against the spec max
    _isPassCu = cu.abs() <= _currentSpecMax;

    setState(() {
      // Format results
      _calculatedResultCum = '${cum.toStringAsFixed(3)} pF/km';
      _calculatedResultCu = '${cu.toStringAsFixed(3)} pF/500m'; // Assuming Cu is also in nF/km
      // If using the original user formula for Cu, the unit might be different!
      // _calculatedResultCu = '${cu.toStringAsFixed(3)} [Some Other Unit?]';

      _showResultTab = true;
    });
      FocusScope.of(context).unfocus(); // Hide keyboard
  }

  // Reset Logic
  void _resetFields() {
    setState(() {
      _capacitanceAGController.clear();
      _capacitanceBGController.clear(); // Clear new controller
      _lengthController.clear();
      _selectedCapacitanceUnitAG = 'nF'; // Reset units
      _selectedCapacitanceUnitBG = 'nF';
      _selectedLengthUnit = 'm';
      _calculatedResultCum = null; // Reset results
      _calculatedResultCu = null;
      _calculationError = null;
      _showResultTab = false;
      _isPassCu = true;
      // _currentSpecMax remains 500.0
    });
    FocusScope.of(context).unfocus(); // Hide keyboard
  }

  // Helper to build input rows (Remains mostly the same, parameters passed during call)
   Widget _buildInputRow({
     required String label,
     required TextEditingController controller,
     required String selectedUnit,
     required List<String> unitOptions,
     required ValueChanged<String?> onUnitChanged, // Callback for unit change
     double fieldWidth = 180,
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
               // Hide result tab when input changes
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Adjusted padding
                  ),
               value: selectedUnit,
               onChanged: (val) {
                 // Call the provided callback FIRST
                 onUnitChanged(val);
                 // Then update the state to hide results
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


  @override
  Widget build(BuildContext context) {
    // Define styles for reuse
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    const normalStyle = TextStyle(fontSize: 15, color: Colors.black87);
    final italicStyle = normalStyle.copyWith(fontStyle: FontStyle.italic);
    final formulaStyle = italicStyle.copyWith(fontSize: 14, color: Colors.grey[700]);
    final passStyle = boldStyle.copyWith(color: Colors.green.shade800);
    final failStyle = boldStyle.copyWith(color: Colors.red.shade800);
    final errorStyle = boldStyle.copyWith(color: Colors.red, fontSize: 16);


    return Scaffold(
      appBar: AppBar(title: const Text('Capacitance Unbalance to Earth (Cu)')), // Updated Title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Input Fields - Now two for capacitance
                _buildInputRow(
                  label: 'Capacitance (C_AG):', // Label for AG
                  controller: _capacitanceAGController,
                  selectedUnit: _selectedCapacitanceUnitAG, // Use AG state variable
                  unitOptions: const ['nF', 'pF', 'µF'],
                  // Update the correct state variable for AG unit
                  onUnitChanged: (val) => setState(() => _selectedCapacitanceUnitAG = val!),
                ),
                 _buildInputRow(
                  label: 'Capacitance (C_BG):', // Label for BG
                  controller: _capacitanceBGController,
                  selectedUnit: _selectedCapacitanceUnitBG, // Use BG state variable
                  unitOptions: const ['nF', 'pF', 'µF'],
                   // Update the correct state variable for BG unit
                  onUnitChanged: (val) => setState(() => _selectedCapacitanceUnitBG = val!),
                ),
                _buildInputRow(
                  label: 'Length (L):',
                  controller: _lengthController,
                  selectedUnit: _selectedLengthUnit,
                  unitOptions: const ['km', 'm'],
                   // Update the length unit state variable
                  onUnitChanged: (val) => setState(() => _selectedLengthUnit = val!),
                 ),


                const SizedBox(height: 30),

                // Action Buttons (Remain the same)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(onPressed: _performCalculations, icon: const Icon(Icons.calculate), label: const Text('Calculate'), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Theme.of(context).colorScheme.onPrimary, minimumSize: const Size(120, 45))),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(onPressed: _resetFields, icon: const Icon(Icons.refresh), label: const Text('Reset'), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400], minimumSize: const Size(120, 45))),
                  ],
                ),
                const SizedBox(height: 30),

                // --- UPDATED Result Section ---
                AnimatedOpacity(
                  opacity: _showResultTab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showResultTab
                      ? Container(
                          constraints: const BoxConstraints(maxWidth: 380),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _calculationError != null ? Colors.red[50] : Colors.blue[50],
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
                                // --- Cum Result Block ---
                                const Text('Mutual Unbalance (Cum)', style: boldStyle),
                                const SizedBox(height: 5),
                                Text('Formula: (CAG - CBG) / L (km)', style: formulaStyle), // Updated formula text
                                Text('Calculated: ${_calculatedResultCum ?? '...'}', 
                                style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                const SizedBox(height: 10),
                                const Divider(height: 20, thickness: 1),

                                // --- Cu Result Block ---
                                const Text('Unbalance to Earth (Cu)', style: boldStyle),
                                const SizedBox(height: 5),
                                Text('Formula: Cum * 500 / L (m)', style: formulaStyle),
                                Text('Spec Max: ${_currentSpecMax.toStringAsFixed(1)} pF/500m', style: formulaStyle),
                                Text('Calculated: ${_calculatedResultCu ?? '...'}', 
                                style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                const SizedBox(height: 10),

                                // --- Pass/Fail Comparison Block ---
                                Text(
                                  'Result: ${_isPassCu ? 'Pass' : 'Fail'}', // Compare Cu
                                  style: _isPassCu ? passStyle : failStyle,
                                ),

                              ]
                            ],
                          ),
                        )
                      : const SizedBox.shrink(), // Use SizedBox.shrink() when not visible
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