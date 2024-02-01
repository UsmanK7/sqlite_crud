import 'package:flutter/material.dart';
import 'package:sqlite_crud/sql_helper.dart';
void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQlITE  ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  void _refreshJournals() async{
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshJournals();
    print("..number of items ${_journals.length}");
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();


  Future<void> _addItem() async{
    await SQLHelper.createItem(
      _titleController.text, _descriptionController.text
      );
    _refreshJournals(); 
    print("..number of items ${_journals.length}");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully addded an item')));
  }

  Future<void> _updateItem(int id) async{
    await SQLHelper.updateItem(
      id, _titleController.text, _descriptionController.text);
      _refreshJournals();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully updated an item')));
  }
  void _deleteItem(int id) async{
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted an item')));
      _refreshJournals();
  }


  void _showForm(int? id) async {
    if(id != null){
      final existingJournal = 
      _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }
    showModalBottomSheet(
      context: context, 
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom +120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async{
                if(id == null){
                  await _addItem();
                }
                if(id != null){
                  await _updateItem(id);
                }
                _titleController.text = '';
                _descriptionController.text = '';

                Navigator.of(context).pop();
                
              },
               child: Text(id == null ? 'Create New': 'Update'))
            
          ],
        ),
      ),
    

      );
      
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLITE CRUD operations app',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context,index) => Card(
          color: Colors.blue[100],
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Text(_journals[index]['title']),
            subtitle: Text(_journals[index]['description']),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(onPressed: () => _showForm(_journals[index]['id']), icon: Icon(Icons.edit)),
                  IconButton(onPressed: () => _deleteItem(_journals[index]['id']), icon: Icon(Icons.delete))

                  
                ],

              ),
            
            ),
          ),
        )),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}