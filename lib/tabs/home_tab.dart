import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:onex/photo_page.dart';

class HomeTab extends StatefulWidget{

  final homeContext;

  HomeTab(this.homeContext);

  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<HomeTab> with SingleTickerProviderStateMixin{

  TabController _tabController;
  List<Map> tabs = [
    {"display":"POPULAR","name":"popular"},
    {"display":"AWARDED","name":"awarded"},
  ];
  bool _showLoading = false;

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() async {
      Map map = tabs[_tabController.index];
      String p = map["name"];
      map["list"] = await html(p);
      _showLoading = false;
      setState(() {});
    });
    loadDefaultTab(tabs[0]);
    super.initState();
  }


  loadDefaultTab(map) async {
    String p = map["name"];
    map["list"] = await html(p);
    _showLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (ctx, innerBoxIsScrolled) => <Widget>[
        SliverAppBar(
          title: TabBar(
            controller: _tabController,
            indicatorWeight: 1,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: tabs.map((map) => Text(map["display"], style: TextStyle(fontWeight: FontWeight.w300),)).toList(),
          ),
          actions: <Widget>[Icon(Icons.search)],
        )
      ],
      body: TabBarView(
          controller: _tabController,
          children: tabs.map((map) => grid(map["list"])).toList()
      ),
    );
  }

  Widget grid(list){
    if(list == null) return Container();
    return Stack(children: <Widget>[
      StaggeredGridView.countBuilder(
          itemCount: list.length,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          crossAxisCount: 2,
          itemBuilder: (BuildContext buildContext, int index) =>
              GestureDetector(child: Image.network(
                  "https://gallery.1x.com" +
                      list[index]["url"]),
                onTap: () {
                  Navigator.of(buildContext).push(MaterialPageRoute(
                      builder: (c) =>
                          PhotoPage("https://gallery.1x.com" +
                              list[index]["url"])));
                },),
          staggeredTileBuilder: (index) => StaggeredTile.fit(1)),
      loading(_showLoading)
    ],);
  }

  loading(show){
    return Center(
      child: Visibility(
        child: CircularProgressIndicator(),
        visible: show,
      ),
    );
  }

  Future html(p) async {
    List<Map> photos = List();
    Dio dio = Dio();
    _showLoading = true;
    setState(() {});
    Response response = await dio.get("https://1x.com/", queryParameters: {"p":p});
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
    var nameEndQuot = '<';
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
    return photos;
  }
}