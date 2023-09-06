import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'weatherModel.dart';
import 'package:intl/intl.dart';


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
}

class MeteoDisplayWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MeteoAPI>(
      future: OpenMeteoApiClient().fetchMeteoData(),
      builder: (context, snapshot) {

        final DateTime now = DateTime.now();
        final String currentTime = DateFormat('HH:mm').format(now);
        String imagePath;
        final List<Map<String, dynamic>> jsonData; // Dichiarazione di jsonData come attributo


        if (currentTime.compareTo('06:00') >= 0 && currentTime.compareTo('18:00') <= 0) {
          // È giorno cambia immagine con il meteo mattutino
          imagePath = 'assets/day_image.png'; // Percorso dell'immagine per il giorno
        } else {
          // È notte cambia immagine con il meteo notturno
          imagePath = 'assets/night_image.png'; // Percorso dell'immagine per la notte
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
                    image: AssetImage('assets/cityMinimal.jpeg'), // Imposta il percorso dell'immagine
                    fit: BoxFit.cover, // Regola la modalità di riempimento dell'immagine
                  ),
                ),
            child: Center(
              child: // Spazio vuoto per spostare la card in alto
              Column(
                children: [
                  SizedBox(height: 50),
                  Card(
                    elevation: 20, // Altezza dell'ombra
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // Bordo rotondo
                    ),
                    child: Container(
                      width: 300, // Larghezza della card
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent!, Colors.yellowAccent[100]!], // Sfumatura grigia
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            imagePath, // Utilizza il percorso dell'immagine
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
                    constraints: BoxConstraints(maxHeight: 200), // Imposta un'altezza massima
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: meteoData.hourly?.time?.length ?? 0, // Usa la lunghezza di meteoData.time
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text('Time: ${meteoData.hourly?.temperature2m?[index]}'),
                            subtitle: Text('Temperature 2m: ${meteoData.hourly?.temperature2m?[index]}'),
                          ),
                        );
                      },
                    ),
                  )

                ],
              ),


            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }

}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text(
            'Challenge Weather API',
            style: TextStyle(
              color: Colors.black, // Imposta il colore del testo in nero
              fontWeight: FontWeight.w300, // Imposta il testo in grassetto
            ),
        ),
        backgroundColor: Colors.lime,

      ),

      body: MeteoDisplayWidget(),
    ),
  ));
}
