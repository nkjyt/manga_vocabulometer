/*
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:zoom_widget/zoom_widget.dart';

class textBox extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return textBoxState();
  }
}

class textBoxState extends State<StatefulWidget>{

  PhotoViewScaleStateController scaleStateController = PhotoViewScaleStateController();

  var height;
  var width;
  _onTap() {
    setState(() {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    });
    print(width/height);
    print("width:${width-40}");
    print("height:${height-170}");
    double height_cut = (height-1.5*width)/2;
    var width_cut = (3*width-2*(height-height_cut*2))/6;
    print(width_cut);


    print(3*width);
    print('height');
    print(width-(height-height_cut*2)*2/3);
  }

  _callback() {
    print(scaleStateController.scaleState);
    print("aa");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: <Widget>[
          Zoom(
            width: MediaQuery.of(context).size.width*1.0,
            height: MediaQuery.of(context).size.height*1.0,
            child: Container(
              child: Stack(
                children: <Widget>[
                  //Center(child: Image.asset('assets/0001.png')),
                  Center(child: PhotoView(
                    imageProvider: AssetImage("assets/0001.png"),
                    scaleStateController: scaleStateController,
                    scaleStateChangedCallback: _callback(),
                    maxScale: PhotoViewComputedScale.covered * 1.5,
                    minScale: PhotoViewComputedScale.contained,
                  )),
                  Positioned(
                    top:  (MediaQuery.of(context).size.height+170)*0.16,
                    left: MediaQuery.of(context).size.width*0.69,
                    height:  MediaQuery.of(context).size.height*0.05,
                    width:  MediaQuery.of(context).size.width*0.08,
                    child: Container(
                      color: Colors.red.withOpacity(0.6),
                    ),
                  ),
                  Positioned(
                    top:  (MediaQuery.of(context).size.height+170)*0.37,
                    left: MediaQuery.of(context).size.width*0.74,
                    height:  MediaQuery.of(context).size.height*0.1,
                    width:  MediaQuery.of(context).size.width*0.12,
                    child: Container(
                      color: Colors.red.withOpacity(0.6),
                    ),
                  ),
                  Positioned(
                    top:  (MediaQuery.of(context).size.height+170)*0.31,
                    left: MediaQuery.of(context).size.width*0.33,
                    height:  MediaQuery.of(context).size.height*0.02,
                    width:  MediaQuery.of(context).size.width*0.08,
                    child: Container(
                      color: Colors.red.withOpacity(0.6),
                    ),
                  ),
                  Positioned(
                    top:  85+(MediaQuery.of(context).size.height-170)*0.44,
                    left: MediaQuery.of(context).size.width*0.08,
                    height:  MediaQuery.of(context).size.height*0.20,
                    width:  MediaQuery.of(context).size.width*0.10,
                    child: Container(
                      color: Colors.red.withOpacity(0.6),
                    ),
                  ),
                  Positioned(
                    top: 85,
                    left: 20,
                    height:  MediaQuery.of(context).size.height-170,
                    width:  MediaQuery.of(context).size.width-40,
                    child: Container(
                      color: Colors.red.withOpacity(0.6),
                    ),
                  ),
                  FlatButton(
                    onPressed: _onTap(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}*/
