
import 'package:flutter/material.dart';

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
    return Image.network(widget.url.replaceAll("ld", "hd4"));
  }

}