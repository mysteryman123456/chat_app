// import 'package:chat_app/app/routes/app_route.dart';
// import 'package:chat_app/common/my_snack_bar.dart';
// import 'package:chat_app/features/auth/presentation/pages/signup_screen.dart';
// import 'package:chat_app/features/auth/presentation/state/auth_state.dart';
// import 'package:chat_app/features/auth/presentation/view_model/auth_viewmodel.dart';
// import 'package:chat_app/features/dashboard/presentation/pages/dashboard_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//
//   final RegExp _passwordRegex = RegExp(
//     r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
//   );
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//
//
//   Future<void> _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       await ref
//           .read(authViewModelProvider.notifier)
//           .loginUser(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       if (next.status == AuthStatus.authenticated) {
//         AppRoutes.pushReplacement(context, const DashboardScreen());
//       } else if (next.status == AuthStatus.error && next.error != null) {
//         showMySnackBar(context: context, message: next?.error ?? "Invalid email or password",color: Colors.red);
//       }
//     });
//
//     return Scaffold(
//       appBar: AppBar(),
//       body: Padding(
//         padding: const EdgeInsets.all(40),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Welcome Back!",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Please enter your email and password to login",
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 40),
//
//                 // EMAIL
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(
//                     labelText: "Email",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Email is required";
//                     }
//                     if (!_emailRegex.hasMatch(value)) {
//                       return "Enter a valid email address";
//                     }
//                     return null;
//                   },
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // PASSWORD
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     labelText: "Password",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Password is required";
//                     }
//                     if (!_passwordRegex.hasMatch(value)) {
//                       return "Password must be 8+ chars with uppercase, lowercase & number";
//                     }
//                     return null;
//                   },
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 // LOGIN BUTTON
//                 Consumer(
//                   builder: (context, ref, child) {
//                     final isLoading = authState.status == AuthStatus.loading;
//
//                     return SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.all(15),
//                           backgroundColor: Colors.indigo,
//                           shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(10)),
//                           ),
//                         ),
//                         onPressed: isLoading ? null : _handleLogin,
//                         child: isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               )
//                             : const Text("Sign In"),
//                       ),
//                     );
//                   },
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 // SIGNUP
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Don't have an account?"),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const SignupScreen(),
//                           ),
//                         );
//                       },
//                       child: const Text("Signup"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
