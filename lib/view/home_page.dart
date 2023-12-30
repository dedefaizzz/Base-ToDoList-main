import 'package:base_todolist/model/item_list.dart';
import 'package:base_todolist/view/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  bool isComplete = false;

  // inisialisasi utk menjalankan logika inisialisasi dasar
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // app berinteraksi dgn koleksi dokumen 'Todos' di firestore serupa
    CollectionReference todoCollection = _firestore.collection('Todos');

    // menyimpan informasi user yg sdg login yg diambil dari currentUser
    // User? = pengguna dpt bernilai null jika tdk ada yg login
    final User? user = _auth.currentUser;

    // method addTodo utk menambah data ke dlm firestore
    Future<void> addTodo() {
      return todoCollection.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isComplete': isComplete,
        'uid': _auth.currentUser!.uid,
        // ignore: invalid_return_type_for_catch_error
      }).catchError((error) => print('Failed to add todo: $error'));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Todo List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Apakah anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Tidak'),
                    ),
                    TextButton(
                      onPressed: () {
                        _signOut();
                      },
                      child: Text('Ya'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (textEntered) {
                searchResult(textEntered);

                setState(() {
                  _searchController.text = textEntered;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _searchController.text.isEmpty
                    ? _firestore
                        .collection('Todos')
                        .where('uid', isEqualTo: user!.uid)
                        .snapshots()
                    : searchResultsFuture != null
                        ? searchResultsFuture!
                            .asStream()
                            .cast<QuerySnapshot<Map<String, dynamic>>>()
                        : Stream.empty(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  List<Todo> listTodo = snapshot.data!.docs.map((document) {
                    final data = document.data();
                    final String title = data['title'];
                    final String description = data['description'];
                    final bool isComplete = data['isComplete'];
                    final String uid = user!.uid;

                    return Todo(
                        uid: uid,
                        title: title,
                        description: description,
                        isComplete: isComplete,
                        docId: 'J8G2zUpWxVmW33GaqwGS');
                  }).toList();

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: listTodo.length,
                      itemBuilder: (context, index) {
                        return ItemList(
                          todo: listTodo[index],
                        );
                      });
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Tambah Todo'),
              content: SizedBox(
                width: 200,
                height: 100,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(hintText: 'Judul Todo'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(hintText: 'Deskripsi Todo'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Batalkan'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Tambah'),
                  onPressed: () {
                    addTodo();
                    clearText();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // method utk signOut dari akun user
  Future<void> _signOut() async {
    // memanggil method signOut dari objek _auth
    // utk melakukan proses logout dari firebase authentication
    await _auth.signOut();

    // restart aplikasi dgn membuat instance baru
    // dari MaterialApp dan menetapkan LoginPage sbg halaman utama
    runApp(new MaterialApp(
      home: new LoginPage(),
    ));
  }

  /* method searchResult utk mencari data dari firestore */
  // Deskripsi: Dideklarasikan sebagai objek Future yang dapat mengembalikan QuerySnapshot atau nilai null.
  // Tujuan: Digunakan untuk menyimpan hasil pencarian atau query di masa mendatang.
  Future<QuerySnapshot>? searchResultsFuture;

  // pencarian data pd koleksi "Todos" di firestore
  Future<void> searchResult(String textEntered) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Todos") // query ke firestore
        .where("title", isGreaterThanOrEqualTo: textEntered)
        .where("title", isLessThan: textEntered + 'z')
        .get(); // Mencari dokumen dengan nilai atribut "title" yang lebih besar dari atau sama dengan dan kurang dari

    // memperbarui state
    setState(() {
      searchResultsFuture = Future.value(querySnapshot);
    });
  }

  // setelah pemanggilan nilai akan kosong
  void clearText() {
    _titleController.clear();
    _descriptionController.clear();
  }
}
