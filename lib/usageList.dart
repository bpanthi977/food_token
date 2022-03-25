import 'package:flutter/material.dart';
import 'package:food_token/usage.dart';
import './token.dart';

class UsageList extends StatelessWidget {
  Widget build(BuildContext context) {
    Widget body = FutureBuilder(
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error occured while loading");
          } else if (!snapshot.hasData) {
            return Text("Loading...");
          } else {
            List<Usage> data = snapshot.data! as List<Usage>;
            return ListView.builder(
                itemBuilder: (BuildContext context, int i) {
                  return UsageTile(data[i]);
                },
                itemCount: data.length);
          }
        },
        future: Usage.listAll());
    return Scaffold(
        appBar: AppBar(title: Text("Tokens Usage list")), body: body);
  }
}

class UsageTile extends StatelessWidget {
  final Usage data;
  UsageTile(this.data);

  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error loading token usage");
          } else if (!snapshot.hasData) {
            return Text("Loading");
          } else {
            Token token = snapshot.data as Token;
            return Column(children: [
                Row(children: [
                Expanded(child: Text(token.name)),
                Text(this.data.count.toString())
              ]),
              Text(this.data.timestamp!.toDate().toIso8601String())
            ]);
          }
        },
        future: data.getToken());
  }
}
