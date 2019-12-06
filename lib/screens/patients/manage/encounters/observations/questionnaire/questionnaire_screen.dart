import 'package:flutter/material.dart';

class QuestionnaireScreen extends StatelessWidget {
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
                  Text('Enter blood test result (where available)', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 50,),
                  
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.drafts),
                              SizedBox(width: 20),
                              Text('Lipid Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.transparent, size: 36,),
                        ),
                      ),
                    ],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
