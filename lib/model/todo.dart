class Todo {
  final String uid;
  final String title;
  final String description;
  final bool isComplete;
  final String docId;

  Todo({
    required this.uid,
    required this.title,
    required this.description,
    required this.isComplete,
    required this.docId,
  });
}

// List<Todo> listdata = [
//   Todo(
//     title: 'Studi Kasus 1',
//     description: 'Membuat Program Dasar Java',
//   ),
//   Todo(
//     title: 'Studi Kasus 2',
//     description: 'Membuat Studi Kasus List Makanan',
//   ),
//   Todo(
//     title: 'Studi Kasus 3',
//     description: 'Membuat Aplikasi To Do List',
//   ),
// ];
