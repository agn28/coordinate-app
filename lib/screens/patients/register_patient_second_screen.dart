import 'package:flutter/material.dart';
import 'register_patient_third_screen.dart';

class RegisterPatientSecondScreen extends StatelessWidget {
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
              child: Text('Contact Person', style: TextStyle(fontSize: 20),),
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
                      hintText: "Contact First Name",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Contact Last Name",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Relationship",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Contact Address",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Contact Mobile Phone",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Contact Home Phone",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    style: TextStyle(
                      fontSize: 22,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Contact Email",
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15)
                    ),
                  ),
                  SizedBox(height: 20,),
                  ButtonTheme(
                    minWidth: 200.0,
                    height: 60.0,
                    child: RaisedButton(
                      onPressed: () => Navigator.push(context, 
                        MaterialPageRoute(builder: (ctx) => RegisterPatientThirdScreen())
                      ),
                      child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 22),),
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
