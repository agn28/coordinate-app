import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/widgets/search_widget.dart';

class WorkListSearchScreen extends CupertinoPageRoute {
  WorkListSearchScreen()
      : super(builder: (BuildContext context) => new WorkListSearch());

}

class WorkListSearch extends StatefulWidget {
  @override
  _WorkListSearchState createState() => _WorkListSearchState();
}

class _WorkListSearchState extends State<WorkListSearch> {

  List patients = [];
  List workList = [1, 2];

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
        title: const Text("Work List"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              color: kPrimaryColor,
              child: Column(
                children: <Widget>[
                  workList.length > 0 ? CustomSearchWidget(
                    listContainerHeight: 500,
                    dataList: patients,
                    hideSearchBoxWhenItemSelected: false,
                    queryBuilder: (query, list) {
                      return patients
                        .toList();
                    },
                    popupListItemBuilder: (item) {
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
                  workList.length == 0 ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 15),
                        child: Text('No item found', style: TextStyle(color: Colors.white, fontSize: 20),),
                      )
                    ],
                  ) : Container()
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
        // Patient().setPatient(item);
        // Navigator.of(context).push(PatientRecordsScreen());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: kBackgroundGrey,
          borderRadius: BorderRadius.circular(3)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      child: Image.asset('assets/images/work_list_1.png', )
                    ),
                  ),
                  SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Nurul begum', style: TextStyle(fontSize: 18),),
                      SizedBox(height: 12,),
                      Text('45Y F - 1992121324283', style: TextStyle(fontSize: 16),),
                      SizedBox(height: 12,),
                      Text('Counselling about reduced salt intake', style: TextStyle(fontSize: 15, color: kTextGrey),),
                      SizedBox(height: 12,),
                      Text('Within 1 month of recommendation of goal', style: TextStyle(fontSize: 15, color: kTextGrey),),
                    ],
                  )
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: kPrimaryColor,)
          ],
        ),
      ),
    );
  }
}
