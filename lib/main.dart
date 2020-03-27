import 'package:flutter/material.dart';

void main() => runApp(HomePage());

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1x App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: body(),
      ),
    );
  }

  body() {
    return NestedScrollView(
      headerSliverBuilder: (buildContext, innerBoxIsScrolled) => <Widget>[
        SliverAppBar(
          title: TabBar(),
        ),
      ],
      body: Container(),
    );
  }
}
