import 'package:calculator/pages/insulation_resistance_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Import your page files - ensure these paths are correct
import 'shrinkage_page.dart';
import 'conductor_resistance_page.dart';
import 'hot_set_page.dart';
import 'calculator_page.dart'; // General calculator
import 'mutual_capacitance_page.dart'; // For drawer
import 'capacitance_unbalance_page.dart'; // For drawer
import 'ageing_page.dart'; // For drawer


// Import the PDF Viewer Page
import 'pdf_viewer_page.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  // Map containing the title and the corresponding page widget for navigation
  final Map<String, Widget> _pages = {
    'Shrinkage': const ShrinkagePage(),
    'Conductor Resistance': const ConductorResistancePage(),
    'Insulation Resistance': const InsulationResistancePage(),
    'Hot Set': const HotSetPage(),
    'Mutual Capacitance': const MutualCapacitancePage(), // Added from user's import
    'Capacitance Unbalance to Earth (Cu)': const CapacitanceUnbalancePage(), // Added from user's import
    'Tensile Strength & Elongation (Ageing)': const AgeingPage(), // Added from user's import
  };

  // Map to store PDF paths associated with each page
  final Map<String, String> _pagePdfPaths = {
    'Shrinkage': 'images/pdfs/shrinkage.pdf',
    'Conductor Resistance': 'images/pdfs/conductor_resistance.pdf',
    'Insulation Resistance': 'images/pdfs/insulation_resistance.pdf',
    'Insulation Resistance (Drawer)': 'images/pdfs/insulation_resistance (drawer).pdf',
    'Tests on Insulation (Drawer)': 'images/pdfs/tests_on_insulation (drawer).pdf',
    'Tests on Sheath (Drawer)': 'images/pdfs/tests_on_sheath (drawer).pdf',
    'Hot Set': 'images/pdfs/hot_set_dumbbell.pdf', 
    'Mutual Capacitance': 'images/pdfs/mutual_capacitance.pdf', 
    'Capacitance Unbalance to Earth (Cu)': 'images/pdfs/capacitance_unbalance.pdf', 
    'Tensile Strength & Elongation (Ageing)': 'images/pdfs/ageing.pdf',
  };

  // Map to track the expansion state of each item
  final Map<String, bool> _isExpanded = {};

  // Placeholder for your company logo path
  final String _companyLogoPath = 'images/keystone.png';

  // State for Carousel Indicator
  int _currentCarouselIndex = 0;

  // Define heights for collapsed and expanded states
  final double _carouselHeightCollapsed = 440.0;
  final double _carouselHeightExpanded = 485.0;

  @override
  void initState() {
    super.initState();
    // Initialize expansion state for all items to false
    for (var key in _pages.keys) {
      _isExpanded[key] = false;
    }
  }

  void _openPdf(String pageTitle) {
  final String? pdfPath = _pagePdfPaths[pageTitle];
  if (pdfPath != null && pdfPath.isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(pdfAssetPath: pdfPath),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF specification not available for $pageTitle.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final List<String> pageKeys = _pages.keys.toList();
    final Color indicatorColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    final bool isCurrentItemExpanded = _isExpanded.isNotEmpty && pageKeys.length > _currentCarouselIndex
        ? (_isExpanded[pageKeys[_currentCarouselIndex]] ?? false)
        : false;
    final double targetCarouselHeight = isCurrentItemExpanded ? _carouselHeightExpanded : _carouselHeightCollapsed;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
           builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Open Tools Menu',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
        ),
        centerTitle: true,
        title: const Text(
          'Select a Test',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Tools & Resources',
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.titleLarge?.color ?? Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // --- MODIFIED: Calculator ListTile to ExpansionTile ---
            ExpansionTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Tables & Formulas'),
              children: <Widget>[
                // Sub-menu for "Math" calculators
                ExpansionTile(
                  // Indent the sub-expansion tile
                  tilePadding: const EdgeInsets.only(left: 32.0, right: 16.0),
                  leading: const Icon(Icons.flash_on), // Example icon for Math
                  title: const Text('Electrical Tests'),
                  children: <Widget>[
                    ListTile(
                      // Indent further for specific calculator
                      contentPadding: const EdgeInsets.only(left: 48.0, right: 16.0),
                      leading: const Icon(Icons.cable),
                      title: const Text(
                        'Conductor Resistance',
                        style: TextStyle(
                          fontSize: 17.0, // Adjust the font size as needed
                          fontWeight: FontWeight.normal, // Optional: you can make it bold or change other text styles
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        _openPdf('Conductor Resistance (Drawer)');
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 48.0, right: 16.0),
                      leading: const Icon(Icons.shield),
                      title: const Text(
                        'Insulation Resistance',
                        style: TextStyle(
                          fontSize: 17.0, // Adjust the font size as needed
                          fontWeight: FontWeight.normal, // Optional: you can make it bold or change other text styles
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _openPdf('Insulation Resistance (Drawer)');
                      },
                    ),
                  ],
                ),

                ExpansionTile(
                  // Indent the sub-expansion tile
                  tilePadding: const EdgeInsets.only(left: 32.0, right: 16.0),
                  leading: const Icon(Icons.flash_off), // Example icon for Math
                  title: const Text('Non-Electrical Tests'),
                  children: <Widget>[
                    ListTile(
                      // Indent further for specific calculator
                      contentPadding: const EdgeInsets.only(left: 48.0, right: 16.0),
                      leading: const Icon(Icons.search),
                      title: const Text(
                        'Tests on Insulation',
                        style: TextStyle(
                          fontSize: 17.0, // Adjust the font size as needed
                          fontWeight: FontWeight.normal, // Optional: you can make it bold or change other text styles
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        _openPdf('Tests on Insulation (Drawer)');
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 48.0, right: 16.0),
                      leading: const Icon(Icons.search),
                      title: const Text(
                        'Tests on Sheath',
                        style: TextStyle(
                          fontSize: 17.0, // Adjust the font size as needed
                          fontWeight: FontWeight.normal, // Optional: you can make it bold or change other text styles
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _openPdf('Tests on Sheath (Drawer)');
                      },
                    ),
                  ],
                ),
              ],
            ),
            // --- End of Modification ---
            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: const Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalculatorPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                 Navigator.pop(context);
                 showAboutDialog(context: context, applicationName: 'Keystone App', applicationVersion: '25.05.09'); // User updated version
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Image.asset(
                      _companyLogoPath,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.business, size: 80, color: Colors.grey);
                      },
                    ),
                  ),
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double availableWidth = constraints.maxWidth;
                      double containerWidth = availableWidth < 700 ? availableWidth : availableWidth * 0.4;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 0),
                        curve: Curves.easeInOut,
                        height: targetCarouselHeight,
                        width: containerWidth,
                        child: Center(
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: targetCarouselHeight,
                              enableInfiniteScroll: false,
                              viewportFraction: containerWidth < 350 ? 0.9 : 0.8,
                              initialPage: 0,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.2,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  if (_isExpanded.containsValue(true)) {
                                    _isExpanded.updateAll((key, value) => false);
                                  }
                                  _currentCarouselIndex = index;
                                });
                              },
                            ),
                            items: pageKeys.map((pageName) {
                              final pageWidget = _pages[pageName]!;
                              final bool isExpanded = _isExpanded[pageName] ?? false;
                              final String? pdfPath = _pagePdfPaths[pageName];
                              return _buildCarouselItem(
                                context,
                                pageName,
                                pageWidget,
                                isExpanded,
                                pdfPath,
                                () {
                                  setState(() {
                                    final newState = !isExpanded;
                                    _isExpanded.updateAll((key, value) => false);
                                    _isExpanded[pageName] = newState;
                                  });
                                }
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pageKeys.asMap().entries.map((entry) {
                        int index = entry.key;
                        bool isActive = _currentCarouselIndex == index;
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: indicatorColor.withAlpha(isActive ? 230 : 102),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, top: 5.0),
            child: Text(
              '© Keystone Cable 2025',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(
    BuildContext context,
    String title,
    Widget pageWidget,
    bool isCurrentlyExpanded,
    String? pdfPath,
    VoidCallback onExpandToggle,
  ) {
     final imagePath = _getImagePathForPage(title);
     final image = Image.asset(
       imagePath,
       fit: BoxFit.cover,
       errorBuilder: (context, error, stackTrace) {
         return Container(
           color: Colors.grey[300],
           child: Center(
             child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[600]),
           ),
         );
       },
     );

     final bool pdfAvailable = pdfPath != null && pdfPath.isNotEmpty;

     return Container(
       margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(15.0),
         color: Colors.white,
         boxShadow: [
           BoxShadow(
             color: Colors.grey.withAlpha(77),
             spreadRadius: 1,
             blurRadius: 5,
             offset: const Offset(0, 3),
           ),
         ],
       ),
       child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Column(
             mainAxisSize: MainAxisSize.min,
             mainAxisAlignment: MainAxisAlignment.start,
             children: <Widget>[
               SizedBox(
                 height: 275,
                 width: double.infinity,
                 child: image,
               ),
               Padding(
                 padding: const EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     minimumSize: const Size(double.infinity, 45),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8.0),
                     ),
                   ),
                   onPressed: () {
                     if (isCurrentlyExpanded) {
                        onExpandToggle();
                        Future.delayed(const Duration(milliseconds: 0), () {
                          if (context.mounted) {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => pageWidget),
                             );
                          }
                        });
                     } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => pageWidget),
                        );
                     }
                   },
                   child: Text(title, style: const TextStyle(fontSize: 16)),
                 ),
               ),
               if (pdfAvailable)
                 TextButton.icon(
                   icon: Icon(
                     isCurrentlyExpanded ? Icons.expand_less : Icons.expand_more,
                     size: 20.0,
                   ),
                   label: const Text("More Info"),
                   style: TextButton.styleFrom(
                     foregroundColor: Colors.grey[700],
                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                     textStyle: const TextStyle(fontSize: 14.0),
                   ),
                   onPressed: onExpandToggle,
                 )
               else
                 const SizedBox(height: 48.0), // Placeholder for consistent height
               Visibility(
                 visible: isCurrentlyExpanded && pdfAvailable,
                 maintainAnimation: true,
                 maintainState: true,
                 child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 0),
                    opacity: isCurrentlyExpanded ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 60.0, right: 60.0, bottom: 15.0, top: 5),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                        label: const Text("View PDF"),
                        style: OutlinedButton.styleFrom(
                           foregroundColor: Colors.deepPurple,
                           maximumSize: const Size(double.infinity, 40),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(8.0),
                           ),
                           side: const BorderSide(color: Colors.deepPurple),
                        ),
                        onPressed: () {
                          if (pdfPath != null && pdfPath.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewerPage(pdfAssetPath: pdfPath),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('PDF specification not available for $title.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                 ),
               ),
             ],
           ),
       ),
     );
  }

  String _getImagePathForPage(String title) {
    switch (title) {
      case 'Shrinkage': return 'images/shrinkage.png';
      case 'Conductor Resistance': return 'images/conductor_resistance.png';
      case 'Insulation Resistance': return 'images/insulation_resistance.png';
      case 'Hot Set': return 'images/hot_set.png';
      case 'Mutual Capacitance': return 'images/mutual_capacitance.png'; // Example
      case 'Capacitance Unbalance to Earth (Cu)': return 'images/capacitance_unbalance.png'; // Example
      case 'Tensile Strength & Elongation (Ageing)': return 'images/ageing.png'; // Example
      default: return 'images/default_image.png';
    }
  }
}
