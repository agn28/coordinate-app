import 'package:nhealth/models/patient.dart';
import 'package:nhealth/models/questionnaire.dart';

class QuestionnaireController {

  create(type, answers) {
    var questions = Questionnaire().questions[type];
    var data = [];
    print(answers);
    return;
    
    questions['items'].forEach((item) {
      data.add(_prepareData(questions, item, answers));
    });

    return;
  }

  _prepareData(questions, item, answers) {
    var data = {
      "meta": {
        "performed_by": "8vLsBJkEOGOQyyLXQ2vZzycmqQX2",
        "device_id": "DV-1234"
      },
      "body": {
        "type": "questionnaire",
        "data": {
          'question': item['question'],
          'answer': answers[questions['items'].indexOf(item)]
        },
        "patient_id": Patient().getPatient()['uuid'],
        "assessment_id": "264d9d80-1b17-11ea-9ddd-117747515bf8"
      }
    };

    return data;
  }
  
}
