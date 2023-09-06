import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'weatherModel.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';


/*
class OpenMeteoApiClient {
  final String baseUrl = 'https://api.open-meteo.com/v1';
  String latitude = '41.9027835';
  String longitude = '12.4963655';

  Future<MeteoAPI> fetchMeteoData() async {
    final response = await http.get(Uri.parse('$baseUrl/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      final MeteoAPI meteoData = MeteoAPI.fromJson(jsonMap);

      return meteoData;
    } else {
      throw Exception('Failed to load Meteo data');
    }
  }
}*/

class OpenMeteoApiClient {

  //Variables
  final String baseUrl = 'https://api.open-meteo.com/v1';
  String? latitude;
  String? longitude;

  //OpenMeteoApiClient({this.latitude = '41.9027835', this.longitude = '12.4963655'});

  Future<MeteoAPI> fetchMeteoData() async {
    if (latitude == null || longitude == null) {

      /* If you comment the following two lines of code
      you'll obtain the new latitude and longitude values from
      your current position */

      latitude = '41.9027835';
      longitude = '12.4963655';

      // Ottieni la posizione corrente se le coordinate non sono state fornite.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      final MeteoAPI meteoData = MeteoAPI.fromJson(jsonMap);

      return meteoData;

    } else {
      throw Exception('Failed to load Meteo data');
    }
  }
}


class MeteoDisplayWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MeteoAPI>(
      future: OpenMeteoApiClient().fetchMeteoData(),
      builder: (context, snapshot) {

        //Variables
        final DateTime now = DateTime.now();
        final String currentTime = DateFormat('HH:mm').format(now);
        String imagePath;
        final List<Map<String, dynamic>> jsonData; // Dichiarazione di jsonData come attributo

        /* If statement that define that we are actually to morning or night and change
        in a correct way the values of the image */

        if (currentTime.compareTo('06:00') >= 0 && currentTime.compareTo('18:00') <= 0) {
          imagePath = 'assets/day_image.png';
        } else {
          imagePath = 'assets/night_image.png';
        }

        //Check connectionState -> if we have data we load it, otherwise CircularProgressIndicator()

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final MeteoAPI meteoData = snapshot.data!;
          final String temperature2m = meteoData.hourly?.temperature2m?.isNotEmpty == true
              ? meteoData.hourly!.temperature2m![0].toStringAsFixed(1)
              : 'N/A';

          return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/cityMinimal.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
            child: Center(
              child:
              Column(
                children: [
                  const SizedBox(height: 20),
                  Card(
                    elevation: 20, // Altezza dell'ombra
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      width: 400, //
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent!, Colors.yellowAccent[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            imagePath,
                            width: 100,
                            height: 100,
                          ),
                          Text('Latitude: ${meteoData.latitude}'),
                          Text('Longitude: ${meteoData.longitude}'),
                          Text('Temperature at 2m: $temperature2m°C'),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: meteoData.hourly?.time?.length ?? 0,
                      itemBuilder: (context, index) {

                        //Variables
                        String? rawDateTime = meteoData.hourly?.time?[index];
                        if (rawDateTime != null) {

                          //Convert date with the formay yyyy/mm/dd and Timezone with pattern hh:mm
                          DateTime dateTime = DateTime.parse(rawDateTime);
                          String formattedDateTime = "${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}";
                          String formattedTimeZone = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

                          return Container(
                            width: 150,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: imagePath == 'day_night' ? Colors.white70 : Colors.blueAccent,
                              borderRadius: BorderRadius.circular(16.0), // Imposta i bordi tondeggianti
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.yellowAccent.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    imagePath,
                                    scale: 3,
                                  ),
                                ),
                                Column(
                                  children: [
                                    const Divider(),
                                    const Text(
                                      'Time',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(formattedDateTime),
                                    const Divider(),
                                    const Text(
                                        'Orario previsto',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Text(formattedTimeZone),
                                    const Divider(),
                                    const Text(
                                        'Temperature',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Text('${meteoData.hourly?.temperature2m?[index]}')
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text(
            'Challenge Weather API',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w300,
            ),
        ),
        backgroundColor: Colors.lime,
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {

            var data = OpenMeteoApiClient();
            var latitude = '';
            var longitude = '';

            data.fetchMeteoData();
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            latitude = position.latitude.toString();
            longitude = position.longitude.toString();

            print('$latitude,$longitude');

          },
          child: const Icon(Icons.location_on),
        ),
      body: MeteoDisplayWidget(),
    ),
  ));
}
