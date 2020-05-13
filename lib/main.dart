import 'package:flutter/material.dart';
import 'package:nhealth/concept-manager/concept_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nhealth/models/language.dart';
import 'package:nhealth/route_generator.dart';
import 'app_localizations.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/observation_concepts.dart';
import 'package:nhealth/repositories/local/observation_concepts_repository_local.dart';
import 'package:nhealth/screens/home_screen.dart';
import './repositories/local/database_creator.dart';
import './screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Locale appLocale = Locale('en', 'EN');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();

  // Load exsiting lang
  final prefs = await SharedPreferences.getInstance();
  var locale = prefs.getString('locale');
  Map langMapp = {"English": Locale('en', 'EN'), "Bengali": Locale('bn', 'BN')};
  Language().changeLanguage(locale);
  if (locale != null) {
    appLocale = langMapp[locale];
  }

  runApp(MyApp());

  print(DatabaseCreator().dBCreatedStatus());

  if (DatabaseCreator().dBCreatedStatus()) {
    print('codings');
    await ObservationConcepts().getItems().forEach((item) {
      ObservationConceptsRepositoryLocal().create(item);
    });
    await ConceptManager().sync();
    DatabaseCreator().dBCreatedStatusChange(false);
  }
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) async {
    MyAppState state = context.findAncestorStateOfType<MyAppState>();
    state.changeLanguage(newLocale);
  }

  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  changeLanguage(Locale locale) {
    setState(() {
      appLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        theme:
            ThemeData(primaryColor: kPrimaryColor, backgroundColor: Colors.white),
        // List all of the app's supported locales here
        supportedLocales: [
          Locale('en', 'EN'),
          Locale('bn', 'BN'),
        ],
        locale: appLocale,
        // These delegates make sure that the localization data for the proper language is loaded
        localizationsDelegates: [
          // A class which loads the translations from JSON files
          AppLocalizations.delegate,
          // Built-in localization of basic text for Material widgets
          GlobalMaterialLocalizations.delegate,
          // Built-in localization for text direction LTR/RTL
          GlobalWidgetsLocalizations.delegate,
        ],
        // Returns a locale which will be used by the app
        localeResolutionCallback: (locale, supportedLocales) {
          // var t = Locale('bn', 'BN');
          // Check if the current device locale is supported
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          // If the locale of the device is not supported, use the first one
          // from the list (English, in this case).
          return supportedLocales.first;
        },

        onGenerateRoute: RouteGenerator.generarteRoute ,

        initialRoute: '/',

        home: CheckAuth(),
      ),
    );
  }

}

class CheckAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Auth().getStorageAuth().then((data) {
      if (data['status']) {
        if (data['role'] == 'chw') {
          Navigator.of(context).pushReplacementNamed('/chwHome');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
      }
    });

    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
