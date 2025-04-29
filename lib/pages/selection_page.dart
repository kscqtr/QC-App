import 'package:calculator/pages/insulation_resistance_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import the carousel slider

// Import your page files - ensure these paths are correct
import 'shrinkage_page.dart';
import 'conductor_resistance_page.dart';
import 'hot_set_page.dart';
import 'calculator_page.dart';

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
  };

  // Map to store PDF paths associated with each page
  final Map<String, String> _pagePdfPaths = {
    'Shrinkage': 'images/pdfs/shrinkage.pdf', // User updated path
    'Conductor Resistance': 'images/pdfs/conductor_resistance.pdf', // User updated path
    'Insulation Resistance': 'images/pdfs/insulation_resistance.pdf', // User updated path
    'Hot Set': 'images/pdfs/hot_set_dumbbell.pdf', // User updated path
  };

  // Map to track the expansion state of each item
  final Map<String, bool> _isExpanded = {};

  // Placeholder for your company logo path
  final String _companyLogoPath = 'images/keystone.png';

  // State for Carousel Indicator
  int _currentCarouselIndex = 0;

  // Define heights for collapsed and expanded states
  final double _carouselHeightCollapsed = 440.0; // User updated value
  final double _carouselHeightExpanded = 485.0; // User updated value

  @override
  void initState() {
    super.initState();
    // Initialize expansion state for all items to false
    for (var key in _pages.keys) {
      _isExpanded[key] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the list of page keys for easier access by index
    final List<String> pageKeys = _pages.keys.toList();
    // Determine indicator color based on theme
    final Color indicatorColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    // Calculate target height based on current item's expansion state
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
      drawer: Drawer( // Drawer content remains the same
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
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Formula Sheet'),
              onTap: () {
                Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Navigate to Formula Sheet (Not Implemented)'))
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                 Navigator.pop(context);
                 showAboutDialog(context: context, applicationName: 'Keystone App', applicationVersion: '25.04.22');
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
                  // Company Logo Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Image.asset(
                      _companyLogoPath,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        // Log error: Error loading company logo: $error
                        return const Icon(Icons.business, size: 80, color: Colors.grey);
                      },
                    ),
                  ),


                  // --- ADDED LayoutBuilder ---
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      // Calculate width based on constraints provided by LayoutBuilder
                      double availableWidth = constraints.maxWidth;
                      // Apply conditional logic based on availableWidth
                      double containerWidth = availableWidth < 700 ? availableWidth : availableWidth * 0.4;

                      // Return the AnimatedContainer using the calculated width
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 0),
                        curve: Curves.easeInOut,
                        height: targetCarouselHeight,
                        width: containerWidth, // Use width from LayoutBuilder
                        child: Center(
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: targetCarouselHeight,
                              enableInfiniteScroll: false,
                              // Adjust viewportFraction based on container width? Optional.
                              viewportFraction: containerWidth < 350 ? 0.9 : 0.8,
                              initialPage: 0,
                              enlargeCenterPage: true, // Keep user's value
                              enlargeFactor: 0.2,     // Keep user's value
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
                                () { // Callback to toggle expansion
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
                  ), // --- End of LayoutBuilder ---

                  // Carousel Indicator Dots Section
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
                  // End of Carousel Indicator

                ],
              ),
            ),
          ),

          // Copyright Notice
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
          // End of Copyright Notice
        ],
      ),
    );
  }

  // Helper method to build each carousel item
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
         // Log error: Error loading image for $title: $error
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
               // Image Section
               SizedBox(
                 height: 275,
                 width: double.infinity,
                 child: image,
               ),
               // Button to Navigate to the Test Page
               Padding(
                 padding: const EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0), // User updated padding
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

               // Expansion Section Toggle
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
                 const SizedBox(height: 48.0),

               // Conditionally Visible PDF Button
               Visibility(
                 visible: isCurrentlyExpanded && pdfAvailable,
                 maintainAnimation: true,
                 maintainState: true,
                 child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 0),
                    opacity: isCurrentlyExpanded ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 60.0, right: 60.0, bottom: 15.0, top: 5), // User updated padding
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                        label: const Text("View PDF"), // User updated text
                        style: OutlinedButton.styleFrom(
                           foregroundColor: Colors.deepPurple,
                           maximumSize: const Size(double.infinity, 40), // User updated to maximumSize
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
               // End of PDF Button Section

             ], // children of Column
           ), // Column
       ), // ClipRRect
     ); // Container
  }


  // Helper method to get image path based on title
  String _getImagePathForPage(String title) {
    switch (title) {
      case 'Shrinkage':
        return 'images/shrinkage.png';
      case 'Conductor Resistance':
        return 'images/conductor_resistance.png';
      case 'Insulation Resistance':
        return 'images/insulation_resistance.png';
      case 'Hot Set':
        return 'images/hot_set.png';
      default:
        return 'images/default_image.png';
    }
  }
}
