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
    accentColor: Colors.white,
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
  TabController _tabController;
  bool _showLoading = false;

  @override
  void initState() {
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
      {"category_id":0,"category_name":"Home","display_name":"Home",},
      {"category_id":1,"category_name":"action","display_name":"Action",},
      {"category_id":2,"category_name":"macro","display_name":"Macro",},
      {"category_id":3,"category_name":"humour","display_name":"Humour",},
      {"category_id":4,"category_name":"mood","display_name":"Mood",},
      {"category_id":5,"category_name":"wildlife","display_name":"Wildlife",},
      {"category_id":6,"category_name":"landscape","display_name":"Landscape",},
      {"category_id":7,"category_name":"street","display_name":"Street",},
      {"category_id":8,"category_name":"documentary","display_name":"Documentary",},
      {"category_id":9,"category_name":"night","display_name":"Night",},
      {"category_id":10,"category_name":"creative-edit","display_name":"Creative Edit",},
      {"category_id":11,"category_name":"architecture","display_name":"Architecture",},
      {"category_id":12,"category_name":"fine-art-nude","display_name":"Fine-art-nude",},
      {"category_id":13,"category_name":"portrait","display_name":"Portrait",},
      {"category_id":14,"category_name":"everyday","display_name":"Everyday",},
      {"category_id":15,"category_name":"abstract","display_name":"Abstract",},

      {"category_id":17,"category_name":"conceptual","display_name":"Conceptual",},
      {"category_id":18,"category_name":"still-life","display_name":"Still-life",},
      {"category_id":19,"category_name":"performance","display_name":"Performance",},
      {"category_id":20,"category_name":"underwater","display_name":"Underwater",},
      {"category_id":21,"category_name":"animals","display_name":"Animals",},
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

  Future html(url,nameEndQuot) async {
    List<Map> photos = List();
    Dio dio = Dio();
    _showLoading = true;
    setState(() {});
    Response response = await dio.get(url, onReceiveProgress: (c,t){
      print("$c/$t");
    });
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
              padding: EdgeInsets.symmetric(vertical: 12,horizontal: 5),
              child: Text(map["display_name"],
                style: TextStyle(fontSize: 20),
              ),
            )).toList(),
          ),
        ),
      ],
      body: Stack(
        children:[
          TabBarView(
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
                  _showLoading = false;
                  setState(() {});
                });
              }else {
                return CategoryTab(map["category_name"], context);
              }
              return Container();
            }
          }).toList(),
        ),
          Center(
            child: Visibility(
              child: CircularProgressIndicator(),
              visible: _showLoading,
            ),
          )
        ],
      ),
    );
  }
}
