import 'package:app_example/repository/database_creator.dart';
import 'package:app_example/repository/repository_service_request.dart';
import 'package:flutter/material.dart';

import 'models/request.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  Future<List<Request>> future;
  String name;
  int id;

 @override
  initState() {
    super.initState();
    future = RepositoryServiceRequest.getAllRequests();
  }

  void readData() async {
    setState(() {
      future = RepositoryServiceRequest.getAllRequests();
    });
  }

  updateRequest(Request req) async {
    req.taskStatus = updateRequestStatus(req);
    await RepositoryServiceRequest.updateRequest(req);
    setState(() {
      future = RepositoryServiceRequest.getAllRequests();
    });
  }

  String updateRequestStatus(Request req) {
    String status;
    switch (req.taskStatus) {
      case "Pendiente":
        status = 'Proceso';
        break;
      case "Proceso":
        status = 'Finalizado';
        break;
      default:
        status = 'Pendiente';
        break;
    }
    return status;
  }

  deleteTodo(Request req) async {
    await RepositoryServiceRequest.deleteRequest(req);
    setState(() {
      id = null;
      future = RepositoryServiceRequest.getAllRequests();
    });
  }

  Card buildItem(Request req) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Name: ${req.result}',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Status: ${req.taskStatus}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => updateRequest(req),
                  child: Text('Update', style: TextStyle(color: Colors.white)),
                  color: Color(0xFFda4e19),
                ),
                SizedBox(width: 8),
                FlatButton(
                  onPressed: () => deleteTodo(req),
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                  color: Color(0xFFf23030),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  TextFormField buildTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Result',
        fillColor: Colors.grey[300],
        filled: true,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
      },
      onSaved: (value) => name = value,
    );
  }

  void createRequest() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      int count = await RepositoryServiceRequest.requestCount();
      final req = Request(count, name, "Pendiente", false);
      await RepositoryServiceRequest.addRequest(req);
      setState(() {
        id = req.requestId;
        future = RepositoryServiceRequest.getAllRequests();
      });
      print(req.requestId);
    }
  }
  void filterById() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        RepositoryServiceRequest.getRequest(name).then((req) {
          future.then((value){
          value.clear();
          value.add(req);
          });
      });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffda4a19),
        title: Text('sqfLite CRUD Request table'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Form(
            key: _formKey,
            child: buildTextFormField(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: createRequest,
                child: Text('Create', style: TextStyle(color: Colors.white)),
                color: Color(0xFF8cb04a),
              ),
              RaisedButton(
                onPressed: id != null ? filterById : null,
                child: Text('Filter by name', style: TextStyle(color: Colors.white)),
                color: Color(0xFF045283),
              ),
              RaisedButton(
                onPressed: id != null ? readData : null,
                child: Text('All', style: TextStyle(color: Colors.white)),
                color: Color(0xFF045283),
              ),
            ],
          ),
          FutureBuilder<List<Request>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: snapshot.data.map((req) => buildItem(req)).toList());
              } else {
                return SizedBox();
              }
            },
          )
        ],
      ),
    );
  }

}
