import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtubedl/network_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var percent = 0.00;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var url = "";
  bool isDownloading = false;
  var _percent = 0.00;
  String message = 'Please enter a link \nand click on \nDownload';

  @override
  Widget build(BuildContext context) {
    //Fuction to Download and merge audio video
    void download({String audioUrl, String vedioUrl, String title}) async {
      print("Downloading....");
      title = title.replaceAll("|", "").replaceAll(" ", "");
      var status = await Permission.storage.request();
      HomePage homePage = HomePage();
      var loc = await getExternalStorageDirectory();
      Dio dio = Dio();

      await dio.download(audioUrl, '/storage/emulated/0/Download/${title}.m4a',
          onReceiveProgress: (actualBytes, totalbytes) {
        setState(() {
          _percent = (actualBytes / totalbytes * 100);
          message =
              'fetching Audio...${(actualBytes / totalbytes * 100).toStringAsPrecision(4)}%';
        });
        print(
            '${(actualBytes / pow(2, 20)).toStringAsFixed(2)} out of ${(totalbytes / pow(2, 20)).round()} MB');
      });
      print("Audio Downloaded!");
      await dio.download(vedioUrl, '/storage/emulated/0/Download/${title}.mp4',
          onReceiveProgress: (actualBytes, totalbytes) {
        setState(() {
          _percent = (actualBytes / totalbytes * 100);
          message = 'downloading Video...${_percent.toStringAsPrecision(4)}%';
        });
        //print(_percent.toStringAsPrecision(2));
        print(
            '${(actualBytes / pow(2, 20)).toStringAsFixed(2)} out of ${(totalbytes / pow(2, 20)).round()} MB');
      });
      print('Video Done!!');

      FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
      await flutterFFmpeg.execute(
          "-i /storage/emulated/0/Download/${title}.mp4 -i /storage/emulated/0/Download/${title}.m4a -c copy /storage/emulated/0/Download/${title.toString()}.mkv");
      var dir = Directory("/storage/emulated/0/Download/$title.mp4");
      dir.deleteSync(recursive: true);
      setState(() {
        message = "Done!!! enjoy your video ;-)";
      });
      isDownloading = false;
    }

    var tempColor = Colors.redAccent[100];
    return Scaffold(
      appBar: AppBar(
        title: Text("Youtube-dl"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [tempColor = Colors.redAccent[100], Colors.white],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  hintText: "Enter link",
                  labelText: "Link",
                ),
                onChanged: (value) {
                  url = value;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 35,
              child: RaisedButton(
                elevation: 10,
                onPressed: () async {
                  setState(() {
                    isDownloading = !isDownloading;
                  });
                  if (url.isNotEmpty && url.length > 17) {
                    NetworkHelper networkhelper = NetworkHelper(url: url);
                    var vedioData = await networkhelper.getVedioData();
                    download(
                      title: vedioData['title'],
                      audioUrl: vedioData['audiolink'],
                      vedioUrl: vedioData['videolink'],
                    );
                  }
                },
                child: Text(
                  "Download",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                color: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.redAccent[100],
                value: _percent / 100, //Works on 0 to 1 => 0% to 100%
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              message,
              textScaleFactor: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}

//https://youtu.be/gzmXpwF_MK4
