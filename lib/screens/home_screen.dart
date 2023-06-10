import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:virtual_assistant/models/radio.dart';
import 'package:virtual_assistant/utils/ai_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // We initialize the list of radios
  List<MyRadio> radios = [];
  late MyRadio selectedRadio;
  late Color selectedColor;
  bool isPlaying = false;

  // Initialization of AudioPlayer library
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();

    // Listener to play or pause
    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        isPlaying = true;
      } else {
        isPlaying = false;
      }
    });
  }

  // Method to fetch radios from API
  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    // final jsonData = json.decode(radioJson);
    // Then we get it fromJson method from the list of MyRadio
    radios = MyRadioList.fromJson(radioJson).radios;
    print(radios);
    setState(() {});
  }

  // Method to play music from URL
  playMusic(String url) {
    audioPlayer.play(UrlSource(url));
    selectedRadio = radios.firstWhere((element) => element.url == url);
    print(selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [
      Pallete.primaryColor,
      Pallete.secondaryColor,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const Drawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Shimmer.fromColors(
            baseColor: Pallete.whiteColor,
            highlightColor: Pallete.secondaryColor,
            child: Text(
              "AI Radio",
              style: TextStyle(
                color: Pallete.whiteColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Stack(
              // fit: StackFit.expand,
              children: [
                CarouselSlider.builder(
                  itemCount: radios.length,
                  itemBuilder: (context, index, realIndex) {
                    final rad = radios[index];
                    return GestureDetector(
                      onDoubleTap: () {
                        playMusic(rad.url);
                        print("Double tapped!");
                      },
                      child: Container(
                        // padding: const EdgeInsets.all(16),
                        // margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(color: Colors.black, width: 5),
                          image: DecorationImage(
                            image: NetworkImage(rad.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.4),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.circular(16).copyWith(
                                    topRight: const Radius.circular(50),
                                    bottomRight: const Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  rad.category.toUpperCase(),
                                  style: TextStyle(
                                    color: Pallete.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    rad.name,
                                    style: TextStyle(
                                      color: Pallete.whiteColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    rad.tagline,
                                    style: TextStyle(
                                      color: Pallete.whiteColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_outline,
                                    color: Pallete.whiteColor,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Double tap to play",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: false,
                    enlargeCenterPage: true,
                    aspectRatio: 1.1,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                isPlaying == true
                    ? Center(
                        child: Text(
                          "Playing now - ${selectedRadio.name}",
                          style: TextStyle(
                            color: Pallete.whiteColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    : const Text(""),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .2),
                  child: InkWell(
                    onTap: () {
                      if (isPlaying) {
                        audioPlayer.stop();
                      } else {
                        playMusic(selectedRadio.url);
                      }
                    },
                    child: Icon(
                      isPlaying
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      color: Pallete.whiteColor,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
