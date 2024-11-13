import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// class ExampleAccountPage extends StatefulWidget {
//   const ExampleAccountPage({super.key});

//   @override
//   _ExampleAccountPageState createState() => _ExampleAccountPageState();
// }

// class _ExampleAccountPageState extends State<ExampleAccountPage> {
  

//   @override
//   void initState() {
//     super.initState();
//     // Gọi hàm nhập dữ liệu tự động vào Firebase
//     addSampleAccounts();
//   }

  Future<void> addSampleAccounts() async {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("accounts");
    // Dữ liệu mẫu 7 tài khoản
    List<Map<String, dynamic>> sampleAccounts = [
      {
        "id": 1,
        "username": "user_one",
        "email": "user1@example.com",
        "phone": 1234567890,
        "password": "password1",
        "list_friends": "[]",
        "score": 10,
        "role": false,
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": true,
      },
      {
        "id": 2,
        "username": "user_two",
        "email": "user2@example.com",
        "phone": 2345678901,
        "password": "password2",
        "list_friends": "[]",
        "score": 20,
        "role": false,
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": false,
      },
      {
        "id": 3,
        "username": "user_three",
        "email": "user3@example.com",
        "phone": 3456789012,
        "password": "password3",
        "list_friends": "[]",
        "score": 30,
        "role": false,
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": true,
      },
      {
        "id": 4,
        "username": "user_four",
        "email": "user4@example.com",
        "phone": 4567890123,
        "password": "password4",
        "list_friends": "[]",
        "score": 40,
        "role": true,
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": false,
      },
      {
        "id": 5,
        "username": "user_five",
        "email": "user5@example.com",
        "phone": 5678901234,
        "password": "password5",
        "list_friends": "[]",
        "score": 50,
        "role": false,
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": true,
      },
      {
        "id": 6,
        "username": "user_six",
        "email": "user6@example.com",
        "phone": 6789012345,
        "password": "password6",
        "list_friends": "[]",
        "score": 60,
        "role": false,
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": false,
      },
      {
        "id": 7,
        "username": "user_seven",
        "email": "user7@example.com",
        "phone": 7890123456,
        "password": "password7",
        "list_friends": "[]",
        "score": 70,
        "role": true,
        "created_at": DateTime.now().toString(),
        "update_at": DateTime.now().toString(),
        "status": true,
      },
    ];

    // Lặp qua danh sách tài khoản và thêm từng tài khoản vào Firebase
    for (var account in sampleAccounts) {
      await usersRef.push().set(account);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhập dữ liệu tài khoản tự động"),
      ),
      body: const Center(
        child: Text("Dữ liệu tài khoản mẫu đã được thêm vào Firebase"),
      ),
    );
  }
// }