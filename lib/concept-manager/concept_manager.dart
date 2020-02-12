import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhealth/repositories/local/concept_manager_repository_local.dart';

class ConceptManager {
  sync() async {
    print('firestore');
    var collection = await Firestore.instance.collection('concepts').getDocuments();
    // print('hello');
    // print(collection.documents[0].data);
    // print(collection.documents[0]);

    collection.documents.forEach((item) async {
      await ConceptManagerRepositoryLocal().create(item.data);
    });

        
  }
}
