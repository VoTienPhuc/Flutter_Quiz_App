import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class TopicManagerScreen extends StatefulWidget {
  const TopicManagerScreen({super.key});

  @override
  _TopicManagerScreenState createState() => _TopicManagerScreenState();
}

class _TopicManagerScreenState extends State<TopicManagerScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  //Controller của dialog
  final TextEditingController titleControllerDialog = TextEditingController();
  final TextEditingController descriptionControllerDialog = TextEditingController();
  //Khai báo realtime database, nếu có database cùng tên, lấy collection, nếu không, tạo mới collection
  final DatabaseReference topicsRef = FirebaseDatabase.instance.ref().child("topics");
  //khai báo focusnode để kiểm tra các ô trống khi bấm nút hay không
  final FocusNode titleFocusNode = FocusNode();
  String errorMessage = ""; // Lưu thông báo lỗi (nếu có)
  
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

  //Kiểm tra id chủ đề
  Future<int> generateNewId() async {
    final snapshot = await FirebaseDatabase.instance.ref().child("id_counter").once();
    final counter = snapshot.snapshot.value as Map?;

    int newId = 1; //nếu chưa có counter, bắt đầu với id là 1

    if (counter != null) {
      // Nếu đã có counter, lấy giá trị id hiện tại
      newId = counter["topic_id"] ?? 1;//?? 1: Đây là toán tử null-aware (kiểm tra null). 
                                        //Nếu counter["topic_id"] là null (tức là nếu Firebase không có giá trị topic_id, chẳng hạn khi chưa khởi tạo lần đầu), 
                                        //thì giá trị mặc định là 1 sẽ được gán cho newId. Điều này đảm bảo rằng nếu chưa có giá trị nào trong topic_id, 
                                        //ID đầu tiên sẽ bắt đầu từ 1.
    }
    
    // Cập nhật lại giá trị counter sau khi tạo id mới
  await FirebaseDatabase.instance.ref().child("id_counter").update({
    "topic_id": newId + 1,
  });

  return newId;
  }

  //Thêm chủ đề
  Future<void> addTopic() async {//Sử dụng Future,async,await để lập trình bất đồng bộ
    if (titleController.text.isEmpty) {// Kiểm tra nếu tiêu đề trống
        setState(() {
          errorMessage = "Tiêu đề không được để trống!";
        });
        titleFocusNode.requestFocus(); // Focus vào TextField tiêu đề nếu trống
        return;//Dừng lại hàm addtopic, ngăn không cho nhập dữ liệu tiêu đề rỗng lên database
      } else {
        setState(() {
          errorMessage = ""; //thông báo lỗi là rỗng nếu có dữ liệu
        });
    }

    //Kiểm tra nếu tiêu đề trùng
    final snapshot = await topicsRef.once();//Sử dụng await để lấy dữ liệu một lần từ topicsRef (tức là tham chiếu đến cơ sở dữ liệu Firebase cho các chủ đề).
                                            //topicsRef.once() trả về một DataSnapshot (ảnh chụp dữ liệu) chứa tất cả các mục hiện có trong nhánh topicsRef.
    final topics = snapshot.snapshot.value as Map?;//Gán giá trị của snapshot.snapshot.value (dữ liệu của các chủ đề đã tải từ Firebase) cho biến topics và ép kiểu sang Map?.
                                                  //topics sẽ là null nếu không có chủ đề nào trong Firebase. 
                                                  //Nếu có, topics là một Map trong đó các key là ID của từng chủ đề, còn giá trị là các chi tiết chủ đề (bao gồm tiêu đề, mô tả,trạng thái).
    
    if (topics != null) { 
                        //topics.values lấy tất cả các giá trị trong Map topics (tức là các chi tiết chủ đề).
                        //any là một hàm lặp kiểm tra từng phần tử của danh sách và trả về true nếu điều kiện trong hàm là true với bất kỳ phần tử nào.
                        //ở đây, isDuplicate sẽ là true nếu bất kỳ tiêu đề nào trong Firebase giống với tiêu đề người dùng nhập, và false nếu không.
      bool isDuplicate = topics.values.any((topic) =>
        (topic as Map)["title"] == titleController.text);
      //(topic as Map)["title"] == titleController.text kiểm tra xem tiêu đề của chủ đề trong Firebase có khớp với tiêu đề hiện tại trong TextField (titleController.text) hay không.
      if (isDuplicate) {
        setState(() {
          errorMessage = "Tiêu đề này đã tồn tại!";
        });
        titleFocusNode.requestFocus();
        return; // Dừng lại nếu tiêu đề trùng lặp
      }
    }

    final newId = await generateNewId(); // Tạo id mới tăng tự động dựa trên số lớn nhất

    //Thêm mới chủ đề
    await topicsRef.push().set({
      "id": newId, //thêm id tư động tăng
      "title": titleController.text,
      "description": descriptionController.text,
      "created_at": DateTime.now().toString(),
      "update_at": DateTime.now().toString(),
      "status": true, // Trạng thái mặc định là mở khóa
    });
    titleController.clear();
    descriptionController.clear();
  }

  //Cập nhật thông tin chủ đề
  Future<void> updateTopic(String key,String title, String description) async {
    await topicsRef.child(key).update({
      "title": title,
      "description": description,
      "update_at": DateTime.now().toString(),
    });
    titleController.clear();
    descriptionController.clear();
  }

  //Thay đổi trạng thái của chủ đề
  Future<void> toggleTopicStatus(String key, bool currentStatus) async {
    await topicsRef.child(key).update({
      "status": !currentStatus, // Đảo ngược trạng thái
      "update_at": DateTime.now().toString(),
    });
  }

  //Hiện dialogbox chỉnh sửa chủ đề
  void showEditDialog(BuildContext context, String key, String title, String description) {
    titleControllerDialog.text = title;
    descriptionControllerDialog.text = description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.blue[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    const Text(
                      "Chỉnh sửa chủ đề",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    CircleAvatar(
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: titleControllerDialog,
                  decoration: const InputDecoration(
                    labelText: "Tiêu Đề",
                    hintText: "Nhập tiêu đề",
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                TextField(
                  controller: descriptionControllerDialog,
                  decoration: const InputDecoration(
                    labelText: "Mô Tả",
                    hintText: "Nhập mô tả",
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    updateTopic(key,titleControllerDialog.text,descriptionControllerDialog.text); // Gọi hàm cập nhật chủ đề với key, title và description từ dialog
                    Navigator.pop(context); // Đóng dialog sau khi lưu
                  },
                  child: const Text("Lưu"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text("Quản Lý Chủ Đề"),
      ),

      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    //autofocus: true,                  
                    controller: titleController,
                    focusNode: FocusNode(),//Gán focusnode vào Textfield
                    decoration:  InputDecoration(
                      labelText: "Tiêu Đề",
                      errorText: errorMessage.isEmpty ? null : errorMessage,),//Hiển thị thông báo lỗi dưới TextField
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Mô Tả"),
                  ),
                  ElevatedButton(
                    onPressed: addTopic,
                    child: const Text("Thêm Chủ Đề"),
                  ),
                ],
              ),
            ),//Expanded là một widget trong Flutter cho phép các widget con (trong trường hợp này là FirebaseAnimatedList) chiếm hết không gian còn lại trong widget cha của nó. 
              //Expanded giúp linh hoạt khi bạn cần quản lý không gian trong một layout có thể thay đổi kích thước (như Column hoặc Row).
            Expanded( 
              child: FirebaseAnimatedList(//Sử dụng FirebaseAnimatedList để hiển thị danh sách chủ đề được lưu trữ trong Firebase Realtime Database.
                query: topicsRef, //topicsRef là tham chiếu đến Firebase Realtime Database (trong trường hợp này là topicsRef chứa các chủ đề).
                                  //FirebaseAnimatedList sẽ sử dụng query này để lấy dữ liệu từ cơ sở dữ liệu Firebase.
                itemBuilder: (//itemBuilder là một hàm callback được gọi mỗi khi MỘT PHẦN TỬ trong danh sách cần được xây dựng
                  context, //context: Là ngữ cảnh (context) của widget hiện tại.
                  snapshot, //snapshot: Chứa dữ liệu của mục hiện tại từ Firebase. snapshot.value sẽ trả về dữ liệu của mục dưới dạng một Map.
                  animation, //animation: Cung cấp hiệu ứng hoạt ảnh khi mục được thêm vào danh sách.
                  index) {//index: Chỉ số (index) của mục trong danh sách.

                  Map topic = snapshot.value as Map;//snapshot.value as Map: Dữ liệu từ Firebase được trả về dưới dạng Map, trong đó các khóa là tên các trường dữ liệu trong Firebase, 
                                                    //và các giá trị là dữ liệu của chúng. Dòng mã này ép kiểu dữ liệu của snapshot.value thành Map, 
                                                    //cho phép truy cập các trường dữ liệu như title, description
                                                    //
                  bool isActive = topic["status"];// Lưu trữ trạng thái của chủ đề (true hoặc false), được lấy từ trường status trong Firebase.
                                                  //Trạng thái này xác định xem chủ đề có mở khóa hay không (ví dụ: chủ đề có thể bị khóa hay mở khóa
                  return ListTile(//Là một widget phổ biến trong Flutter để hiển thị một mục danh sách với các thông tin như tiêu đề, mô tả, hành động đi kèm, v.v. 
                                  //ListTile thường được sử dụng trong các ứng dụng quản lý danh sách
                    title: Text(topic["title"]),//title: Text(topic["title"]): Đây là tiêu đề của mục danh sách, lấy giá trị từ trường title trong topic (là dữ liệu từ Firebase).
                    subtitle: Text(topic["description"]),//subtitle: Text(topic["description"]): Đây là mô tả của mục danh sách, lấy giá trị từ trường description trong topic.
                    trailing: Row(//trailing: là khu vực ở cuối ListTile, nơi đặt các hành động như nút bấm (IconButton). Trong trường hợp này, một Row sẽ chứa các nút bấm 
                                  //Row: Là widget để sắp xếp các widget con theo chiều ngang. Ở đây, Row sẽ chứa các icon buttons để chỉnh sửa và thay đổi trạng thái của chủ đề.
                      mainAxisSize: MainAxisSize.min,//mainAxisSize: MainAxisSize.min: chiều rộng của Row sẽ chỉ đủ để chứa các phần tử bên trong, thay vì chiếm toàn bộ chiều rộng của khu vực chứa Row
                      children: [//children: danh sách các widget con được đặt trong Row. Trong trường hợp này, Row chứa hai nút IconButton: chỉnh sửa và thay đổi trạng thái (mở khóa/khóa).
                        IconButton(//IconButton: widget nút bấm có biểu tượng. Dùng để thực hiện một hành động khi người dùng nhấn vào nút.
                          icon: const Icon(Icons.edit),//icon: const Icon(Icons.edit): Chỉ định biểu tượng của nút là biểu tượng "edit" (sửa đổi),
                          onPressed: () {//onPressed: Hàm callback khi người dùng nhấn vào IconButton. Hành động sẽ được thực thi khi nhấn.
                            showEditDialog(//Truyền các giá trị vào cho hàm showEditDialog
                              context, //Ngữ cảnh của widget.
                              snapshot.key!, //Lấy khóa của mục trong Firebase (định nghĩa ở phía trên), đảm bảo rằng nó không phải là null (! là toán tử để ép kiểu không null).
                              topic ["title"], //Truyền tiêu đề của chủ đề vào dialog.
                              topic ["description"]);//Truyền mô tả của chủ đề vào dialog.
                          },
                        ),
                        IconButton(
                          icon: Icon(                               //icon: Icon( isActive ? Icons.lock_open : Icons.lock): Nếu chủ đề đang mở khóa (isActive = true), thì   
                            isActive ? Icons.lock_open : Icons.lock,//biểu tượng sẽ là khóa mở (lock_open).Nếu chủ đề đang khóa (isActive = false), biểu tượng sẽ là khóa đóng (lock).
                            color: isActive ? Colors.green : Colors.red,//Khóa thì nút màu xanh, không khóa thì nút màu đỏ
                          ),
                          onPressed: () => toggleTopicStatus(snapshot.key!, isActive),//Hàm toggleTopicStatus để thay đổi trạng thái của chủ đề từ mở khóa sang khóa và ngược lại.
                        ),                                                            //toggleTopicStatus(snapshot.key!, isActive): Truyền khóa của mục (snapshot.key!) 
                                                                                      //và trạng thái hiện tại (isActive) vào hàm toggleTopicStatus để cập nhật trạng thái của chủ đề.
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
      ),
    );
  }
  
}