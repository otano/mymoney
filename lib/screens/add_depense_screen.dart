import 'package:flutter/material.dart';
import '../models/depense.dart';
import 'package:uuid/uuid.dart';

class AddDepenseScreen extends StatefulWidget {
  final Depense? existingDepense;
  final List<String> categories;
  const AddDepenseScreen({super.key, this.existingDepense, this.categories = const []});

  @override
  _AddDepenseScreenState createState() => _AddDepenseScreenState();
}

class _AddDepenseScreenState extends State<AddDepenseScreen> {
  final _formKey = GlobalKey<FormState>();

  double? montant;
  String? categorie;
  DateTime? date;

  @override
  void initState() {
    super.initState();
    if (widget.existingDepense != null) {
      montant = widget.existingDepense!.montant;
      categorie = widget.existingDepense!.categorie;
      date = widget.existingDepense!.date;
    }
  }

  bool get _isEditing => widget.existingDepense != null;

  void submit() {
    if (_formKey.currentState!.validate() && date != null) {
      _formKey.currentState!.save();

      final depense = Depense(
        id: widget.existingDepense?.id ?? Uuid().v4(),
        montant: montant!,
        categorie: categorie!,
        date: date!,
      );

      Navigator.pop(context, depense);
    }
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "Modifier" : "Ajouter")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Montant"),
                keyboardType: TextInputType.number,
                initialValue: _isEditing ? widget.existingDepense!.montant.toString() : null,
                validator: (value) => value!.isEmpty ? "Obligatoire" : null,
                onSaved: (value) => montant = double.parse(value!),
              ),
              Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return widget.categories;
                  }
                  return widget.categories.where((option) =>
                      option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                initialValue: _isEditing
                    ? TextEditingValue(text: widget.existingDepense!.categorie)
                    : null,
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: "Catégorie",
                      suffixIcon: widget.categories.isNotEmpty ? Icon(Icons.arrow_drop_down) : null,
                    ),
                    validator: (value) => value!.isEmpty ? "Obligatoire" : null,
                    onSaved: (value) => categorie = value,
                  );
                },
              ),
              ElevatedButton(
                onPressed: pickDate,
                child: Text(date == null ? "Choisir une date" : date!.ymd),
              ),
              ElevatedButton(
                onPressed: submit,
                child: Text("Valider"),
              ),
              if (_isEditing)
                ElevatedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Confirmer"),
                        content: Text("Supprimer cette dépense ?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Non")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Oui")),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      Navigator.pop(context, 'delete');
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Supprimer", style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}