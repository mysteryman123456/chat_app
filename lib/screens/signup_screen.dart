import 'dart:io';

import 'package:flutter/material.dart';

import 'login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(padding: EdgeInsets.all(40),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            children: [
              Text("Create an account", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
              SizedBox(height: 10,),
              Text("Start your messaging journey with GinChat"),
              SizedBox(height: 40,),
              TextFormField(decoration: InputDecoration(labelText: "Username",border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white),borderRadius: BorderRadius.all(Radius.circular(10))))),
              SizedBox(height:20,),
              TextFormField(decoration: InputDecoration(labelText: "Password",border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white),borderRadius: BorderRadius.all(Radius.circular(10))))),
              SizedBox(height:30,),
              SizedBox(width: double.infinity,child: ElevatedButton(style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15),backgroundColor: Colors.indigo,shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))) ,onPressed: (){}, child: Text("Signup")),),
              SizedBox(height:10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                    },
                    child: Text("Login",style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],),
        ),
      ),
    );
  }
}
