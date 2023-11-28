import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app_artifitia/constants/constants.dart';
import 'package:weather_app_artifitia/widgets/custom_snackbar.dart';
import 'package:weather_app_artifitia/widgets/custom_textfield.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  TextEditingController searchController = TextEditingController();
  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  Future<Map<String, dynamic>> fetchWeather(String apiLocation) async {
    String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
    String apiKey = '284b30c0aad1eff063f1d90e0a1ec5fe';

    try {
      final response =
          await http.get(Uri.parse('$baseUrl?q=$apiLocation,in&APPID=$apiKey'));

      if (response.statusCode == 200) {
        showAdlSnackbar(context, 'Weather fetched Successfully');
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to fetch weather');
      }
    } catch (e) {
      showAdlSnackbar(context, 'Failed to fetch weather: $e');

      throw Exception('Failed to fetch weather');
    }
  }

  // double temperatureCelsius = 0.0;
  // bool isCelsius = true;

  // void toggleConversion() {
  //   setState(() {
  //     if (isCelsius) {
  //       temperatureCelsius = (temperatureCelsius * 9 / 5) + 32;
  //     } else {
  //       temperatureCelsius = (temperatureCelsius - 32) * 5 / 9;
  //     }
  //     isCelsius = !isCelsius;
  //   });
  // }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placemarks[0].locality;

    return city ?? '';
  }

  @override
  Widget build(BuildContext context) {
    Future<String> currentCity = getCurrentCity();

    Size size = MediaQuery.of(context).size;
    double scrHeight = size.height;
    double scrWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade200,
        title: const Text('Weather App'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future:
              // searchController.text == ''
              //     ? fetchWeatherbyCurrentLocation(currentCity):
              fetchWeather(searchController.text),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final weatherData = snapshot.data;
              print(weatherData);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AdlTextField(
                      controller: searchController,
                      suffixIcon: const Icon(Icons.search),
                      label: 'Search by location',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: scrHeight * 0.2,
                        width: scrWidth * 0.45,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 33,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: FutureBuilder<String>(
                                future: currentCity,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Text(
                                      '${snapshot.data}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: scrWidth * 0.05,
                      ),
                      Container(
                        height: scrHeight * 0.2,
                        width: scrWidth * 0.45,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://t4.ftcdn.net/jpg/02/88/82/15/360_F_288821575_TM4gJOMpOFgNH1QUIDGzaDQzMZSU92LS.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: scrHeight * 0.2,
                      width: scrWidth,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: scrHeight * 0.1,
                                width: scrWidth * 0.2,
                                child: Image(
                                  image: AssetImage(
                                    weatherData!['weather'][0]['main'] ==
                                            'Clouds'
                                        ? Constants.cloudy
                                        : Constants.loading,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: scrWidth * 0.06,
                              ),
                              // ElevatedButton(
                              //   onPressed: toggleConversion,
                              //   child: const Text('F'),
                              // ),
                              Text(
                                '${kelvinToCelsius(weatherData['main']['temp']).round()}°C',
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: scrHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: scrWidth * 0.2,
                                child: Center(
                                  child: Text(
                                    weatherData['weather'][0]['main'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: scrWidth * 0.05,
                              ),
                              SizedBox(
                                width: scrWidth * 0.3,
                                child: Center(
                                  child: Text(
                                    weatherData['weather'][0]['description'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
