import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
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
        primarySwatch: Colors.blue,
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
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
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
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                  ),
                  child: Text('Finde Kodi-Instanzen', style: Theme.of(context).textTheme.headline5),
                  onPressed: () {
                    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FindKodiWidget()),
                      );
                    } else {
                      final scaffold = ScaffoldMessenger.of(context);
                      scaffold.showSnackBar(
                        SnackBar(
                          content: const Text('Suche nach Kodi-Instanzen nur unter Android verf??gbar!'),
                          action: SnackBarAction(label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                  ),
                  child: Text('??ndere Einstellungen', style: Theme.of(context).textTheme.headline5),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsWidget()),
                    );
                  },
                ),
              ),
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
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

class FindKodiWidget extends StatefulWidget {
  const FindKodiWidget({Key? key}) : super(key: key);

  @override
  State<FindKodiWidget> createState() => _FindKodiWidgetState();
}

class _FindKodiWidgetState extends State<FindKodiWidget> {
  List<BonsoirService> serviceList = [];

  _FindKodiWidgetState() {
    searchKodiInstances();
  }

  void searchKodiInstances() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // set the type of service we're looking for
      String type = '_http._tcp'; //'_smb._tcp'; '._http._tcp.local.';

      // start the discovery
      BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
      await discovery.ready;
      await discovery.start();

      // listen to the discovery
      discovery.eventStream!.listen((event) {
        if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_RESOLVED) {
          developer.log('Service found : ${event.service!.toJson()}');
          setState(() {
            serviceList.add(event.service!);
          });
        } else if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_LOST) {
          developer.log('Service lost : ${event.service!.toJson()}');
        }
      });

      // stop the discovery
      //await discovery.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kodi-Instanzen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Container()),
            Text(
              'Kodi-Instanzen',
              style: Theme.of(context).textTheme.headline3,
            ),
            Expanded(child: Container()),
            SizedBox(
              height: 400,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: serviceList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    child: Container(
                      height: 75,
                      color: Colors.amberAccent,
                      child: Center(
                          child: Text(
                              '${serviceList[index].name} unter der Adresse ${serviceList[index].toJson()['service.ip']}:${serviceList[index].port}',
                              style: Theme.of(context).textTheme.headline6)),
                    ),
                    onTap: () => handleTap(serviceList[index]),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  void handleTap(BonsoirService service) {
    String address = '${service.toJson()['service.ip']}:${service.port + 1}';
    var scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(
      content: Text('Setze die Adresse $address in den Einstellungen!'),
      action: SnackBarAction(label: 'INFO', onPressed: scaffold.hideCurrentSnackBar),
    ));
    Future f = SharedPreferences.getInstance();
    f.then((prefs) => {prefs.setString('serverUrl', address)});
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
          title: 'Host-Adresse f??r Kodi-Instanz',
          settingKey: 'serverUrl',
          initialValue: '192.168.10.15:8081',
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
            title: 'Soll der Film-Plot ??bersetzt werden?',
            defaultValue: false,
            leading: const Icon(Icons.language),
            settingKey: 'translatePlot'),
      ]),
      SettingsGroup(title: 'Oberfl??che', children: [
        CheckboxSettingsTile(
          title: 'Alles voller Animationen!',
          settingKey: 'animateEverything',
          leading: const Icon(Icons.animation),
          defaultValue: true,
        ),
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
  bool animateEverything = true;

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
          serverUrl = prefs.getString('serverUrl') ?? '192.168.10.15:8081',
          userName = prefs.getString('userName') ?? 'John Doe',
          translatePlot = prefs.getBool('translatePlot') ?? false,
          animateEverything = prefs.getBool('animateEverything') ?? true
        });
  }

  Future fetchMovie() {
    developer.log('Fetching movie data from $serverUrl...');
    // reset internal data structures
    movieGenres.clear();
    movieCountry.clear();

    // get information about next movie
    Future response = http.get(
      Uri.http(serverUrl, '/movie', {
        'username': userName,
      }),
    );
    // TODO: Handle network errors!
    ScaffoldMessengerState scaffold;
    return response.then((response) => _parseMovieData(response.body),
        onError: (error) => {
              scaffold = ScaffoldMessenger.of(context),
              scaffold.showSnackBar(
                SnackBar(
                  content: const Text('Konnte keine Film-Daten laden!'),
                  action: SnackBarAction(label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
                ),
              ),
              developer.log('Error while fetching movie data: $error')
            });
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
        title: const Text('Filme-Bewertung'),
      ),
      body: SimpleGestureDetector(
        onVerticalSwipe: (direction) {},
        onHorizontalSwipe: (direction) {
          if (direction == SwipeDirection.right) {
            uploadVote(Voting.up);
          } else if (direction == SwipeDirection.left) {
            uploadVote(Voting.down);
          }
        },
        onLongPress: () {},
        onTap: () {},
        swipeConfig: const SimpleSwipeConfig(
          verticalThreshold: 30.0,
          horizontalThreshold: 30.0,
          swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
        ),
        child: DecoratedBox(
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
            padding: const EdgeInsets.all(15),
            child: MediaQuery.of(context).size.aspectRatio < 1 ? buildMovieInfoPortrait() : buildMovieInfoLandscape(),
          ),
        ),
      ),
    );
  }

  buildMovieInfoPortrait() {
    // TODO: Use package for handling different display sizes and orientations. (e.g. https://pub.dev/packages/sizer or https://pub.dev/packages/flutter_screenutil)
    final scaleFactor = MediaQuery.of(context).size.height / 650;
    return Column(
      children: [
        animateEverything
            ? AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    movieName,
                    textAlign: TextAlign.center,
                    textStyle: Theme.of(context).textTheme.headline4!.apply(
                      fontWeightDelta: 5,
                      fontSizeDelta: 5 * scaleFactor,
                      shadows: [
                        const BoxShadow(
                          color: Colors.black54,
                          offset: Offset(3, 3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    colors: [
                      Colors.purple,
                      Colors.blue,
                      Colors.yellow,
                      Colors.red,
                    ],
                  ),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
                onTap: () {},
              )
            : Text(movieName,
                textScaleFactor: scaleFactor,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4!.apply(
                  shadows: [
                    const BoxShadow(
                      color: Colors.black54,
                      offset: Offset(3, 3),
                      blurRadius: 4,
                    ),
                  ],
                )),
        Expanded(child: Container()),
        Stack(alignment: Alignment.bottomRight, children: [
          moviePosterUrl == ''
              ? const Text('')
              : Image.network(
                  moviePosterUrl,
                  fit: BoxFit.contain,
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15, horizontal: 7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  movieYear != 0
                      ? Text('Jahr: $movieYear',
                          textScaleFactor: scaleFactor, style: Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white))
                      : const Text(''),
                  movieRuntime.isNotEmpty
                      ? Text('Laufzeit: $movieRuntime',
                          textScaleFactor: scaleFactor, style: Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white))
                      : const Text(''),
                  movieCountry.isNotEmpty
                      ? Text('Land: ${movieCountry[0]}',
                          textScaleFactor: scaleFactor, style: Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white))
                      : const Text(''),
                  movieGenres.isNotEmpty
                      ? Text('Genres: ${movieGenres.join(', ')}',
                          textAlign: TextAlign.left,
                          textScaleFactor: scaleFactor,
                          style: Theme.of(context).textTheme.bodyText1!.apply(color: Colors.white))
                      : const Text(''),
                  movieRating != 0.0
                      ? RatingBarIndicator(
                          rating: movieRating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                          unratedColor: Colors.black,
                          itemCount: 10,
                          itemSize: 20.0 * scaleFactor,
                          direction: Axis.horizontal,
                        )
                      : Container(),
                ],
              ),
              onPressed: () {}),
        ]),
        Expanded(child: Container()),
        animateEverything
            ? SizedBox(
                height: 30,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(movieYear != 0 ? 'Jahr: $movieYear' : '',
                        textStyle: Theme.of(context).textTheme.bodyText1!.apply(fontSizeDelta: 2 * scaleFactor)),
                    TypewriterAnimatedText(movieRuntime.isNotEmpty ? 'Laufzeit: $movieRuntime' : '',
                        textStyle: Theme.of(context).textTheme.bodyText1!.apply(fontSizeDelta: 2 * scaleFactor)),
                    TypewriterAnimatedText(movieCountry.isNotEmpty ? 'Land: ${movieCountry[0]}' : '',
                        textStyle: Theme.of(context).textTheme.bodyText1!.apply(fontSizeDelta: 2 * scaleFactor)),
                    TypewriterAnimatedText(movieGenres.isNotEmpty ? 'Genres: ${movieGenres.join(', ')}' : '',
                        textStyle: Theme.of(context).textTheme.bodyText1!.apply(fontSizeDelta: 2 * scaleFactor)),
                  ],
                  repeatForever: true,
                  isRepeatingAnimation: true,
                  onTap: () {},
                ),
              )
            : Container(),
        Expanded(child: Container()),
        Text(
          moviePlot,
          style: Theme.of(context).textTheme.bodyText1,
          textScaleFactor: scaleFactor,
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
        Expanded(child: Container()),
        Row(children: [
          Expanded(child: Container()),
          MaterialButton(
            color: Colors.redAccent,
            shape: const CircleBorder(),
            onPressed: () => uploadVote(Voting.down),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.thumb_down, size: 30.0),
            ),
          ),
          MaterialButton(
            color: Colors.black26,
            shape: const CircleBorder(),
            onPressed: () => uploadVote(Voting.neutral),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.album_outlined, size: 30.0),
            ),
          ),
          MaterialButton(
            color: Colors.greenAccent,
            shape: const CircleBorder(),
            onPressed: () => uploadVote(Voting.up),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.thumb_up, size: 30.0),
            ),
          ),
          Expanded(child: Container()),
        ]),
      ],
    );
  }

  buildMovieInfoLandscape() {
    final scaleFactor = MediaQuery.of(context).size.width / 850;
    return Column(
      children: [
        animateEverything
            ? AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    movieName,
                    textStyle: Theme.of(context).textTheme.headline4!.apply(
                      fontWeightDelta: 5,
                      fontSizeDelta: 5 * scaleFactor,
                      shadows: [
                        const BoxShadow(
                          color: Colors.black54,
                          offset: Offset(3, 3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    colors: [
                      Colors.purple,
                      Colors.blue,
                      Colors.yellow,
                      Colors.red,
                    ],
                  ),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
                onTap: () {},
              )
            : Text(movieName,
                textScaleFactor: scaleFactor,
                style: Theme.of(context).textTheme.headline4!.apply(
                  shadows: [
                    const BoxShadow(
                      color: Colors.black54,
                      offset: Offset(4, 4),
                      blurRadius: 4,
                    ),
                  ],
                )),
        Expanded(child: Container()),
        Row(
          children: [
            moviePosterUrl == ''
                ? const Text('')
                : Image.network(
                    moviePosterUrl,
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height * 0.65,
                    width: MediaQuery.of(context).size.width * 0.50,
                  ),
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    animateEverything
                        ? AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(moviePlot,
                                  textStyle: Theme.of(context).textTheme.bodyText1!.apply(fontSizeDelta: 5 * scaleFactor)),
                            ],
                            onTap: () {},
                          )
                        : Text(moviePlot, textScaleFactor: scaleFactor, style: Theme.of(context).textTheme.bodyText1),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        movieYear != 0
                            ? Text('Jahr: $movieYear', textScaleFactor: scaleFactor, style: Theme.of(context).textTheme.bodyText1)
                            : const Text(''),
                        movieCountry.isNotEmpty
                            ? Text('Land: ${movieCountry[0]}', textScaleFactor: scaleFactor, style: Theme.of(context).textTheme.bodyText1)
                            : const Text(''),
                        movieGenres.isNotEmpty
                            ? Text('Genres: ${movieGenres.join(', ')}',
                                textScaleFactor: scaleFactor, textAlign: TextAlign.left, style: Theme.of(context).textTheme.bodyText1)
                            : const Text(''),
                        movieRuntime.isNotEmpty
                            ? Text('Laufzeit: $movieRuntime', textScaleFactor: scaleFactor, style: Theme.of(context).textTheme.bodyText1)
                            : const Text(''),
                        movieRuntime.isNotEmpty
                            ? RatingBarIndicator(
                                rating: movieRating,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 10,
                                itemSize: 20.0 * scaleFactor,
                                direction: Axis.horizontal,
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(child: Container()),
        Row(children: [
          Expanded(child: Container()),
          MaterialButton(
            color: Colors.redAccent,
            shape: const CircleBorder(),
            onPressed: () => uploadVote(Voting.down),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.thumb_down, size: 30.0),
            ),
          ),
          MaterialButton(
            color: Colors.black26,
            shape: const CircleBorder(),
            onPressed: () => uploadVote(Voting.neutral),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.album_outlined, size: 30.0),
            ),
          ),
          MaterialButton(
            color: Colors.greenAccent,
            shape: const CircleBorder(),
            onPressed: () => uploadVote(Voting.up),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.thumb_up, size: 30.0),
            ),
          ),
          Expanded(child: Container()),
        ]),
      ],
    );
  }
}
