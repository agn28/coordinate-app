import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'package:nhealth/app_localizations.dart';
import 'package:nhealth/constants/constants.dart';
import 'package:nhealth/controllers/followup_controller.dart';
import 'package:nhealth/controllers/patient_controller.dart';
import 'package:nhealth/custom-classes/custom_toast.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'package:nhealth/screens/auth_screen.dart';
import 'package:nhealth/widgets/patient_topbar_widget.dart';

class EditPatientScreen extends StatefulWidget {
  static const path = '/editPatient';
  @override
  _EditPatientScreenState createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  var _patient;
  bool isLoading = false;
  bool avatarExists = false;
  final format = DateFormat("yyyy-MM-dd");
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();


  List referralReasons = ['urgent medical attempt required', 'NCD screening required'];
  var selectedReason;
  List clinicTypes = ['community clinic', 'upazila health complex', 'hospital'];
  var selectedtype;
  List status = ['pending', 'completed'];
  var selectedStatus;
  var clinicNameController = TextEditingController();
  var outcomeController = TextEditingController();
  var dateController = TextEditingController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();

  var selectedDate;

  setDate(date) {
    if (date != null) {
      selectedDate = date;
    }
  }

  @override
  void initState() {
    super.initState();
    _patient = Patient().getPatient();
    Helpers().clearObservationItems();
    setData();
  }

  setData() {
    print(_patient);
    setState(() {
      firstNameController.text = _patient['data']['first_name'];
      lastNameController.text = _patient['data']['last_name'];
      phoneController.text = _patient['data']['mobile'] ?? '';
      emailController.text = _patient['data']['email'] ?? '';
      storageAvatar = Patient().getPatient()['data']['avatar'] ?? '';
    });
  }

  _checkAvatar() async {
    avatarExists = await File(Patient().getPatient()['data']['avatar']).exists();
  }

  _checkAuth() {
    if (Auth().isExpired()) {
      Auth().logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => AuthScreen()));
    }
  }
  File _image;
  bool firstTime = true;
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: gsBucket);
  StorageUploadTask _uploadTask;
  String storageAvatar = '';
  String uploadedImageUrl = '';
  bool imageUpdated = false;
  Future getImageFromCam() async {
    _image = await ImagePicker.pickImage(source: ImageSource.camera);
    // setState(() {
    //   _image = image;
    // });

    imageUpdated = true;
    await cropImage();
  }

  cropImage() async {
    
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: _image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: kPrimaryColor,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      )
    );
    if (croppedImage != null) {
      _image.delete();
      setState(() {
        _image = croppedImage;
      });
    } else if (firstTime) {
      _image.delete();
      setState(() {
        firstTime = false;
        _image = null;
      });
    }
    
  }

  uploadImage() async {
    var url = '';
    if (_image != null) {
      String filePath = 'images/patients/${firstNameController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('file path');
      print(filePath);

      setState(() {
        _uploadTask = _storage.ref().child(filePath).putFile(_image);
      });
      await _uploadTask.onComplete;
      if (_uploadTask.isComplete) {
        var url = await _storage.ref().child(filePath).getDownloadURL();
        print('url');
        print(url);
        setState(() {
          uploadedImageUrl = url;
        });
      }

      // if (_uploadTask.isCanceled) {

      // }


      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate('updatePatient'), style: TextStyle(color: Colors.white, fontSize: 20),),
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      PatientTopbar(),
                      SizedBox(height: 30,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(AppLocalizations.of(context).translate('firstName'), style: TextStyle(fontSize: 20),)
                      ),
                      SizedBox(height: 10,),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        color: kSecondaryTextField,
                        child: TextField(
                          enabled: false,
                          style: TextStyle(
                            color: Colors.grey
                          ),
                          controller: firstNameController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10, right: 10),
                            hintStyle: TextStyle(fontSize: 18)
                          ),
                        )
                      ),

                      SizedBox(height: 20,),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(AppLocalizations.of(context).translate('lastName'), style: TextStyle(fontSize: 20),)
                      ),
                      SizedBox(height: 10,),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        color: kSecondaryTextField,
                        child: TextField(
                          enabled: false,
                          controller: lastNameController,
                          style: TextStyle(
                            color: Colors.grey
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10, right: 10),
                            hintStyle: TextStyle(fontSize: 18)
                          ),
                        )
                      ),

                      SizedBox(height: 20,),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(AppLocalizations.of(context).translate('mobile'), style: TextStyle(fontSize: 20),)
                      ),
                      SizedBox(height: 10,),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        color: kSecondaryTextField,
                        child: TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10, right: 10),
                            hintStyle: TextStyle(fontSize: 18)
                          ),
                        )
                      ),

                      SizedBox(height: 20,),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(AppLocalizations.of(context).translate('emailAddress'), style: TextStyle(fontSize: 20),)
                      ),
                      SizedBox(height: 10,),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        color: kSecondaryTextField,
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10, right: 10),
                            hintStyle: TextStyle(fontSize: 18)
                          ),
                        )
                      ),

                      Container(
                        height: 130,
                        margin: EdgeInsets.only(left: 20, top: 20),
                        // width: 200,
                        // alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: kTableBorderGrey)
                        ),
                        child: _image == null && storageAvatar == '' ? 
                        GestureDetector(
                          onTap: () => getImageFromCam(),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.camera_alt, size: 60, color: kPrimaryColor,),
                                Text(AppLocalizations.of(context).translate('addPhoto'), style: TextStyle(color: kPrimaryColor, fontSize: 20, height: 1))
                              ],
                            ),
                          ),
                        ) : _image == null && storageAvatar != '' ? 
                        Container(
                          height: 120,
                          width: 120,
                          child: Stack(
                          children: <Widget>[
                            Image.network(storageAvatar, fit: BoxFit.contain),
                            CachedNetworkImage(
                              imageUrl: storageAvatar,
                              placeholder: (context,url) => 
                              Center(),
                              errorWidget: (context,url,error) => 
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.error),
                                    Text(AppLocalizations.of(context).translate("imageNotFound"))
                                  ],
                                )
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 40,
                              child: GestureDetector(
                                onTap: () => getImageFromCam(),
                                child: CircleAvatar(
                                  radius: 15,
                                  child: Icon(Icons.edit, size: 20,),
                                ),
                              ),
                            )
                          ],
                        ),
                        ) : Container(
                          height: 120,
                          width: 120,
                          child: Stack(
                          children: <Widget>[
                            Image.file(_image, fit: BoxFit.contain),
                            Positioned(
                              bottom: 0,
                              left: 20,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _image.delete();
                                    setState(() {
                                      storageAvatar = '';
                                    });
                                    _image = null;
                                    firstTime = true;
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 15,
                                  child: Icon(Icons.delete, size: 20,),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 20,
                              child: GestureDetector(
                                onTap: () => cropImage(),
                                child: CircleAvatar(
                                  radius: 15,
                                  child: Icon(Icons.edit, size: 20,),
                                ),
                              ),
                            )
                          ],
                        ),
                        )
                      ) ,

                      SizedBox(height: 50,),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(left: 20, right: 20),
                              height: 50,
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: FlatButton(
                                onPressed: () async {
                                  // return;
                                  // Navigator.of(context).pushNamed('/chwNavigation',);

                                  var data = {
                                    'meta': _patient['meta'],
                                    'body': _patient['data']
                                  };

                                  data['body']['mobile'] = phoneController.text;
                                  data['body']['email'] = emailController.text;

                                  if (imageUpdated) {
                                    var url = await uploadImage();
                                    data['body']['avatar'] = uploadedImageUrl;
                                  }

                                  print(data);

                                  setState(() {
                                    isLoading = true;
                                  });
                                  print('response');
                                  var response = await PatientController().update(data, true);
                                  print('response');
                                  print(response);
                                  setState(() {
                                    isLoading = false;
                                  });

                                  Navigator.of(context).pushReplacementNamed('/chwHome',);
                                  
                                  print('response');
                                  // print(response);
                                  // return;
                                   
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                child: Text(AppLocalizations.of(context).translate('updatePatient').toUpperCase(), style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ], 
                  ),
                ),
              ),
              isLoading ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Color(0x90FFFFFF),
                child: Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),backgroundColor: Color(0x30FFFFFF),)
                ),
              ) : Container(),
              // Container(
              //   height: 300,
              //   width: double.infinity,
              //   color: Colors.black12,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
