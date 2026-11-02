
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5035';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // ================= TASKS =================

  static Future<List<dynamic>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/api/Tasks'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load tasks: ${response.body}');
  }

  static Future<void> addTask(Map<String, dynamic> task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Tasks'),
      headers: _headers,
      body: jsonEncode(task),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add task: ${response.body}');
    }
  }

  static Future<void> updateTask(
    int id,
    Map<String, dynamic> task,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/Tasks/$id'),
      headers: _headers,
      body: jsonEncode(task),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  static Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/Tasks/$id'),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }

  // ================= NOTES =================

  static Future<List<dynamic>> getNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/Notes'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load notes: ${response.body}');
  }

  static Future<void> addNote(Map<String, dynamic> note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Notes'),
      headers: _headers,
      body: jsonEncode(note),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add note: ${response.body}');
    }
  }

  static Future<void> updateNote(
    int id,
    Map<String, dynamic> note,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/Notes/$id'),
      headers: _headers,
      body: jsonEncode(note),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update note: ${response.body}');
    }
  }

  static Future<void> deleteNote(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/Notes/$id'),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete note: ${response.body}');
    }
  }

  // ================= REMINDERS =================

  static Future<List<dynamic>> getReminders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Reminders'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load reminders: ${response.body}');
  }

  static Future<void> addReminder(
    Map<String, dynamic> reminder,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Reminders'),
      headers: _headers,
      body: jsonEncode(reminder),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add reminder: ${response.body}');
    }
  }

  static Future<void> updateReminder(
    int id,
    Map<String, dynamic> reminder,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/Reminders/$id'),
      headers: _headers,
      body: jsonEncode(reminder),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update reminder: ${response.body}');
    }
  }

  static Future<void> deleteReminder(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/Reminders/$id'),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete reminder: ${response.body}');
    }
  }

  // ================= SHOPPING ITEMS =================

  static Future<List<dynamic>> getShoppingItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ShoppingItems'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load shopping items: ${response.body}');
  }

  static Future<void> addShoppingItem(
    Map<String, dynamic> item,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ShoppingItems'),
      headers: _headers,
      body: jsonEncode(item),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add shopping item: ${response.body}');
    }
  }

  static Future<void> updateShoppingItem(
    int id,
    Map<String, dynamic> item,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/ShoppingItems/$id'),
      headers: _headers,
      body: jsonEncode(item),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update shopping item: ${response.body}');
    }
  }

  static Future<void> deleteShoppingItem(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/ShoppingItems/$id'),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete shopping item: ${response.body}');
    }
  }

  // ================= ACTIVITIES =================

  static Future<List<dynamic>> getActivities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Activities'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load activities: ${response.body}');
  }

  static Future<void> addActivity(
    Map<String, dynamic> activity,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Activities'),
      headers: _headers,
      body: jsonEncode(activity),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add activity: ${response.body}');
    }
  }

  static Future<void> deleteActivity(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/Activities/$id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete activity: ${response.body}');
    }
  }
}
