import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:flutter/cupertino.dart';




class AllergiesTab extends StatefulWidget {
  AllergiesTab({this.allergies});

  var allergies;

  @override
  _AllergiesState createState() => _AllergiesState();
}

class _AllergiesState extends State<AllergiesTab> {
  bool isLoading = false;
  bool confirmLoading = false;
  bool reviewLoading = false;

  bool canEdit = false;
  final commentsController = TextEditingController();
  var medications = [];
  var conditions = [];
  bool avatarExists = false;

  @override
  initState() {
    super.initState();

    // getReports();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.allergies.length > 0 ? "Allergies" : 'No Allergy types', style: TextStyle(fontSize: 21),),
          SizedBox(height: 10,),

          ...widget.allergies.map((item) {
            return Container(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: kBorderLighter)
                )
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.lens, size: 7, color: kPrimaryColor),
                  SizedBox(width: 20,),
                  Text(item, style: TextStyle(fontSize: 17),),
                ],
              ),
            );
          }).toList(),

        ],
      ),
    );
  }
}
