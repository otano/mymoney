import 'package:flutter/material.dart';
import '../models/depense.dart';
import '../services/storage_service.dart';

enum _Periode { semaine, mois, annee }

class StatsScreen extends StatefulWidget {
  final String devise;
  const StatsScreen({super.key, required this.devise});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Depense> depenses = [];
  final StorageService _storageService = StorageService();
  _Periode _periode = _Periode.mois;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  late DateTime _selectedMonday;

  @override
  void initState() {
    super.initState();
    _selectedMonday = _mondayOf(DateTime.now());
    _loadDepenses();
  }

  Future<void> _loadDepenses() async {
    final loaded = await _storageService.loadDepenses();
    setState(() => depenses = loaded);
  }

  DateTime _mondayOf(DateTime d) {
    final result = d.subtract(Duration(days: d.weekday - 1));
    return DateTime(result.year, result.month, result.day);
  }
//On est d'ac qu' il y a 7 jours dans la semaine, on compte quand même samedi et dimanche.;-)
  int _numeroSemaine(DateTime date) {
    final firstJan = DateTime(date.year, 1, 1);
    final daysSince = date.difference(firstJan).inDays;
    return ((daysSince + firstJan.weekday - 1) / 7).floor() + 1;
  }

  bool _estDansPeriode(Depense d) {
    switch (_periode) {
      case _Periode.semaine:
        final finSemaine = _selectedMonday.add(Duration(days: 6));
        return !d.date.isBefore(_selectedMonday) && !d.date.isAfter(finSemaine);
      case _Periode.mois:
        return d.date.year == _selectedYear && d.date.month == _selectedMonth;
      case _Periode.annee:
        return d.date.year == _selectedYear;
    }
  }

  Map<String, double> get _totalsByCategorie {
    final map = <String, double>{};
    for (final d in depenses.where(_estDansPeriode)) {
      map[d.categorie] = (map[d.categorie] ?? 0) + d.montant;
    }
    return map;
  }

  double get _totalGlobal {
    double total = 0;
    for (final v in _totalsByCategorie.values) {
      total += v;
    }
    return total;
  }

  String get _titrePeriode {
    const mois = [
      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];
    switch (_periode) {
      case _Periode.semaine:
        return "Semaine ${_numeroSemaine(_selectedMonday)}";
      case _Periode.mois:
        return "${mois[_selectedMonth - 1]} $_selectedYear";
      case _Periode.annee:
        return "$_selectedYear";
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totalsByCategorie;
    final total = _totalGlobal;
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: Text("Statistiques")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: SegmentedButton<_Periode>(
              segments: const [
                ButtonSegment(value: _Periode.semaine, label: Text("Semaine")),
                ButtonSegment(value: _Periode.mois, label: Text("Mois")),
                ButtonSegment(value: _Periode.annee, label: Text("Année")),
              ],
              selected: {_periode},
              onSelectionChanged: (selected) {
                setState(() => _periode = selected.first);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => setState(() => _selectedYear--),
              ),
              Text(_selectedYear.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () => setState(() => _selectedYear++),
              ),
            ],
          ),
          if (_periode == _Periode.mois)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      if (_selectedMonth == 1) {
                        _selectedMonth = 12;
                        _selectedYear--;
                      } else {
                        _selectedMonth--;
                      }
                    });
                  },
                ),
                Text(_titrePeriode, style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      if (_selectedMonth == 12) {
                        _selectedMonth = 1;
                        _selectedYear++;
                      } else {
                        _selectedMonth++;
                      }
                    });
                  },
                ),
              ],
            ),
          if (_periode == _Periode.semaine)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: () =>
                          setState(() => _selectedMonday = _selectedMonday.subtract(Duration(days: 7))),
                    ),
                    Text(_titrePeriode, style: TextStyle(fontSize: 18)),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: () =>
                          setState(() => _selectedMonday = _selectedMonday.add(Duration(days: 7))),
                    ),
                  ],
                ),
                Text(
                  "du ${_selectedMonday.ymd} au ${_selectedMonday.add(Duration(days: 6)).ymd}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          SizedBox(height: 8),
          if (entries.isEmpty)
            const Expanded(
              child: Center(child: Text("Aucune dépense")),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: entries.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == entries.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("${total.toStringAsFixed(2)} ${widget.devise}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  final entry = entries[index];
                  final ratio = total > 0 ? entry.value / total : 0.0;
                  return ListTile(
                    title: Text(entry.key),
                    trailing: Text("${entry.value.toStringAsFixed(2)} ${widget.devise}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${(ratio * 100).toStringAsFixed(1)}%"),
                        SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(value: ratio, minHeight: 6),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
