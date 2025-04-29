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
  // Flag to control visibility of the specification text
  bool _showSpecification = false;


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
        _rowResults.add('');
        _showSpecification = false; // Hide spec when rows change
      });
    }
  }

  // Function to remove the last row of input fields
  void _removeRow() {
    if (_controllers.length > 1) {
      // Dispose resources before removing
      _controllers.last[0].dispose();
      _controllers.last[1].dispose();
      _focusNodes.last[0].dispose();
      _focusNodes.last[1].dispose();
      // Remove from lists
      _controllers.removeLast();
      _focusNodes.removeLast();
      _rowResults.removeLast();
       _showSpecification = false; // Hide spec when rows change
    }
  }

  // Function to clear all input fields and reset to one row
  void _resetFields() {
    setState(() {
      // Remove all rows except the first one
      while (_controllers.length > 1) {
         _controllers.last[0].dispose();
         _controllers.last[1].dispose();
         _focusNodes.last[0].dispose();
         _focusNodes.last[1].dispose();
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
       // Hide specification text on reset
       _showSpecification = false;
    });
     // Move focus to the first field after reset
     if (_focusNodes.isNotEmpty && _focusNodes[0].isNotEmpty) {
       FocusScope.of(context).requestFocus(_focusNodes[0][0]);
     }
  }

  // Function to perform calculation for all rows
  void _calculate() {
     if(_rowResults.length != _controllers.length) {
        _rowResults = List<String>.filled(_controllers.length, '');
     }

    setState(() {
       _showSpecification = true; // Show specification text after calculation
       for (int i = 0; i < _controllers.length; i++) {
        final initialText = _controllers[i][0].text; // X value text
        final finalText = _controllers[i][1].text;   // Y value text

        if (initialText.isEmpty && finalText.isEmpty) {
          _rowResults[i] = 'Input is empty';
          continue;
        }
         if (initialText.isEmpty || finalText.isEmpty) {
          _rowResults[i] = 'Error: Both values required';
          continue;
        }

        final double? initialValue = double.tryParse(initialText); // Parsed X
        final double? finalValue = double.tryParse(finalText);   // Parsed Y

        if (initialValue == null || finalValue == null) {
          _rowResults[i] = 'Error: Invalid number';
          continue;
        }


        // Perform the calculation: ((X - Y) - 2) / 2 * 100
        double result = ((initialValue - finalValue).abs() - 2) / 2 * 100;

        // Determine Pass/Fail based on specification
        if (result > _specification) {
           _rowResults[i] = 'Result: ${result.toStringAsFixed(2)}% (Fail)';
        } else {
           _rowResults[i] = 'Result: ${result.toStringAsFixed(2)}% (Pass)';
        }
      }
    });
    // Hide keyboard after calculation
    FocusScope.of(context).unfocus();
  }

  // Function to navigate to the next page
  void _navigateToNextPage() {
     Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DumbbellCalculation2Page()),
      );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Updated title to be more specific
        title: const Text('Dumbbell: Elongation Under Load'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display Specification conditionally
             Visibility(
               visible: _showSpecification,
               child: Padding(
                 padding: const EdgeInsets.only(bottom: 10.0),
                 child: Text(
                   'Specification: ${_specification.toStringAsFixed(0)}%', // Show spec value
                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                 ),
               ),
             ),

            // Scrollable list for input rows and their results
            Expanded(
              child: ListView.builder(
                itemCount: _controllers.length, // Number of rows
                itemBuilder: (context, index) {
                  final bool hasResult = index < _rowResults.length;
                  final String currentResult = hasResult ? _rowResults[index] : '';

                  // Determine result color based on content
                  Color resultColor = Colors.blueGrey[700]!; // Default color
                  if (currentResult.startsWith('Error:')) {
                     resultColor = Colors.redAccent;
                  } else if (currentResult == 'Input is empty') {
                     resultColor = Colors.grey;
                  } else if (currentResult.contains('(Fail)')) {
                     resultColor = Colors.redAccent;
                  } else if (currentResult.contains('(Pass)')) {
                     resultColor = Colors.green[700]!; // Darker green for pass
                  }


                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row( // Input Row
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, 
                          children: [
                            Text('Sample ${index + 1}: '),
                            SizedBox(
                              width: 90,
                              child: TextField(
                                controller: _controllers[index][0],
                                focusNode: _focusNodes[index][0],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 15.0),
                                decoration: InputDecoration(
                                  hintText: 'Marking 1',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('to'),
                            ),
                             SizedBox(
                              width: 90,
                              child: TextField(
                                controller: _controllers[index][1],
                                focusNode: _focusNodes[index][1],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 15.0),
                                decoration: InputDecoration(
                                  hintText: 'Marking 2',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                   contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text('cm'),
                            ),
                          ],
                        ),
                        // Display Result/Error/Empty message for this row with dynamic color
                        if (hasResult && currentResult.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 70.0),
                            child: Text(
                              currentResult,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: resultColor, // Use dynamic color
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- Control Buttons ---

            // Row for Add and Remove buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (_controllers.length > 1)
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _removeRow()),
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                         minimumSize: const Size(120, 40),
                      ),
                    )
                  else
                    const SizedBox(width: 120, height: 40),

                  if (_controllers.length < _maxRows)
                    ElevatedButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        minimumSize: const Size(120, 40),
                      ),
                    )
                  else
                    const SizedBox(width: 120, height: 40),
                ],
              ),
            ),

            // Row for Calculate and Reset buttons
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _resetFields,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.grey[500],
                       minimumSize: const Size(120, 40),
                     ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Theme.of(context).primaryColor,
                       foregroundColor: Theme.of(context).colorScheme.onPrimary,
                       minimumSize: const Size(120, 40),
                     ),
                  ),
                ],
              ),
            ),

             // Next Button
             Padding(
               padding: const EdgeInsets.only(top: 15.0), // Add space above the next button
               child: Center( // Center the next button
                 child: ElevatedButton.icon(
                   onPressed: _navigateToNextPage, // Navigate on press
                   icon: const Icon(Icons.arrow_forward),
                   label: const Text('Next Page'),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.blueAccent, // Distinct color for next
                     foregroundColor: Colors.white,
                     minimumSize: const Size(150, 45), // Make it slightly larger
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                   ),
                 ),
               ),
             ),

             const SizedBox(height: 5), // Final padding adjusted
          ],
        ),
      ),
    );
  }
}

