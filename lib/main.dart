import 'package:aws_polly/aws_polly.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pain_scale/widgets/slider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

// { "name": "John" }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference ref = FirebaseDatabase.instance.ref("scale");
  String imageUrl = "https://media.giphy.com/media/4p1JhLCYEOEJa/giphy.gif";
  String rating = "0";
  String painLevel = "No Pain";
  String _url = "";

  final AwsPolly _awsPolly = AwsPolly.instance(
    // put your poolId from AWS here
    poolId: 'us-east-1:xxxx-xxx-xxxxx',
    region: AWSRegionType.USEast1,
  );

  void onLoadUrl() async {
    // setState(() => _url = "");
    final url = await _awsPolly.getUrl(
      voiceId: AWSPolyVoiceId.kimberly,
      input: 'Your Score is $painLevel',
    );
    setState(() => _url = url);
  }

  void onPlay() async {
    if (_url == "") return;
    final player = AudioPlayer();
    await player.setUrl(_url);
    player.play();
  }

  @override
  void initState() {
    // getImage();
    super.initState();
  }

  void getImage() async {
    // Get the data once
    DatabaseEvent event = await ref.once();

    // Print the data of the snapshot
    for (var element in event.snapshot.children) {
      if (element.key! == rating) {
        for (var key in element.children) {
          if (key.key! == "image_url") {
            setState(() {
              imageUrl = key.value.toString();
            });
          } else if (key.key! == "rating") {
            setState(() {
              painLevel = key.value.toString();
              onLoadUrl();
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(children: [
          SLider(
            scaleLevel: painLevel,
            imageUrl: imageUrl,
          ),
          SliderTheme(
              data: SliderTheme.of(context).copyWith(
                  trackHeight: 15,
                  overlayColor: Colors.transparent,
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 10,
                    disabledThumbRadius: 10,
                  )),
              child: Slider(
                label: rating,
                min: 0.0,
                max: 10.0,
                value: double.parse(rating),
                onChanged: (val) {
                  setState(() {
                    rating = val.toInt().toString();
                    getImage();
                  });
                  {}
                },
              )),
          ElevatedButton(onPressed: onPlay, child: const Text("Submit"))
        ]));
  }
}
