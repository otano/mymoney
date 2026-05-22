import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/depense.dart';

class StorageService {
  static const String _storageKey = 'depenses';

  Future<void> saveDepenses(List<Depense> depenses) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      depenses.map((d) => d.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  Future<List<Depense>> loadDepenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_storageKey);

    if (encodedData == null) {
      return [];
    }

    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => Depense.fromMap(item)).toList();
  }
}
