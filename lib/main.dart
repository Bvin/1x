import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

void main() => runApp(HomePage());

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<HomePage> with SingleTickerProviderStateMixin{

  List<Map> _categories;
  List<Map> _photos = List();
  TabController _tabController;

  @override
  void initState() {
    localCategories();
    html();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1x App',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: body(),
      ),
    );
  }

  localCategories(){
    _categories = <Map>[
      {"category_id":0,"category_name":"Home",},
      {"category_id":15,"category_name":"Abstract",},
      {"category_id":1,"category_name":"Action",},
      {"category_id":21,"category_name":"Animals",},
      {"category_id":11,"category_name":"Architecture",},
      {"category_id":17,"category_name":"Conceptual",},
      {"category_id":10,"category_name":"Creative edit",},
      {"category_id":8,"category_name":"Documentary",},
      {"category_id":14,"category_name":"Everyday",},
      {"category_id":12,"category_name":"Fine Art Nude",},
      {"category_id":3,"category_name":"Humour",},
      {"category_id":2,"category_name":"Macro",},
      {"category_id":4,"category_name":"Mood",},
      {"category_id":9,"category_name":"Night",},
      {"category_id":19,"category_name":"Performance",},
      {"category_id":13,"category_name":"Portrait",},
      {"category_id":18,"category_name":"Still life",},
      {"category_id":7,"category_name":"Street",},
      {"category_id":20,"category_name":"Underwater",},
      {"category_id":5,"category_name":"Wildlife",},
    ];
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  html() async {
    Dio dio = Dio();
    Response response = await dio.get("https://1x.com/");
    String data = response.data;
    print("start");
    RegExp regExp = RegExp("\/images\/user.*?jpg");
    Iterable<Match> matches = regExp.allMatches(data);
    print(matches.length);
    for (Match m in matches) {
      Map map = Map();
      map["url"] = m.group(0);
      _photos.add(map);
        //print(m.group(0));
    }
    print("end");
    print("start");
    regExp = RegExp("&copy;.*?<");
    Iterable<Match>  _matches = regExp.allMatches(data);
    for (int i=0;i<_matches.length;i++) {
      Match m = _matches.elementAt(i);
      Map map = _photos[i];
      String name = m.group(0);
      map["author"] = name.substring(name.indexOf(" "),name.lastIndexOf("<")).trim();
      print(m.group(0));
    }
    print("end");
    print(_photos);
  }

  body() {
    return NestedScrollView(
      headerSliverBuilder: (buildContext, innerBoxIsScrolled) => <Widget>[
        SliverAppBar(
          title: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorWeight: 1,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: _categories.map((Map map) => Container(
              child: Text(map["category_name"]),
            )).toList(),
          ),
        ),
      ],
      body: Container(
        child: TabBarView(
          controller: _tabController,
          children: _categories.map((Map map) => Container(
            color: Colors.blue,
            child: Text(map["category_name"]),
          )).toList(),
        ),
      ),
    );
  }
}
