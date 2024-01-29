import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Article> firstLayoutArticles = [];
  List<Article> secondLayoutArticles = [];
  int currentPage = 1;
  int secondLayoutCurrentPage = 1; // New variable
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFirstLayoutData();
    _loadSecondLayoutData();

    _scrollController.addListener(() {
      if (!isLoading &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
        _loadSecondLayoutData();
      }
    });
  }

  Future<void> _loadFirstLayoutData() async {
    final apiKey = 'd4b30006874e49828a05a28d516fd02c';
    final query = 'film';

    final apiUrl =
        'https://newsapi.org/v2/everything?q=$query&page=$currentPage&pageSize=5&apiKey=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    _handleResponse(response, isSecondLayout: false);
  }

  Future<void> _loadSecondLayoutData() async {
    setState(() {
      isLoading = true;
    });

    final apiKey = 'd4b30006874e49828a05a28d516fd02c';
    final query = 'marvel';

    final apiUrl =
        'https://newsapi.org/v2/everything?q=$query&language=en&page=$secondLayoutCurrentPage&pageSize=10&apiKey=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    _handleResponse(response, isSecondLayout: true);

    setState(() {
      isLoading = false;
      secondLayoutCurrentPage++; // Increment the page for the next load
    });
  }

  void _handleResponse(http.Response response, {required bool isSecondLayout}) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('articles')) {
        List<Article> fetchedArticles = (responseData['articles'] as List)
            .map((data) => Article.fromJson(data))
            .toList();

        setState(() {
          if (isSecondLayout) {
            secondLayoutArticles.addAll(fetchedArticles);
          } else {
            firstLayoutArticles.addAll(fetchedArticles);
            currentPage++;
          }
        });
      } else {
        print('Key "articles" not found in response');
      }
    } else {
      print('Failed to load articles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mandiri App",
          style: TextStyle(color: Colors.white),
        ),
        titleSpacing: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        backgroundColor: Color.fromARGB(255, 3, 37, 84),
        actions: const [
          Icon(Icons.notifications, color: Colors.white),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 9, 77, 173),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      'https://i.pinimg.com/originals/a9/1a/fd/a91afd8e05e4ac4d5fe8f75a8a19e014.png', // Replace with your image URL
                      height: 70,
                      width: 70,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            // Add more items as needed
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          firstLayoutArticles.isNotEmpty
              ? ArticleItem(article: firstLayoutArticles.first)
              : Container(),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0),
            child: Text(
              "Berita Terkini",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 66, 66, 51),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: secondLayoutArticles.length,
              itemBuilder: (context, index) {
                return ArticleListItem(article: secondLayoutArticles[index]);
              },
              controller: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}

class Article {
  final String title;
  final String description;
  final String date;
  final String image;
  final String source;

  Article({
    required this.title,
    required this.description,
    required this.date,
    required this.image,
    required this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['content'] ?? '',
      date: _formatDate(json['publishedAt']) ?? '',
      image: json['urlToImage'] ?? '',
      source: json['source']['name'] ?? '',
    );
  }

  static String? _formatDate(String? dateString) {
    if (dateString == null) {
      return null;
    }

    final DateTime dateTime = DateTime.parse(dateString);
    final String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    return formattedDate;
  }
}

//About Layout
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 3, 37, 84),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Icon(Icons.notifications),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Image.network(
                'https://i.pinimg.com/originals/a9/1a/fd/a91afd8e05e4ac4d5fe8f75a8a19e014.png', // Replace with your image URL
                height: 150,
                width: 150,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 20),
            const Text(
              "Welcome to Our App!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            const Text(
              "We have been delivering high-quality content and news since 1998. "
              "Our mission is to keep you informed and entertained.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            const Text(
              "Since 1998",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => const Icon(
                  Icons.star,
                  size: 30,
                  color: Colors.amber,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("HOME"),
            ),
          ],
        ),
      ),
    );
  }
}

//First Layout
class ArticleItem extends StatelessWidget {
  final Article article;

  ArticleItem({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.network(
                    "https://i.pinimg.com/originals/a9/1a/fd/a91afd8e05e4ac4d5fe8f75a8a19e014.png",
                    height: 30.0,
                    width: 30.0,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: 8),
                const Text(
                  "Mandiri News",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 66, 66, 51),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              "Berita Terbaru",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 66, 66, 51),
              ),
            ),
          ),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                article.image,
                height: 150.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 66, 66, 51),
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      article.source,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 86, 84, 84),
                      ),
                    ),
                    SizedBox(width: 8),
                    Spacer(),
                    Icon(Icons.date_range, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      article.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 86, 84, 84),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticlePage(
                    articleTitle: article.title,
                    description: article.description,
                    date: article.date,
                    image: article.image,
                    source: article.source,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//Second Layout
class ArticleListItem extends StatelessWidget {
  final Article article;

  ArticleListItem({required this.article});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          article.image,
          height: 80.0,
          width: 80.0,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        article.title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 66, 66, 51),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey, size: 16),
              SizedBox(width: 4),
              Text(
                article.source,
                style: TextStyle(
                  fontSize: 11,
                  color: Color.fromARGB(255, 86, 84, 84),
                ),
              ),
              SizedBox(width: 8),
              Spacer(),
              Icon(Icons.date_range, color: Colors.grey, size: 16),
              SizedBox(width: 4),
              Text(
                article.date,
                style: TextStyle(
                  fontSize: 11,
                  color: Color.fromARGB(255, 86, 84, 84),
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticlePage(
              articleTitle: article.title,
              description: article.description,
              date: article.date,
              image: article.image,
              source: article.source,
            ),
          ),
        );
      },
    );
  }
}

//Page Layout
class ArticlePage extends StatelessWidget {
  final String articleTitle;
  final String description;
  final String date;
  final String image;
  final String source;

  ArticlePage({
    required this.articleTitle,
    required this.description,
    required this.date,
    required this.image,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          articleTitle,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        titleSpacing: 0,
        backgroundColor: Color.fromARGB(255, 3, 37, 84),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              // Handle notifications button press
            },
            icon: Icon(Icons.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                articleTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 3, 37, 84),
                ),
              ),
              SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Light gray background color for the image section
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 248, 248, 248),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 6,
                    child: IconButton(
                      onPressed: () {
                        // Handle flag button press
                      },
                      icon: const Icon(
                        Icons.flag,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Author: $source',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Published: $date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}