import 'package:flutter/material.dart';
import 'package:nhealth/helpers/helpers.dart';
import 'package:nhealth/models/patient.dart';

class PatientTopbar extends StatelessWidget {
  const PatientTopbar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 17, horizontal: 10),
      decoration: BoxDecoration(
      color: Colors.white,
        boxShadow: [BoxShadow(
          blurRadius: 20.0,
          color: Colors.black,
          offset: Offset(0.0, 1.0)
        )]
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Row(
                children: <Widget>[
                  Patient().getPatient()['data']['avatar'] == null ? 
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Image.asset(
                      'assets/images/avatar.png',
                      height: 35.0,
                      width: 35.0,
                    ),
                  ) :
                  CircleAvatar(
                    radius: 17,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Image.network(
                        Patient().getPatient()['data']['avatar'],
                        height: 35.0,
                        width: 35.0,
                      ),
                    ),
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  SizedBox(width: 15,),
                  Text(Helpers().getPatientName(Patient().getPatient()), style: TextStyle(fontSize: 18))
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(Helpers().getPatientAgeAndGender(Patient().getPatient()), style: TextStyle(fontSize: 18), textAlign: TextAlign.center,)
          ),
          Expanded(
            child: Text('PID: N-121933421', style: TextStyle(fontSize: 18))
          )
        ],
      ),
    );
  }
}
