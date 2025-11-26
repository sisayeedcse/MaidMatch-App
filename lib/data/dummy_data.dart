import 'package:cloud_firestore/cloud_firestore.dart';

// Our dummy data list
final List<Map<String, dynamic>> dummyMaids = [
  {
    "name": "Rahima Begum",
    "location": "Dhanmondi, Dhaka",
    "rating": "4.8",
    "skill": "Cooking",
    "verified": true,
    "phone": "01700000001",
  },
  {
    "name": "Fatima Akter",
    "location": "Gulshan 1",
    "rating": "4.5",
    "skill": "Cleaning",
    "verified": true,
    "phone": "01700000002",
  },
  {
    "name": "Sumaiya Islam",
    "location": "Banani",
    "rating": "4.9",
    "skill": "Babysitting",
    "verified": true,
    "phone": "01700000003",
  },
  {
    "name": "Aleya Khatun",
    "location": "Mirpur 10",
    "rating": "4.2",
    "skill": "All Rounder",
    "verified": false, // Showing a non-verified one adds realism
    "phone": "01700000004",
  },
];

// Function to upload this to Firebase (Run this once)
Future<void> uploadDummyData() async {
  CollectionReference maids = FirebaseFirestore.instance.collection('maids');

  // Check if data already exists to avoid duplicates
  var snapshot = await maids.get();
  if (snapshot.docs.isNotEmpty) {
    // Data already exists. Skipping upload.
    return;
  }

  for (var maid in dummyMaids) {
    await maids.add(maid);
  }
  // Dummy data uploaded successfully!
}
