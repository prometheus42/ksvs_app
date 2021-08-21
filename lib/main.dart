import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

void main() {
  initSettings().then((_) {
    runApp(const KsvsApp());
  });
}

// Initialize the settings provider, see https://pub.dev/packages/flutter_settings_screens/example
Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: SharePreferenceCache(),
  );
}

class KsvsApp extends StatelessWidget {
  const KsvsApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kodi Simple Voting System',
      theme: ThemeData(
          //primarySwatch: Colors.blue,
          ),
      home: const MainMenu(title: 'Kodi Simple Voting System'),
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  void searchKodiInstances() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // This is the type of service we're looking for :
      String type = '_wonderful-service._tcp';

      // Once defined, we can start the discovery :
      BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
      await discovery.ready;
      await discovery.start();

      // If you want to listen to the discovery :
      discovery.eventStream!.listen((event) {
        if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_RESOLVED) {
          print('Service found : ${event.service!.toJson()}');
        } else if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_LOST) {
          print('Service lost : ${event.service!.toJson()}');
        }
      });

      // Then if you want to stop the discovery :
      //await discovery.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //const Image(image: AssetImage('assets/logo.png')),
            Text(
              'Kodi Simple Voting System',
              style: Theme.of(context).textTheme.headline2,
            ),
            const SizedBox(height: 50),
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 400),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                  ),
                  child: Text('Starte Film-Auswahl', style: Theme.of(context).textTheme.headline5),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MovieScoreWidget()),
                    );
                  },
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 400),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                  ),
                  child: Text('Finde Kodi-Instanzen', style: Theme.of(context).textTheme.headline5),
                  onPressed: () {
                    searchKodiInstances();
                  },
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 400),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                  ),
                  child: Text('Ändere Einstellungen', style: Theme.of(context).textTheme.headline5),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsWidget()),
                    );
                  },
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 400),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                  ),
                  child: Text('Beende App', style: Theme.of(context).textTheme.headline5),
                  // exit app programmatically: https://stackoverflow.com/a/49067313
                  onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return SettingsScreen(title: 'Einstellungen', children: [
      SettingsGroup(title: 'Kodi', children: [
        TextInputSettingsTile(
          title: 'Host-Adresse für Kodi-Instanz',
          settingKey: 'serverUrl',
          initialValue: '192.168.10.9:8081',
          keyboardType: TextInputType.url,
        ),
      ]),
      SettingsGroup(title: 'Benutzer', children: [
        TextInputSettingsTile(
          title: 'Benutzername',
          settingKey: 'userName',
          initialValue: '',
          keyboardType: TextInputType.text,
        ),
        CheckboxSettingsTile(
            title: 'Soll der Film-Plot übersetzt werden?',
            defaultValue: false,
            leading: const Icon(Icons.language),
            settingKey: 'translatePlot'),
      ]),
    ]);
  }
}

enum Voting { up, neutral, down }

class MovieScoreWidget extends StatefulWidget {
  const MovieScoreWidget({Key? key}) : super(key: key);

  @override
  State<MovieScoreWidget> createState() => _MovieScoreWidgetState();
}

class _MovieScoreWidgetState extends State<MovieScoreWidget> {
  final translator = GoogleTranslator();
  String serverUrl = '';
  String userName = '';
  bool translatePlot = false;

  static const int maxTextLength = 200;

  int movieId = 0;
  String movieName = ''; // "label" or "title" or "originaltitle" or "sorttitle"
  List<String> movieCountry = [];
  List<String> movieGenres = [];
  String moviePlot = '';
  double movieRating = 0.0;
  String movieRuntime = '';
  String movieTagline = '';
  int movieYear = 0;
  String moviePosterUrl = '';
  String movieFanartUrl = '';

  _MovieScoreWidgetState() {
    loadConfiguration().whenComplete(() => {fetchMovie()});
  }

  Future loadConfiguration() {
    Future f = SharedPreferences.getInstance();
    return f.then((prefs) => {
          serverUrl = prefs.getString('serverUrl') ?? 'http://127.0.0.1:5000',
          userName = prefs.getString('userName') ?? 'John Doe',
          translatePlot = prefs.getBool('translatePlot') ?? false
        });
  }

  Future fetchMovie() {
    developer.log('Fetching movie data from $serverUrl...');
    Future response = http.get(
      Uri.http(serverUrl, '/movie', {
        'username': userName,
      }),
    );
    // TODO: Handle network errors!
    return response.then((response) => _parseMovieData(response.body));
  }

  void _parseMovieData(responseBody) async {
    developer.log('Parsing movie data...');
    Map<String, dynamic> jsonInput = jsonDecode(responseBody);

    setState(() {
      movieName = jsonInput['title'];
      // reset plot string, because otherwise the old plot is shown while the translation is fetched
      moviePlot = '';
      for (var item in jsonInput['country']) {
        movieCountry.add(item.toString());
      }
      for (var item in jsonInput['genre']) {
        movieGenres.add(item.toString());
      }
      movieYear = jsonInput['year'];
      movieRating = jsonInput['rating'];
      Duration runtime = Duration(seconds: jsonInput['runtime']);
      // format runtime from integer to hh:mm:ss (source: https://stackoverflow.com/a/57117567)
      movieRuntime =
          '${runtime.inHours.toString().padLeft(2, '0')}:${runtime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${runtime.inSeconds.remainder(60).toString().padLeft(2, '0')}';

      //final String thumbnailUrl = jsonInput['thumbnail'];
      movieFanartUrl = jsonInput['fanart'];
      moviePosterUrl = jsonInput['art']['poster'];
      movieTagline = jsonInput['tagline'];
      movieId = jsonInput['movieid'];
      developer.log('Parsed movie with id: $movieId.');
    });

    if (translatePlot) {
      translator.translate(jsonInput['plot'], from: 'en', to: 'de').then((s) {
        setState(() {
          moviePlot = s.text;
        });
      });
    } else {
      setState(() {
        moviePlot = jsonInput['plot'];
      });
    }
  }

  void uploadVote(Voting voting) {
    switch (voting) {
      case Voting.down:
        developer.log('Movie was voted down!');
        http
            .post(
              Uri.http(serverUrl, '/vote'),
              headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode(<String, String>{'movieid': movieId.toString(), 'vote': '-1', 'username': userName}),
            )
            .whenComplete(() => {fetchMovie()});
        break;
      case Voting.neutral:
        developer.log('Movie was voted neutral!');
        http
            .post(
              Uri.http(serverUrl, '/vote'),
              headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode(<String, String>{'movieid': movieId.toString(), 'vote': '0', 'username': userName}),
            )
            .whenComplete(() => {fetchMovie()});
        break;
      case Voting.up:
        developer.log('Movie was voted up!');
        http
            .post(
              Uri.http(serverUrl, '/vote'),
              headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode(<String, String>{'movieid': movieId.toString(), 'vote': '1', 'username': userName}),
            )
            .whenComplete(() => {fetchMovie()});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bewerte Filme'),
      ),
      body: DecoratedBox(
        decoration: movieFanartUrl.isNotEmpty
            ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(movieFanartUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                ),
              )
            : const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(children: [
            Text(movieName,
                style: Theme.of(context).textTheme.headline3!.apply(
                  shadows: [
                    const BoxShadow(
                      color: Colors.black54,
                      offset: Offset(4, 4),
                      blurRadius: 4,
                    ),
                  ],
                )),
            Expanded(child: Container()),
            moviePosterUrl == ''
                ? const Text('')
                : Image.network(
                    moviePosterUrl,
                    height: 400,
                  ),
            Expanded(child: Container()),
            Text(moviePlot.length > maxTextLength ? moviePlot.substring(0, maxTextLength) + '...' : moviePlot,
                style: Theme.of(context).textTheme.headline5),
            Expanded(child: Container()),
            Text('Jahr: $movieYear', style: Theme.of(context).textTheme.headline6),
            Text('Land: ${movieCountry.isNotEmpty ? movieCountry[0] : ''}', style: Theme.of(context).textTheme.headline6),
            Text('Genres: ${movieGenres.isNotEmpty ? movieGenres.join(', ') : ''}',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6),
            Text('Laufzeit: $movieRuntime', style: Theme.of(context).textTheme.headline6),
            RatingBarIndicator(
              rating: movieRating,
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 10,
              itemSize: 30.0,
              direction: Axis.horizontal,
            ),
            Expanded(child: Container()),
            Row(children: [
              Expanded(child: Container()),
              MaterialButton(
                color: Colors.redAccent,
                shape: const CircleBorder(),
                onPressed: () => uploadVote(Voting.down),
                child: const Padding(
                  padding: EdgeInsets.all(25),
                  child: Icon(Icons.thumb_down, size: 50.0),
                ),
              ),
              MaterialButton(
                color: Colors.black26,
                shape: const CircleBorder(),
                onPressed: () => uploadVote(Voting.neutral),
                child: const Padding(
                  padding: EdgeInsets.all(25),
                  child: Icon(Icons.album_outlined, size: 50.0),
                ),
              ),
              MaterialButton(
                color: Colors.greenAccent,
                shape: const CircleBorder(),
                onPressed: () => uploadVote(Voting.up),
                child: const Padding(
                  padding: EdgeInsets.all(25),
                  child: Icon(Icons.thumb_up, size: 50.0),
                ),
              ),
              Expanded(child: Container()),
            ]),
          ]),
        ),
      ),
    );
  }
}
