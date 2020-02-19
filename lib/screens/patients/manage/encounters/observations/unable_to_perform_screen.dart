import 'package:flutter/material.dart';
import 'package:nhealth/app_localizations.dart';

class UnableToPerformScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('observations')),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 40, right: 40),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 40,),
                  Text(AppLocalizations.of(context).translate('enterReason'), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 50,),
                  SizedBox(height: 50,),
                  
                  Container(
                    alignment: Alignment.topCenter,
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      height: 60.0,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text(AppLocalizations.of(context).translate('patientRefused'), style: TextStyle(color: Colors.white, fontSize: 22),),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),
                  Container(
                    alignment: Alignment.topCenter,
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      height: 60.0,
                      child: RaisedButton(
                        color: Colors.grey,
                        onPressed: () {},
                        child: Text(AppLocalizations.of(context).translate('patientUnable'), style: TextStyle(color: Colors.white, fontSize: 22),),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),
                  Container(
                    alignment: Alignment.topCenter,
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      height: 60.0,
                      child: RaisedButton(
                        color: Colors.grey,
                        onPressed: () {},
                        child: Text(AppLocalizations.of(context).translate('instrumentError'), style: TextStyle(color: Colors.white, fontSize: 22),),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),
                  Container(
                    alignment: Alignment.topCenter,
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      height: 60.0,
                      child: RaisedButton(
                        color: Colors.grey,
                        onPressed: () {},
                        child: Text(AppLocalizations.of(context).translate('instrumentUnavailable'), style: TextStyle(color: Colors.white, fontSize: 22),),
                      ),
                    ),
                  ),

                  SizedBox(height: 120,),
                  Container(
                    alignment: Alignment.topCenter,
                    child: ButtonTheme(
                      minWidth: 200,
                      height: 60.0,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text(AppLocalizations.of(context).translate('done'), style: TextStyle(color: Colors.white, fontSize: 22),),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
