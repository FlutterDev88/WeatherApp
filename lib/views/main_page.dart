import 'dart:developer';

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/constants/constants.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/service_api.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<WeatherModel> getData(bool isCurrentCity, String cityName) async {
    return await ServiceAPI().callWeatherAPi(isCurrentCity, cityName);
  }

  TextEditingController textController = TextEditingController(text: "");
  Future<WeatherModel>? _myData;
  @override
  void initState() {
    setState(() {
      _myData = getData(true, "");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: FutureBuilder(
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If error occured
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error.toString()} occurred',
                  style: const TextStyle(fontSize: 18),
                ),
              );

              // if data has no errors
            } else if (snapshot.hasData) {
              // Extracting data from snapshot object
              final data = snapshot.data as WeatherModel;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 1),
                    colors: <Color>[
                      Color.fromARGB(255, 105, 89, 224),
                      Color.fromARGB(255, 23, 92, 215),
                      Color.fromARGB(255, 12, 88, 177),
                      Color(0xfff89060),
                      Color(0xfff5b56b),
                    ],
                    tileMode: TileMode.mirror,
                  ),
                ),
                width: double.infinity,
                height: double.infinity,
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20), 
                        child: Text('Weather App',style: middleTextStyle,)
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Location: ${data.city}',
                              style: smallTextStyle,
                            ),
                            const SizedBox(height: 25,),
                            Text(
                              'Status: ${data.desc}',
                              style: smallTextStyle,
                            ),
                            const SizedBox(height: 25,),
                            Text(
                              'Temperature: ' "${data.temp}°C",
                              style: smallTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Text('Please input search location',style: smallTextStyle,),
                      AnimSearchBar(
                        rtl: false,
                        width: 400,
                        color: const Color(0xffffb56b),
                        textController: textController,
                        suffixIcon: const Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 26,
                        ),
                        onSuffixTap: () async {
                          textController.text == ""
                              ? log("No city entered")
                              : setState(() {
                                  _myData = getData(false, textController.text);
                                });

                          FocusScope.of(context).unfocus();
                          textController.clear();
                        },
                        style: smallTextStyle, 
                        onSubmitted: (result ) { 
                          textController.text == ""
                              ? log("No city entered")
                              : setState(() {
                                  _myData = getData(false, result);
                                });

                          FocusScope.of(context).unfocus();
                          textController.clear();
                         },
                      ),
                    ],
                  ),
                ),
              );
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text("${snapshot.connectionState} occured"),
            );
          }
          return const Center(
            child: Text("Server timed out!"),
          );
        },
        future: _myData!,
      ),
    );
  }
}
