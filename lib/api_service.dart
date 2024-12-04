import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://fakestoreapi.com/products";


  Future<List<dynamic>> fetchLaptops() async {
    final response = await http.get(Uri.parse('$baseUrl/category/electronics')); 

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);  
      } catch (e) {
        throw Exception('Failed to parse JSON');
      }
    } else {
      throw Exception('Failed to load laptops');
}
}
}