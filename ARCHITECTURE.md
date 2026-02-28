# Architecture de Gestion de Stock - Flutter + GetX + Sqflite

## ✅ STATUT DU PROJET

### Progression: 90% complète

---

## 📦 DÉPENDANCES AJOUTÉES/MISES À JOUR

✅ **Removed:**
- `provider: ^6.1.5+1` (ChangeNotifier)

✅ **Added:**
- `get: ^4.6.6` (State management, Routing, Dependency Injection)
- `flutter_secure_storage: ^9.2.2` (Stockage sécurisé)

✅ **Retained:**
- `sqflite: ^2.4.2` (Base de données SQLite)
- `path_provider: ^2.1.5` (Accès aux chemins)
- `path: ^1.9.1` (Manipulation de chemins)
- `intl: ^0.20.2` (Formatage dates/nombres)
- `uuid: ^4.5.2` (Génération d'IDs uniques)
- `crypto: ^3.0.7` (Hachage des mots de passe)
- `shared_preferences: ^2.2.2` (Gestion session utilisateur)
- Autres packages (flutter_slidable, url_launcher, csv)

---

## 🏗️ ARCHITECTURE STRUCTURELLE

### **1. Base de Données (lib/database/)**
```
lib/database/
├── database_helper.dart
    └── Tables: users, products, stock_entries, stock_outputs, sales, sale_items
```

**Tables implémentées:**
- `users` → Identifiant, email, mot de passe (hashé), rôle (admin/caissier), nom
- `products` → Code produit (SKU), nom, prix, quantité, description
- `stock_entries` → Entrées de stock avec utilisateur responsable
- `stock_outputs` → Sorties de stock (ventes) avec utilisateur (caissier)
- `sales` & `sale_items` → Tables de compatibilité pour les historiques

### **2. Modèles (lib/models/)**
```
lib/models/
├── product.dart      ✅ Refactorisé
├── user.dart        ✅ Refactorisé
├── entry_model.dart  ✅ Créé (nouveau)
├── output_model.dart ✅ Créé (nouveau)
└── sale.dart        ✅ Existant
```

### **3. Services (lib/services/)**
```
lib/services/
├── database_service.dart   ✅ Créé (wrapper pour DatabaseHelper)
├── auth_service.dart       ✅ Refactorisé (GetX compatible)
├── product_service.dart    ✅ Refactorisé (méthodes enrichies)
├── user_service.dart       ✅ Refactorisé (GetX compatible)
├── entry_service.dart      ✅ Créé (gestion des entrées)
└── output_service.dart     ✅ Créé (gestion des sorties/ventes)
```

**Services responsabilités:**
- Exécuter les requêtes SQL via Sqflite
- Retourner des objets Model
- Gérer les erreurs et transactions
- **Pas de logique métier** (réservée au Controller)

### **4. Controllers (lib/controllers/)**
```
lib/controllers/
├── auth_controller.dart    ✅ Refactorisé → GetxController
├── product_controller.dart ✅ Refactorisé → GetxController
├── user_controller.dart    ✅ Refactorisé → GetxController
├── entry_controller.dart   ✅ Créé → GetxController
├── output_controller.dart  ✅ Créé → GetxController
├── sale_controller.dart    (vide - à développer si nécessaire)
└── sale_item_controller.dart (vide - à développer si nécessaire)
```

**Controllers responsabilités:**
- Logique métier (validations)
- Gestion états réactifs (Rx)
- Appel aux services
- Gestion des notifications (snackbars)
- Navigation via Get.offAllNamed(), Get.toNamed()
- Accès au rôle utilisateur (admin/caissier)

### **5. Bindings (lib/bindings/)**
```
lib/bindings/
├── auth_binding.dart    ✅ Créé (injection AuthService + AuthController)
├── product_binding.dart ✅ Créé (injection ProductService + ProductController)
├── user_binding.dart    ✅ Créé (injection UserService + UserController)
├── entry_binding.dart   ✅ Créé (injection EntryService + ProductService + EntryController)
└── output_binding.dart  ✅ Créé (injection OutputService + ProductService + OutputController)
```

**Bindings responsabilités:**
- Injection de dépendances (GetX)
- Inicialisation des Services et Controllers
- Utilisation de `Get.lazyPut()` (initialisation lazy)

### **6. Routes (lib/routes/)**
```
lib/routes/
├── app_routes.dart      ✅ Créé (constantes de routes)
└── app_pages.dart       ✅ Créé (définition des pages GetX)
```

**Routes implémentées:**
- `/login` → LoginView
- `/admin-dashboard` → AdminDashboardView (placeholder)
- `/cashier-dashboard` → CashierDashboardView (placeholder)

**Routes à implémenter:**
- Admin: `/admin-product-list`, `/admin-entry-form`, `/admin-user-list`, etc.
- Cashier: `/cashier-product-list`, `/cashier-output-form`, `/cashier-history`, etc.

### **7. Views (lib/views/)**
```
lib/views/
├── user/
│   ├── login_view.dart              ✅ Refactorisé (GetX compatible)
│   ├── profile_view.dart
│   ├── SplashScreen_view.dart
│   ├── dashboard/
│   │   ├── dashboardAdmin.dart      (ancien - deprecated)
│   │   └── dashboardCaissier.dart   (ancien - deprecated)
│   └── all_users/
│       └── user_view.dart           ❌ Utilise encore Provider
├── admin/                            ✅ Créé (nouvelle structure)
│   ├── admin_dashboard_view.dart    ✅ Placeholder
│   ├── product/                      (à développer)
│   ├── entries/                      (à développer)
│   ├── outputs/                      (à développer)
│   └── users/                        (à développer)
├── cashier/                          ✅ Créé (nouvelle structure)
│   ├── cashier_dashboard_view.dart  ✅ Placeholder
│   ├── product/                      (à développer)
│   ├── outputs/                      (à développer)
│   └── history/                      (à développer)
├── product/                          ❌ Utilise encore Provider
│   ├── product_detail_view.dart
│   ├── product_form.dart
│   └── edit_product_form.dart
└── sale/
    ├── sale_detail_view.dart
    └── sale_view.dart
```

### **8. Main Application (lib/main.dart)**
✅ Refactorisé
```dart
// Utilisation de GetMaterialApp
// Initialisation de DatabaseService
// Routes GetX avec AppPages
// Navigation via GetX
```

---

## 🔄 FLUX D'AUTHENTIFICATION

```
LoginView
    ↓
AuthController.login()
    ↓
AuthService.login()  // Vérifie email + password hashé
    ↓
SharedPreferences  // Enregistre session
    ↓
Redirection automatique:
    ├── Admin → /admin-dashboard
    └── Caissier → /cashier-dashboard
```

---

## 📊 FLUX D'UNE ENTRÉE DE STOCK

```
AdminEntryFormView
    ↓
EntryController.createEntry()
    ↓
EntryService.createEntry()  // Insère dans stock_entries
    ↓
ProductService.updateStock()  // Ajoute quantité au produit
    ↓
UI actualisation (Rx)  // Recharge instantanée
    ↓
Notification snackbar
```

---

## 🛒 FLUX D'UNE VENTE (OutputController)

```
CashierOutputFormView
    ↓
OutputController.createOutput()
    ↓
Vérification stock  // isStockAvailable()
    ↓
OutputService.createOutput()  // Insère dans stock_outputs
    ↓
ProductService.updateStock()  // Soustrait quantité
    ↓
UI actualisation (Rx)
    ↓
Notification succès
```

---

## ❌ ERREURS RESTANTES À CORRIGER (10%)

### Views utilisant encore Provider:
- ❌ `lib/views/product/product_detail_view.dart`
- ❌ `lib/views/product/product_form.dart`
- ❌ `lib/views/product/edit_product_form.dart`
- ❌ `lib/views/user/all_users/user_view.dart`

### Action requise:
```dart
// REMPLACER:
import 'package:provider/provider.dart';
context.watch<Controller>()
context.read<Controller>()

// PAR:
import 'package:get/get.dart';
Get.find<Controller>() ou Get.put<Controller>(Controller())
Obx(() => ...)  // Pour les réactivités
```

### Exemple de refactorisation:
```dart
// AVANT (Provider)
class ProductDetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();
    return ListView(children: [
      for(var p in controller.products)
        Text(p.name),
    ]);
  }
}

// APRÈS (GetX)
class ProductDetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();
    return Obx(() => ListView(
      children: [
        for(var p in controller.products)
          Text(p.name),
      ],
    ));
  }
}
```

---

## ✅ FONCTIONNALITÉS COMPLÈTES

### Authentication:
- ✅ Login avec email/mot de passe
- ✅ Hachage SHA-256
- ✅ Redirection basée rôle
- ✅ Logout
- ✅ Session persistante (SharedPreferences)

### Gestion Produits:
- ✅ Créer produit (SKU unique)
- ✅ Modifier produit
- ✅ Supprimer produit
- ✅ Lister produits
- ✅ Rechercher produits
- ✅ Vérifier stock disponible
- ✅ Obtenir produits en rupture

### Gestion Utilisateurs (Admin):
- ✅ Créer utilisateur (admin/caissier)
- ✅ Modifier utilisateur
- ✅ Supprimer utilisateur
- ✅ Lister utilisateurs
- ✅ Filtrer par rôle
- ✅ Vérifier email unique

### Entrées de Stock (Admin):
- ✅ Créer entrée
- ✅ Supprimer entrée (restore stock)
- ✅ Lister entrées
- ✅ Estadistiques journalières
- ✅ Filtre par produit/utilisateur

### Sorties/Ventes (Admin + Caissier):
- ✅ Créer vente
- ✅ Vérifier stock avant vente
- ✅ Annuler vente (restore stock)
- ✅ Lister ventes
- ✅ Statistiques journalières
- ✅ Montant total vendu
- ✅ Historique par caissier/date

---

## 📋 TODO - PROCHAINES ÉTAPES

### Phase 1: Corriger les erreurs Provider
- [ ] Refactoriser product_detail_view.dart
- [ ] Refactoriser product_form.dart
- [ ] Refactoriser edit_product_form.dart
- [ ] Refactoriser user_view.dart

### Phase 2: Créer Views Admin
- [ ] AdminProductListView (liste + CRUD)
- [ ] AdminProductFormView
- [ ] AdminEntryListView
- [ ] AdminEntryFormView
- [ ] AdminOutputListView
- [ ] AdminUserListView
- [ ] AdminUserFormView

### Phase 3: Créer Views Caissier
- [ ] CashierProductListView
- [ ] CashierOutputListView
- [ ] CashierOutputFormView
- [ ] CashierHistoryView

### Phase 4: Améliorations
- [ ] Ajouter pagination aux listes
- [ ] Ajouter filtres avancés
- [ ] Ajouter exports PDF/Excel
- [ ] Ajouter graphiques statistiques
- [ ] Ajouter recherche en temps réel
- [ ] Ajouter synchronisation cloud (optionnel)

---

## 🎯 STRUCTURE FINALE (PRÉVUE)

```
lib/
├── main.dart
├── app/
│   ├── bindings/
│   │   ├── auth_binding.dart
│   │   ├── product_binding.dart
│   │   ├── user_binding.dart
│   │   ├── entry_binding.dart
│   │   └── output_binding.dart
│   ├── controllers/
│   │   ├── auth_controller.dart
│   │   ├── product_controller.dart
│   │   ├── user_controller.dart
│   │   ├── entry_controller.dart
│   │   └── output_controller.dart
│   ├── models/
│   │   ├── product.dart
│   │   ├── user.dart
│   │   ├── entry_model.dart
│   │   └── output_model.dart
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   ├── services/
│   │   ├── database_service.dart
│   │   ├── auth_service.dart
│   │   ├── product_service.dart
│   │   ├── user_service.dart
│   │   ├── entry_service.dart
│   │   └── output_service.dart
│   ├── views/
│   │   ├── user/
│   │   │   ├── login_view.dart
│   │   │   └── ...
│   │   ├── admin/
│   │   │   ├── admin_dashboard_view.dart
│   │   │   ├── product/
│   │   │   ├── entries/
│   │   │   ├── outputs/
│   │   │   └── users/
│   │   └── cashier/
│   │       ├── cashier_dashboard_view.dart
│   │       ├── product/
│   │       ├── outputs/
│   │       └── history/
│   └── database/
│       └── database_helper.dart
└── assets/
    └── images/
```

---

## 🧪 TESTE L'APPLICATION

### Compte Admin par défaut:
- **Email:** `admin@local.com`
- **Mot de passe:** `@admin123`

### Pour créer un caissier:
1. Connectez-vous en tant qu'admin
2. Allez dans "Utilisateurs"
3. Créez un nouvel utilisateur avec rôle "caissier"

---

## 📚 RÉFÉRENCES

- **GetX Documentation:** https://github.com/jonataslaw/getx
- **Sqflite:** https://pub.dev/packages/sqflite
- **Flutter MVC Pattern:** https://medium.com/flutter-community

---

## ⚠️ NOTES IMPORTANTES

1. **Injection Dépendances:** Utilisez `Get.put()`, `Get.lazyPut()`, ou `Get.find()` 
2. **Réactivité:** Utilisez `RxList`, `RxString`, `RxBool`, `Obx()` pour les mises à jour UI
3. **Navigation:** Utilisez `Get.toNamed()`, `Get.offAllNamed()` au lieu de `Navigator.push()`
4. **Services:** Pas de logique métier, uniquement accès aux données
5. **Controllers:** Contiennent la logique métier et orchestrent les services

---

Projet mis à jour: **28 février 2026**
Architecture: **MVC + GetX + Services (sans Provider, sans Repository)**
