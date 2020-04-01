import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../photo_page.dart';

class MineTab extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<MineTab> with SingleTickerProviderStateMixin{

  TabController _tabController;
  List<Map> tabs = [
    {"display":"Following","name":"following"},
    {"display":"Favorites","name":"favorites"},
    {"display":"History","name":"history"},
  ];
  bool _showLoading = false;

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
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
        )
      ],
      body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            followsTab(tabs[0]["list"]),
            favoriteTab(tabs[1]["list"]),
            historyTab()
          ]
      ),
    );
  }

  followsTab(List<Map> members){
    if(members == null) return Container();
    return Stack(children: <Widget>[
      ListView.builder(
        itemCount: members.length,
          itemBuilder: (ctx, index) => ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(members[index]["img"]),),
            title: Text(members[index]["name"]),
          )
      ),
    ],);
  }

  favoriteTab(List<Map> list){
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
      ]);
  }

  historyTab(){
    return Container();
  }

  loading(show){
    return Center(
      child: Visibility(
        child: CircularProgressIndicator(),
        visible: show,
      ),
    );
  }
}