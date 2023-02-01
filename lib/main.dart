import 'package:blinkid_flutter/microblink_scanner.dart';
import 'package:blinkid_flutter/overlay_settings.dart';
import 'package:blinkid_flutter/recognizer.dart';
import 'package:blinkid_flutter/overlays/blinkid_overlays.dart';
import 'package:blinkid_flutter/recognizers/blink_id_recognizer.dart';
import 'package:flutter/material.dart';
import "dart:convert";
import "dart:async";

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _firstName = "";
  String _lastName = "";
 void scan() async {
   String license;
   if (Theme.of(context).platform == TargetPlatform.iOS) {
     license =
     "sRwAAAEeY29tLmV0aGlvcGlhbmFpcmxpbmVzLmV0bW9iaWxlYL37NAHJujK9V1S/8gbr+iOXC/74pcSYaSG4FMLyiszGQF7CILqDrtR0M84lLGuV7Zw2eb2nEaSbRiAnOHvAt2vfbRH+TFGm0TvWDoHogHnh9/ODJC1X9bouYS3ua4ylCQ9hFUQP8PEfmHjTu0INjaGZ6+foOY3zsX6K3tw8tXKNot99jKDB6Iuy";
   }  else {
     license = "";
   }
    var idSingleSideRecognizer = BlinkIdRecognizer();

    // var settings = DocumentOverlaySettings()..enableBeep = true;
    var settings = DocumentVerificationOverlaySettings()
      ..enableBeep = true;

    try {
      var results = await MicroblinkScanner.scanWithCamera(
          RecognizerCollection([idSingleSideRecognizer]),
          settings,
          license);

      if (!mounted) return;

    if (results.length == 0) return;
    for (var result in results) {
      if (result is BlinkIdRecognizerResult) {

        setState(() {
          _firstName = result.firstName ?? "";
          _lastName= result.lastName ?? "";
        });

        return;
      }
    }

    } catch (ex, stack) {
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    Widget fullDocumentFirstImage = Container();
    if (_firstName != null &&
        _lastName != "") {
      fullDocumentFirstImage = Column(
        children: <Widget>[
          const Text("Document First Name:"),
          Text(_firstName ),

        ],
      );
    }

    Widget fullDocumentSecondImage = Container();
    if (_firstName != null &&
        _lastName != "") {
      fullDocumentSecondImage = Column(
        children: <Widget>[
          const Text("Document Last Name:"),
          Text(_lastName)
        ],
      );
    }

    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text("BlinkId Sample"),
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ElevatedButton(
                          child: const Text("Scan"),
                          onPressed: () => scan(),
                        )),

                    fullDocumentFirstImage,
                    fullDocumentSecondImage,
                  ],
                ),
              )),
        ));
  }
}
