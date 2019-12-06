import 'package:flutter/material.dart';
import 'register_patient_success_screen.dart';

class RegisterPatientThirdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 40, right: 40, top: 20),
              child: Text('National ID', style: TextStyle(fontSize: 20),),
            ),
            
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 40, right: 40),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20,),
                  TextField(
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "National ID",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 40,),
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 60.0,
                    child: RaisedButton(
                      onPressed: () => Navigator.push(context, 
                        MaterialPageRoute(builder: (ctx) => RegisterPatientSuccessScreen())
                      ),
                      child: Text("Register", style: TextStyle(color: Colors.white, fontSize: 22),),
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
