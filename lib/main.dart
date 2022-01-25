import 'package:flutter/material.dart';
import 'package:mangavocabulometer/screens/Flashcard.dart';
import 'package:mangavocabulometer/screens/ReviewSetA.dart';
import 'package:mangavocabulometer/screens/User_Information.dart';
import 'package:mangavocabulometer/screens/authentication.dart';
import 'package:mangavocabulometer/widget/BottomTabBar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';


//void main() => runApp(MyApp());

final sharedPreferencesProvider =
    Provider<SharedPreferences>((_) => throw UnimplementedError());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider
          .overrideWithValue(await SharedPreferences.getInstance()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Vocabulometer',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      //home: new AuthScreen(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => AuthScreen(),
        '/UserInformation': (BuildContext context) =>
            new UserInformationScreen(),
        '/HomePage': (BuildContext context) => new BottomTabBar(),
        '/Flashcard': (BuildContext context) => new Flashcard(),
        'ReviewSetA': (BuildContext context) => new ReviewSetA(),
      },
    );
  }
}
