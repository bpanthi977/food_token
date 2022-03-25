import 'package:cloud_firestore/cloud_firestore.dart';
import './token.dart';
import './config.dart';

class Usage {
  String? id;
  final int count;
  final String issuer;
  Timestamp? timestamp;
  DocumentReference? token;
  Token? _token;

  Usage({this.count = 0, this.issuer = "", this.timestamp, this.token});

  factory Usage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Usage();

    return Usage(
        count: json['count'],
        issuer: json['issuer'],
        timestamp: json['timestamp'],
        token: json['token']);
  }

  Future<Token?> getToken() async {
    if (_token != null) return _token;

    DocumentSnapshot snapshot = await token!.get();
    if (snapshot.exists) {
      _token = Token.fromJson(snapshot.data() as Map<String, dynamic>);
      return _token;
    }

    return null;
  }

  static Future<List<Usage>> listAll() async {
    QuerySnapshot<Map<String, dynamic>> usages = await FirebaseFirestore
        .instance
        .collection("usage")
        .where('issuer', isEqualTo: Config.issuer)
        .get();
    return usages.docs.map((e) => Usage.fromJson(e.data())).toList();
  }
}
