import 'package:flutter/material.dart';
import 'total_cholesterol_screen.dart';

class BloodTestScreen extends StatelessWidget {
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
                  GestureDetector(
                    onTap: () => Navigator.push(context, 
                      MaterialPageRoute(builder: (ctx) => TotalCholesterolScreen())
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 10,
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(bottom: 20, top: 20),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(width: 1, color: Colors.black12)
                              )
                            ),
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 45),
                                Text('Total Cholesterol', style: TextStyle(fontSize: 20,),)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 15, top: 13),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(width: 1, color: Colors.black12)
                              )
                            ),
                            alignment: Alignment.topRight,
                            child: Icon(Icons.highlight_off, color: Colors.red, size: 36,),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(bottom: 20, top: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 45),
                              Text('HDL', style: TextStyle(fontSize: 20,),)
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15, top: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.red, size: 36,),
                        ),
                      ),
                    ],
                  ),
                  
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(bottom: 20, top: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 45),
                              Text('Triglycerides', style: TextStyle(fontSize: 20,),)
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15, top: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.red, size: 36,),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(bottom: 20, top: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.equalizer),
                              SizedBox(width: 20),
                              Text('Blood Glucose', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15, top: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.red, size: 36,),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(bottom: 20, top: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.event_note),
                              SizedBox(width: 20),
                              Text('HbA1c', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15, top: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.red, size: 36,),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(bottom: 20, top: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.healing),
                              SizedBox(width: 20),
                              Text('2H OGTT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15, top: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.black12)
                            )
                          ),
                          alignment: Alignment.topRight,
                          child: Icon(Icons.highlight_off, color: Colors.red, size: 36,),
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
