import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:food_token/tokenVerificationScreen.dart';
import './token.dart';

class TokenEmailScreen extends StatelessWidget {
  final List<Token> tokens;

  TokenEmailScreen(this.tokens);

  Widget build(BuildContext context) {
    if (tokens.length == 0) return Text("No token!");

    Widget body = Column(children: [
      ...tokens.map((token) => TokenView(token)).toList(),
      ElevatedButton(onPressed: this.submit, child: Text("Submit Email"))
    ]);

    return Scaffold(appBar: AppBar(title: Text("Token Email")), body: body);
  }

  String emailBody() {
    String linkBase =
        "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=";
    String text = "Click on the link to view food token qr code for: <br/>";
    tokens.forEach((token) {
      text += '<a href="' +
          linkBase +
          token.id +
          '"> ' +
          token.humanDay() +
          "</a> <br/>";
    });
    print(text);
    return text;
  }

  String emailBody0() {
    String linkBase =
        "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=";
    String text = "Hello ${tokens[0].name}!\n Thank you for being involved in Aadhar-2078! \n";
    text += "Following are the links to view food token qr code for: \n";
    tokens.forEach((token) {
      text += token.humanDay() + ":  " + linkBase + token.id + "\n";
      if (token.role == "other") {
        text +=
            "( ${token.total} coupons; for being involved in ${token.program})\n";
      } else {
        text +=
            "( ${token.total} coupons; for contributing as ${token.role} in ${token.program})\n";
      }
    });
    return text;
  }

  void submit() async {
    final Email email = Email(
      body: this.emailBody0(),
      subject: 'CESS Food Token',
      recipients: [tokens[0].email],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}
