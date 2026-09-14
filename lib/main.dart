import 'dart:async';
import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const SmartSchedulerApp());
}

class SmartSchedulerApp extends StatelessWidget {
  const SmartSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Smart Resource Scheduler',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

// 1. MODELS & DATA STRUCTURES
enum UserRole { admin, viewer }
enum BookingStatus { pending, completed, cancelled }

class UserSession {
  final String username;
  final UserRole role;

  UserSession({required this.username, required this.role});

  bool get isAdmin => role == UserRole.admin;
}

class Category {
  String id;
  String name;
  List<Resource> resources;

  Category({required this.id, required this.name, required this.resources});
}

class Resource {
  String id;
  String name;

  Resource({required this.id, required this.name});
}

class Instructor {
  String id;
  String name;

  Instructor({required this.id, required this.name});
}

class Cadet {
  String id;
  String name;

  Cadet({required this.id, required this.name});
}

class ScheduleBooking {
  final String id;
  String title;
  String resourceId;
  int startMinuteFrom8AM;
  int durationMinutes;
  Color color;
  
  String field1; // Instructor / Driver / Speaker
  String field2; // Cadet / Student / Plate / Group
  String field3; // Lesson / Service / Subject
  String comments;
  bool isStandby;
  
  bool isCancelledManually;

  ScheduleBooking({
    required this.id,
    required this.title,
    required this.resourceId,
    required this.startMinuteFrom8AM,
    required this.durationMinutes,
    required this.color,
    this.field1 = '',
    this.field2 = '',
    this.field3 = '',
    this.comments = '',
    this.isStandby = false,
    this.isCancelledManually = false,
  });

  // Calculate Status dynamically based on Current Time
  BookingStatus getStatus(DateTime now) {
    if (isCancelledManually == true) {
      return BookingStatus.cancelled;
    }

    int currentMinutesFrom8 = (now.hour * 60 + now.minute) - (8 * 60);
    int endMinuteFrom8 = startMinuteFrom8AM + durationMinutes;

    if (currentMinutesFrom8 >= endMinuteFrom8) {
      return BookingStatus.completed;
    }

    return BookingStatus.pending;
  }
}

List<Category> getDomainCategories(String domain) {
  if (domain == 'Parking') {
    return [
      Category(
        id: 'p_cat1',
        name: 'VIP & Short-Term Parking',
        resources: [
          Resource(id: 'pr1', name: 'Spot A-101 (VIP)'),
          Resource(id: 'pr2', name: 'Spot A-102 (VIP)'),
        ],
      ),
      Category(
        id: 'p_cat2',
        name: 'EV Charging Stations',
        resources: [
          Resource(id: 'pr3', name: 'EV Charger Fast B-201'),
          Resource(id: 'pr4', name: 'EV Charger Ultra B-202'),
        ],
      ),
    ];
  } else if (domain == 'Training') {
    return [
      Category(
        id: 't_cat1',
        name: 'Theory Classrooms',
        resources: [
          Resource(id: 'tr1', name: 'Hall Alpha (Cap: 30)'),
          Resource(id: 'tr2', name: 'Hall Beta (Cap: 15)'),
        ],
      ),
      Category(
        id: 't_cat2',
        name: 'Labs & Simulators',
        resources: [
          Resource(id: 'tr3', name: 'IT & VR Lab 1'),
          Resource(id: 'tr4', name: 'Sim Room 101'),
        ],
      ),
    ];
  } else {
    return [
      Category(
        id: 'cat1',
        name: 'Training Aircraft',
        resources: [
          Resource(id: 'r1', name: 'Cessna 172 (SX-ABC)'),
          Resource(id: 'r2', name: 'Piper PA-28 (SX-DEF)'),
        ],
      ),
      Category(
        id: 'cat2',
        name: 'Passenger / Travel Aircraft',
        resources: [
          Resource(id: 'r3', name: 'Beechcraft Baron (SX-GHI)'),
        ],
      ),
    ];
  }
}

List<Instructor> getInitialInstructors() {
  return [
    Instructor(id: 'i1', name: 'Capt. Nikos P.'),
    Instructor(id: 'i2', name: 'Capt. Sarah M.'),
  ];
}

List<Cadet> getInitialCadets() {
  return [
    Cadet(id: 'c1', name: 'Giorgos S.'),
    Cadet(id: 'c2', name: 'Alex K.'),
  ];
}

// 2. LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? errorMessage;

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    UserSession? session;

    if (username == 'admin' && password == 'admin') {
      session = UserSession(username: 'Administrator', role: UserRole.admin);
    } else if (username == 'user' && password == 'user') {
      session = UserSession(username: 'Standard User', role: UserRole.viewer);
    }

    if (session != null) {
      setState(() => errorMessage = null);
      
      List<Category> initialCategories = getDomainCategories('Aviation');
      List<Instructor> initialInstructors = getInitialInstructors();
      List<Cadet> initialCadets = getInitialCadets();

      if (session.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryManagerScreen(
              session: session!,
              categories: initialCategories,
              instructors: initialInstructors,
              cadets: initialCadets,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetupWizardScreen(
              session: session!,
              categories: initialCategories,
              instructors: initialInstructors,
              cadets: initialCadets,
            ),
          ),
        );
      }
    } else {
      setState(() {
        errorMessage = 'Invalid Username or Password (admin/admin or user/user)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_person_rounded, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text(
                'Smart Scheduler Login',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: _handleLogin,
                child: const Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. CATEGORY & PERSONNEL MANAGER SCREEN (ADMIN ONLY)
class CategoryManagerScreen extends StatefulWidget {
  final UserSession session;
  final List<Category> categories;
  final List<Instructor> instructors;
  final List<Cadet> cadets;

  const CategoryManagerScreen({
    super.key,
    required this.session,
    required this.categories,
    required this.instructors,
    required this.cadets,
  });

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen> {
  late List<Category> categories;
  late List<Instructor> instructors;
  late List<Cadet> cadets;

  Category? selectedCategory;
  Resource? selectedResource;
  Instructor? selectedInstructor;
  Cadet? selectedCadet;

  @override
  void initState() {
    super.initState();
    categories = widget.categories;
    instructors = widget.instructors;
    cadets = widget.cadets;

    if (categories.isNotEmpty) {
      selectedCategory = categories.first;
      if (selectedCategory!.resources.isNotEmpty) {
        selectedResource = selectedCategory!.resources.first;
      }
    }
    if (instructors.isNotEmpty) selectedInstructor = instructors.first;
    if (cadets.isNotEmpty) selectedCadet = cadets.first;
  }

  void _addCategory() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Category Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  final newCat = Category(id: DateTime.now().toString(), name: controller.text.trim(), resources: []);
                  categories.add(newCat);
                  selectedCategory = newCat;
                  selectedResource = null;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _editCategory() {
    if (selectedCategory == null) return;
    final controller = TextEditingController(text: selectedCategory!.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Category Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  selectedCategory!.name = controller.text.trim();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _deleteCategory() {
    if (selectedCategory == null) return;
    setState(() {
      categories.remove(selectedCategory);
      selectedCategory = categories.isNotEmpty ? categories.first : null;
      selectedResource = selectedCategory != null && selectedCategory!.resources.isNotEmpty ? selectedCategory!.resources.first : null;
    });
  }

  void _addResource() {
    if (selectedCategory == null) return;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Resource (${selectedCategory!.name})'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Resource Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  final newRes = Resource(id: DateTime.now().toString(), name: controller.text.trim());
                  selectedCategory!.resources.add(newRes);
                  selectedResource = newRes;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _editResource() {
    if (selectedResource == null) return;
    final controller = TextEditingController(text: selectedResource!.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Resource'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Resource Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  selectedResource!.name = controller.text.trim();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _deleteResource() {
    if (selectedResource == null || selectedCategory == null) return;
    setState(() {
      selectedCategory!.resources.remove(selectedResource);
      selectedResource = selectedCategory!.resources.isNotEmpty ? selectedCategory!.resources.first : null;
    });
  }

  void _addInstructor() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Instructor'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Instructor Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  final newInst = Instructor(id: DateTime.now().toString(), name: controller.text.trim());
                  instructors.add(newInst);
                  selectedInstructor = newInst;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _editInstructor() {
    if (selectedInstructor == null) return;
    final controller = TextEditingController(text: selectedInstructor!.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Instructor'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Instructor Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  selectedInstructor!.name = controller.text.trim();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _deleteInstructor() {
    if (selectedInstructor == null) return;
    setState(() {
      instructors.remove(selectedInstructor);
      selectedInstructor = instructors.isNotEmpty ? instructors.first : null;
    });
  }

  void _addCadet() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Cadet / Student'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Cadet Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  final newCadet = Cadet(id: DateTime.now().toString(), name: controller.text.trim());
                  cadets.add(newCadet);
                  selectedCadet = newCadet;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _editCadet() {
    if (selectedCadet == null) return;
    final controller = TextEditingController(text: selectedCadet!.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Cadet / Student'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Cadet Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  selectedCadet!.name = controller.text.trim();
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _deleteCadet() {
    if (selectedCadet == null) return;
    setState(() {
      cadets.remove(selectedCadet);
      selectedCadet = cadets.isNotEmpty ? cadets.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Resource Manager'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('1. Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<Category>(
                  value: selectedCategory,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategory = val;
                      selectedResource = val != null && val.resources.isNotEmpty ? val.resources.first : null;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filledTonal(icon: const Icon(Icons.add), onPressed: _addCategory, tooltip: 'Add Category'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(icon: const Icon(Icons.edit), onPressed: selectedCategory != null ? _editCategory : null, tooltip: 'Edit Category'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(icon: const Icon(Icons.delete), onPressed: selectedCategory != null ? _deleteCategory : null, tooltip: 'Delete Category'),
                  ],
                ),
                const Divider(height: 28),

                const Text('2. Subcategories / Resources (Aircrafts/Spots)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<Resource>(
                  value: selectedResource,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: selectedCategory != null
                      ? selectedCategory!.resources.map((res) => DropdownMenuItem(value: res, child: Text(res.name))).toList()
                      : [],
                  onChanged: (val) {
                    setState(() {
                      selectedResource = val;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filledTonal(icon: const Icon(Icons.add), onPressed: selectedCategory != null ? _addResource : null, tooltip: 'Add Resource'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(icon: const Icon(Icons.edit), onPressed: selectedResource != null ? _editResource : null, tooltip: 'Edit Resource'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(icon: const Icon(Icons.delete), onPressed: selectedResource != null ? _deleteResource : null, tooltip: 'Delete Resource'),
                  ],
                ),
                const Divider(height: 28),

                const Text('3. Instructors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<Instructor>(
                  value: selectedInstructor,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: instructors.map((inst) => DropdownMenuItem(value: inst, child: Text(inst.name))).toList(),
                  onChanged: (val) => setState(() => selectedInstructor = val),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filledTonal(icon: const Icon(Icons.add), onPressed: _addInstructor, tooltip: 'Add Instructor'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(icon: const Icon(Icons.edit), onPressed: selectedInstructor != null ? _editInstructor : null, tooltip: 'Edit Instructor'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(icon: const Icon(Icons.delete), onPressed: selectedInstructor != null ? _deleteInstructor : null, tooltip: 'Delete Instructor'),
                  ],
                ),
                const Divider(height: 28),

                const Text('4. Cadets / Students', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<Cadet>(
                  value: selectedCadet,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: cadets.map((cadet) => DropdownMenuItem(value: cadet, child: Text(cadet.name))).toList(),
                  onChanged: (val) => setState(() => selectedCadet = val),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filledTonal(icon: const Icon(Icons.add), onPressed: _addCadet, tooltip: 'Add Cadet'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(icon: const Icon(Icons.edit), onPressed: selectedCadet != null ? _editCadet : null, tooltip: 'Edit Cadet'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(icon: const Icon(Icons.delete), onPressed: selectedCadet != null ? _deleteCadet : null, tooltip: 'Delete Cadet'),
                  ],
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Proceed to Setup Wizard'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetupWizardScreen(
                          session: widget.session,
                          categories: categories,
                          instructors: instructors,
                          cadets: cadets,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 4. SETUP WIZARD SCREEN
class SetupWizardScreen extends StatefulWidget {
  final UserSession session;
  final List<Category> categories;
  final List<Instructor> instructors;
  final List<Cadet> cadets;

  const SetupWizardScreen({
    super.key,
    required this.session,
    required this.categories,
    required this.instructors,
    required this.cadets,
  });

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  String selectedDomain = 'Aviation';
  int timeSlotMinutes = 30;
  bool preventOverlaps = true;

  List<Category> activeCategories = [];

  @override
  void initState() {
    super.initState();
    activeCategories = widget.categories.isNotEmpty ? widget.categories : getDomainCategories(selectedDomain);
  }

  void _onDomainChanged(String newDomain) {
    setState(() {
      selectedDomain = newDomain;
      activeCategories = getDomainCategories(newDomain);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Configuration'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Chip(
                avatar: Icon(widget.session.isAdmin ? Icons.admin_panel_settings : Icons.visibility),
                label: Text('Logged in as: ${widget.session.username} (${widget.session.isAdmin ? "Admin" : "Read Only"})'),
              ),
              const SizedBox(height: 20),
              const Text('Select Domain', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedDomain,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Aviation', child: Text('Aviation / Flight School')),
                  DropdownMenuItem(value: 'Parking', child: Text('Parking Lot / EV Station')),
                  DropdownMenuItem(value: 'Training', child: Text('Training Center')),
                ],
                onChanged: (val) => _onDomainChanged(val!),
              ),
              const SizedBox(height: 20),
              const Text('Grid Time Step', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 15, label: Text('15m')),
                  ButtonSegment(value: 30, label: Text('30m')),
                  ButtonSegment(value: 60, label: Text('1h')),
                ],
                selected: {timeSlotMinutes},
                onSelectionChanged: (val) => setState(() => timeSlotMinutes = val.first),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Strict Conflict Prevention'),
                value: preventOverlaps,
                onChanged: (val) => setState(() => preventOverlaps = val),
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, child) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Night / Dark Mode'),
                    value: mode == ThemeMode.dark,
                    onChanged: (val) {
                      themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                    },
                  );
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.grid_on),
                label: const Text('Open Schedule Grid'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SchedulerGridScreen(
                        session: widget.session,
                        domain: selectedDomain,
                        slotMinutes: timeSlotMinutes,
                        preventOverlaps: preventOverlaps,
                        categories: activeCategories,
                        instructors: widget.instructors,
                        cadets: widget.cadets,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 5. SCHEDULER GRID SCREEN (DYNAMIC COLORING: GREEN FOR COMPLETED, RED FOR CANCELLED)
class SchedulerGridScreen extends StatefulWidget {
  final UserSession session;
  final String domain;
  final int slotMinutes;
  final bool preventOverlaps;
  final List<Category> categories;
  final List<Instructor> instructors;
  final List<Cadet> cadets;

  const SchedulerGridScreen({
    super.key,
    required this.session,
    required this.domain,
    required this.slotMinutes,
    required this.preventOverlaps,
    required this.categories,
    required this.instructors,
    required this.cadets,
  });

  @override
  State<SchedulerGridScreen> createState() => _SchedulerGridScreenState();
}

class _SchedulerGridScreenState extends State<SchedulerGridScreen> {
  late List<ScheduleBooking> bookings;
  late List<int> timeSlots;
  Timer? _timer;
  late DateTime _now;

  String? _hoveredSlotKey;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _generateSlots();
    _loadBookings();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateSlots() {
    timeSlots = [];
    for (int min = 0; min <= 600; min += widget.slotMinutes) {
      timeSlots.add(min);
    }
  }

  void _loadBookings() {
    final allRes = _allResources;
    String firstResId = allRes.isNotEmpty ? allRes.first.id : 'r1';
    String defaultInstructor = widget.instructors.isNotEmpty ? widget.instructors.first.name : 'Capt. Nikos P.';
    String defaultCadet = widget.cadets.isNotEmpty ? widget.cadets.first.name : 'Giorgos S.';

    if (widget.domain == 'Parking') {
      bookings = [
        ScheduleBooking(
          id: 'b1',
          title: 'Parking Spot Reserve',
          resourceId: firstResId,
          startMinuteFrom8AM: 60,
          durationMinutes: 120,
          color: Colors.indigo.shade600,
          field1: 'Nikos P.',
          field2: 'ZAB-1234',
          field3: 'EV Fast Charge',
          comments: 'Park near charger',
          isStandby: false,
        ),
      ];
    } else if (widget.domain == 'Training') {
      bookings = [
        ScheduleBooking(
          id: 'b1',
          title: 'Flutter Masterclass',
          resourceId: firstResId,
          startMinuteFrom8AM: 60,
          durationMinutes: 180,
          color: Colors.indigo.shade600,
          field1: 'Dr. Alex',
          field2: 'Group B2',
          field3: 'Mobile Dev Course',
          comments: 'Projector required',
          isStandby: false,
        ),
      ];
    } else {
      bookings = [
        ScheduleBooking(
          id: 'b1',
          title: 'Flight Training Slot',
          resourceId: firstResId,
          startMinuteFrom8AM: 60,
          durationMinutes: 120,
          color: Colors.indigo.shade600,
          field1: defaultInstructor,
          field2: defaultCadet,
          field3: 'PPL Navigation',
          comments: 'Check weather before takeoff',
          isStandby: false,
        ),
      ];
    }
  }

  String _formatMinutesToTime(int minutesFrom8) {
    int totalMinutes = 8 * 60 + minutesFrom8;
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  List<Resource> get _allResources {
    List<Resource> resList = [];
    for (var cat in widget.categories) {
      resList.addAll(cat.resources);
    }
    return resList;
  }

  bool _hasConflict(ScheduleBooking booking, String targetResourceId, int targetStartMin, int durationMin) {
    if (!widget.preventOverlaps) return false;
    int targetEndMin = targetStartMin + durationMin;

    for (var b in bookings) {
      if (b.id == booking.id) continue;
      if (b.resourceId != targetResourceId) continue;
      if (b.getStatus(_now) == BookingStatus.cancelled) continue;

      int bStart = b.startMinuteFrom8AM;
      int bEnd = b.startMinuteFrom8AM + b.durationMinutes;

      if (targetStartMin < bEnd && targetEndMin > bStart) return true;
    }
    return false;
  }

  void _confirmDeleteBooking(ScheduleBooking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete the booking "${booking.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                bookings.removeWhere((b) => b.id == booking.id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ Booking deleted.'), backgroundColor: Colors.redAccent),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBookingFormDialog({ScheduleBooking? existingBooking, String? initialResourceId, int? initialStartMin}) {
    if (!widget.session.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔒 Read-Only: You do not have edit permissions.')),
      );
      return;
    }

    final allRes = _allResources;
    if (allRes.isEmpty) return;

    bool isEditing = existingBooking != null;

    String selectedResId = isEditing ? existingBooking.resourceId : (initialResourceId ?? allRes.first.id);
    int selectedStartMin = isEditing ? existingBooking.startMinuteFrom8AM : (initialStartMin ?? 0);
    int selectedDurationMin = isEditing ? existingBooking.durationMinutes : (widget.slotMinutes * 2);

    String label1 = widget.domain == 'Parking' ? 'Driver Name' : (widget.domain == 'Training' ? 'Trainer / Speaker' : 'Instructor');
    String label2 = widget.domain == 'Parking' ? 'Vehicle License Plate' : (widget.domain == 'Training' ? 'Group / Class' : 'Cadet / Student');
    String label3 = widget.domain == 'Parking' ? 'Service / Charge' : (widget.domain == 'Training' ? 'Course / Subject' : 'Flight Lesson Type');
    String defaultTitle = widget.domain == 'Parking' ? 'Spot Reservation' : (widget.domain == 'Training' ? 'Class Session' : 'Flight Slot');

    final titleController = TextEditingController(text: isEditing ? existingBooking.title : defaultTitle);
    final field1Controller = TextEditingController(text: isEditing ? existingBooking.field1 : (widget.instructors.isNotEmpty ? widget.instructors.first.name : ''));
    final field2Controller = TextEditingController(text: isEditing ? existingBooking.field2 : (widget.cadets.isNotEmpty ? widget.cadets.first.name : ''));
    final field3Controller = TextEditingController(text: isEditing ? existingBooking.field3 : '');
    final commentsController = TextEditingController(text: isEditing ? existingBooking.comments : '');
    bool isStandby = isEditing ? existingBooking.isStandby : false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setFormState) {
            BookingStatus currentStatus = isEditing ? existingBooking.getStatus(_now) : BookingStatus.pending;

            bool conflict = _hasConflict(
              ScheduleBooking(
                id: isEditing ? existingBooking.id : 'temp',
                title: '',
                resourceId: selectedResId,
                startMinuteFrom8AM: selectedStartMin,
                durationMinutes: selectedDurationMin,
                color: Colors.indigo.shade600,
              ),
              selectedResId,
              selectedStartMin,
              selectedDurationMin,
            );

            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit_calendar : Icons.add_task, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Booking' : 'New Booking ($defaultTitle)',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // READ-ONLY STATUS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status (Automatic):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Chip(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              backgroundColor: currentStatus == BookingStatus.cancelled
                                  ? Colors.red.shade100
                                  : (currentStatus == BookingStatus.completed ? Colors.green.shade100 : Colors.amber.shade100),
                              side: BorderSide.none,
                              avatar: Icon(
                                currentStatus == BookingStatus.cancelled
                                    ? Icons.cancel
                                    : (currentStatus == BookingStatus.completed ? Icons.check_circle : Icons.schedule),
                                size: 16,
                                color: currentStatus == BookingStatus.cancelled
                                    ? Colors.red.shade900
                                    : (currentStatus == BookingStatus.completed ? Colors.green.shade900 : Colors.amber.shade900),
                              ),
                              label: Text(
                                currentStatus.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: currentStatus == BookingStatus.cancelled
                                      ? Colors.red.shade900
                                      : (currentStatus == BookingStatus.completed ? Colors.green.shade900 : Colors.amber.shade900),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedResId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: widget.domain == 'Parking' ? 'Spot / Location' : (widget.domain == 'Training' ? 'Classroom / Lab' : 'Aircraft / Resource'),
                          border: const OutlineInputBorder(),
                        ),
                        items: allRes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) => setFormState(() => selectedResId = val!),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedStartMin,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Start Time', border: OutlineInputBorder()),
                              items: timeSlots.where((s) => s < 600).map((s) => DropdownMenuItem(value: s, child: Text(_formatMinutesToTime(s)))).toList(),
                              onChanged: (val) => setFormState(() => selectedStartMin = val!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedDurationMin,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()),
                              items: [15, 30, 45, 60, 90, 120, 180, 240]
                                  .map((d) => DropdownMenuItem(
                                        value: d,
                                        child: Text('${d}m', overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) => setFormState(() => selectedDurationMin = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Booking Title', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: field1Controller,
                              decoration: InputDecoration(labelText: label1, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.person_outline, size: 20)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: field2Controller,
                              decoration: InputDecoration(labelText: label2, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.badge_outlined, size: 20)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: field3Controller,
                        decoration: InputDecoration(labelText: label3, border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: commentsController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Comments / Notes', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Standby Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: const Text('Highlight booking with special indicator', style: TextStyle(fontSize: 10)),
                        value: isStandby,
                        onChanged: (val) => setFormState(() => isStandby = val ?? false),
                      ),

                      // ROUNDED CANCEL BUTTON
                      if (isEditing && currentStatus != BookingStatus.cancelled) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade300, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancel Booking (Set Status to Cancelled)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            onPressed: () {
                              setState(() {
                                existingBooking.isCancelledManually = true;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('🛑 Booking marked as Cancelled.'), backgroundColor: Colors.redAccent),
                              );
                            },
                          ),
                        ),
                      ],

                      if (conflict) ...[
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '⚠️ Warning: Overlap detected with another booking!',
                                style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                if (isEditing)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteBooking(existingBooking);
                    },
                  ),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: conflict ? Colors.grey : Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: conflict
                      ? null
                      : () {
                          setState(() {
                            Color itemColor = isStandby
                                ? Colors.orange.shade700
                                : Colors.indigo.shade600;

                            if (isEditing) {
                              existingBooking.title = titleController.text.trim().isEmpty ? 'Booking' : titleController.text.trim();
                              existingBooking.resourceId = selectedResId;
                              existingBooking.startMinuteFrom8AM = selectedStartMin;
                              existingBooking.durationMinutes = selectedDurationMin;
                              existingBooking.field1 = field1Controller.text.trim();
                              existingBooking.field2 = field2Controller.text.trim();
                              existingBooking.field3 = field3Controller.text.trim();
                              existingBooking.comments = commentsController.text.trim();
                              existingBooking.isStandby = isStandby;
                              existingBooking.color = itemColor;
                            } else {
                              bookings.add(
                                ScheduleBooking(
                                  id: DateTime.now().toString(),
                                  title: titleController.text.trim().isEmpty ? 'Booking' : titleController.text.trim(),
                                  resourceId: selectedResId,
                                  startMinuteFrom8AM: selectedStartMin,
                                  durationMinutes: selectedDurationMin,
                                  color: itemColor,
                                  field1: field1Controller.text.trim(),
                                  field2: field2Controller.text.trim(),
                                  field3: field3Controller.text.trim(),
                                  comments: commentsController.text.trim(),
                                  isStandby: isStandby,
                                ),
                              );
                            }
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? '✅ Booking updated!' : '✅ Booking created successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                  child: Text(isEditing ? 'Save' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double slotWidth = widget.slotMinutes == 15 ? 60.0 : (widget.slotMinutes == 30 ? 80.0 : 110.0);

    int currentMinutesFrom8 = (_now.hour * 60 + _now.minute) - (8 * 60);
    double? timeIndicatorOffset;

    if (currentMinutesFrom8 >= 0 && currentMinutesFrom8 <= 600) {
      double pixelsPerMinute = slotWidth / widget.slotMinutes;
      timeIndicatorOffset = 180.0 + (currentMinutesFrom8 * pixelsPerMinute);
    }

    List<int> gridSlots = timeSlots.where((s) => s < 600).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Grid (${widget.domain}) - ${widget.session.isAdmin ? "Edit Mode" : "Read Only"}'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      floatingActionButton: widget.session.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showBookingFormDialog(),
              icon: const Icon(Icons.add),
              label: const Text('New Booking'),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 180,
                              height: 45,
                              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
                              child: const Center(child: Text('Categories / Resources', style: TextStyle(fontWeight: FontWeight.bold))),
                            ),
                            SizedBox(
                              width: gridSlots.length * slotWidth,
                              height: 45,
                              child: Stack(
                                children: [
                                  Row(
                                    children: gridSlots
                                        .map(
                                          (min) => Container(
                                            width: slotWidth,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                                              border: Border(
                                                left: BorderSide(color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.5),
                                                top: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                                                bottom: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  ...gridSlots.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    int min = entry.value;
                                    return Positioned(
                                      left: (index * slotWidth) - 25,
                                      top: 12,
                                      child: SizedBox(
                                        width: 50,
                                        child: Text(
                                          _formatMinutesToTime(min),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ...widget.categories.map((cat) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 180.0 + (gridSlots.length * slotWidth),
                                height: 32,
                                color: isDarkMode ? Colors.indigo.shade900.withOpacity(0.6) : Colors.indigo.shade100,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text(
                                  '📂 ${cat.name.toUpperCase()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo),
                                ),
                              ),
                              ...cat.resources.map((res) {
                                return Row(
                                  children: [
                                    Container(
                                      width: 180,
                                      height: 55,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                                        border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                                      ),
                                      child: Align(alignment: Alignment.centerLeft, child: Text(res.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                    ),
                                    Builder(
                                      builder: (context) {
                                        List<Widget> slotWidgets = [];
                                        int slotIndex = 0;

                                        while (slotIndex < gridSlots.length) {
                                          int slotMin = gridSlots[slotIndex];

                                          final bookingIndex = bookings.indexWhere(
                                            (b) => b.resourceId == res.id && b.startMinuteFrom8AM == slotMin,
                                          );

                                          if (bookingIndex != -1) {
                                            final booking = bookings[bookingIndex];
                                            
                                            int spannedSlots = (booking.durationMinutes / widget.slotMinutes).ceil();
                                            if (spannedSlots < 1) spannedSlots = 1;

                                            double bookingWidth = slotWidth * spannedSlots;

                                            slotWidgets.add(
                                              DragTarget<ScheduleBooking>(
                                                onWillAcceptWithDetails: (details) => widget.session.isAdmin,
                                                onAcceptWithDetails: (details) {
                                                  if (!widget.session.isAdmin) return;
                                                  if (_hasConflict(details.data, res.id, slotMin, details.data.durationMinutes)) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('⚠️ Overlap! Drag cancelled.'), backgroundColor: Colors.redAccent),
                                                    );
                                                  } else {
                                                    setState(() {
                                                      details.data.resourceId = res.id;
                                                      details.data.startMinuteFrom8AM = slotMin;
                                                    });
                                                  }
                                                },
                                                builder: (context, candidateData, rejectedData) {
                                                  return Container(
                                                    width: bookingWidth,
                                                    height: 55,
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        left: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300, width: 1.5),
                                                        top: BorderSide(color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200),
                                                        bottom: BorderSide(color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200),
                                                      ),
                                                    ),
                                                    child: widget.session.isAdmin
                                                        ? Draggable<ScheduleBooking>(
                                                            data: booking,
                                                            feedback: Material(
                                                              elevation: 6,
                                                              child: Container(
                                                                width: bookingWidth,
                                                                height: 45,
                                                                padding: const EdgeInsets.all(6),
                                                                color: booking.color.withOpacity(0.85),
                                                                child: Text(booking.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                                              ),
                                                            ),
                                                            childWhenDragging: Container(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
                                                            child: InkWell(
                                                              onTap: () => _showBookingFormDialog(existingBooking: booking),
                                                              child: _buildBookingTile(booking, bookingWidth),
                                                            ),
                                                          )
                                                        : GestureDetector(
                                                            onTap: () {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(content: Text('🔒 Read-Only: You do not have edit permissions.')),
                                                              );
                                                            },
                                                            child: _buildBookingTile(booking, bookingWidth),
                                                          ),
                                                  );
                                                },
                                              ),
                                            );

                                            slotIndex += spannedSlots;
                                          } else {
                                            String slotKey = '${res.id}_$slotMin';
                                            bool isHovered = _hoveredSlotKey == slotKey;

                                            slotWidgets.add(
                                              DragTarget<ScheduleBooking>(
                                                onWillAcceptWithDetails: (details) => widget.session.isAdmin,
                                                onAcceptWithDetails: (details) {
                                                  if (!widget.session.isAdmin) return;
                                                  if (_hasConflict(details.data, res.id, slotMin, details.data.durationMinutes)) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('⚠️ Overlap! Drag cancelled.'), backgroundColor: Colors.redAccent),
                                                    );
                                                  } else {
                                                    setState(() {
                                                      details.data.resourceId = res.id;
                                                      details.data.startMinuteFrom8AM = slotMin;
                                                    });
                                                  }
                                                },
                                                builder: (context, candidateData, rejectedData) {
                                                  return MouseRegion(
                                                    onEnter: (_) => setState(() => _hoveredSlotKey = slotKey),
                                                    onExit: (_) => setState(() => _hoveredSlotKey = null),
                                                    child: Container(
                                                      width: slotWidth,
                                                      height: 55,
                                                      decoration: BoxDecoration(
                                                        color: candidateData.isNotEmpty
                                                            ? (isDarkMode ? Colors.indigo.shade900 : Colors.indigo.shade50)
                                                            : (isDarkMode ? const Color(0xFF121212) : Colors.white),
                                                        border: Border(
                                                          left: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300, width: 1.5),
                                                          top: BorderSide(color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200),
                                                          bottom: BorderSide(color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200),
                                                        ),
                                                      ),
                                                      child: isHovered && widget.session.isAdmin
                                                          ? Center(
                                                              child: IconButton(
                                                                icon: const Icon(Icons.add_circle, color: Colors.indigo, size: 22),
                                                                onPressed: () => _showBookingFormDialog(
                                                                  initialResourceId: res.id,
                                                                  initialStartMin: slotMin,
                                                                ),
                                                                tooltip: 'New booking on this slot',
                                                              ),
                                                            )
                                                          : null,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                            slotIndex++;
                                          }
                                        }

                                        return Row(children: slotWidgets);
                                      },
                                    ),
                                  ],
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    ),
                    if (timeIndicatorOffset != null)
                      Positioned(
                        left: timeIndicatorOffset,
                        top: 0,
                        bottom: 0,
                        child: Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.session.isAdmin)
            DragTarget<ScheduleBooking>(
              onAcceptWithDetails: (details) {
                _confirmDeleteBooking(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                bool isHovered = candidateData.isNotEmpty;
                return Container(
                  height: 50,
                  width: double.infinity,
                  color: isHovered ? Colors.red.shade700 : Colors.red.shade900.withOpacity(0.8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_forever, color: isHovered ? Colors.yellow : Colors.white, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        isHovered ? 'Drop here to DELETE' : 'Drag booking here to delete (Trash Zone)',
                        style: TextStyle(
                          color: isHovered ? Colors.yellow : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBookingTile(ScheduleBooking booking, double itemWidth) {
    int startMin = booking.startMinuteFrom8AM;
    int endMin = booking.startMinuteFrom8AM + booking.durationMinutes;
    BookingStatus status = booking.getStatus(_now);

    // DYNAMIC COLOR SELECTION:
    // Cancelled -> RED
    // Completed -> GREEN
    // Pending   -> Default Booking Color
    Color tileColor = booking.color;
    if (status == BookingStatus.cancelled) {
      tileColor = Colors.red.shade800;
    } else if (status == BookingStatus.completed) {
      tileColor = Colors.green.shade700;
    }

    return Container(
      width: itemWidth - 4,
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(6),
        border: booking.isStandby ? Border.all(color: Colors.amberAccent, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    decoration: status == BookingStatus.cancelled ? TextDecoration.lineThrough : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (booking.isStandby)
                const Text('⏳', style: TextStyle(fontSize: 10)),
            ],
          ),
          Text(
            '${_formatMinutesToTime(startMin)} - ${_formatMinutesToTime(endMin)} (${booking.durationMinutes}m)',
            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              if (booking.field1.isNotEmpty)
                Expanded(
                  child: Text(
                    booking.field1,
                    style: const TextStyle(color: Colors.white70, fontSize: 8),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (status == BookingStatus.completed)
                const Text('✓ Completed', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))
              else if (status == BookingStatus.cancelled)
                const Text('🚫 Cancelled', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}