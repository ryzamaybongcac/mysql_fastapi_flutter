import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MySQL User List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UsersPage(),
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List users = [];
  bool isLoading = true;
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // Updated fetchUsers function integrated here
  Future<void> fetchUsers() async {
    final url = Uri.parse("http://127.0.0.1:8000/"); 

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          // This matches 'data' from your Pic 1
          users = responseData['data']; 
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users from MySQL"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg.isNotEmpty
              ? Center(child: Text(errorMsg, style: const TextStyle(color: Colors.red)))
              : users.isEmpty
                  ? const Center(child: Text("No users found in the database."))
                  : RefreshIndicator(
                      onRefresh: fetchUsers,
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(user['idno']?.toString() ?? "?"),
                              ),
                              title: Text(user['name'] ?? "No Name"),
                              subtitle: Text(user['gender'] ?? "No Gender"),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}