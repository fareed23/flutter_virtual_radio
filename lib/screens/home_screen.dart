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
  // Suggestions for the user hard-coded; you can use API for it
  final sugg = [
    "Play",
    "Play pop music",
    "Stop",
    "Play rock music",
    "Play 1-7 FM",
    "Play next",
    "Play 104 FM",
    "Pause",
    "Play previous",
  ];

  final randomColors = [
    const Color.fromARGB(255, 147, 45, 37),
    const Color.fromARGB(255, 36, 87, 128),
    const Color.fromARGB(255, 126, 185, 127),
    const Color.fromARGB(255, 79, 77, 58),
    const Color.fromARGB(255, 44, 79, 76),
    const Color.fromARGB(255, 216, 204, 165),
    const Color.fromARGB(255, 191, 90, 90),
    const Color.fromARGB(255, 125, 94, 203),
    const Color.fromARGB(255, 215, 107, 199),
    const Color.fromARGB(255, 206, 155, 75),
  ];

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

      case "play_channel":
        final id = response['id'];
        audioPlayer.pause();
        MyRadio newRadio = radios.firstWhere((element) => element.id == id);
        radios.remove(newRadio);
        radios.insert(0, newRadio);
        playMusic(newRadio.url);
        break;
      case "stop":
        audioPlayer.stop();
        break;
      case "next":
        final index = selectedRadio!.id;
        MyRadio newRadio;
        if (index + 1 > radios.length) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index + 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        playMusic(newRadio.url);
        break;

      case "prev":
        final index = selectedRadio!.id;
        MyRadio newRadio;
        if (index - 1 <= 0) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index - 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        playMusic(newRadio.url);
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
        drawer: Drawer(
          elevation: 0,
          backgroundColor: selectedColor ?? Pallete.secondaryColor,
          // ignore: unnecessary_null_comparison
          child: radios != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(top: 50, left: 20, bottom: 20),
                      child: Text(
                        "All Channels",
                        style:
                            TextStyle(color: Pallete.whiteColor, fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: radios
                            .map(
                              (e) => ListTile(
                                leading: CircleAvatar(
                                    backgroundImage: NetworkImage(e.icon)),
                                title: Text(
                                  '${e.name} FM',
                                  style: TextStyle(color: Pallete.whiteColor),
                                ),
                                subtitle: Text(
                                  e.tagline,
                                  style: TextStyle(color: Pallete.whiteColor),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                )
              : const Offstage(),
        ),
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
            // Text -> Start with - Hey Alan
            Container(
              margin: const EdgeInsets.only(top: 30, bottom: 30),
              padding: EdgeInsets.zero,
              child: Text(
                "Start with - Hey Alan 👇",
                style: TextStyle(
                  color: Pallete.whiteColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CarouselSlider.builder(
                  itemCount: sugg.length,
                  itemBuilder: (context, index, realIndex) {
                    final su = sugg[index];
                    return Chip(
                      label: Text(su),
                      backgroundColor: randomColors[index],
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    height: 50,
                    viewportFraction: 0.35,
                    autoPlayAnimationDuration: const Duration(seconds: 3),
                    autoPlayCurve: Curves.linear,
                    enableInfiniteScroll: true,
                    pauseAutoPlayInFiniteScroll: true,
                  ),
                ),
                const SizedBox(height: 25),
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
                                    border: Border.all(
                                        color: Colors.black, width: 5),
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
                                                BorderRadius.circular(16)
                                                    .copyWith(
                                              topRight:
                                                  const Radius.circular(50),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                                  // selectedRadio = radios[index];
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
                  padding: const EdgeInsets.only(top: 45),
                  child: Column(
                    children: [
                      isPlaying
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: Center(
                                child: Text(
                                  "Playing now - ${selectedRadio!.name} FM",
                                  style: TextStyle(
                                    color: Pallete.whiteColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          : const Text(""),
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
                          size: 50,
                        ),
                      ),
                    ],
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
