import 'dart:io';

import 'package:flutter/material.dart';

import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
             Text("Welcome Back !", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
             SizedBox(height: 10,),
             Text("Please give your username and password to login"),
             SizedBox(height: 40,),
             TextFormField(decoration: InputDecoration(labelText: "Username",border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white),borderRadius: BorderRadius.all(Radius.circular(10))))),
             SizedBox(height:20,),
             TextFormField(decoration: InputDecoration(labelText: "Password",border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white),borderRadius: BorderRadius.all(Radius.circular(10))))),
             SizedBox(height:30,),
             SizedBox(width: double.infinity,child: ElevatedButton(style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15),backgroundColor: Colors.indigo,shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))) ,onPressed: (){}, child: Text("Sign in")),),
             SizedBox(height:10,),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text("Already have an account?"),
                 TextButton(
                   onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                   },
                   child: Text("Signup",style: TextStyle(color: Colors.white)),
                 ),
               ],
             )
         ],),
        ),
      ),
    );
  }
}
