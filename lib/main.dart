import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nhealth/concept-manager/concept_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nhealth/controllers/sync_controller.dart';
import 'package:nhealth/controllers/device_controller.dart';
import 'package:nhealth/models/devices.dart';
import 'package:nhealth/models/language.dart';
import 'package:nhealth/route_generator.dart';
import 'app_localizations.dart';

import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/observation_concepts.dart';
import 'package:nhealth/repositories/local/observation_concepts_repository_local.dart';
import './repositories/local/database_creator.dart';
import './screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

Locale appLocale = Locale('en', 'US');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  final syncController = Get.put(SyncController());

  // Load exsiting lang
  final prefs = await SharedPreferences.getInstance();
  var locale = prefs.getString('language');
  Map langMapp = {"English": Locale('en', 'US'), "Bengali": Locale('bn', 'BN')};
  Language().changeLanguage(locale);
  if (locale != null) {	
    appLocale = langMapp[locale];	
    Language().changeLanguage(locale);	
  } else {	
    appLocale = langMapp["Bengali"];	
    Language().changeLanguage('Bengali');	
  }
  _getDevices();
  runApp(MyApp());
  // Connectivity().onConnectivityChanged.listen(syncController.checkConnection);


  if (DatabaseCreator().dBCreatedStatus()) {

    await ObservationConcepts().getItems().forEach((item) {
      ObservationConceptsRepositoryLocal().create(item);
    });
    await ConceptManager().sync();
    DatabaseCreator().dBCreatedStatusChange(false);
  }
  // const oneSec = const Duration(minutes: 20);

  // Timer.periodic(oneSec, (Timer timer) {
  //   if(!syncController.isSyncingToLocal.value) {
  //     syncController.fetchLatestSyncs();
  //   }
  // });
  // Timer.periodic(Duration(seconds: 30), (Timer timer) {
  //   if(!syncController.isSyncingToLocal.value) {
  //     syncController.checktoSync();
  //   }
  // });
}
_getDevices() async {
  var data = await DeviceController().getDevices();
  if (data.length > 0 ) {
    Device().setDevices(data);
  }
}
class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) async {
    MyAppState state = context.findAncestorStateOfType<MyAppState>();
    // state.changeLanguage(newLocale);
    state.setState(() {	
      state.locale = newLocale;	
    });
  }

  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  // final syncController = Get.put(SyncController());
  Locale locale;	
  @override	
  void initState() {	
    super.initState();	
    this._fetchLocale().then((locale) {	
      setState(() {	
        this.locale = locale;	
      });	
    });	
  }	
  _fetchLocale() async {	
    var prefs = await SharedPreferences.getInstance();	
    if (prefs.getString('language_code') == null) {	
      return Locale('bn', 'BN');
    }	
    return Locale(prefs.getString('language_code'), 	
      prefs.getString('country_code'));	
  }
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
      child: GetMaterialApp(
        theme: ThemeData(
            primaryColor: kPrimaryColor, backgroundColor: Colors.white),
        // List all of the app's supported locales here
        supportedLocales: [
          Locale('en', 'US'),
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
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          if (this.locale == null) {	
            this.locale = deviceLocale;	
          }	
          return this.locale;
          // // var t = Locale('bn', 'BN');
          // // Check if the current device locale is supported
          // for (var supportedLocale in supportedLocales) {
          //   if (supportedLocale.languageCode == locale.languageCode &&
          //       supportedLocale.countryCode == locale.countryCode) {
          //     return supportedLocale;
          //   }
          // }
          // // If the locale of the device is not supported, use the first one
          // // from the list (English, in this case).
          // return supportedLocales.first;
        },

        onGenerateRoute: RouteGenerator.generarteRoute,

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
        }
        else if(data['role'] == 'chcp') {
          Navigator.of(context).pushReplacementNamed('/chcpHome');
        }
        else{
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
