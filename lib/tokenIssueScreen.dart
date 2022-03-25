import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_token/config.dart';
import 'package:food_token/tokenEmailScreen.dart';
import './token.dart';

class TokenIssueScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TokenIssueScreen();
  }
}

class _TokenIssueScreen extends State<TokenIssueScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameCont = TextEditingController();
  final emailCont = TextEditingController();
  final couponCount = TextEditingController();
  String program = "BE Quiz";
  String role = "Participant";
  bool day1 = false;
  bool day2 = false;
  bool day3 = false;

  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter name',
              ),
              validator: this.notNullString,
              controller: nameCont,
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter Email',
              ),
              validator: this.validateEmail,
              keyboardType: TextInputType.emailAddress,
              controller: emailCont,
            ),
            DropdownButtonFormField<String>(
              items: <String>[
                "BE Model",
                "+2 Model",
                "BE Quiz",
                "Paper Bridge",
                "Popsicle Bridge"
              ]
                  .map((String str) =>
                      DropdownMenuItem<String>(child: Text(str), value: str))
                  .toList(),
              value: program,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    program = value;
                  });
                }
              },
            ),
            DropdownButtonFormField<String>(
              items: <String>[
                "Participant",
                "Coordinator",
                "Volunteer",
                "Judge",
                "Other"
              ]
                  .map((String str) =>
                      DropdownMenuItem<String>(child: Text(str), value: str))
                  .toList(),
              value: role,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    role = value;
                  });
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter Number of Coupons',
              ),
              controller: couponCount,
              keyboardType: TextInputType.number,
            ),
            Row(children: [
              Text("Day 1"),
              Checkbox(
                  value: day1,
                  onChanged: (value) {
                    setState(() {
                      day1 = (value == null) ? false : value;
                    });
                  })
            ]),
            Row(children: [
              Text("Day 2"),
              Checkbox(
                  value: day2,
                  onChanged: (value) {
                    setState(() {
                      day2 = (value == null) ? false : value;
                    });
                  })
            ]),
            Row(children: [
              Text("Day 3"),
              Checkbox(
                  value: day3,
                  onChanged: (value) {
                    setState(() {
                      day3 = (value == null) ? false : value;
                    });
                  })
            ]),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    this.submit(context);
                  }
                },
                child: Text("Issue Tokens"))
          ],
        ));
  }

  String? validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value))
      return 'Enter a valid email address';
    else
      return null;
  }

  String? notNullString(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter some text';
    }
    return null;
  }

  void submit(BuildContext context) async {
    String name = nameCont.text;
    String email = emailCont.text;
    int coupon = int.parse(couponCount.text);
    List<Token> tokens = [];

    if (day1 == true) {
      Token? token = await Token(
              name: name,
              email: email,
              total: coupon,
              issued: Timestamp.now(),
              program: program,
              day: Timestamp.fromDate(Config.firstDay.add(Duration(days: 0))),
              role: role)
          .add();
      if (token != null) tokens.add(token);
    }

    if (day2 == true) {
      Token? token = await Token(
              name: name,
              email: email,
              total: coupon,
              issued: Timestamp.now(),
              program: program,
              day: Timestamp.fromDate(Config.firstDay.add(Duration(days: 1))),
              role: role)
          .add();
      if (token != null) tokens.add(token);
    }

    if (day3 == true) {
      Token? token = await Token(
              name: name,
              email: email,
              total: coupon,
              issued: Timestamp.now(),
              program: program,
              day: Timestamp.fromDate(Config.firstDay.add(Duration(days: 2))),
              role: role)
          .add();
      if (token != null) tokens.add(token);
    }
    print(tokens.toString());
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => TokenEmailScreen(tokens)));
  }
}
