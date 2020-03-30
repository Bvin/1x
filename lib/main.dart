import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:onex/photo_page.dart';

import 'category_tab.dart';
import 'event_bus_service.dart';

void main() => runApp(MaterialApp(
  title: '1x App',
  theme: ThemeData(
    platform: TargetPlatform.iOS,
    brightness: Brightness.dark,
  ),
  home: HomePage(),
));

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
  Dio _dio;

  @override
  void initState() {
    _dio = Dio();
    localCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: body(context),
      );
  }

  localCategories(){
    _categories = <Map>[
      {"category_id":0,"category_name":"Home",},
      {"category_id":15,"category_name":"abstract",},
      {"category_id":1,"category_name":"action",},
      {"category_id":21,"category_name":"animals",},
      {"category_id":11,"category_name":"architecture",},
      {"category_id":17,"category_name":"conceptual",},
      {"category_id":10,"category_name":"creative-edit",},
      {"category_id":8,"category_name":"documentary",},
      {"category_id":14,"category_name":"everyday",},
      {"category_id":12,"category_name":"fine-art-nude",},
      {"category_id":3,"category_name":"humour",},
      {"category_id":2,"category_name":"macro",},
      {"category_id":4,"category_name":"mood",},
      {"category_id":9,"category_name":"night",},
      {"category_id":19,"category_name":"performance",},
      {"category_id":13,"category_name":"portrait",},
      {"category_id":18,"category_name":"still-life",},
      {"category_id":7,"category_name":"street",},
      {"category_id":20,"category_name":"underwater",},
      {"category_id":5,"category_name":"wildlife",},
    ];
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener((){
      print(_tabController.index);
      var map = _categories[_tabController.index];
      eventBus.emit("onTabChange",map["category_name"]);
      print(map);
      /*html("https://1x.com/photos/latest/" + map["category_name"],'\"')
          .then((list) {
            print(list);
        map["list"] = list;
        setState(() {});
      });*/
    });
  }

  api(){
    _dio.get("https://1x.com/backend/loadmore.php",);
  }

  Future html(url,nameEndQuot) async {
    List<Map> photos = List();
    Dio dio = Dio();
    Response response = await dio.get(url);
    String data = response.data;
    print("start");
    RegExp regExp = RegExp("\/images\/user.*?jpg");
    Iterable<Match> matches = regExp.allMatches(data);
    print(matches.length);
    for (Match m in matches) {
      Map map = Map();
      map["url"] = m.group(0);
      photos.add(map);
        //print(m.group(0));
    }
    print("end");
    print("start");
    regExp = RegExp("&copy;.*?"+nameEndQuot);
    Iterable<Match>  _matches = regExp.allMatches(data);
    for (int i=0;i<_matches.length;i++) {
      Match m = _matches.elementAt(i);
      Map map = photos[i];
      String name = m.group(0);
      map["author"] = name.substring(name.indexOf(" "),name.lastIndexOf(nameEndQuot)).trim();
      print(m.group(0));
    }
    print("end");
    //print(photos);
    return photos;
    setState(() {});
  }

  body(context) {
    return NestedScrollView(
      headerSliverBuilder: (buildContext, innerBoxIsScrolled) => <Widget>[
        SliverAppBar(
          pinned: true,
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
          children: _categories.map((Map map) {
            if(map.containsKey("list")){
              return Container(
                child: StaggeredGridView.countBuilder(
                    itemCount: map["list"].length,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    crossAxisCount: 2,
                    itemBuilder: (BuildContext buildContext, int index) =>
                        GestureDetector(child: Image.network(
                            "https://gallery.1x.com" +
                                map["list"][index]["url"]),
                          onTap: () {
                            Navigator.of(buildContext).push(MaterialPageRoute(
                                builder: (c) =>
                                    PhotoPage("https://gallery.1x.com" +
                                        map["list"][index]["url"])));
                          },),
                    staggeredTileBuilder: (index) => StaggeredTile.fit(1)),
              );
            }else {
              print("=====================================");
              if(map["category_id"] == 0){
                html("https://1x.com/","<")
                    .then((list) {
                  //_photos = list;
                  map["list"] = list;
                  setState(() {});
                });
              }else {
                return CategoryTab(map["category_name"], context);
              }
              return Container();
            }
          }).toList(),
        ),
      ),
    );
  }
}
