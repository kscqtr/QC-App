import 'package:flutter/material.dart';

class DumbbellCalculation2Page extends StatefulWidget {
  const DumbbellCalculation2Page({super.key});

  @override
  State<DumbbellCalculation2Page> createState() => _DumbbellCalculation2PageState();
}

class _DumbbellCalculation2PageState extends State<DumbbellCalculation2Page> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  List<String> _rowResults = [];

  final int _maxRows = 6;
  final double _specification = 15.0;
  bool _showResultsSection = false;

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    if (_controllers.length < _maxRows) {
      setState(() {
        _controllers.add(TextEditingController());
        _focusNodes.add(FocusNode());
        _rowResults.add('');
        _showResultsSection = false;
      });
    }
  }

  void _removeRow(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers[index].dispose();
        _focusNodes[index].dispose();
        _controllers.removeAt(index);
        _focusNodes.removeAt(index);
        _rowResults.removeAt(index);
        _showResultsSection = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one sample is required.')),
      );
    }
  }

  void _resetFields() {
    setState(() {
      while (_controllers.length > 1) {
        _controllers.last.dispose();
        _focusNodes.last.dispose();
        _controllers.removeLast();
        _focusNodes.removeLast();
        _rowResults.removeLast();
      }
      if (_controllers.isNotEmpty) {
        _controllers[0].clear();
      }
      if (_rowResults.isNotEmpty) {
        _rowResults[0] = '';
      } else if (_controllers.isNotEmpty) {
        _rowResults = [''];
      }
      _showResultsSection = false;
    });
    if (_focusNodes.isNotEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }
  }

  void _calculate() {
    if (_rowResults.length != _controllers.length) {
      _rowResults = List<String>.filled(_controllers.length, '');
    }

    setState(() {
      bool allInputsValid = true;
      bool hasAnyData = false;

      for (int i = 0; i < _controllers.length; i++) {
        final yText = _controllers[i].text;

        if (yText.isNotEmpty) {
          hasAnyData = true;
        }

        if (yText.isEmpty) {
          _rowResults[i] = 'Input is empty';
          continue;
        }

        final double? yValue = double.tryParse(yText);

        if (yValue == null) {
          _rowResults[i] = 'Error: Invalid number';
          allInputsValid = false;
          continue;
        }

        double result = ((yValue - 2) / 2) * 100;

        if (result > _specification) {
          _rowResults[i] = '${result.toStringAsFixed(2)}% (Fail)';
        } else {
          _rowResults[i] = '${result.toStringAsFixed(2)}% (Pass)';
        }
      }

      if (!hasAnyData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter data for at least one sample.')),
        );
        _showResultsSection = false;
      } else {
        _showResultsSection = true;
      }
    });
    FocusScope.of(context).unfocus();
  }

  void _navigateBack() {
    int popCount = 0;
    Navigator.of(context).popUntil((route) {
      return popCount++ == 2;
    });
  }

  void _showFormulaDialog(BuildContext context, String title, String formula) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(formula),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildSampleInputCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 1.5,
      color: const Color(0xFFFFF0F0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Sample ${index + 1}:', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15.0),
                decoration: InputDecoration(
                  labelText: 'Y (cm)',
                  labelStyle: const TextStyle(fontSize: 15.0),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                ),
                onChanged: (_) => setState(() => _showResultsSection = false),
              ),
            ),
            if (_controllers.length > 1)
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade600),
                tooltip: 'Remove Sample ${index + 1}',
                onPressed: () => _removeRow(index),
              )
            else
              const SizedBox(width: 48), // Placeholder for alignment
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required BuildContext context,
    required int index,
    required String result,
  }) {
    final ThemeData theme = Theme.of(context);
    final resultValueStyle = const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500);

    Color resultColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    FontWeight fontWeight = FontWeight.normal;

    if (result.startsWith('Error:')) {
      resultColor = theme.colorScheme.error;
      fontWeight = FontWeight.bold;
    } else if (result == 'Input is empty') {
      resultColor = Colors.grey.shade600;
    } else if (result.contains('(Fail)')) {
      resultColor = theme.colorScheme.error;
      fontWeight = FontWeight.bold;
    } else if (result.contains('(Pass)')) {
      resultColor = Colors.green.shade700;
      fontWeight = FontWeight.bold;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Permanent Elongation = [ (Y - 2cm) / 2cm ] * 100',
                  child: IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    onPressed: () => _showFormulaDialog(context, 'Permanent Elongation Formula', 'Permanent Elongation = [ (Y - 2cm) / 2cm ] * 100'),
                    padding: const EdgeInsets.only(right: 6),
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ),
                Flexible(child: Text('Sample ${index + 1}:', style: resultValueStyle)),
              ],
            ),
          ),
          Text(
            result,
            style: resultValueStyle.copyWith(color: resultColor, fontWeight: fontWeight),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    final specStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo.shade800);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dumbbell: Permanent Elongation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 1.5,
                    color: Colors.indigo[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Text(
                          'Specification: Max ${_specification.toStringAsFixed(0)}%',
                          style: specStyle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controllers.length,
                    itemBuilder: (context, index) {
                      return _buildSampleInputCard(index);
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
                                  const Divider(height: 20, thickness: 1),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _rowResults.length,
                                    itemBuilder: (context, index) {
                                      final String currentResult = _rowResults[index];
                                      if (currentResult.isEmpty && _controllers[index].text.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return _buildResultRow(
                                        context: context,
                                        index: index,
                                        result: currentResult,
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
                      onPressed: _navigateBack,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Return'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
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
        ),
      ),
    );
  }
}
