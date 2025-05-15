import 'package:flutter/material.dart';
import 'dumbbell_calculation2_page.dart'; // Import the next page

class DumbbellCalculationPage extends StatefulWidget {
  const DumbbellCalculationPage({super.key});

  @override
  State<DumbbellCalculationPage> createState() => _DumbbellCalculationPageState();
}

class _DumbbellCalculationPageState extends State<DumbbellCalculationPage> {
  // List to hold pairs of controllers for each row [initial (X), final (Y)]
  final List<List<TextEditingController>> _controllers = [];
  // List to hold pairs of FocusNodes for each row [initial (X), final (Y)]
  final List<List<FocusNode>> _focusNodes = [];
  // List to hold result strings for each row
  List<String> _rowResults = [];

  // Maximum number of input field rows allowed
  final int _maxRows = 6;
  // Specification threshold
  final double _specification = 175.0;
  // Flag to control visibility of the results section (and specification)
  bool _showResultsSection = false;

  @override
  void initState() {
    super.initState();
    // Initialize with one row when the page loads
    _addRow();
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes to free up resources
    for (var controllerPair in _controllers) {
      controllerPair[0].dispose();
      controllerPair[1].dispose();
    }
    for (var focusNodePair in _focusNodes) {
      focusNodePair[0].dispose();
      focusNodePair[1].dispose();
    }
    super.dispose();
  }

  // Function to add a new row of input fields
  void _addRow() {
    if (_controllers.length < _maxRows) {
      setState(() {
        _controllers.add([TextEditingController(), TextEditingController()]);
        _focusNodes.add([FocusNode(), FocusNode()]);
        _rowResults.add(''); // Initialize result for the new row
        _showResultsSection = false; // Hide results when rows change
      });
    }
  }

  // Function to remove a specific row of input fields
  void _removeRow(int index) {
    if (_controllers.length > 1) {
      setState(() {
        // Dispose resources before removing
        _controllers[index][0].dispose();
        _controllers[index][1].dispose();
        _focusNodes[index][0].dispose();
        _focusNodes[index][1].dispose();
        // Remove from lists
        _controllers.removeAt(index);
        _focusNodes.removeAt(index);
        _rowResults.removeAt(index);
        _showResultsSection = false; // Hide results when rows change
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one sample is required.')),
      );
    }
  }

  // Function to clear all input fields and reset to one row
  void _resetFields() {
    setState(() {
      // Remove all rows except the first one
      while (_controllers.length > 1) {
        int lastIndex = _controllers.length - 1;
        _controllers[lastIndex][0].dispose();
        _controllers[lastIndex][1].dispose();
        _focusNodes[lastIndex][0].dispose();
        _focusNodes[lastIndex][1].dispose();
        _controllers.removeLast();
        _focusNodes.removeLast();
        _rowResults.removeLast();
      }
      // Clear the text in the remaining first row
      if (_controllers.isNotEmpty) {
        _controllers[0][0].clear();
        _controllers[0][1].clear();
      }
      // Clear the result for the first row
      if (_rowResults.isNotEmpty) {
        _rowResults[0] = '';
      } else if (_controllers.isNotEmpty) {
        _rowResults = [''];
      }
      // Hide results section on reset
      _showResultsSection = false;
    });
    if (_focusNodes.isNotEmpty && _focusNodes[0].isNotEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[0][0]);
    }
  }

  // Function to perform calculation for all rows
  void _calculate() {
    if (_rowResults.length != _controllers.length) {
      _rowResults = List<String>.filled(_controllers.length, '');
    }

    setState(() {
      bool allInputsValid = true;
      bool hasAnyData = false; // To check if any data was entered at all

      for (int i = 0; i < _controllers.length; i++) {
        final initialText = _controllers[i][0].text;
        final finalText = _controllers[i][1].text;

        if (initialText.isNotEmpty || finalText.isNotEmpty) {
            hasAnyData = true; // Mark that some data was entered
        }

        if (initialText.isEmpty && finalText.isEmpty) {
          _rowResults[i] = 'Input is empty';
          continue;
        }
        if (initialText.isEmpty || finalText.isEmpty) {
          _rowResults[i] = 'Error: Both values required';
          allInputsValid = false;
          continue;
        }

        final double? initialValue = double.tryParse(initialText);
        final double? finalValue = double.tryParse(finalText);

        if (initialValue == null || finalValue == null) {
          _rowResults[i] = 'Error: Invalid number';
          allInputsValid = false;
          continue;
        }
        // Negative values are allowed.

        double currentDistanceBetweenMarks = (initialValue - finalValue).abs();
        double originalGaugeLength = 2.0; // cm

        double result = ((currentDistanceBetweenMarks - originalGaugeLength) / originalGaugeLength) * 100;

        if (result > _specification) {
          _rowResults[i] = '${result.toStringAsFixed(2)}% (Fail)';
        } else {
          _rowResults[i] = '${result.toStringAsFixed(2)}% (Pass)';
        }
      }

      if (!hasAnyData) { // If no data was entered in any row
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter data for at least one sample.')),
          );
        _showResultsSection = false;
      } else if (_controllers.any((c) => c[0].text.isNotEmpty || c[1].text.isNotEmpty) || !allInputsValid) {
        _showResultsSection = true;
      } else {
        _showResultsSection = false; // This case might need review if all valid but no results to show explicitly
      }
    });
    FocusScope.of(context).unfocus();
  }

  // Function to navigate to the next page
  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DumbbellCalculation2Page()),
    );
  }

  // Helper to build individual text fields within a card
  Widget _buildMarkingTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText, // Changed from hintText to labelText
    double? fieldWidth,
  }) {
    return SizedBox(
      width: fieldWidth ?? MediaQuery.of(context).size.width * 0.35,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15.0),
        decoration: InputDecoration(
          labelText: labelText, // Using labelText for floating label effect
          labelStyle: const TextStyle(fontSize: 15.0), // Style for the label
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), // Adjusted padding for label
        ),
        onChanged: (_) => setState(() => _showResultsSection = false),
      ),
    );
  }

  // New helper to build sample input cards
  Widget _buildDumbbellSampleCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 1.5,
      color: const Color(0xFFFFF0F0), // Light reddish/pinkish
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sample ${index + 1}', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                if (_controllers.length > 1)
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade600),
                    tooltip: 'Remove Sample ${index + 1}',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _removeRow(index),
                  ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMarkingTextField(
                  controller: _controllers[index][0],
                  focusNode: _focusNodes[index][0],
                  labelText: 'Marking 1 (cm)', // Changed from hintText
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('to', style: TextStyle(fontSize: 15)),
                ),
                _buildMarkingTextField(
                  controller: _controllers[index][1],
                  focusNode: _focusNodes[index][1],
                  labelText: 'Marking 2 (cm)', // Changed from hintText
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    final resultValueStyle = const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500);
    final specStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: theme.colorScheme.secondary);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dumbbell: Elongation Under Load'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controllers.length,
                itemBuilder: (context, index) {
                  return _buildDumbbellSampleCard(index);
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(120, 45),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _resetFields,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      minimumSize: const Size(120, 45),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_controllers.length < _maxRows)
                    ElevatedButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Sample'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade300,
                        minimumSize: const Size(120, 45),
                      ),
                    )
                  else
                    const SizedBox(width: 120, height: 45),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _showResultsSection ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _showResultsSection
                    ? Card(
                        elevation: 2.0,
                        color: Colors.blue[50],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Results:', style: boldStyle.copyWith(fontSize: 18)),
                              const SizedBox(height: 5),
                              Text(
                                'Specification: Max ${_specification.toStringAsFixed(0)}%',
                                style: specStyle,
                              ),
                              const Divider(height: 20, thickness: 1),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _rowResults.length,
                                itemBuilder: (context, index) {
                                  final String currentResult = _rowResults[index];
                                  if (currentResult.isEmpty && _controllers[index][0].text.isEmpty && _controllers[index][1].text.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  if (currentResult.isEmpty) {
                                     return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text(
                                        'Sample ${index + 1}: Processing...',
                                        style: resultValueStyle.copyWith(color: Colors.grey.shade600),
                                        ),
                                    );
                                  }

                                  Color resultColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
                                  FontWeight fontWeight = FontWeight.normal;

                                  if (currentResult.startsWith('Error:')) {
                                    resultColor = theme.colorScheme.error;
                                    fontWeight = FontWeight.bold;
                                  } else if (currentResult == 'Input is empty') {
                                    resultColor = Colors.grey.shade600;
                                  } else if (currentResult.contains('(Fail)')) {
                                    resultColor = theme.colorScheme.error;
                                    fontWeight = FontWeight.bold;
                                  } else if (currentResult.contains('(Pass)')) {
                                    resultColor = Colors.green.shade700;
                                    fontWeight = FontWeight.bold;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      'Sample ${index + 1}: $currentResult',
                                      style: resultValueStyle.copyWith(color: resultColor, fontWeight: fontWeight),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _navigateToNextPage,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Page'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 45),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
