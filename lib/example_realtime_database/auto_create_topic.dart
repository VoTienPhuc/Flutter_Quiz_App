
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// class ExampleTopicPage extends StatefulWidget {
//   const ExampleTopicPage({super.key});

//   @override
//   _ExampleTopicPageState createState() => _ExampleTopicPageState();
// }
// class _ExampleTopicPageState extends State<ExampleTopicPage> {
  
//   @override
//   void initState() {
//     super.initState();
//     // Gọi hàm nhập dữ liệu tự động vào Firebase
//     addSampleData();
//   }

  Future<void> addSampleTopic() async {
    final DatabaseReference topicsRef = FirebaseDatabase.instance.ref().child("topics");

    // Dữ liệu mẫu 5 chủ đề
    List<Map<String, dynamic>> sampleTopics = [
      {
        "id":1,
        "title": "Lịch sử",
        "description": "Mô tả về chủ đề 1",
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": true,
      },

      {
        "id":2,
        "title": "Địa lý",
        "description": "Mô tả về chủ đề 2",
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": false,
      },

      {
        "id":3,
        "title": "Toán Học",
        "description": "Mô tả về chủ đề 3",
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": true,
      },

      {
        "id":4,
        "title": "Vật Lý",
        "description": "Mô tả về chủ đề 4",
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": false,
      },

      {  "id":5,
        "title": "Tiếng Anh",
        "description": "Mô tả về chủ đề 5",
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": true,
      },
    ];

    // Lặp qua danh sách chủ đề và thêm từng chủ đề vào Firebase
    for (var topic in sampleTopics) {
      await topicsRef.push().set({
        "id":topic["id"],
        "title": topic["title"],
        "description": topic["description"],
        "created_at": topic["created_at"],
        "update_at": topic["update_at"],
        "status": topic["status"],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhập dữ liệu chủ đề tự động"),
      ),
      body: const Center(
        child: Text("Dữ liệu chủ đềmẫu đã được thêm vào Firebase"),
      ),
    );
  }
// }