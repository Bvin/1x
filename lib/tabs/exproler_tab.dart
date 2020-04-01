import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onex/category_tab.dart';

class ExploreTab extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<ExploreTab> with SingleTickerProviderStateMixin{

  List<Map> _categories;
  TabController _tabController;

  @override
  void initState() {
    _categories = <Map>[
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (ctx, innerBoxIsScrolled) => <Widget>[
        SliverAppBar(
          title: tabBar(),
        )
      ],
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((map) => CategoryTab(map["category_name"], context)).toList(),
      ),
    );
  }

  tabBar(){
    return TabBar(
      controller: _tabController,
      indicatorWeight: 1,
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: _categories.map((map) => Text(map["display_name"], style: TextStyle(fontWeight: FontWeight.w300),)).toList(),
    );
  }

}
