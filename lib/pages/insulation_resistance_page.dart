import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import carousel slider

// Import the specific pages needed for navigation
// Ensure these paths are correct
import 'ambient_temperature_page.dart';
import 'constant_ki_page.dart';

class InsulationResistancePage extends StatefulWidget {
  const InsulationResistancePage({super.key});

  @override
  State<InsulationResistancePage> createState() => _InsulationResistancePageState();
}

class _InsulationResistancePageState extends State<InsulationResistancePage> {
  // State for current index
  int _currentCarouselIndex = 0;

  // --- REMOVED: Expansion State Map ---
  // final Map<String, bool> _isExpanded = {};

  // Define the items list data
  final List<Map<String, dynamic>> _carouselItemsData = [
    {
      'title': 'Ambient Temperature',
      'imagePath': 'images/hot_set_tubular.jpg',
      'pageBuilder': () => const AmbientTemperaturePage(),
    },
    {
      'title': 'Constant Ki',
      'imagePath': 'images/hot_set_dumbbell.jpg',
      'pageBuilder': () => const ConstantKiPage(),
    },
  ];

  // Placeholder for logo
  final String _companyLogoPath = 'images/keystone.png'; // Adjust path if needed

  // --- Use Single Fixed Carousel Height (like SelectionPage) ---
  static const double carouselHeight = 480.0;

  // Fixed values for styling consistency
  static const double appBarFontSize = 22.0;
  static const double logoVerticalPadding = 20.0;
  static const double logoHeight = 80.0;
  static const double indicatorPaddingTop = 15.0;
  static const double indicatorPaddingBottom = 10.0;
  static const double copyrightPaddingBottom = 20.0;
  static const double copyrightPaddingTop = 5.0;
  static const double copyrightFontSize = 12.0;

  // --- REMOVED: initState for expansion ---

  @override
  Widget build(BuildContext context) {
    // Determine indicator color based on theme
    final Color indicatorColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    // --- REMOVED: Dynamic Height Calculation ---

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // --- Corrected AppBar Title for IR ---
        title: const Text(
          'Insulation Resistance',
          style: TextStyle(
            fontSize: appBarFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Add leading back button automatically
      ),
      // Use Column > Expanded > SingleChildScrollView structure (like SelectionPage)
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Company Logo Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: logoVerticalPadding),
                    child: Image.asset(
                      _companyLogoPath,
                      height: logoHeight,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.business, size: logoHeight, color: Colors.grey);
                      },
                    ),
                  ),

                  // LayoutBuilder for dynamic width
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double availableWidth = constraints.maxWidth;
                      // Match SelectionPage's width logic (adjust breakpoint if needed)
                      double containerWidth = availableWidth < 700 ? availableWidth : availableWidth * 0.4;

                      // --- Use Container with fixed height ---
                      return SizedBox(
                        height: carouselHeight, // Use fixed height
                        width: containerWidth,     // Use dynamic width
                        child: Center(
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: carouselHeight, // Use fixed height
                              enableInfiniteScroll: false,
                              viewportFraction: containerWidth < 350 ? 0.9 : 0.8, // Keep adjustment
                              initialPage: 0,
                              enlargeCenterPage: true, // Keep enlarge effect
                              enlargeFactor: 0.2,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentCarouselIndex = index;
                                });
                              },
                            ),
                            // --- Map items - Call simplified _buildCarouselItem ---
                            items: _carouselItemsData.map((itemData) {
                               return _buildCarouselItem( // Simplified call
                                 context,
                                 itemData['title'],
                                 itemData['imagePath'],
                                 () { // Navigation callback
                                   Navigator.push( context, MaterialPageRoute(builder: (context) => itemData['pageBuilder']()));
                                 }
                               );
                            }).toList(),
                          ),
                        ),
                      ); // End Container
                    }, // End LayoutBuilder builder
                  ), // End LayoutBuilder

                  // Indicator Dots Section
                  Padding(
                    padding: const EdgeInsets.only(top: indicatorPaddingTop, bottom: indicatorPaddingBottom),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _carouselItemsData.asMap().entries.map((entry) {
                        int index = entry.key;
                        bool isActive = _currentCarouselIndex == index;
                        const double dotSize = 8.0;
                        const double dotMargin = 4.0;
                        return Container(
                          width: dotSize,
                          height: dotSize,
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: dotMargin),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: indicatorColor.withAlpha(isActive ? 230 : 102),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // End of Carousel Indicator

                ], // Children of Column inside SingleChildScrollView
              ),
            ),
          ), // End Expanded

          // Copyright Notice
          Padding(
            padding: const EdgeInsets.only(bottom: copyrightPaddingBottom, top: copyrightPaddingTop),
            child: Text(
              '© Keystone Cable 2025',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: copyrightFontSize,
              ),
            ),
          ),
          // End Copyright Notice
        ], // Children of main Column
      ), // End main Column
    ); // End Scaffold
  }

  // --- Simplified _buildCarouselItem (No expansion) ---
  Widget _buildCarouselItem(
      BuildContext context,
      String title,
      String imagePath,
      VoidCallback onPressed // Only navigation callback needed
   ) {

    final image = Image.asset( // Use final for image widget
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
         return Container(
           color: Colors.grey[300],
           child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[600])),
         );
       },
    );

    // Define fixed styles (similar to SelectionPage item)
    const double itemHorizontalMargin = 10.0;
    const double itemVerticalMargin = 10.0;
    const double itemBorderRadius = 15.0;
    // --- Use Increased Image Height (like SelectionPage) ---
    const double imageHeight = 350.0;
    const double buttonPaddingTop = 15.0;
    const double buttonPaddingH = 55.0; // User's specific padding
    const double buttonPaddingB = 15.0;
    const double buttonMinHeight = 45.0;
    const double buttonFontSize = 16.0;
    const double buttonBorderRadius = 8.0;
    const double maxButtonWidth = 500.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: itemHorizontalMargin, vertical: itemVerticalMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(itemBorderRadius),
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
         borderRadius: BorderRadius.circular(itemBorderRadius),
         child: Column(
          // --- Use MainAxisSize.min ---
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // --- Image Section with fixed height ---
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: image,
            ),

            // Button Section
            Center(
              child: SizedBox(
                width: maxButtonWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: buttonPaddingTop, left: buttonPaddingH, right: buttonPaddingH, bottom: buttonPaddingB),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, buttonMinHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonBorderRadius),
                      ),
                    ),
                    onPressed: onPressed,
                    child: Text(
                        title,
                        style: const TextStyle(fontSize: buttonFontSize),
                        textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
             // --- REMOVED Expansion Toggle and Content ---
          ],
        ),
      ),
    );
  }
}
