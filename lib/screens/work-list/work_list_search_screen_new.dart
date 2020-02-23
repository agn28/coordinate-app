import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:nhealth/widgets/search_widget.dart';
import 'package:nhealth/app_localizations.dart';

final searchController = TextEditingController();
List allWorklist = [];
List worklist = [];

class WorkListSearchScreenNew extends CupertinoPageRoute {
  WorkListSearchScreenNew()
      : super(builder: (BuildContext context) => new WorkListSearch());

}

class WorkListSearch extends StatefulWidget {
  @override
  _WorkListSearchState createState() => _WorkListSearchState();
}

class _WorkListSearchState extends State<WorkListSearch> {

  List patients = [];

  /// Get all the worklist
  _getWorklist() async {
    setState(() {
      allWorklist = ['Rokeya Khatun', 'Zahid Hasan'];
      worklist = allWorklist;
    });
  }

  search(query) {
    setState(() {
      worklist = [...allWorklist]
      .where((item) => item
      .toLowerCase()
      .contains(query.toLowerCase()))
      .toList();
    });
  }

  @override
  initState() {
    super.initState();
    _getWorklist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('workList')),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              // padding: EdgeInsets.symmetric(vertical: 20),
              color: kPrimaryColor,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 20),
                    child: TextField(
                      controller: searchController,
                      onChanged: (query) {
                        search(query);
                      },
                      // focusNode: focusNode,
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
                            setState(() {
                              searchController.text = '';
                              worklist = allWorklist;
                            });
                          },
                          icon: Icon(Icons.cancel, color: kTextGrey, size: 25,)
                        ),
                        border: InputBorder.none,
                        hintText: AppLocalizations.of(context).translate('searchHere'),
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 20,
                          top: 14,
                          bottom: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8,)
                ],
              )
            ),
            SizedBox(height: 20,),
            ...worklist.map((item) => GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
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
                              child: Image.asset('assets/images/work_list_${worklist.indexOf(item) + 1}.png', )
                            ),
                          ),
                          SizedBox(width: 20,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(item, style: TextStyle(fontSize: 18),),
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
            )).toList(),
            worklist.length == 0 ? Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(AppLocalizations.of(context).translate('worklistFound'), style: TextStyle(color: Colors.black87, fontSize: 20),),
            ) : Container()
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
          hintText: AppLocalizations.of(context).translate('searchHere'),
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
          AppLocalizations.of(context).translate('noItems'),
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
      onTap: () {},
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
