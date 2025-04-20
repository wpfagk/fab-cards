import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _cards = [];
  List<Map<String, dynamic>> _filteredCards = [];
  String _selectedFilter = '';

  void incrementCounter() {
    print("Bouton cliqué !");
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fab_cards.db');

    await deleteDatabase(path);
    print("Base supprimée !");

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE cards(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            cost INTEGER,
            imageUrl TEXT
          )
        ''');
      },
    );

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM cards'),
    );

    if (count == 0) {
      List<Map<String, dynamic>> defaultCards = [
        {
          'name': 'Ravenous Rabble',
          'type': 'Attack Action',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/AAZ012.webp',
        },
        {
          'name': 'Sink Below',
          'type': 'Defense Reaction',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/ASB016.webp',
        },
        {
          'name': 'Snatch',
          'type': 'Attack Action',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/AST014.webp',
        },
        {
          'name': 'Savor Bloodshed',
          'type': 'Attack Action',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT198.webp',
        },
        {
          'name': 'Oath of Loyalty',
          'type': 'Attack Action',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT149.webp',
        },
        {
          'name': 'Dual Threat',
          'type': 'Generic Action',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT223.webp',
        },
        {
          'name': 'Loyalty Beyond the Grave',
          'type': 'Defense Reaction',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT150.webp',
        },
        {
          'name': 'Pain in the Backside',
          'type': 'Attack Action',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT174.webp',
        },
        {
          'name': 'Shelter from the Storm',
          'type': 'Defense Reaction',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT222.webp',
        },
        {
          'name': 'Chain Reaction',
          'type': 'Defense Reaction',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT253.webp',
        },
        {
          'name': 'Jagged Edge',
          'type': 'Attack Action',
          'cost': 1,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT116.webp',
        },
        {
          'name': 'Throw Dagger',
          'type': 'Attack Reaction',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT175.webp',
        },
        {
          'name': 'Cull',
          'type': 'Action',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT259.webp',
        },
        {
          'name': 'Perforate',
          'type': 'Attack Reaction',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/HNT197.webp',
        },
        {
          'name': 'Enlightened Strike',
          'type': 'Attack Action',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/WTR159.webp',
        },
        {
          'name': 'Red in the Ledger',
          'type': 'Attack Action',
          'cost': 1,
          'imageUrl': 'https://prod-content.fabrary.io/cards/AAZ013.webp',
        },
        {
          'name': 'Scar for a Scar',
          'type': 'Attack Action',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/KAT015.webp',
        },
        {
          'name': 'Fate Foreseen',
          'type': 'Defense Reaction',
          'cost': 0,
          'imageUrl': 'https://prod-content.fabrary.io/cards/ARC200.webp',
        },
        {
          'name': 'Unmovable',
          'type': 'Defense Reaction',
          'cost': 3,
          'imageUrl': 'https://prod-content.fabrary.io/cards/WTR212.webp',
        },
      ];

      for (final card in defaultCards) {
        await db.insert('cards', card);
      }
    }

    final cards = await db.query('cards');

    setState(() {
      _cards = cards;
      _filteredCards = cards;
    });
  }

  void _applyFilter() {
    if (_selectedFilter == '') {
      _filteredCards = _cards;
    } else if (_selectedFilter.startsWith('cost_')) {
      final cost = int.parse(_selectedFilter.split('_')[1]);
      _filteredCards = _cards.where((c) => c['cost'] == cost).toList();
    } else if (_selectedFilter.startsWith('type_')) {
      final typeMap = {
        'attack': 'Attack Action',
        'defense': 'Defense Reaction',
        'react': 'Attack Reaction',
        'generic': 'Generic Action',
      };
      final type = _selectedFilter.split('_')[1];
      _filteredCards = _cards.where((c) => c['type'] == typeMap[type]).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
                _applyFilter();
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'cost_1', child: Text('Coût 1')),
                  const PopupMenuItem(value: 'cost_2', child: Text('Coût 2')),
                  const PopupMenuItem(value: 'cost_3', child: Text('Coût 3')),
                  const PopupMenuItem(
                    value: 'type_attack',
                    child: Text('Attack Action'),
                  ),
                  const PopupMenuItem(
                    value: 'type_defense',
                    child: Text('Defense Reaction'),
                  ),
                  const PopupMenuItem(
                    value: 'type_react',
                    child: Text('Attack Reaction'),
                  ),
                  const PopupMenuItem(
                    value: 'type_generic',
                    child: Text('Generic Action'),
                  ),
                  const PopupMenuItem(value: '', child: Text('Tout afficher')),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                Text(
                  'Bienvenue dans FaB Deck Builder !',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 8),
                Text(
                  'Prépare-toi à construire ton premier deck 🧙‍♂️',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCards.length,
              itemBuilder: (context, index) {
                final card = _filteredCards[index];
                return ListTile(
                  leading: Image.network(
                    card['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(card['name']),
                  subtitle: Text('${card['type']} - Coût: ${card['cost']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardDetailsPage(card: card),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddCardPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Page pour ajouter une carte
class AddCardPage extends StatelessWidget {
  const AddCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une carte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(child: Text('Page d’ajout de carte à venir…')),
    );
  }
}

// Page de détails
class CardDetailsPage extends StatelessWidget {
  final Map<String, dynamic> card;

  const CardDetailsPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card['name']),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (card['imageUrl'] != null) Image.network(card['imageUrl']),
            const SizedBox(height: 16),
            Text(card['type'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Coût : ${card['cost']}'),
          ],
        ),
      ),
    );
  }
}
