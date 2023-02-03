import 'package:blinkid_flutter/microblink_scanner.dart' as blinkid;
import 'package:blinkid_flutter/overlay_settings.dart';
import 'package:blinkid_flutter/recognizer.dart' as blinkidRecognizer;
import 'package:blinkid_flutter/overlays/blinkid_overlays.dart';
import 'package:blinkid_flutter/recognizers/blink_id_recognizer.dart';
import 'package:flutter/material.dart';
import 'package:blinkcard_flutter/microblink_scanner.dart' as blinkcard;
import 'package:blinkcard_flutter/overlay_settings.dart';
import 'package:blinkcard_flutter/overlays/blinkcard_overlays.dart';
import 'package:blinkcard_flutter/recognizer.dart' as blinkcardRecognizer;
import 'package:blinkcard_flutter/recognizers/blink_card_recognizer.dart';
import 'package:blinkcard_flutter/types.dart';
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
  String _documentNumber = "";
  String _cardNumber = "";
  String _ownerName = "";

  void scanDocument() async {
    String license;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      license =
      "sRwAAAEeY29tLmV0aGlvcGlhbmFpcmxpbmVzLmV0bW9iaWxlYL37NAHJujK9V1S/8gbr+iOXC/74pcSYaSG4FMLyiszGQF7CILqDrtR0M84lLGuV7Zw2eb2nEaSbRiAnOHvAt2vfbRH+TFGm0TvWDoHogHnh9/ODJC1X9bouYS3ua4ylCQ9hFUQP8PEfmHjTu0INjaGZ6+foOY3zsX6K3tw8tXKNot99jKDB6Iuy";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      license =
      'sRwAAAAnY29tLmV0aGlvcGlhbmFpcmxpbmVzLmV0aGlvcGlhbmFpcmxpbmVztjdiLN/+l4a6ug+S6Kg70FUGs9B5LvlUz0HbB3uU2o2Vxlawd1+r9t+4cy+JBO5opNpHeDfC6na3h045O8U+x6uy9IHy1EF3C78lXhlj9PIHWTc+F7k2aIq8vLP2iLPcDH6wfRsntVHNAlseP9OAKLdrY8xzlUtuPy6+ULM+DQzFMUUGb2YExHtk';
    } else {
      license = "";
    }
    var idSingleSideRecognizer = BlinkIdRecognizer();

    var settings = DocumentVerificationOverlaySettings()..enableBeep = true;

    try {
      var results = await blinkid.MicroblinkScanner.scanWithCamera(
          blinkidRecognizer.RecognizerCollection([idSingleSideRecognizer]),
          settings,
          license);

      if (!mounted) return;

      if (results.length == 0) return;
      for (var result in results) {
        if (result is BlinkIdRecognizerResult) {
          setState(() {
            _firstName = result.firstName ?? "";
            _lastName = result.lastName ?? "";
            _documentNumber= result.documentNumber ?? "";
          });

          return;
        }
      }
    } catch (ex, stack) {}
    return null;
  }

  void scanCreditCard() async {
    String license;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      license =
      "sRwAAAEeY29tLmV0aGlvcGlhbmFpcmxpbmVzLmV0bW9iaWxlYL37NAHJujK9Vyw/8wHr+sNTGHvJ1fZJowVaUSyJmJGQlEcaTAB6RAqzdI/YgD6Ax40L1Ha4YZkrt5D0THW8RrJKfw1gMI1CkoYNZGS3BkFgZnFVYYU4wAzIQTIDdcfitj719u38yWSkPzDBQMLbbdiZuJsmFqJz/D8GanUZvVcxObnv5Tv/";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      license =
      "sRwAAAAnY29tLmV0aGlvcGlhbmFpcmxpbmVzLmV0aGlvcGlhbmFpcmxpbmVztjdiLN/+l4a6uncS6a870LCKooP4eju4kWY3E0FYeVY0apCRybQNFqfA5lOv4sRS8/5S8TcmfFwlqzrtA6HKjMFXEr/PqyN3g+D8USpwJcL0SgZlHAfrTQHgrKoy0pitLh2VaX2D5V7DcEVT20ZX0Wj7UFHn9swDe9JrF9oA+HfygcVJAOLy";
    } else {
      license = "";
    }
    CardNumberAnonymizationSettings? cardNumberAnonymizationSettings =
    CardNumberAnonymizationSettings()
      ..mode = BlinkCardAnonymizationMode.FullResult;

    BlinkCardAnonymizationSettings blinkCardAnonymizationSettings =
    BlinkCardAnonymizationSettings()
      ..cvvAnonymizationMode = BlinkCardAnonymizationMode.FullResult
      ..cardNumberAnonymizationSettings = cardNumberAnonymizationSettings
      ..cardNumberPrefixAnonymizationMode =
          BlinkCardAnonymizationMode.FullResult;

    var cardRecognizer = BlinkCardRecognizer()
      ..returnFullDocumentImage = true;

    BlinkCardOverlaySettings settings = BlinkCardOverlaySettings()
      ..firstSideInstructions = 'Place front side of payment card'
      ..flipCardInstructions = 'Place back side of payment card'
      ..enableBeep = true;

    try {
      var results = await blinkcard.MicroblinkScanner.scanWithCamera(
          blinkcardRecognizer.RecognizerCollection([cardRecognizer]),
          settings,
          license);

      if (results.isEmpty) return null;
      for (var result in results) {
        if (result is BlinkCardRecognizerResult) {
          setState(() {
            _cardNumber = (result.cardNumber?.contains(" ") ?? false
                ? result.cardNumber?.replaceAll(" ", "")
                : result.cardNumber) ??
                "";
            _ownerName =  result.owner ?? "";

          });

        }
      }
    } catch (ex, stack) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget scannedIdentityDocument = Container();
    Widget scannedPaymentCard = Container();
    if (_firstName != null && _lastName != "") {
      scannedIdentityDocument = Column(
        children: <Widget>[
          const Text("Full name:"),
          Text("$_firstName $_lastName"),
          const Text("Document number"),
          Text(_documentNumber),
        ],
      );
    }
    if(_ownerName !=null && _cardNumber != null){
      scannedPaymentCard = Column(
        children: <Widget>[
          const Text("Full name:"),
          Text(_ownerName),
          const Text("Card number"),
          Text(_cardNumber),
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
                        child: const Text("Scan document"),
                        onPressed: () => scanDocument(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton(
                        child: const Text("Scan payment card"),
                        onPressed: () => scanCreditCard(),
                      ),
                    ),
                    scannedIdentityDocument,
                    const SizedBox(height: 10,),
                    scannedPaymentCard,
                  ],
                ),
              )),
        ));
  }
}
