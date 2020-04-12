import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:nhealth/models/auth.dart';
import 'package:nhealth/models/patient.dart';
import 'dart:developer';

var _questions = {
    'tobacco': {
      'items' : [
        {
          'question': 'Have you used tobacco (all forms – cigarettes, biri, chewing tobacco, zarda, gul) during the past 12 months?',
          'options': ['yes', 'no']
        },
        {
          'question': 'Were you regularly exposed to secondhand tobacco smoke in the past 12 months?',
          'options': ['yes', 'no']
        }
      ]
    },
    'alcohol': {
      'items' : [
        {
          'question': 'Did you drink any alcohol in the last 30 days?',
          'options': ['yes', 'no']
        },
        {
          'question': 'How many days in the last 30 days?',
          'options': ['yes', 'no']
        },
        {
          'question': 'How many standard drinks units per day?',
          'options': ['yes', 'no']
        }
      ]
    },
    'diet': {
      'items' : [
        {
          'question': 'Do you eat at least 5 portions of fruit and vegetables (excluding starchy vegetables) daily? (1 serving = 0.5 cup cooked vegetables or 1 cup raw vegetables; 1 orange, apple, banana, mango)',
          'options': ['yes', 'no']
        },
        {
          'question': 'Do you eat red meat, fried foods, canned or other processed foods on most days?',
          'options': ['yes', 'no']
        },
        {
          'question': 'Do you have sugary drinks (for example, soda, juice, sweetened milk) on most days?',
          'options': ['yes', 'no']
        },
        {
          'question': 'Do you add extra salt to your meals?',
          'options': ['yes', 'no']
        }
      ],
    },
    'physical_activity': {
      'items' : [
        {
          'question': 'Do you do physical activity of moderate intensity i.e. you get a little bit out of breath, for at least 30 minutes per day on 5 days per week, or for 150 minutes per week?',
          'options': ['yes', 'no']
        },
        {
          'question': 'Do you spend more than 5 hours sitting down every day?',
          'options': ['yes', 'no']
        },
      ]
    },

    'current_medication': {
      'items' : [
        {
          'question': 'What medications are you taking (including over-the-counter /herbal /traditional remedies/recreational)?',
          'options': ['yes', 'no']
        },
        {
          'question': 'Are you taking your medications exactly as prescribed?',
          'options': ['yes', 'no']
        },
        {
          'question': 'What problems have you had taking your medicines?',
          'options': ['yes', 'no']
        },
      ]
    },

    'medical_history': {
      'items' : [
        {
          'question': 'Heart attack/angina/other heart diseases (e.g. heart failure, rheumatic heart disease)',
          'options': ['yes', 'no']
        },
        {
          'question': 'Stroke/ transient ischaemic attack (TIA)',
          'options': ['yes', 'no']
        },
        {
          'question': 'High blood pressure (hypertension)',
          'options': ['yes', 'no']
        },
        {
          'question': 'High blood sugar (diabetes)',
          'options': ['yes', 'no']
        },
        {
          'question': 'High blood cholesterol or dyslipidemia',
          'options': ['yes', 'no']
        },
        {
          'question': 'Kidney disease',
          'options': ['yes', 'no']
        },
        {
          'question': 'Other illnesses such as tuberculosis, HIV (confirm HIV status, testing as per national guidelines)',
          'options': ['yes', 'no']
        },
        {
          'question': 'Do you have any allergies?',
          'type': 'allergy',
          'options': ['yes', 'no']
        },
      ]
    }
    
};

var _qnItems = [];

List _questionnaireItems = [];
var _alcoholItems = {};
var _tobaccoItems = {};
List _physicalActivityItems = [];
List _medicalHistoryItems = [];

class Questionnaire {

  /// Add questionnnaire answers
  /// [type], [comment] are required
  addQuestionnaire(type, answers) {
    var questions = Questionnaire().questions[type];
    var data = [];
    return;

    questions['items'].forEach((item) {
      _qnItems.add(_prepareData(questions, item, answers, type));
    });

    return 'success';
  }

  addQnItemsForEdit(observation) {
    _questionnaireItems.add(observation);
    _qnItems.add(observation['body']['data']);
  }

  addTobacco(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareTobaccoData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareTobaccoData(questions, answers, type));
    }

    return 'success';
  }

  addPhysicalActivity(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _preparePhysicalActivityData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_preparePhysicalActivityData(questions, answers, type));
    }
    
    return 'success';
  }

  addMedicalHistory(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareMedicalHistoryData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareMedicalHistoryData(questions, answers, type));
    }

    return 'success';
  }

  addCurrentMedication(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareCurrentMedicationData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareCurrentMedicationData(questions, answers, type));
    }
    
    return 'success';
  }

  addDiet(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;

    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareDietData(questions, answers, type);
        updated = true;
      }
    }

    if (!updated) {
      _questionnaireItems.add(_prepareDietData(questions, answers, type));
    }
    
    return 'success';
  }

  addAlcohol(type, answers) {
    var questions = Questionnaire().questions[type];
    var updated = false;
    for (var qn in _questionnaireItems) {
      if (qn['body']['data']['type'] == type) {
        answers.length == 1 ? _questionnaireItems[_questionnaireItems.indexOf(qn)] = _prepareNonAlcoholData(questions, answers, type) : _questionnaireItems[_questionnaireItems.indexOf(qn)] = _alcoholItems = _prepareAlcoholData(questions, answers, type); 
        updated = true;
      } 
    }

    if (!updated) {
      answers.length == 1 ? _questionnaireItems.add(_prepareNonAlcoholData(questions, answers, type)) : _questionnaireItems.add(_prepareAlcoholData(questions, answers, type));
    }
    
    return 'success';
  }

  /// Prepare questionnaire data
  _prepareCurrentMedicationData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'medications': answers[0],
          'as_prescribed': answers[1],
          'problems_by_taking_medicines': answers[2],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  _prepareNonAlcoholData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'last_30_days': answers[0],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  _prepareAlcoholData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'last_30_days': answers[0],
          'days': int.parse(answers[1]),
          'units_per_day': int.parse(answers[2]),
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  _prepareTobaccoData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'last_12_months': answers[0],
          'secondhand_smoke': answers[1]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Prepare questionnaire data
  _prepareDietData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'fruits_vegitables_daily': answers[0],
          'processed_foods': answers[1],
          'sugary_drinks': answers[2],
          'extra_salt': answers[3]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Prepare questionnaire data
  _preparePhysicalActivityData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'physical_activity': answers[0],
          'sitting_more_than_5_hours': answers[1]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  /// Prepare questionnaire data
  _prepareMedicalHistoryData(questions, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'heart_disease': answers[0],
          'stroke': answers[1],
          'high_blood_pressure': answers[2],
          'diabetes': answers[3],
          'high_blood_cholesterol': answers[4],
          'kidney_disease': answers[5],
          'other_ilness': answers[6],
          'allergies': answers[7],
          'allergy_types': answers[8],
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }


  /// Prepare questionnaire data
  _prepareData(questions, item, answers, type) {
    var data = {
      "meta": {
        "performed_by": Auth().getAuth()['uid'],
        "created_at": DateFormat('y-MM-dd').format(DateTime.now())
      },
      "body": {
        "type": "survey",
        "data": {
          'name': type,
          'question': item['question'],
          'answer': answers[questions['items'].indexOf(item)]
        },
        "patient_id": Patient().getPatient()['uuid'],
      }
    };

    return data;
  }

  isCompleted(type) {
    type = type.replaceAll(' ', '_').toLowerCase();
    for(var item in _questionnaireItems) {
      if (item['body']['data']['name'] == type) {
        return true;
      }
    }
    return false;
  }

  /// Get all answers
  List get qnItems {
    return [..._questionnaireItems];
  }

  clearItems() {
    _questionnaireItems = [];
  }

  // Get all questions
  get questions  {
    return _questions;
  }
}
