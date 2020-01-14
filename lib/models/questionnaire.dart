import 'package:flutter/material.dart';
import 'package:nhealth/models/patient.dart';

List _qnItems = [];
var _questions = [
  {
    'type': 'tobacco',
    'items' : [
      {
        'question': 'Do you currently smoke any tobacco products daily, such as cigaretts, cigars or pipes?',
        'options': ['Yes', 'No']
      },
      {
        'question': 'Do you take alcohol?',
        'options': ['Never', 'Past (12 months back)', 'Current (within 12 months)']
      }
    ]
  }
];

class Questionnaire {

  addQuestionnaire(type, answers) {

    var questions = Questionnaire().questions.where((qn) => qn['type'] == type).first;
    questions['items'].forEach((item) => {
      _qnItems.add(_prepareData(questions, item, answers, type))
    });

    print(_qnItems);

    return 'success';
  }

  _prepareData(questions, item, answers, type) {
    var data = {
      "meta": {
        "performed_by": "8vLsBJkEOGOQyyLXQ2vZzycmqQX2",
        "device_id": "DV-1234"
      },
      "body": {
        "type": "questionnaire",
        "data": {
          'type': type,
          'question': item['question'],
          'answer': item['options'][answers[questions['items'].indexOf(item)]]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  List get qnItems {
    return [..._qnItems];
  }

  List get questions  {
    return [..._questions];
  }
}