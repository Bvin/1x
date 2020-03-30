import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'event_bus_service.dart';
import 'gallary_page.dart';

class CategoryTab extends StatefulWidget{

  final cat;
  final rootContext;

  CategoryTab(this.cat,this.rootContext);

  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<CategoryTab>{

  List<Map> _photos = List();
  Dio _dio;
  String _sort = "latest";
  int _loadIndex = 0;
  ScrollController _scrollController;

  @override
  void initState() {
    _dio = Dio();
    _scrollController = ScrollController();
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        load();
        print("加载下一页");
      }

    });
    super.initState();
    eventBus.on("onTabChange", (arg) {
      if (arg == widget.cat) {
        load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        child: StaggeredGridView.countBuilder(
          key: PageStorageKey(widget.cat),
          controller: _scrollController,
          itemCount: _photos.length,
          crossAxisCount: 2,
          itemBuilder: (BuildContext buildContext, int index) {
            print(index);
            var url = "https://gallery.1x.com" + _photos[index]["url"];
            return GestureDetector(
              child: CachedNetworkImage(imageUrl: url,),
              onTap: () {
                Navigator.of(widget.rootContext).push(
                    MaterialPageRoute(
                        builder: (bc) => GalleryPage(_photos,index)
                    )
                );
              },
            );
          },
          staggeredTileBuilder: (index) => StaggeredTile.fit(1),
        ),
      ),
    );
  }

  Future<Null> _refreshData() async {
    _photos.clear();
    setState(() {});
    _loadIndex = 0;
    load();
  }

  load() async {
    Response response = await _dio.get("https://1x.com/backend/loadmore.php",
        queryParameters: {
          "app": "photos",
          "cat": widget.cat,
          "from": _loadIndex,
          "sort": _sort,
        }
    );
    List<Map> parsedPhotos = parse(response.data);
    _loadIndex += parsedPhotos.length;
    _photos.addAll(parsedPhotos);
    if(mounted) {
      setState(() {});
    }
  }

  parse(data){
    print("start");
    List<Map> photos = List();
    RegExp regExp = RegExp("\/images\/user.*?jpg");
    Iterable<Match> matches = regExp.allMatches(data);
    print(matches.length);
    for (Match m in matches) {
      Map map = Map();
      map["url"] = m.group(0);
      photos.add(map);
    }
    print("end");

    print("start");
    regExp = RegExp("&copy.*?<");
    Iterable<Match>  _matches = regExp.allMatches(data);
    for (int i=0;i<_matches.length;i++) {
      Match m = _matches.elementAt(i);
      Map map = photos[i];
      String name = m.group(0);
      map["author"] = name.substring(name.indexOf(" "),name.lastIndexOf("<")).trim();
      print(name);
    }
    print("end${_matches.length}");

    print("start");
    RegExp _regExp = RegExp("\/member\/.*?\"");
    Iterable<Match> __matches = _regExp.allMatches(data);
    for (int i=0;i<__matches.length;i++) {
      Match m = __matches.elementAt(i);
      Map map = photos[i];
      String name = m.group(0);
      map["memberid"] = name.substring(name.indexOf("/member/"),name.indexOf('"')).trim();
      //print(name);
    }
    print("end");
    return photos;
  }

}