import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(MaterialApp(
    home: FAQPage(),
  ));
}

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<FAQItem> faqItems = [
    FAQItem(
      question: 'What is an accident hotspot, and how does your app define it?',
      answer: '''
An accident hotspot is a location with a statistically higher-than-average number of accidents compared to other areas. Our app identifies these hotspots by analyzing historical accident data, traffic volume, road geometry, and other relevant factors.  We then use predictive modeling to forecast future hotspots based on these trends.
''',
    ),
    FAQItem(
      question:
          'What data sources does your app use to predict accident hotspots?',
      answer:
          'We utilize various data sources, including historical accident records from government agencies, real-time traffic data, weather data, road network information (e.g., speed limits, number of lanes, road curvature), and user-reported incidents.  Combining these sources allows for a comprehensive and accurate prediction model.',
    ),
    FAQItem(
      question:
          'How frequently is the data updated, and how does this affect prediction accuracy?',
      answer:
          'Our data is updated at different intervals depending on the source.  Real-time traffic and weather data are updated continuously. Accident records are typically updated monthly or quarterly, depending on the reporting agency.  Frequent updates ensure that our predictions are based on the most current information, improving accuracy and reliability.',
    ),
    FAQItem(
      question: 'Does the app provide real-time alerts for accident hotspots?',
      answer:
          'Yes, the app provides real-time alerts for accident hotspots along your planned route.  These alerts give you advanced warning, allowing you to adjust your driving behavior and potentially avoid dangerous situations. Alert frequency and sensitivity can be customized in the app settings.',
    ),
    FAQItem(
      question:
          'How can I report an accident or hazard to improve the app\'s accuracy?',
      answer:
          'You can easily report accidents or hazards directly through the app.  Simply tap the "Report Incident" button and provide details about the location, type of incident, and any relevant observations.  This user-generated data helps us validate our models and improve the overall accuracy of our hotspot predictions. Photos can also be uploaded if safe to do so.',
    ),
    FAQItem(
      question:
          'What safety tips does the app offer in high-risk accident zones?',
      answer:
          'In high-risk accident zones, the app provides contextually relevant safety tips, such as reducing speed, increasing following distance, being aware of pedestrians and cyclists, and paying extra attention to road signs. These tips are tailored to the specific characteristics of the hotspot and aim to promote safer driving practices.',
    ),
    FAQItem(
      question:
          'How does your app protect user privacy when collecting and using location data?',
      answer:
          'We are committed to protecting user privacy.  All location data is anonymized and aggregated before being used in our prediction models.  We do not track individual user movements or share personally identifiable information with any third parties.  Our privacy policy outlines our data handling practices in detail, and we comply with all applicable data protection regulations.',
    ),
    FAQItem(
      question:
          'What is the accuracy rate of the accident hotspot predictions?',
      answer:
          'Our accident hotspot predictions are continuously evaluated for accuracy.  While accuracy can vary depending on data availability and region, we typically achieve a precision rate of over 80% in identifying areas with a high risk of accidents. We actively monitor performance and refine our models to further improve accuracy.',
    ),
    FAQItem(
      question:
          'Can I customize the alert settings to receive notifications only for specific types of hotspots?',
      answer:
          'Yes, the app allows you to customize alert settings. You can choose to receive notifications for all hotspots or filter alerts based on specific risk factors, such as weather conditions, time of day, or accident severity. Customization provides a more tailored and relevant alerting experience.',
    ),
    FAQItem(
      question: 'Is the app free to use, or does it require a subscription?',
      answer:
          'The app offers both a free and a premium subscription. The free version provides basic accident hotspot prediction and real-time alerts. The premium subscription unlocks advanced features, such as detailed route analysis, personalized safety recommendations, historical accident data visualizations, and an ad-free experience.',
    ),
  ];

  List<bool> _expandedStates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpandedStates();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  _loadExpandedStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _expandedStates = List.generate(faqItems.length, (index) {
        return prefs.getBool('faq$index') ?? false;
      });
    });
  }

  saveExpandedState(int index, bool isExpanded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('faq$index', isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900; // Adjust breakpoint as needed
    final contentWidth =
        isDesktop ? screenWidth * 0.7 : screenWidth; // Responsive width
    final fontSizeTitle = isDesktop ? 32.0 : 28.0;
    final fontSizeNormal = isDesktop ? 18.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(context),
          )
        ],
      ),
      backgroundColor: Color(0xFFD3F0EE),
      body: _isLoading
          ? _buildLoadingShimmer()
          : Center(
              child: Container(
                width: contentWidth,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                          fontSize: fontSizeTitle,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ).animate().fadeIn(duration: Duration(milliseconds: 500)),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: faqItems.length,
                        itemBuilder: (context, index) {
                          return _buildFAQItem(
                              faqItem: faqItems[index],
                              index: index,
                              isExpanded: _expandedStates[index],
                              isDesktop: isDesktop,
                              fontSizeNormal: fontSizeNormal);
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Still have questions? Contact our support team!',
                        style: TextStyle(
                            fontSize: fontSizeNormal, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ExpansionTile(
              title: Container(
                width: double.infinity,
                height: 24,
                color: Colors.white,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQItem(
      {required FAQItem faqItem,
      required int index,
      required bool isExpanded,
      required bool isDesktop,
      required double fontSizeNormal}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        title: Text(
          faqItem.question,
          style: TextStyle(
              fontSize: fontSizeNormal + 2, fontWeight: FontWeight.w600),
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _expandedStates[index] = expanded;
            saveExpandedState(index, expanded);
          });
        },
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: MarkdownBody(
              data: faqItem.answer,
              onTapLink: (text, url, title) {
                if (url != null) {
                  _launchURL(url);
                }
              },
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: TextStyle(fontSize: fontSizeNormal, color: Colors.grey[700]),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: Duration(milliseconds: 300)),
    );
  }

  _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    String searchTerm = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search FAQs'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter your search term'),
            onChanged: (value) {
              searchTerm = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () {
                Navigator.of(context).pop();
                _performSearch(searchTerm);
              },
            ),
          ],
        );
      },
    );
  }

  void _performSearch(String searchTerm) {
    if (searchTerm.isEmpty) return;

    List<FAQItem> results = faqItems
        .where((item) =>
            item.question.toLowerCase().contains(searchTerm.toLowerCase()) ||
            item.answer.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchResultsPage(results: results, searchTerm: searchTerm),
      ),
    );
  }
}

class SearchResultsPage extends StatelessWidget {
  final List<FAQItem> results;
  final String searchTerm;

  const SearchResultsPage(
      {super.key, required this.results, required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final contentWidth = isDesktop ? screenWidth * 0.7 : screenWidth;
    final fontSizeTitle = isDesktop ? 24.0 : 20.0;
    final fontSizeNormal = isDesktop ? 17.0 : 15.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$searchTerm"'),
      ),
      body: Center(
        child: Container(
          width: contentWidth,
          padding: const EdgeInsets.all(16.0),
          child: results.isEmpty
              ? Center(
                  child: Text(
                    'No results found for "$searchTerm".',
                    style: TextStyle(fontSize: fontSizeNormal),
                  ),
                )
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              results[index].question,
                              style: TextStyle(
                                  fontSize: fontSizeTitle,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              results[index].answer,
                              style: TextStyle(
                                  fontSize: fontSizeNormal,
                                  color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
