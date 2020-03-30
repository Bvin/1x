import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoViewGallery.builder(
          pageController: PageController(initialPage: widget.position),
          itemCount: widget.photos.length,
          builder: (BuildContext context, int index) {
            var url = widget.photos[index]["url"];
            url = "https://gallery.1x.com" + url.replaceAll("ld", "hd4");
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(url),
            );
          }
      ),
    );
  }

}