import 'package:flutter/material.dart';
import 'package:nhealth/screens/patients/manage/encounters/observations/unable_to_perform_screen.dart';

class WaistScreen extends StatelessWidget {
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
                  Text('Take Patient Waist Measurement', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 50,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 20),
                          child: TextField(
                            style: TextStyle(
                              fontSize: 22,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Waist",
                              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 15,)
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: TextField(
                            style: TextStyle(
                              fontSize: 22,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "cm",
                              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 15,)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40,),
                  Container(
                    width: double.infinity,
                    child: DropdownButton<String>(
                      style: TextStyle(fontSize: 20, color: Colors.black87,),
                      items: [
                        DropdownMenuItem<String>(
                          child: Text('Item 1'),
                          value: 'one',
                        ),
                        DropdownMenuItem<String>(
                          child: Text('Item 2'),
                          value: 'two',
                        ),
                        DropdownMenuItem<String>(
                          child: Text('Item 3'),
                          value: 'three',
                        ),
                      ],
                      onChanged: (String value) {},
                      hint: Text('Select a Device'),
                    ),
                  ),
                  SizedBox(height: 60,),

                  Container(
                    alignment: Alignment.topCenter,
                    child: TextField(
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        fillColor: Color(0xFFeff0f1),
                        filled: true,
                        hintText: 'Comments/Notes (Optional)',
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    )
                  ),
                  
                  SizedBox(height: 50,),
                  
                  Container(
                    alignment: Alignment.topCenter,
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      height: 60.0,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 22),),
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
                        onPressed: () => Navigator.push(context, 
                            MaterialPageRoute(builder: (ctx) => UnableToPerformScreen())
                        ),
                        child: Text("Unable to Perform", style: TextStyle(color: Colors.white, fontSize: 22),),
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
