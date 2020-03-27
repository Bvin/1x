
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPage extends StatefulWidget{

  final String url;

  PhotoPage(this.url);

  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<PhotoPage>{
  @override
  Widget build(BuildContext context) {
    return PhotoView(imageProvider: NetworkImage(widget.url.replaceAll("ld", "hd4")),);
  }

}