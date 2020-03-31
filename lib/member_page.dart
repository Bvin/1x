import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'gallary_page.dart';

class MemberPage extends StatefulWidget{

  final memberId;
  final name;

  MemberPage(this.memberId, this.name);

  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<MemberPage>{

  String backgroundImage;
  String avatar;

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
    loadMember();
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: body(),
      ),
      theme: ThemeData.dark(),
    );
  }

  body() {
    return NestedScrollView(
      headerSliverBuilder: (buildContext, innerBoxIsScrolled) => <Widget>[
        SliverAppBar(
          title: Text(widget.name),
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            title: avatar == null ? Container() : CircleAvatar(
              child: CachedNetworkImage(imageUrl: avatar,),),
            background: backgroundImage == null ? Container(): CachedNetworkImage(
                imageUrl: backgroundImage,
                fit: BoxFit.fitHeight,
              ),
          ),
        ),
      ],
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child:  StaggeredGridView.countBuilder(
              key: PageStorageKey(widget.memberId),
              itemCount: _photos.length,
              crossAxisCount: 2,
              itemBuilder: (BuildContext buildContext, int index) {
                print(index);
                var url = "https://gallery.1x.com" + _photos[index]["url"];
                return GestureDetector(
                  child: CachedNetworkImage(imageUrl: url,),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (bc) => GalleryPage(_photos, index)
                        )
                    );
                  },);
              },
              staggeredTileBuilder: (index) => StaggeredTile.fit(1),
            ),
    ));
  }


  Future<Null> _refreshData() async {
    _photos.clear();
    setState(() {});
    _loadIndex = 0;
    load();
  }

  loadMember() async {
    print(widget.memberId);
    Response response = await _dio.get("https://1x.com${widget.memberId}");
    String data = response.data;
    RegExp regExp = RegExp("\/images\/profile.*?jpg");
    Match cover = regExp.firstMatch(data);
    avatar = "https://gallery.1x.com"+cover.group(0);
    print(avatar);

    regExp = RegExp("\/images\/cover.*?jpg");
    Match profile = regExp.firstMatch(data);
    if (profile != null) {
      backgroundImage = "https://gallery.1x.com" + profile.group(0);
      print(backgroundImage);
    }
    setState(() {});
  }

  load() async {
    Response response = await _dio.get("https://1x.com/backend/loadmore.php",
        queryParameters: {
          "app": "photos",
          "userid": widget.memberId,
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
    }
    print("end");
    return photos;
  }
}