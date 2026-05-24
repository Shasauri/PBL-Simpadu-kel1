import 'package:flutter/material.dart';

class AdminAkademikHomePage extends StatelessWidget {

  const AdminAkademikHomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Admin Akademik"),
      ),

      body: const Center(
        child: Text(
          "HALAMAN ADMIN AKADEMIK",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}