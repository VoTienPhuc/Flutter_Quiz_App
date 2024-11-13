import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quizapp3/admin_page.dart';
import 'package:quizapp3/account/realtime_database_account.dart';
import 'package:quizapp3/topic/realtime_database_topic.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  //Từ khóa "const" được dùng khi giá trị của biến ĐƯỢC BIẾT TRƯỚC và không đổi - hay nói cách khác là Hằng Số.
  //Ví dụ, tạo biến const double pi = 3.14; sau khi tạo ra nếu cố thay đổi giá trị của nó thì nó sẽ báo lỗi
  //Sử dụng khi tạo biến tĩnh (Static Variable):Biến static được khai báo trong một class với từ khóa "static", 
  //phía bên ngoài các phương thức, constructor và block.
  //Sẽ chỉ có duy nhất một bản sao của các biến static được tạo ra, dù bạn tạo bao nhiêu đối tượng từ lớp tương ứng.
  //Tạo 1 file a.dart, gõ: class User { final int id; static const String name ="abc"; const User(this.id)}
  //File main.dart, gõ: User user=const User(1);  User user2=const User(1);
  //2 thằng này sẽ có cùng địa chỉ ô nhớ thay vì tạo 2 vùng địa chỉ ô nhớ khác nhau nhưng giá trị y chang nhau.

  //Từ khóa "final" được dùng khi giá trị của biến KHÔNG ĐƯỢC BIẾT TRƯỚC trong 1 khoảng thời gian,
  //nhưng sau khi biết trước thì không đổi - cũng là Hằng Số.
  //Ví dụ, tạo biến final response, sau đó viết hàm rồi gán cái API cho nó, sau đó giá trị API này không thể đổi.
  //Sử dụng khi tạo biến toàn cục (Instance Variable)

  //"final" và "const" trên thực tế là giống nhau, đều không thay đổi giá trị của biến
  //nhưng "final" ít nghiêm ngặt hơn, nó chứa các giá trị không thay đổi
  //nhưng giá trị đó có thể không xác định trong 1 khoảng thời gian ngay cả sau khi biên dịch
  //nhưng một khi đã xác định thì giá trị đó không bao giờ thay đổi
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return   MaterialApp(
      initialRoute: "/",
      routes: {
        "/topicManager": (context) => const TopicManagerScreen(),
        "/questionManager": (context) => const TopicManagerScreen(),
        "/accountManager": (context) => const AccountManagerScreen(),
      },
      debugShowCheckedModeBanner: false,
      //home: const ExampleTopicPage(),//Tạo tự động 5 chủ đề có id từ 1-5
      //home: const QuestionManagerScreen(),
      home: const AdminHomePage(),//Home, chạy ra admin
      //home: const TopicManagerScreen()
      //home: const AccountManagerScreen(),//Mặc định khi tạo flutter, thay đổi tên "MyHomePage" thành tên khác để chạy
    );
  }
}

