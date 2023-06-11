import 'package:alan_voice/alan_voice.dart';
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
  MyRadio? selectedRadio;
  Color? selectedColor;
  bool isPlaying = false;

  // Initialization of AudioPlayer library
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();
    setupAlan();

    // Listener to play or pause
    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        isPlaying = true;
      } else {
        isPlaying = false;
      }
      setState(() {});
    });
  }

  // Method to fetch radios from API
  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");

    // Then we get it fromJson method from the list of MyRadio
    radios = MyRadioList.fromJson(radioJson).radios;
    selectedRadio = radios[0];
    selectedColor = Color(int.parse(selectedRadio!.color));
    print(radios);
    setState(() {});
  }

  // Method to play music from URL
  playMusic(String url) {
    audioPlayer.play(UrlSource(url));
    selectedRadio = radios.firstWhere((element) => element.url == url);
    print(selectedRadio!.name);
    setState(() {});
  }

  setupAlan() {
    AlanVoice.addButton(
        "1d1891c7b42ae6e8dd60affc3aa8530a2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) {
      handleCommand(command.data);
    });
  }

  handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        playMusic(selectedRadio!.url);

        break;
      default:
        print("Command was ${response['command']}");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [
      Pallete.secondaryColor,
      selectedColor ??
          Pallete.primaryColor // if its null it will go Pallete.primaryColor,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              // fit: StackFit.expand,
              children: [
                radios.isNotEmpty
                    ? CarouselSlider.builder(
                        itemCount: radios.length,
                        itemBuilder: (context, index, realIndex) {
                          final rad = radios[index];
                          return GestureDetector(
                            onTap: () {
                              audioPlayer.stop();
                              print("Single Tapped!");
                            },
                            onDoubleTap: () {
                              playMusic(rad.url);
                              print("Double tapped!");
                            },
                            child: AnimatedContainer(
                              duration: const Duration(seconds: 1),
                              // padding: const EdgeInsets.all(16),
                              // margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                border:
                                    Border.all(color: Colors.black, width: 5),
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
                                          bottomRight:
                                              const Radius.circular(10),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                            onPageChanged: (index, reason) {
                              final colorHex = radios[index].color;
                              selectedColor = Color(int.parse(colorHex));
                              setState(() {});
                            }),
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          color: Pallete.whiteColor,
                        ),
                      ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  isPlaying
                      ? Center(
                          child: Text(
                            "Playing now - ${selectedRadio!.name} FM",
                            style: TextStyle(
                              color: Pallete.whiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const Text(""),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        audioPlayer.stop();
                      } else {
                        playMusic(selectedRadio!.url);
                      }
                    },
                    child: Icon(
                      isPlaying
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outlined,
                      color: Pallete.whiteColor,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
