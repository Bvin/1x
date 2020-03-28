import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CategoryTab extends StatefulWidget{

  final cat;

  CategoryTab(this.cat);

  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<CategoryTab>{

  List<Map> _photos = List();
  Dio _dio;
  String _sort = "latest";
  int _pageIndex = 0;

  @override
  void initState() {
    _dio = Dio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StaggeredGridView.countBuilder(
        itemCount: _photos.length,
          crossAxisCount: 2,
          itemBuilder: (BuildContext buildContext, int index) {
            var url = "https://gallery.1x.com" + _photos[index]["url"];
            return GestureDetector(
              child: CachedNetworkImage(imageUrl: url,),
              onTap: () {

              },
            );
          },
          staggeredTileBuilder: (index) => StaggeredTile.fit(1),
      ),
    );
  }

  load() async {
    Response response = await _dio.get("https://1x.com/backend/loadmore.php",
        queryParameters: {
          "app": "photos",
          "cat": widget.cat,
          "from": _pageIndex,
          "sort": _sort,
        }
    );
    List<Map> parsedPhotos = parse(response.data);
    _photos.addAll(parsedPhotos);
    setState(() {});
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
    regExp = RegExp("&copy;.*?<");
    Iterable<Match>  _matches = regExp.allMatches(data);
    for (int i=0;i<_matches.length;i++) {
      Match m = _matches.elementAt(i);
      Map map = photos[i];
      String name = m.group(0);
      map["author"] = name.substring(name.indexOf(" "),name.lastIndexOf("<")).trim();
      print(m.group(0));
    }
    print("end");
    return photos;
  }

}