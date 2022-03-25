import 'package:cloud_firestore/cloud_firestore.dart';

import 'config.dart';

class Token {
  String id;
  final String name;
  final String email;
  final int total;
  int used;
  final Timestamp? day;
  final Timestamp? issued;
  final String program;
  final String role;

  Token(
      {this.id = "",
      this.name = "",
      this.email = "",
      this.total = 0,
      this.used = 0,
      this.day,
      this.issued,
      this.program = "",
      this.role = ""});

  int remaining() {
    int n = this.total - this.used;
    DateTime now = DateTime.now();
    DateTime dt = this.day!.toDate();
    if (dt.day != now.day || dt.year != now.year || dt.month != now.month) {
      return 0;
    }
    return n;
  }

  String humanDay() {
    DateTime date = this.day!.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  factory Token.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Token();
    return Token(
        name: json['name'],
        email: json['email'],
        total: json['total'],
        used: json['used'],
        day: json['day'],
        issued: json['issued'],
        program: json['program'],
        role: json['role']);
  }

  static Future<Token?> loadToken(id) async {
    CollectionReference tokens =
        FirebaseFirestore.instance.collection("tokens");
    DocumentSnapshot tokenData =
        await tokens.doc(id).get(GetOptions(source: Source.server));
    if (tokenData.exists) {
      print(tokenData.data());
      Token token = Token.fromJson(tokenData.data() as Map<String, dynamic>);
      token.id = id;
      return token;
    } else {
      return null;
    }
  }

  Future<Token?> use(int n) async {
    // Create a reference to the document the transaction will use
    DocumentReference tokenRef =
        FirebaseFirestore.instance.collection('tokens').doc(this.id);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the document
        DocumentSnapshot snapshot = await transaction.get(tokenRef);

        if (!snapshot.exists) {
          throw Exception("Token doesn't exist");
        }

        Token token = Token.fromJson(snapshot.data() as Map<String, dynamic>);
        if (token.total - token.used < n) {
          throw Exception("Free tokens not avaliable");
        }

        // Perform an update on the document
        transaction.update(tokenRef, {'used': token.used + n});
        // Add an usage record
        DocumentReference usage =
            FirebaseFirestore.instance.collection('usage').doc();
        transaction.set(usage, {
          'count': n,
          'issuer': Config.issuer,
          'timestamp': Timestamp.now(),
          'token': snapshot.reference
        });
        // Return the new count
        this.used = token.used + n;
        return this.used;
      });
      return this;
    } catch (error) {
      print("Failed to update token: $error");
      return await Token.loadToken(this.id);
    }
  }

  Future<Token?> useAll() async {
    return await this.use(this.total - this.used);
  }

  Future<Token?> add() async {
    CollectionReference tokens =
        FirebaseFirestore.instance.collection("tokens");
    DocumentReference tokenRef = await tokens.add({
      'name': this.name,
      'email': this.email,
      'total': this.total,
      'used': this.used,
      'issued': this.issued,
      'program': this.program,
      'role': this.role,
      'day': this.day
    });
    this.id = tokenRef.id;
    return this;
  }
}
