import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;

class FollowsTab extends StatefulWidget{

  final userid;

  FollowsTab(this.userid);

  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}
class TabState extends State<FollowsTab>{

  List<Map> _members = List();
  Dio _dio;
  String _sort = "following";
  int _loadIndex = 0;
  ScrollController _scrollController;
  bool _showLoading = false;

  @override
  void initState() {
    _dio = Dio();
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return followsTab(_members);
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

  Future<Null> _refreshData() async {
    _loadIndex = 0;
    load();
  }

  load() async {
    if(_loadIndex == 0){
      _showLoading = true;
      setState(() {});
    }
    Response response = await _dio.get("https://1x.com/backend/loadmore.php?app=members&from=0&userid=590298&sort=following",
    );
    List<Map> parsedPhotos = parse(response.data);
    _loadIndex += parsedPhotos.length;
    _members.addAll(parsedPhotos);
    _showLoading = false;
    if(mounted) {
      setState(() {});
    }
  }

  parse(data){
    print(data);
    html.Document document = html.Document.html(data);
    List<html.Element> element = document.getElementsByClassName("members_name");
    print(element);

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

  @override
  bool get wantKeepAlive => true;

}