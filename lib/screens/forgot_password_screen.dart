import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/primary_button_widget.dart';
import '../widgets/primary_textfield_widget.dart';

class ForgotPasswordScreen extends CupertinoPageRoute {
  ForgotPasswordScreen()
      : super(builder: (BuildContext context) => new ForgotPassword());

}

class ForgotPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password', style: TextStyle(color: Colors.white, fontSize: 22),),
        backgroundColor: kPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white,),
      ),

      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 60),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 40,),
                Container(
                  child: Text('Enter your email address and submit a password reset request to your administrator',
                    style: TextStyle(fontSize: 20,),
                    textAlign: TextAlign.center,
                  )
                ),
                SizedBox(height: 30,),
                PrimaryTextField(
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.black45,
                    size: 30,
                  ),
                  topPaadding: 20,
                  bottomPadding: 20,
                  hintText: 'Email Address',
                ),
                SizedBox(height: 40,),
                PrimaryButton(
                  text: Text('REQUEST PASSWORD RESET', style: TextStyle(color: Colors.white, fontSize: 16)),
                  onTap: () {},
                ),

                SizedBox(height: 40,),
                FlatButton(
                  onPressed: () {},
                  child: Text("Forgot Password?", style: TextStyle(color: Colors.white, fontSize: 19),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
