import 'package:flutter/material.dart';

class RegisterPatientSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(left: 40, right: 40),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50,),
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Color(0xFF1dc555),
                      shape: BoxShape.circle
                    ),
                    child: Icon(Icons.done, size: 150, color: Colors.white,)
                  ),
                  SizedBox(height: 30,),
                  Text('Patient Registered', style: TextStyle(fontSize: 25)),
                  SizedBox(height: 200,),
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 60.0,
                    child: RaisedButton(
                      onPressed: () {},
                      child: Text("Home", style: TextStyle(color: Colors.white, fontSize: 22),),
                    ),
                  ),
                  SizedBox(height: 30,),
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 60.0,
                    child: RaisedButton(
                      onPressed: () {},
                      child: Text("Screen Patient", style: TextStyle(color: Colors.white, fontSize: 22),),
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
