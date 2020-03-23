import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhealth/repositories/local/concept_manager_repository_local.dart';

class ConceptManager {
  sync() async {
    var collection = await Firestore.instance.collection('concepts').getDocuments();

    collection.documents.forEach((item) async {
      await ConceptManagerRepositoryLocal().create(item.data);
    });

  }
}
