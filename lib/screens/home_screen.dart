import 'package:flutter/material.dart';
import '../models/depense.dart';
import '../services/storage_service.dart';
import 'add_depense_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

enum _SortCriter { date, montant, categorie }

class HomeScreen extends StatefulWidget {
  final String devise;
  const HomeScreen({super.key, required this.devise});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Depense> depenses = [];
  final StorageService _storageService = StorageService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  _SortCriter _sortCriter = _SortCriter.date;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadDepenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Depense> get _filteredDepenses {
    var result = depenses.where((d) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return d.categorie.toLowerCase().contains(q) ||
          d.montant.toString().contains(q) ||
          d.date.ymd.contains(q);
    }).toList();

    result.sort((a, b) {
      int cmp;
      switch (_sortCriter) {
        case _SortCriter.date:
          cmp = a.date.compareTo(b.date);
        case _SortCriter.montant:
          cmp = a.montant.compareTo(b.montant);
        case _SortCriter.categorie:
          cmp = a.categorie.toLowerCase().compareTo(b.categorie.toLowerCase());
      }
      return _sortAscending ? cmp : -cmp;
    });

    return result;
  }

  Future<void> _loadDepenses() async {
    final loadedDepenses = await _storageService.loadDepenses();
    setState(() {
      depenses = loadedDepenses;
    });
  }

  Future<void> _saveDepenses() async {
    await _storageService.saveDepenses(depenses);
  }

  List<String> get _categories =>
      depenses.map((d) => d.categorie).toSet().toList()..sort();

  void ajouterDepense(Depense d) {
    setState(() {
      depenses.add(d);
    });
    _saveDepenses();
  }

  void modifierDepense(Depense updated) {
    setState(() {
      final index = depenses.indexWhere((d) => d.id == updated.id);
      if (index != -1) {
        depenses[index] = updated;
      }
    });
    _saveDepenses();
  }

  void supprimerDepense(String id) {
    setState(() {
      depenses.removeWhere((d) => d.id == id);
    });
    _saveDepenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes dépenses"),
        actions: [
          PopupMenuButton<_SortCriter>(
            icon: Icon(Icons.sort),
            onSelected: (criter) {
              setState(() {
                if (_sortCriter == criter) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortCriter = criter;
                  _sortAscending = criter != _SortCriter.date;
                }
              });
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: _SortCriter.date,
                child: Row(
                  children: [
                    Text("Date"),
                    if (_sortCriter == _SortCriter.date)
                      Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _SortCriter.montant,
                child: Row(
                  children: [
                    Text("Montant"),
                    if (_sortCriter == _SortCriter.montant)
                      Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _SortCriter.categorie,
                child: Row(
                  children: [
                    Text("Catégorie"),
                    if (_sortCriter == _SortCriter.categorie)
                      Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatsScreen(devise: widget.devise),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDepenses.length,
              itemBuilder: (ctx, index) {
                final d = _filteredDepenses[index];
                return Dismissible(
                  key: ValueKey(d.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    return await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Confirmer"),
                        content: Text("Supprimer ?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Non"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("Oui"),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => supprimerDepense(d.id),
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text("${d.montant} ${widget.devise}"),
                    subtitle: Text("${d.categorie} - ${d.date.ymd}"),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddDepenseScreen(existingDepense: d, categories: _categories),
                        ),
                      );
                      if (result is Depense) {
                        modifierDepense(result);
                      } else if (result == 'delete') {
                        supprimerDepense(d.id);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddDepenseScreen(categories: _categories)),
          );

          if (result != null) {
            ajouterDepense(result);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
