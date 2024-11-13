import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import "package:quizapp3/example_realtime_database/auto_create_account.dart";
import "package:quizapp3/example_realtime_database/auto_create_topic.dart";


class AdminHomePage extends StatefulWidget {
  const AdminHomePage(
      {super.key}); // đây là chỗ yêu cầu "title"
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeIdCounter();//gọi hàm tạo counter
  }

  //Hàm tạo counter
  Future<void> initializeIdCounter() async {
   // final snapshot = await FirebaseDatabase.instance.ref().child('id_counter').once();//once() được sử dụng để thực hiện một yêu cầu đọc dữ liệu ngay lập tức, 
                                                                                      //nhận dữ liệu một lần duy nhất từ Firebase và sau đó ngừng lắng nghe. 
                                                                                      //Kết quả trả về là một DataSnapshot chứa dữ liệu hiện có tại vị trí đã chỉ định.
                                                                                       //Nếu không thêm .once() hoặc onValue, chỉ có một DatabaseReference trỏ tới vị trí đó,
                                                                                       //và không có hành động nào được thực hiện để lấy dữ liệu.
                                                                                       //Điều này sẽ không tạo ra bất kỳ yêu cầu đọc nào, nên sẽ không nhận được dữ liệu từ Firebase.

    //if (snapshot.snapshot.value == null) {
      // Nếu giá trị của id_counter là rỗng
      await FirebaseDatabase.instance.ref().child('id_counter').remove();
      await FirebaseDatabase.instance.ref().child('id_counter').set({
        'topic_id': 1,    // Gán giá trị mặc định cho topic_id
        'account_id': 1,  // Gán giá trị mặc định cho account_id
        'question_id': 1, // Gán giá trị mặc định cho question_id
        'answer_id': 1,   // Gán giá trị mặc định cho answer_id
        
      });
      ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Đã reset lại counter "),
              ),
            );
    //}
  }

  //Hàm xóa dữ liệu của chude
  Future<void> deleteTopicData() async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
      try {
      // Xóa tất cả dữ liệu trong node "chude"
      await databaseRef.child('topics').remove();
      ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Đã xóa dữ liệu của chủ đề"),
              ),
            );
      print("Dữ liệu trong nhóm chủ đề đã được xóa thành công.");
    } catch (e) {
      print("Lỗi khi xóa dữ liệu: $e");
    }
  }

  Future<void> deleteAccountData() async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
      try {
      // Xóa tất cả dữ liệu trong node "chude"
        await databaseRef.child('accounts').remove();
        ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Đã xóa dữ liệu của tài khoản"),
                ),
        );
        print("Dữ liệu trong nhóm chủ đề đã được xóa thành công.");
      } catch (e) {
        print("Lỗi khi xóa dữ liệu: $e");
      }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(//Scaffold là một widget trong Flutter được sử dụng để triển khai cấu trúc bố cục hình ảnh material design cơ bản.
                    //Nó đủ nhanh để tạo một ứng dụng di động có mục đích chung và chứa hầu hết mọi thứ chúng ta cần để tạo một ứng dụng Flutter có chức năng và phản ứng.
                    //Widget này có thể chiếm toàn bộ màn hình thiết bị.
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Colors.purple,
        
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Trang của admin",style: TextStyle(color: Colors.white),), // "title" này sẽ lấy dữ liệu của title trên cùng kia nhất, hoặc cũng có thể
        leading: Builder(//định nghĩa lại nội dung của title này, ví dụ "title: const Text('Paracetamol giảm đau'),"
          builder: (context){
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ), 
      
      drawer: Drawer(
        // thêm menu xổ xuống của các chức năng - ngăn kéo (drawer), nên sử dụng widget "Drawer"
        child: ListView(
          //điền các phần tử vào ngăn kéo, dùng "Column"/ hoặc "Listview" khi phần tử quá nhiều so với màn hình
          padding: EdgeInsets.zero, //Đặt độ lệch bằng không theo mọi hướng
          children:  [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Chức năng"),
            ),

            ListTile(
              title: const Text("Câu hỏi"),
              onTap: () {//Viết code để chuyển tới trang xử lý câu hỏi
                
                Navigator.pop(context);
              },
            ),

            ListTile(
              title: const Text("Chủ đề"),
              onTap: () {//Viết code để chuyển tới trang xử lý chủ đề
                Navigator.pushNamed(context, '/topicManager');
                //Navigator.pop(context);
              },
              
            ),

            ListTile(
              title: const Text("Tài khoản"),
              onTap: () {//Viết code để chuyển tới trang xử lý tài khoản
                Navigator.pushNamed(context, '/accountManager');              
              },
            )
          ],
        ),
      ),
      
      body: Stack(
        alignment: Alignment.center,//Căn chỉnh tất cả các widget con về giữa
        children: [

          //Nút tạo dữ liệu
          Positioned(
            bottom: 80,
            //right: 20,
            child: FloatingActionButton.extended(
              onPressed:  ()async{
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Xin chờ 1 chút, đang tạo dữ liệu mẫu"),
                  ),
                );
                await addSampleTopic();
                await addSampleAccounts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Dữ liệu mẫu của chủ đề và tài khoản đã được thêm vào"),
                  ),
                );
              }, 
              label: const Text("Tạo dữ liệu tự động")
            ),
          ),

          //Nút xóa dữ liệu chủ đề
          Positioned(
            bottom: 160,
            //right: 20,
            child: FloatingActionButton.extended(
              onPressed:  (){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đang xóa dữ liệu của chủ đề"),
                  ),
                );
                deleteTopicData();
                }, 
              label: const Text("Xóa dữ liệu của chủ đề")
            ),
          ),

          //Nút xóa dữ liệu tài khoản
          Positioned(
            bottom: 240,
            //right: 20,
            child: FloatingActionButton.extended(
              onPressed:  (){
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đang xóa dữ liệu của tài khoản"),
                  ),
                );
                deleteAccountData();
                }, 
              label: const Text("Xóa dữ liệu của tài khoản")
            ),
          ),

          //Nút đặt lại counter
          Positioned(
            bottom: 320,
            //right: 20,
            child: FloatingActionButton.extended(
              onPressed:  (){
                initializeIdCounter();
                }, 
              label: const Text("Reset lại counter (id tăng tự động)")
            ),
          ),
          const Positioned(
            top:  40,
            //left: 20,
            child: Text(
              "Các nút dưới đây dùng để test dữ liệu",
              style: TextStyle(
                fontSize: 20,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold
                ),
              )
            ),
        ],
      ),     
    );
  }  
}
