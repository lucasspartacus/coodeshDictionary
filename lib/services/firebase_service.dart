import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  static String get userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado");
    }
    return user.uid;
  }

  static Future<void> addFavorite(String word) async {
    await _db.collection('users').doc(userId)
      .collection('favorites').doc(word).set({'addedAt': DateTime.now()});
  }

  static Future<void> removeFavorite(String word) async {
    await _db.collection('users').doc(userId)
      .collection('favorites').doc(word).delete();
  }

  static Future<void> addToHistory(String word) async {
    await _db.collection('users').doc(userId)
      .collection('history').doc(word).set({'viewedAt': DateTime.now()});
  }

  static Future<List<String>> getFavorites() async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  static Future<List<String>> getHistory() async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('viewedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
