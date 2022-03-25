import 'package:flutter/material.dart';
import './token.dart';

class TokenVerificationScreen extends StatelessWidget {
  final String? token;
  TokenVerificationScreen(this.token);

  Widget build(BuildContext context) {
    Widget body = Text("No token");
    if (this.token != null) {
      body = FutureBuilder(
          future: Token.loadToken(this.token),
          initialData: false,
          builder: (BuildContext context, snapshot) {
            print(snapshot.data);
            print(this.token);
            if (snapshot.hasError) {
              return Text("Error Occured! Check your network connection");
            } else if (snapshot.data == null) {
              return Text("Invalid Token");
            } else if (snapshot.data == false) {
              return Text("Loading token ${this.token}...");
            } else {
              Token token = snapshot.data as Token;
              return TokenActionStall(token);
            }
          });
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Token Details"),
        ),
        body: body);
  }
}

class TokenActionStall extends StatefulWidget {
  final Token token;
  TokenActionStall(this.token);

  @override
  State<StatefulWidget> createState() {
    return _TokenActionStall(this.token);
  }
}

class _TokenActionStall extends State<TokenActionStall> {
  Token? token;
  bool loading = false;
  _TokenActionStall(this.token);

  Widget build(BuildContext context) {
    Widget widgets = Column(children: [
      TokenView(token),
      Row(children: [
        ElevatedButton(
          onPressed: (this.loading || this.token!.remaining() == 0)
              ? null
              : () async {
                  this.loadingIndicator();
                  this.updateToken(await this.token!.useAll());
                },
          child: Text("Use All"),
        ),
        ElevatedButton(
            onPressed: (this.loading || this.token!.remaining() == 0)
                ? null
                : () async {
                    this.loadingIndicator();
                    this.updateToken(await this.token!.use(1));
                  },
            child: Text("Use one"))
      ])
    ]);

    if (this.loading) {
      return Stack(
        children: [
          Center(child: CircularProgressIndicator()),
          IgnorePointer(child: widgets)
        ],
      );
    } else {
      return widgets;
    }
  }

  void loadingIndicator() {
    setState(() {
      this.loading = true;
    });
  }

  void updateToken(Token? newToken) {
    setState(() {
      this.token = newToken;
      this.loading = false;
    });
  }
}

class TokenView extends StatelessWidget {
  final Token? token;

  TokenView(this.token);

  Widget build(BuildContext context) {
    if (this.token != null)
      return Column(
        children: [
          Text("Name: ${this.token!.name}"),
          Text("Email: ${this.token!.email}"),
          Text("Remaining Coupon Count: ${this.token!.remaining()}"),
          Text("Used: ${this.token!.used}/${this.token!.total}"),
          Text("Issued for Day: ${this.token!.humanDay()}")
        ],
      );

    return Text("Invalid Token or Error");
  }
}
