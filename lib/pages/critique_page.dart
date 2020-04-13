import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:html/dom.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';

import '../photo_page.dart';

class CritiquePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<CritiquePage>{

  Dio _dio;
  List<Map> _photos;
  int _loadIndex = 0;
  bool _showLoading = false;
  ScrollController _scrollController;

  @override
  void initState() {
    _dio = Dio();
    _photos = List();
    _dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
    _scrollController = ScrollController();
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        load();
        print("加载下一页");
      }
    });
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(_photos == null){
      return Center(
        child: Visibility(
          child: CircularProgressIndicator(),
          visible: _showLoading,
        ),
      );
    }
    return grid();
  }

  load() async {
    Response response = await _dio.get(
        "https://1x.com/backend/loadmore.php",
        queryParameters: {
          "app": "critique",
          "from": _loadIndex,
          "cat": "critique",
          "sort": "latest",
          "userid": 0
        },
        options: buildCacheOptions(Duration(minutes: 30)));
    XmlDocument xmlDocument = xml.parse(response.data);
    Document html = Document.html(xmlDocument.children[1].text);
    html.getElementsByClassName("photos_rendertable_photo").forEach((e){
      Map map = Map();
      map["img"] = "https://gallery.1x.com"+e.attributes["src"].toString();
      map["url"] = e.parent.attributes["href"];
      _photos.add(map);
      _loadIndex++;
    });
    setState(() {});
  }

  grid(){
    return StaggeredGridView.countBuilder(
      controller: _scrollController,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      crossAxisCount: 2,
      itemCount: _photos.length,
      itemBuilder: (ctx,index)=> GestureDetector(
        child: CachedNetworkImage(imageUrl: _photos[index]["img"]),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PhotoPage(_photos[index]["img"])));
        },
      ),
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
  }

}