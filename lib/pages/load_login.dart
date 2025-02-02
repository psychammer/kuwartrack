import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadLogin extends StatefulWidget {
  const LoadLogin({super.key});

  @override
  State<LoadLogin> createState() => _LoadLoginState();
}

class _LoadLoginState extends State<LoadLogin> {
  Map data = {};
  String time = 'loading';

  Future<bool> login(String user, String password) async {
    final url = Uri.parse("https://e585-130-105-115-165.ngrok-free.app/api/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user": user, "password": password}),
    );

    if (response.statusCode == 200) {
      if(jsonDecode(response.body)!=null){ // returns a dictionary-like structure. In this case, Returns true or false
        // Decoding the JSON response
        Map<String, dynamic> decodedResponse = jsonDecode(response.body);

        var userId = decodedResponse['id'];

        Navigator.pushReplacementNamed(context, '/home', arguments: {'user_id': userId});

        return true; // user credentials is correct.
      }
      else{ // user credentials is wrong
        Navigator.pop(context, false);
        return false;
      }
    }
    else {// user credentials is wrong
      Navigator.pop(context, false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings?.arguments as Map;
    login(data['email'], data['password']);
    return Scaffold(
        backgroundColor: Color(0xFF53197B),
        body: Center(
          child: SpinKitPouringHourGlass(
            color: Colors.white,
            size: 50.0,
          ),
        )
    );
  }
}