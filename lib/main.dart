import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model untuk produk
class Product {
  final String title;
  final String description;
  final String image;
  final double price;

  Product({
    required this.title,
    required this.description,
    required this.image,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      image: json['image'] ?? 'https://via.placeholder.com/150',
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}

// Service untuk mengambil data dari FakeStoreAPI
class ProductService {
  final String baseUrl = 'https://fakestoreapi.com/products';

  Future<List<Product>> fetchProductsByCategory(String category) async {
    String url = '$baseUrl/category/$category';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> fetchAllProducts() async {
    String url = baseUrl;

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Fetch products by search query
  Future<List<Product>> fetchProductsBySearch(String query) async {
    // Fetch all products
    List<Product> allProducts = await fetchAllProducts();

    // Filter products that match the query in title or description
    return allProducts.where((product) {
      return product.title.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}

// Halaman utama dengan PageView
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService productService = ProductService();
  PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  // Daftar halaman untuk di slide
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(productService: productService),
      ShoppingScreen(),
      AboutUsScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengubah halaman dengan animasi geser
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Fungsi untuk menangani tap pada BottomNavigationBar
  void _onItemTapped(int selectedIndex) {
    _pageController.animateToPage(
      selectedIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF868686),
      // Tidak perlu AppBar di sini karena AppBar berada di setiap halaman
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
        physics: NeverScrollableScrollPhysics(), // Nonaktifkan geser manual
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 10, 0, 76),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.yellowAccent,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Us',
          ),
        ],
      ),
    );
  }
}

// Halaman Beranda (HomePage)
class HomePage extends StatefulWidget {
  final ProductService productService;

  HomePage({required this.productService});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  List<String> categories = [
    'electronics',
    'jewelery',
    'men\'s clothing',
    'women\'s clothing'
  ];
  String selectedCategory = 'all'; // Menambahkan opsi 'all' untuk semua produk
  late Future<List<Product>> productsFuture; // Future untuk produk

  @override
  void initState() {
    super.initState();
    // Menampilkan produk acak saat pertama kali memuat halaman
    productsFuture = widget.productService.fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 10, 0, 76),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to",
              style: TextStyle(
                  fontSize: 14,
                  color: const Color.fromARGB(255, 255, 255, 255)),
            ),
            Text(
              "CommonCircleCatalog",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 255, 255)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menambahkan jarak antara AppBar dan SearchBar
            SizedBox(height: 16),

            // Search bar baru dengan warna abu-abu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search product...',
                  prefixIcon: Icon(Icons.search),
                  filled: true, // Mengaktifkan warna latar belakang
                  fillColor: Colors.grey[300], // Warna abu-abu terang
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSubmitted: (_) {
                  handleSearch(context);
                },
              ),
            ),

            // Menambahkan jarak setelah search bar
            SizedBox(height: 20),

            // Teks untuk menyambut di bawah search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                selectedCategory == 'all'
                    ? 'All Product'
                    : 'Produk ${selectedCategory}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Kategori produk
            Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((category) {
                  return CategoryWidget(
                    category: category,
                    isSelected: category == selectedCategory,
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                      // Menampilkan produk berdasarkan kategori setelah kategori dipilih
                      if (selectedCategory == 'all') {
                        productsFuture =
                            widget.productService.fetchAllProducts();
                      } else {
                        productsFuture = widget.productService
                            .fetchProductsByCategory(selectedCategory);
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            // Menambahkan jarak antara kategori dan produk
            SizedBox(height: 16),

            // Menampilkan produk sesuai kategori atau produk acak jika belum dipilih kategori
            FutureBuilder<List<Product>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No products available'));
                }

                List<Product> productList = snapshot.data!;
                return Column(
                  children: productList
                      .map((product) => ProductCard(product: product))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void handleSearch(BuildContext context) {
    String query = searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
              query: query, productService: widget.productService),
        ),
      );
      searchController.clear();
    }
  }
}

// Shopping Screen: Instagram for purchase
class ShoppingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 0, 76),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DM on Instagram',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5), // Spasi antar baris teks
            Text(
              '@Common.Circle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5), // Spasi antar baris teks
            Text(
              'For Purchasing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// About Us Screen: Information about the app
class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tambahkan AppBar jika diperlukan
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: const Color.fromARGB(255, 10, 0, 76),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'About CommonCircle',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'CommonCircle is your go-to app for all things shopping. We provide a wide range of products across categories such as electronics, clothing, jewelry, and more. Shop from the comfort of your home and enjoy a seamless experience.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Category widget
class CategoryWidget extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  CategoryWidget({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData categoryIcon = Icons.category;

    // Set icons berdasarkan kategori
    switch (category) {
      case 'electronics':
        categoryIcon = Icons.laptop_mac;
        break;
      case 'jewelery':
        categoryIcon = Icons.diamond;
        break;
      case 'men\'s clothing':
        categoryIcon = Icons.man;
        break;
      case 'women\'s clothing':
        categoryIcon = Icons.girl;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 0, 0, 0)
              : const Color.fromARGB(255, 63, 63, 63),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(categoryIcon, color: Colors.white),
            SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ProductCard widget
class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail produk
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(product: product),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Gambar produk
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            // Informasi produk
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul produk
                    Text(
                      product.title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Harga produk
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 77, 221, 82)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product detail screen
class DetailScreen extends StatelessWidget {
  final Product product;

  DetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 10, 0, 76),
        title: Text(
          product.title,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white, // Mengubah warna tombol kembali menjadi putih
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menampilkan gambar produk
              Image.network(
                product.image,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),

              SizedBox(height: 16),

              // Judul produk
              Text(
                product.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),

              // Deskripsi produk
              Text(
                product.description,
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),

              // Menampilkan harga produk
              Text(
                'Price: \$${product.price}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 16),

              // Menambahkan tombol beli atau aksi lainnya
              ElevatedButton(
                onPressed: () {
                  // Aksi untuk membeli produk atau lainnya
                },
                child: Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Search result screen
class SearchResultScreen extends StatelessWidget {
  final String query;
  final ProductService productService;

  SearchResultScreen({required this.query, required this.productService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil pencarian'),
        backgroundColor: const Color.fromARGB(255, 10, 0, 76),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Product>>(
        future: productService.fetchProductsBySearch(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found'));
          }

          List<Product> productList = snapshot.data!;
          return ListView(
            children: productList
                .map((product) => ProductCard(product: product))
                .toList(),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // Hilangkan banner debug
    theme: ThemeData(
      scaffoldBackgroundColor: Color(0xFF868686),
      primaryColor: const Color.fromARGB(255, 10, 0, 76),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromARGB(255, 10, 0, 76),
      ),
    ),
    home: HomeScreen(),
  ));
}
