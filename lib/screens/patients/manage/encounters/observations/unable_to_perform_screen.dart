import 'package:flutter/material.dart';

class UnableToPerformScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Observations'),
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
                  Text('Enter reason for inablity to perform', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 50,),
                  SizedBox(height: 50,),
                  
                  Container(
                    alignment: Alignment.topCenter,
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      height: 60.0,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text("Patient Refused", style: TextStyle(color: Colors.white, fontSize: 22),),
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
                        child: Text("Patient unable", style: TextStyle(color: Colors.white, fontSize: 22),),
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
                        child: Text("Instrument Error", style: TextStyle(color: Colors.white, fontSize: 22),),
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
                        child: Text("Instrument Unavailable", style: TextStyle(color: Colors.white, fontSize: 22),),
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
                        child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 22),),
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
