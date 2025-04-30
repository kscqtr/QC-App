import 'package:flutter/material.dart';

class TubularWeightPage extends StatefulWidget {
  const TubularWeightPage({super.key});

  @override
  State<TubularWeightPage> createState() => _TubularWeightPageState();
}

class _TubularWeightPageState extends State<TubularWeightPage> {
  // Lists for two inputs per row
  final List<TextEditingController> _diameterControllers = []; // Input D
  final List<TextEditingController> _thicknessControllers = []; // Input T
  final List<FocusNode> _diameterFocusNodes = [];
  final List<FocusNode> _thicknessFocusNodes = [];

  // List to hold result pairs [Area, Weight] strings for each row
  List<List<String>> _rowResults = [];

  // Maximum number of input field rows allowed
  final int _maxRows = 6;
  // Constant for weight calculation
  final double _weightFactor = 20.387;

  // State for image visibility
  bool _showImage = false;
  // Image path (ensure asset exists and is relevant for Tubular)
  final String _imagePath = 'images/dumbbell_conversion.png'; // Changed to tubular diagram path


  @override
  void initState() {
    super.initState();
    // Initialize with one row when the page loads
    _addRow();
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    for (var controller in _diameterControllers) {
      controller.dispose();
    }
    for (var controller in _thicknessControllers) {
      controller.dispose();
    }
    for (var focusNode in _diameterFocusNodes) {
      focusNode.dispose();
    }
     for (var focusNode in _thicknessFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Function to add a new row of input fields
  void _addRow() {
    if (_diameterControllers.length < _maxRows) { // Check diameter list length
      setState(() {
        _diameterControllers.add(TextEditingController());
        _thicknessControllers.add(TextEditingController());
        _diameterFocusNodes.add(FocusNode());
        _thicknessFocusNodes.add(FocusNode());
        // Ensure results list grows correctly
        while (_rowResults.length < _diameterControllers.length) {
             _rowResults.add(['', '']);
        }
      });
    }
  }

   // Function to toggle image visibility
  void _toggleImageVisibility() {
    setState(() {
      _showImage = !_showImage;
    });
  }


  // Function to remove the last row of input fields
  void _removeRow() {
    if (_diameterControllers.length > 1) { // Check diameter list length
      setState(() {
          // Dispose resources
          _diameterControllers.last.dispose();
          _thicknessControllers.last.dispose();
          _diameterFocusNodes.last.dispose();
          _thicknessFocusNodes.last.dispose();
          // Remove from lists
          _diameterControllers.removeLast();
          _thicknessControllers.removeLast();
          _diameterFocusNodes.removeLast();
          _thicknessFocusNodes.removeLast();
          // Remove corresponding result
          if (_rowResults.length > 1) {
             _rowResults.removeLast();
          }
      });
    }
  }

  // Function to clear all input fields and reset to one row
  void _resetFields() {
    setState(() {
      while (_diameterControllers.length > 1) { // Check diameter list length
         _diameterControllers.last.dispose();
         _thicknessControllers.last.dispose();
         _diameterFocusNodes.last.dispose();
         _thicknessFocusNodes.last.dispose();
         _diameterControllers.removeLast();
         _thicknessControllers.removeLast();
         _diameterFocusNodes.removeLast();
         _thicknessFocusNodes.removeLast();
         if (_rowResults.length > 1) {
             _rowResults.removeLast();
         }
      }
      // Clear the text in the remaining first row
      if (_diameterControllers.isNotEmpty) {
        _diameterControllers[0].clear();
        _thicknessControllers[0].clear();
      }
      // Clear the result pair for the first row
       if (_rowResults.isNotEmpty) {
         _rowResults[0] = ['', ''];
       } else if (_diameterControllers.isNotEmpty) { // Check diameter list length
         _rowResults = [['', '']];
       }
       _showImage = false; // Hide image on reset
    });
  }


  // Function to perform calculation for all rows
  void _calculate() {
     // --- REMOVED Width parsing/validation ---

     // Ensure results list matches controller list length
     if(_rowResults.length != _diameterControllers.length) { // Use diameter list length
        _rowResults = List<List<String>>.generate(_diameterControllers.length, (_) => ['', ''], growable: true);
     } else {
        for(int i=0; i < _rowResults.length; i++) {
            if (_rowResults[i].length != 2) _rowResults[i] = ['', ''];
        }
     }

    setState(() {
       for (int i = 0; i < _diameterControllers.length; i++) { // Iterate using diameter list length
         // Get both Diameter (D) and Thickness (T)
         final dText = _diameterControllers[i].text;
         final tText = _thicknessControllers[i].text;

         if (dText.isEmpty || tText.isEmpty) {
           _rowResults[i] = ['Input is empty', ''];
           continue;
         }

         final double? dValue = double.tryParse(dText);
         final double? tValue = double.tryParse(tText);

         if (dValue == null || tValue == null) {
           _rowResults[i] = ['Error: Invalid number', ''];
           continue;
         }

         // Validation D > 0, T > 0, and D > T (Specific to Tubular)
         if (dValue <= 0 || tValue <= 0) {
            _rowResults[i] = ['Error: D & T must be > 0', ''];
            continue;
         }
         if (dValue <= tValue) {
            _rowResults[i] = ['Error: Diameter <= Thickness', ''];
            continue;
         }
         // End Validation
         
         // Apply Tubular Formulas
         double area = (dValue - tValue) * tValue * 3.1416;
         double weight = area * _weightFactor;

         // Store results
         _rowResults[i] = [
           'Area: (${dValue.toStringAsFixed(2)} - ${tValue.toStringAsFixed(2)}) x ${tValue.toStringAsFixed(2)} x 3.1416 = ${area.toStringAsFixed(3)} mm²',
           'Mass: ${area.toStringAsFixed(3)} mm² x 20.387 = ${weight.toStringAsFixed(3)} g'
         ];
     }
    });
    FocusScope.of(context).unfocus();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tubular: Weight Calculation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- REMOVED Width Input Field ---

            // Scrollable list for input rows and their results
            Expanded(
              child: ListView.builder(
                itemCount: _diameterControllers.length, // Use length of diameter list
                itemBuilder: (context, index) {
                  final bool hasResult = index < _rowResults.length && _rowResults[index].length == 2;
                  final String areaResult = hasResult ? _rowResults[index][0] : '';
                  final String weightResult = hasResult ? _rowResults[index][1] : '';
                  final bool isErrorOrEmpty = areaResult.startsWith('Error:') || areaResult == 'Input is empty';

                  Color resultColor1 = Colors.grey;
                   if (areaResult.startsWith('Error:')) {resultColor1 = Colors.redAccent;}
                   else if (areaResult.startsWith('Area:')) {resultColor1 = Colors.blueGrey[700]!;}

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      // Center the content of each list item
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Sample Label
                        Text('Sample ${index + 1}: ', style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),

                        // --- MODIFIED: Diameter Input Row ---
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _diameterControllers[index],
                                focusNode: _diameterFocusNodes[index],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 15.0),
                                decoration: InputDecoration(
                                  hintText: 'Diameter',
                                  hintStyle: const TextStyle(fontSize: 15.0, color: Colors.grey),
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(left: 4.0), child: Text('mm')),
                          ],
                        ),
                        const SizedBox(height: 8), // Spacing between inputs

                        // --- MODIFIED: Thickness Input Row ---
                        Row(
                           mainAxisSize: MainAxisSize.min,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _thicknessControllers[index],
                                focusNode: _thicknessFocusNodes[index],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 15.0),
                                decoration: InputDecoration(
                                  hintText: 'Thickness',
                                  hintStyle: const TextStyle(fontSize: 15.0, color: Colors.grey),
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                                ),
                              ),
                            ),
                             const Padding(padding: EdgeInsets.only(left: 4.0), child: Text('mm')),
                           ],
                        ),
                        // --- End Input Section Modification ---

                        // --- Display Results (Centered with Bold Labels) ---
                        if (hasResult && areaResult.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Center(
                              child: RichText( // Use RichText for bolding
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  // Default style for non-bold parts
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: resultColor1),
                                  children: <TextSpan>[
                                    if (areaResult.startsWith('Area:')) ...[
                                      const TextSpan(text: 'Area: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: areaResult.substring(6)), // Rest of the string
                                    ] else TextSpan(text: areaResult), // Handle errors/empty
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (hasResult && weightResult.isNotEmpty && !isErrorOrEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Center(
                              child: RichText( // Use RichText for bolding
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  // Default style for non-bold parts
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.purple[700]),
                                  children: <TextSpan>[
                                     if (weightResult.startsWith('Mass:')) ...[
                                      const TextSpan(text: 'Mass: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: weightResult.substring(6)), // Rest of the string
                                    ] else TextSpan(text: weightResult), // Handle potential errors?
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // --- End Display Results ---
                      ],
                    ),
                  );
                },
              ),
            ), // End Expanded ListView

            // Conditionally visible image
            Visibility(
              visible: _showImage,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                   decoration: BoxDecoration(
                     border: Border.all(color: Colors.black, width: 1.0),
                   ),
                   child: Image.asset(
                     _imagePath,
                     height: 150,
                     errorBuilder: (context, error, stackTrace) {
                       return const Text('Error loading image.', style: TextStyle(color: Colors.red));
                     },
                   ),
                 ),
              ),
            ),

            // Control Buttons (Add/Remove)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (_diameterControllers.length > 1) // Use diameter list length
                    ElevatedButton.icon(
                      onPressed: _removeRow,
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, minimumSize: const Size(120, 40)),
                    )
                  else
                    const SizedBox(width: 120, height: 40),

                  if (_diameterControllers.length < _maxRows)
                    ElevatedButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen, minimumSize: const Size(120, 40)),
                    )
                  else
                    const SizedBox(width: 120, height: 40),
                ],
              ),
            ),

            // Control Buttons (Reset/Calculate)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _resetFields,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400], minimumSize: const Size(120, 40)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate'),
                     style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Theme.of(context).colorScheme.onPrimary, minimumSize: const Size(120, 40)),
                  ),
                ],
              ),
            ),

            // Image Button
             Padding(
               padding: const EdgeInsets.only(top: 0, bottom: 10),
               child: Center(
                 child: ElevatedButton.icon(
                   onPressed: _toggleImageVisibility,
                   icon: const Icon(Icons.image),
                   label: const Text('Image'),
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, minimumSize: const Size(150, 45), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
