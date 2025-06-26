import 'package:flutter/material.dart';


class PressureCalculationPage extends StatefulWidget {
  const PressureCalculationPage({super.key});

  @override
  PressureCalculationPageState createState() =>
      PressureCalculationPageState();
}

class PressureCalculationPageState extends State<PressureCalculationPage> {
  // --- MODIFIED: Controllers for new inputs ---
  final TextEditingController _initialThicknessController = TextEditingController();
  final TextEditingController _secondaryThicknessController = TextEditingController();

  // --- MODIFIED: State variables for new logic ---
  String _selectedThicknessType = 'Indented'; // Default selection
  String? _calculatedResult;
  String? _calculationError;
  bool _showResultTab = false;

  @override
  void dispose() {
    _initialThicknessController.dispose();
    _secondaryThicknessController.dispose();
    super.dispose();
  }

  // --- MODIFIED: Calculation Logic for new inputs and formulas ---
  void _performCalculations() {
    // Clear previous errors/results first
    setState(() {
      _calculationError = null;
      _calculatedResult = null;
      _showResultTab = false;
    });

    // Parse new inputs
    double? initialThickness = double.tryParse(_initialThicknessController.text);
    double? secondaryThickness = double.tryParse(_secondaryThicknessController.text);

    // Validate ALL required inputs
    String? errorMsg;
    if (initialThickness == null) {errorMsg = 'Invalid Initial Thickness input.';}
    else if (secondaryThickness == null) {errorMsg = 'Invalid Thickness input.';}
    else if (initialThickness < 0) {errorMsg = 'Initial Thickness cannot be negative.';}
    else if (secondaryThickness < 0) {errorMsg = 'Thickness cannot be negative.';}
    // Specific validation based on selected type
    else if (_selectedThicknessType == 'Indented' && initialThickness == 0) {
      errorMsg = 'Initial Thickness cannot be zero for Indented calculation.';
    }

    if (errorMsg != null) {
      setState(() { _calculationError = errorMsg; _showResultTab = true; });
      FocusScope.of(context).unfocus();
      return;
    }

    // Perform calculation based on selected type
    double indentation = 0;
    if (_selectedThicknessType == 'Indented') {
      // Indentation = (Indented thickness / Initial thickness) * 100
      indentation = (secondaryThickness! / initialThickness!) * 100;
    } else { // 'Balance'
      // Indentation = (Initial thickness - balance thickness) * 100
      indentation = (initialThickness! - secondaryThickness!) * 100;
    }

    setState(() {
      _calculatedResult = '${indentation.toStringAsFixed(2)}%';
      _showResultTab = true;
    });
      FocusScope.of(context).unfocus();
  }

  // --- MODIFIED: Reset Logic for new inputs ---
  void _resetFields() {
    setState(() {
      _initialThicknessController.clear();
      _secondaryThicknessController.clear();
      _selectedThicknessType = 'Indented'; // Reset to default
      _calculatedResult = null;
      _calculationError = null;
      _showResultTab = false;
    });
  }

  // Helper for a simple input row
  Widget _buildSimpleInputRow({
      required String label,
      required TextEditingController controller,
      double fieldWidth = 150,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
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
    );
  }

  // --- NEW: Helper for an input row with a dropdown on the left ---
  Widget _buildInputRowWithLeftDropdown({
    required String selectedType,
    required List<String> typeOptions,
    required ValueChanged<String?> onTypeChanged,
    required TextEditingController controller,
    double fieldWidth = 110,
    double unitWidth = 110,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: unitWidth,
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              value: selectedType,
              onChanged: (val) {
                onTypeChanged(val);
                setState(() => _showResultTab = false);
              },
              items: typeOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 15.0)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: fieldWidth,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 15.0),
              decoration: const InputDecoration(
                labelText: 'Thickness:',
                labelStyle: TextStyle(fontSize: 15.0),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
      appBar: AppBar(title: const Text('Pressure: Calculation')),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // --- MODIFIED: Input Fields ---
                _buildSimpleInputRow(label: 'Initial thickness:', controller: _initialThicknessController),
                _buildInputRowWithLeftDropdown(
                  selectedType: _selectedThicknessType,
                  typeOptions: const ['Indented', 'Balance'],
                  onTypeChanged: (val) => setState(() => _selectedThicknessType = val!),
                  controller: _secondaryThicknessController
                ),

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

                // --- MODIFIED: Result Section ---
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
                                const Text('Indentation', style: boldStyle),
                                Text(
                                  _selectedThicknessType == 'Indented'
                                      ? '  Formula: (Indented / Initial) * 100'
                                      : '  Formula: (Initial - Balance) * 100',
                                  style: resultValueStyle,
                                ),
                                Text('  Calculated: ${_calculatedResult ?? '...'}', style: resultValueStyle),
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
