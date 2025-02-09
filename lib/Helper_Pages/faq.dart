import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For animations (install: `flutter pub add flutter_animate`)
import 'package:flutter_markdown/flutter_markdown.dart'; // For Markdown formatting (install: `flutter pub add flutter_markdown`)
import 'package:url_launcher/url_launcher.dart'; // For links in Markdown
// For Markdown formatting
import 'package:shared_preferences/shared_preferences.dart'; //For Persisting Open/Closed State (install: `flutter pub add shared_preferences`)
import 'package:shimmer/shimmer.dart'; // For Loading animation (install: `flutter pub add shimmer`)

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<FAQItem> faqItems = [
    FAQItem(
      question: 'How does the app predict accident hotspots?',
      answer: '''
The app leverages **advanced AI algorithms** to analyze historical accident data, traffic patterns, weather conditions, and road infrastructure. By combining these factors, the app identifies areas with a high likelihood of accidents.

- The AI model is trained on vast datasets and is **continuously updated** to improve accuracy.
- We use a combination of time-series analysis and machine learning techniques.

Learn more about our methodology [here](https://www.example.com/methodology).
''',
    ),
    FAQItem(
      question: 'Is the app available worldwide?',
      answer:
          'Currently, the app is available in select regions where we have sufficient data to provide accurate predictions. We are actively working on expanding our coverage to more countries and regions. Stay tuned for updates!',
    ),
    FAQItem(
      question: 'How accurate are the predictions?',
      answer:
          'The accuracy of the predictions depends on the quality and quantity of data available for a specific region. In areas with comprehensive data, the predictions are highly accurate. However, in regions with limited data, the accuracy may vary. We are constantly refining our algorithms and expanding our datasets to improve accuracy across all regions.',
    ),
    FAQItem(
      question: 'Can I contribute data to improve the app?',
      answer:
          'Yes! User contributions are invaluable to us. You can report accidents, traffic conditions, or road hazards through the app. This data helps us improve the accuracy of our predictions and make the roads safer for everyone.',
    ),
    FAQItem(
      question: 'What measures are taken to ensure user privacy?',
      answer:
          'We take user privacy very seriously. All data collected is anonymized and securely stored. We comply with global data protection regulations, such as GDPR, and do not share personal information with third parties without consent.',
    ),
    FAQItem(
      question: 'How often is the data updated?',
      answer:
          'The data is updated in real-time for traffic conditions and weather. Historical accident data is updated monthly, and the AI model is retrained periodically to incorporate new data and improve predictions.',
    ),
    FAQItem(
      question: 'What should I do if I encounter an error in the app?',
      answer:
          'If you encounter any issues or errors, please report them through the "Help & Support" section in the app. Our support team will investigate and resolve the issue as quickly as possible.',
    ),
    FAQItem(
      question: 'Are there any subscription fees?',
      answer:
          'The basic version of the app is free to use. However, we offer a premium subscription that provides additional features such as detailed route analysis, personalized safety tips, and ad-free experience. You can upgrade to premium within the app.',
    ),
  ];

  List<bool> _expandedStates = []; //To Manage the open/close state of each FAQ
  bool _isLoading = true; // Simulate loading data

  @override
  void initState() {
    super.initState();
    _loadExpandedStates();
    // Simulate data loading
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Load the open/closed state of FAQ from local storage
  _loadExpandedStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _expandedStates = List.generate(faqItems.length, (index) {
        return prefs.getBool('faq_$index') ?? false; // Default to closed
      });
    });
  }

  //Save the open/close state of the FAQ to local storage
  _saveExpandedState(int index, bool isExpanded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('faq_$index', isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Frequently Asked Questions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              //Implement search functionality here
              //This will be a search through the FAQ Items
              _showSearchDialog(context);
            },
          )
        ],
      ),
      body: _isLoading
          ? _buildLoadingShimmer()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    ).animate().fadeIn(duration: Duration(milliseconds: 500)),
                    SizedBox(height: 16),
                    ...List.generate(faqItems.length, (index) {
                      return _buildFAQItem(
                          faqItem: faqItems[index],
                          index: index,
                          isExpanded: _expandedStates[index]);
                    }),
                    SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Still have questions? Contact our support team!',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
        itemCount: 5, // Simulate 5 FAQ items loading
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
      required bool isExpanded}) {
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _expandedStates[index] = expanded;
            _saveExpandedState(index, expanded); // Save the state
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
                p: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
      {Key? key, required this.results, required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$searchTerm"'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: results.isEmpty
            ? Center(
                child: Text('No results found for "$searchTerm".'),
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
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            results[index].answer,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
