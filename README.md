# mymoney


> Une app Flutter/dart pour gérer les dépenses simple et éfficace
>réalisé pour découvrir les stacks et android studio


## Fonctionnalités

### **Ajout express**

montant, catégorie, date en un clic
  
**Édition facile**

tapez sur une dépense pour la modifier

**Suppression**

swipe à gauche avec confirmation, ou bouton Supprimer en édition

**Recherche en direct**
  
filtre par montant, catégorie, date — les résultats s'affinent en temps réel
   
**Tri intelligent**

par date, montant ou catégorie — un clic pour inverser l'ordre
  
**Stats par période**

 visualisez vos dépenses par catégorie à la semaine, au mois ou à l'année
  
**Navigation temporelle**

baladez-vous dans le temps avec les flèches ← →
et afficher vos dépenses pour déceler les anomalies (mais ou part tout votre argent ??)
  
**Barres de progression**

 voyez d'un coup d'œil la part de chaque catégorie
  
**Mode sombre**

parce que les yeux fatigués méritent du répit
  
**Change de devise**

€ ou $, comme vous voulez
  
**Sauvegarde automatique**

  tout est persistant, rien ne se perd


📁 Structure

```
lib/
├── main.dart  # Point d'entrée + thème
├── models/depense.dart# Modèle + extension date YMD
├── screens/
│   ├── home_screen.dart   # Liste + recherche + tri
│   ├── add_depense_screen.dart  # Ajout / Édition
│   ├── settings_screen.dart # Sombre / Devise
│   └── stats_screen.dart# Statistiques
├── services/storage_service.dart  # Persistance JSON
└── widgets/depense_item.dart  # (vide — à supprimer ou utiliser)
```

## Pour commencer

```bash
flutter pub get
flutter run
```

Réalisé dans un cadre 🧐 🚸 absolument sans ☕ 



