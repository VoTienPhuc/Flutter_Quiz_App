import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class AccountManagerScreen extends StatefulWidget {
  const AccountManagerScreen({super.key});

  @override
  _AccountManagerScreenState createState() => _AccountManagerScreenState();
}

class _AccountManagerScreenState extends State<AccountManagerScreen> {

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Khai báo realtime database, nếu có database cùng tên, lấy collection, nếu không, tạo mới collection
  final DatabaseReference accountRef = FirebaseDatabase.instance.ref().child("accounts");
  //Không cần focusnode do kiểm tra cả 3 trường 1 lúc

  String errorMessage = "";

  //Thêm chủ đề mới với trạng thái mở khóa (status = 1)
  //Sử dụng Future để lập trình bất đồng bộ, đợi sau khi cập nhật dữ liệu rồi mới chạy tiếp chứ không chạy 1 lèo luôn.
  //Future đại diện cho một giá trị mà người dùng sẽ nhận được trong tương lai.
  //Khi thực hiện một tác vụ bất đồng bộ, người dùng không thể nhận ngay kết quả ngay lập tức vì tác vụ đó có thể mất một khoảng thời gian để hoàn thành.
  //Do đó, bạn nhận được một Future, cho phép bạn đợi giá trị đó trong tương lai.
  //
  //async là một từ khóa trong Dart dùng để đánh dấu một hàm là bất đồng bộ (asynchronous). 
  //Khi đánh dấu một hàm là async, hàm này sẽ trả về một Future. Có thể sử dụng từ khóa await để đợi kết quả trả về.
  //
  //await được sử dụng trong một hàm async để đợi một Future hoàn thành. Khi sử dụng await, chương trình sẽ tạm dừng thực thi đến khi Future trả về kết quả.

  // Kiểm tra id người dùng
  Future<int> generateNewId() async {
    final snapshot = await FirebaseDatabase.instance.ref().child('id_counter').once();
    final counter = snapshot.snapshot.value as Map?;

    int newId = 1; //nếu chưa có counter, bắt đầu với id là 1

    if (counter != null) {
      // Nếu đã có counter, lấy giá trị id hiện tại
      newId = counter["account_id"] ?? 1;//?? 1: Đây là toán tử null-aware (kiểm tra null). 
                                        //Nếu counter["account_id"] là null (tức là nếu Firebase không có giá trị account_id, chẳng hạn khi chưa khởi tạo lần đầu), 
                                        //thì giá trị mặc định là 1 sẽ được gán cho newId. Điều này đảm bảo rằng nếu chưa có giá trị nào trong account_id, 
                                        //ID đầu tiên sẽ bắt đầu từ 1.
    }

    // Cập nhật lại counter
    await FirebaseDatabase.instance.ref().child('id_counter').update({
      'account_id': newId + 1,
    });

    return newId;
  }

  // Thêm tài khoản
  Future<void> addAccount() async {//Sử dụng Future,async,await để lập trình bất đồng bộ
    // Kiểm tra nếu username, email hoặc password trống
    if (usernameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
        setState(() {
          errorMessage = 'Tất cả các trường đều phải điền đầy đủ!';
        });

        return; // Dừng hàm nếu có trường rỗng
    } else {
        setState(() {
          errorMessage = ''; // Xóa thông báo lỗi nếu không có lỗi
        });
    }
    
    // Kiểm tra nếu username ít hơn 8 kí tự, có kí tự đặc biệt, có chữ số
    RegExp upperCaseExp = RegExp(r'[A-Z]');
    RegExp specialCharExp = RegExp(r'[!@#\$%&*]');
    RegExp numberExp = RegExp(r'[0-9]');
    if (usernameController.text.length<8 || 
        !specialCharExp.hasMatch(usernameController.text) || 
        !upperCaseExp.hasMatch(usernameController.text) || 
        !numberExp.hasMatch(usernameController.text)) {
        setState(() {
          errorMessage = 'Username phải hơn 8 kí tự, có ít nhất 1 ký tự đặc biệt, ít nhất 1 chữ số';
        });

        return; // Dừng hàm nếu gặp lỗi
    } else {
        setState(() {
          errorMessage = ''; // Xóa thông báo lỗi nếu không có lỗi
        });
    }

    // Kiểm tra email có kết thúc bằng @gmail.com
    if (!emailController.text.endsWith("@gmail.com")) {
        setState(() {
          errorMessage = 'Phần đuôi của email phải là @gmail.com';
        });

        return; // Dừng hàm nếu có trường rỗng
    } else {
        setState(() {
          errorMessage = ''; // Xóa thông báo lỗi nếu không có lỗi
        });
    }
    

    // Kiểm tra nếu username hoặc email đã tồn tại trong database
    final snapshot = await accountRef.once();
    final users = snapshot.snapshot.value as Map?;

    if (users != null) {
      bool isUsernameDuplicate = users.values.any((user) => (user as Map)['username'] == usernameController.text);
      bool isEmailDuplicate = users.values.any((user) => (user as Map)['email'] == emailController.text);

      if (isUsernameDuplicate) {
        setState(() {
          errorMessage = 'Tên người dùng đã tồn tại!';
        });
        return; // Dừng hàm nếu username trùng
      }

      if (isEmailDuplicate) {
        setState(() {
          errorMessage = 'Email đã tồn tại!';
        });
        return; // Dừng hàm nếu email trùng
      }
    }

    // Tạo ID mới cho tài khoản
    final newId = await generateNewId();

    // Thêm tài khoản người dùng vào Firebase Realtime Database
    await accountRef.push().set({
      "id": newId,
      "username": usernameController.text,
      "email": emailController.text,
      "phone": "", // Mặc định là rỗng
      "password": passwordController.text,
      "list_friends": "", // Mặc định là rỗng
      "score": 0,
      "role": false, // Mặc định là người dùng bình thường
      "created_at": DateTime.now().toString(),
      "update_at": DateTime.now().toString(),
      "status": false, // Mặc định tài khoản bị khóa
    });

    // Xóa các trường trong form sau khi thêm tài khoản thành công
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  // Thay đổi trạng thái tài khoản (khóa/mở khóa)
  Future<void> toggleUserStatus(String key, bool currentStatus) async {

    await accountRef.child(key).update({
      "status": !currentStatus, // Đảo ngược trạng thái
      "update_at": DateTime.now().toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản Lý Tài Khoản"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Tên đăng nhập"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Mật khẩu"),
                  obscureText: true, // Đảm bảo mật khẩu được ẩn
                ),
                ElevatedButton(
                  onPressed: addAccount, // Gọi hàm thêm tài khoản mới
                  child: const Text("Thêm Tài Khoản Mới"),
                ),
                if (errorMessage.isNotEmpty) 
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: FirebaseAnimatedList(
              query: accountRef,
              itemBuilder: (context, snapshot, animation, index) {
                Map user = snapshot.value as Map;
                bool isActive = user["status"];

                return ListTile(
                  title: Text(user["username"]),
                  subtitle: Text(user["email"]),
                  trailing: IconButton(
                    icon: Icon(
                      isActive ? Icons.lock_open : Icons.lock,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                    onPressed: () => toggleUserStatus(snapshot.key!, isActive),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){}),
    );
  }
}
