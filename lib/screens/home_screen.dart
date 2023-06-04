import 'dart:ui';

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

  @override
  void initState() {
    super.initState();
    fetchRadios();
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    // final jsonData = json.decode(radioJson);
    // Then we get it fromJson method from the list of MyRadio
    radios = MyRadioList.fromJson(radioJson).radios;
    print(radios);
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            CarouselSlider.builder(
              itemCount: radios.length,
              itemBuilder: (context, index, realIndex) {
                final rad = radios[index];
                return GestureDetector(
                  onDoubleTap: () {
                    print("Double tapped!");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                          top: -10,
                          right: -10,
                          child: ClipOval(
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              // clipBehavior: Clip.antiAlias,
                              // padding: const EdgeInsets.all(5),
                              // margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                rad.category.toUpperCase(),
                                style: TextStyle(
                                  color: Pallete.whiteColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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
                        )
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                aspectRatio: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
