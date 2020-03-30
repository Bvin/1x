import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'member_page.dart';

class GalleryPage extends StatefulWidget{

  final List<Map> photos;
  final int position;

  GalleryPage(this.photos, this.position);


  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}
class PageState extends State<GalleryPage>{

  PageController _pageController;
  String _name = "";
  String _memberId;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.position);
    _pageController.addListener((){
      int index = _pageController.page.floor();
      _name = widget.photos[index]["author"];
      _memberId = widget.photos[index]["memberid"];
      setState(() {});
    });
    _name = widget.photos[widget.position]["author"];
    print(_name);
    _memberId = widget.photos[widget.position]["memberid"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Stack(
      children: <Widget>[
        PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.photos.length,
            builder: (BuildContext context, int index) {
              var url = widget.photos[index]["url"];
              url = "https://gallery.1x.com" + url.replaceAll("ld", "hd4");
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(url),
              );
            }
        ),
        Container(
          margin: EdgeInsets.only(bottom: 25),
          child: ListTile(
          leading: GestureDetector(child: Icon(Icons.keyboard_backspace),onTap: (){
            Navigator.of(context).pop();
          },),
          title: GestureDetector(child: Text(_name, ), onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder:
                (ctx) => MemberPage(_memberId, _name)
            ));
          },),
          trailing: GestureDetector(child: Icon(Icons.favorite_border),),
        ),
        )
      ] ,
      alignment: Alignment.bottomCenter,
    ),),theme: ThemeData.dark(),);
  }

}