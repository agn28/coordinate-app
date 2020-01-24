import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/patients/manage/patient_records_screen.dart';
import 'package:nhealth/screens/patients/manage/search_widget.dart';
import 'package:nhealth/screens/patients/register_patient_screen.dart';

class TestSearchScreen extends CupertinoPageRoute {
  TestSearchScreen()
      : super(builder: (BuildContext context) => new TestSearch());

}

class TestSearch extends StatefulWidget {
  @override
  _TestSearchState createState() => _TestSearchState();
}

class _TestSearchState extends State<TestSearch> {

  List patients = [];

  _getPatients() async {
    var data = await PatientController().getAllPatients();
    setState(() {
      patients =  data;
    });
  }

  @override
  initState() {
    super.initState();
    _getPatients();
  }
  LeaderBoard _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Patients"),
        elevation: 0,
        actions: <Widget>[
          FlatButton(
            child: Column(
              children: <Widget>[
                SizedBox(height: 5,),
                Icon(Icons.person_add, color: Colors.white, size: 20,),
                SizedBox(height: 5,),
                Text('New Patient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),)
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(RegisterPatientScreen());
            },
          ),
          FlatButton(
            child: Column(
              children: <Widget>[
                SizedBox(height: 5,),
                Icon(Icons.fingerprint, color: Colors.white, size: 20,),
                SizedBox(height: 5,),
                Text('Use Thumbprint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),)
              ],
            ),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              color: kPrimaryColor,
              child: Column(
                children: <Widget>[
                  patients.length > 0 ? CustomSearchWidget(
                  listContainerHeight: 500,
                  dataList: patients,
                  hideSearchBoxWhenItemSelected: false,
                  queryBuilder: (query, list) {
                    return patients
                      .where((item) => item['data']['name']
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                      .toList();
                  },
                  popupListItemBuilder: (item) {
                    print(item);
                    return PopupListItemWidget(item);
                  },
                  selectedItemBuilder: (selectedItem, deleteSelectedItem) {
                    return SelectedItemWidget(selectedItem, deleteSelectedItem);
                  },
                  // widget customization
                  noItemsFoundWidget: NoItemsFound(),
                  textFieldBuilder: (controller, focusNode) {
                    return MyTextField(controller, focusNode);
                  },
                  onItemSelected: (item) {
                    setState(() {
                      _selectedItem = item;
                    });
                  },
                ) : Container(),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 20),
                  child: Text('Pending Recommendations Only', style: TextStyle(color: Colors.white),),
                ),
                ],
              )
            ),
            Text(''),
          ],
        ),
      ),
    );
  }
}

class LeaderBoard {
  LeaderBoard(this.username, this.score);

  final String username;
  final double score;
}

class SelectedItemWidget extends StatelessWidget {
  const SelectedItemWidget(this.selectedItem, this.deleteSelectedItem);

  final selectedItem;
  final VoidCallback deleteSelectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}

class MyTextField extends StatelessWidget {
  const MyTextField(this.controller, this.focusNode);

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x4437474F),
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5)
            )
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: () { 
              controller.text = '';
             },
            icon: Icon(Icons.cancel, color: kTextGrey, size: 25,)
          ),
          border: InputBorder.none,
          hintText: "Search here...",
          contentPadding: const EdgeInsets.only(
            left: 16,
            right: 20,
            top: 14,
            bottom: 14,
          ),
        ),
      ),
    );
  }
}

class NoItemsFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.folder_open,
          size: 24,
          color: Colors.grey[900].withOpacity(0.7),
        ),
        const SizedBox(width: 10),
        Text(
          "No Items Found",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[900].withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class PopupListItemWidget extends StatelessWidget {
  const PopupListItemWidget(this.item);

  final item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('hello');
        Patient().setPatient(item);
          Navigator.of(context).push(PatientRecordsScreen());
      },
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(item['data']['name'],
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),
            Expanded(
              child: Text(item['data']['age'].toString() + 'Y ' + '${item['data']['gender'][0].toUpperCase()}' + ' - ' + item['data']['nid'].toString(), 
              style: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400
                ), 
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
