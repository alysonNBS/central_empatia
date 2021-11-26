import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(color: Colors.deepPurpleAccent[300]),
        scaffoldBackgroundColor: Colors.deepPurpleAccent[700],
      ),
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('Alguma coisa deu errado!');
          if (snapshot.hasData) return const MyHomePage();
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central da Empatia')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            color: Colors.white70,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Qual grupo ou ação deseja contribuir hoje?",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    shrinkWrap: true,
                    children: _gridViewItems(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _gridViewItems(BuildContext context) {
    return <Map<String, dynamic>>[
      {
        'route': const CategoryView('SI7KO33Cj5vIo8fLD2nA', 'Crianças'),
        'asset': 'criancas'
      },
      {
        'route': const CategoryView('ecoxh9eBjYydkJO2dKKE', 'Idosos'),
        'asset': 'idosos'
      },
      {
        'route': const CategoryView('gnDX2nvrQdjx0z3xZs6O', 'Animais'),
        'asset': 'animais'
      },
      {
        'route': const CategoryView('rWKo3dCF2dGPKeeBiX9f', 'Meio Ambiente'),
        'asset': 'ambiente'
      },
      {
        'route': const CategoryView('8mZhurLHcHlfDhFiI2pe', 'Doação de Sangue'),
        'asset': 'sangue'
      },
      {'route': AllCategory(), 'asset': 'outros'},
    ]
        .map((e) =>
            _gridViewItem(context, e['route'], 'assets/${e['asset']}.png'))
        .toList();
  }

  Widget _gridViewItem(BuildContext context, Widget route, String asset) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => route),
      ),
      child: AssetImageContainer(asset),
    );
  }
}

class AssetImageContainer extends StatelessWidget {
  final String name;

  const AssetImageContainer(this.name, {Key? key}) : super(key: key);

  Color _randomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _randomColor(),
      child: Image.asset(name),
    );
  }
}

class AllCategory extends StatelessWidget {
  final _colStream =
      FirebaseFirestore.instance.collection('categories').snapshots();

  AllCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categorias")),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _colStream,
          builder: (context, snapshot) {
            if (snapshot.hasError)
              // ignore: curly_braces_in_flow_control_structures
              return const Text('Alguma coisa deu errado!');
            if (snapshot.hasData)
              // ignore: curly_braces_in_flow_control_structures
              return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data()!
                        as Map<String, Object?>;
                    final label = data['label']! as String;

                    return InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CategoryView(
                              snapshot.data!.docs[index].id, label))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.white70,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class CategoryView extends StatelessWidget {
  final String catedoryID;
  final String title;

  const CategoryView(this.catedoryID, this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('institutions')
        .where('categoriesID', arrayContains: catedoryID);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              // ignore: curly_braces_in_flow_control_structures
              return const Text('Alguma coisa deu errado!');
            if (snapshot.hasData)
              // ignore: curly_braces_in_flow_control_structures
              return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docChanges[index].doc.data()!
                        as Map<String, Object?>;
                    final label = data['name']! as String;

                    return InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => InstitutionView(data))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.white70,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class InstitutionView extends StatelessWidget {
  final Map<String, Object?> data;

  const InstitutionView(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final address = data['address'] as String;
    final description = data['description'] as String;
    final name = data['name'] as String;
    final phone = data['phone'] as String;
    final photoURL = data['photoURL'] as String?;

    return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    photoURL == null
                        ? const SizedBox(width: 0, height: 0)
                        : Image.network(photoURL),
                    const SizedBox(height: 6),
                    Text(description),
                    const SizedBox(height: 6),
                    Text(address),
                    const SizedBox(height: 6),
                    Text(phone),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
