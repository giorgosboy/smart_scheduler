import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartSchedulerApp());
}

class SmartSchedulerApp extends StatefulWidget {
  const SmartSchedulerApp({super.key});

  @override
  State<SmartSchedulerApp> createState() => _SmartSchedulerAppState();
}

class _SmartSchedulerAppState extends State<SmartSchedulerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Resource Scheduler',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
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
      home: LoginScreen(onThemeChanged: _toggleTheme, currentThemeMode: _themeMode),
    );
  }
}

// 1. MODELS & USER ROLES
enum UserRole { admin, viewer }

class UserSession {
  final String username;
  final UserRole role;

  UserSession({required this.username, required this.role});

  bool get isAdmin => role == UserRole.admin;
}

class Resource {
  final String id;
  final String name;
  final String type;

  Resource({required this.id, required this.name, required this.type});
}

class ScheduleBooking {
  final String id;
  final String title;
  String resourceId;
  int startMinuteFrom8AM;
  int durationMinutes;
  final Color color;

  ScheduleBooking({
    required this.id,
    required this.title,
    required this.resourceId,
    required this.startMinuteFrom8AM,
    required this.durationMinutes,
    required this.color,
  });
}

// 2. LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentThemeMode;

  const LoginScreen({super.key, required this.onThemeChanged, required this.currentThemeMode});

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SetupWizardScreen(
            session: session!,
            onThemeChanged: widget.onThemeChanged,
            currentThemeMode: widget.currentThemeMode,
          ),
        ),
      );
    } else {
      setState(() {
        errorMessage = 'Λάθος Username ή Password (χρησιμοποιήστε admin/admin ή user/user)';
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
                child: const Text('Σύνδεση', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. SETUP WIZARD SCREEN
class SetupWizardScreen extends StatefulWidget {
  final UserSession session;
  final Function(bool) onThemeChanged;
  final ThemeMode currentThemeMode;

  const SetupWizardScreen({
    super.key,
    required this.session,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  String selectedDomain = 'Aviation';
  int timeSlotMinutes = 30;
  bool preventOverlaps = true;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.currentThemeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Διαμόρφωση Συστήματος'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.onThemeChanged(!isDarkMode);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    onThemeChanged: widget.onThemeChanged,
                    currentThemeMode: widget.currentThemeMode,
                  ),
                ),
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
                label: Text('Σύνδεση ως: ${widget.session.username} (${widget.session.isAdmin ? "Admin" : "Read Only"})'),
              ),
              const SizedBox(height: 20),
              const Text('Επιλογή Domain', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedDomain,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Aviation', child: Text('Αεροδρόμιο / Σχολή Πτήσεων')),
                  DropdownMenuItem(value: 'Parking', child: Text('Σταθμός Parking')),
                  DropdownMenuItem(value: 'Training', child: Text('Κέντρο Εκπαίδευσης')),
                ],
                onChanged: (val) => setState(() => selectedDomain = val!),
              ),
              const SizedBox(height: 20),
              const Text('Βήμα Χρόνου Grid', style: TextStyle(fontWeight: FontWeight.bold)),
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
                title: const Text('Αυστηρή απαγόρευση επικαλύψεων'),
                value: preventOverlaps,
                onChanged: (val) => setState(() => preventOverlaps = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Night / Dark Mode'),
                value: isDarkMode,
                onChanged: (val) {
                  widget.onThemeChanged(val);
                  setState(() {});
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
                label: const Text('Άνοιγμα Schedule Grid'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SchedulerGridScreen(
                        session: widget.session,
                        domain: selectedDomain,
                        slotMinutes: timeSlotMinutes,
                        preventOverlaps: preventOverlaps,
                        onThemeChanged: widget.onThemeChanged,
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

// 4. GRID SCREEN (WITH CURRENT TIME LINE & INSTANT DARK MODE TOGGLE)
class SchedulerGridScreen extends StatefulWidget {
  final UserSession session;
  final String domain;
  final int slotMinutes;
  final bool preventOverlaps;
  final Function(bool) onThemeChanged;

  const SchedulerGridScreen({
    super.key,
    required this.session,
    required this.domain,
    required this.slotMinutes,
    required this.preventOverlaps,
    required this.onThemeChanged,
  });

  @override
  State<SchedulerGridScreen> createState() => _SchedulerGridScreenState();
}

class _SchedulerGridScreenState extends State<SchedulerGridScreen> {
  late List<Resource> resources;
  late List<ScheduleBooking> bookings;
  late List<int> timeSlots;
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _generateSlots();
    _loadDomainData();
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
    for (int min = 0; min < 600; min += widget.slotMinutes) {
      timeSlots.add(min);
    }
  }

  void _loadDomainData() {
    if (widget.domain == 'Aviation') {
      resources = [
        Resource(id: 'r1', name: 'Cessna 172 (SX-ABC)', type: 'Aircraft'),
        Resource(id: 'r2', name: 'Piper PA-28 (SX-DEF)', type: 'Aircraft'),
      ];
      bookings = [
        ScheduleBooking(id: 'b1', title: 'Flight Training', resourceId: 'r1', startMinuteFrom8AM: 60, durationMinutes: 120, color: Colors.blue.shade600),
      ];
    } else {
      resources = [Resource(id: 'r1', name: 'Spot A-101', type: 'Bay')];
      bookings = [ScheduleBooking(id: 'b1', title: 'Tesla Model 3', resourceId: 'r1', startMinuteFrom8AM: 0, durationMinutes: 180, color: Colors.green.shade600)];
    }
  }

  String _formatMinutesToTime(int minutesFrom8) {
    int totalMinutes = 8 * 60 + minutesFrom8;
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  bool _hasConflict(ScheduleBooking booking, String targetResourceId, int targetStartMin, int durationMin) {
    if (!widget.preventOverlaps) return false;
    int targetEndMin = targetStartMin + durationMin;

    for (var b in bookings) {
      if (b.id == booking.id) continue;
      if (b.resourceId != targetResourceId) continue;
      int bStart = b.startMinuteFrom8AM;
      int bEnd = b.startMinuteFrom8AM + b.durationMinutes;

      if (targetStartMin < bEnd && targetEndMin > bStart) return true;
    }
    return false;
  }

  void _showResizeDialog(ScheduleBooking booking) {
    if (!widget.session.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔒 Read-Only: Δεν έχετε δικαιώματα αλλαγών.')),
      );
      return;
    }

    int tempDuration = booking.durationMinutes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int endMin = booking.startMinuteFrom8AM + tempDuration;
            bool conflict = _hasConflict(booking, booking.resourceId, booking.startMinuteFrom8AM, tempDuration);

            return AlertDialog(
              title: Text('Αλλαγή Διάρκειας: ${booking.title}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Έναρξη: ${_formatMinutesToTime(booking.startMinuteFrom8AM)}'),
                  Text('Λήξη: ${_formatMinutesToTime(endMin)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: tempDuration > widget.slotMinutes
                            ? () {
                                setModalState(() {
                                  tempDuration -= widget.slotMinutes;
                                });
                              }
                            : null,
                      ),
                      Text('$tempDuration λεπτά', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setModalState(() {
                            tempDuration += widget.slotMinutes;
                          });
                        },
                      ),
                    ],
                  ),
                  if (conflict) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Η νέα διάρκεια δημιουργεί επικάλυψη με άλλη κράτηση!',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ακύρωση'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: conflict ? Colors.grey : Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: conflict
                      ? null
                      : () {
                          setState(() {
                            booking.durationMinutes = tempDuration;
                          });
                          Navigator.pop(context);
                        },
                  child: const Text('Αποθήκευση'),
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
      timeIndicatorOffset = 150.0 + (currentMinutesFrom8 * pixelsPerMinute);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Grid (${widget.domain}) - ${widget.session.isAdmin ? "Edit Mode" : "Read Only"}'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.onThemeChanged(!isDarkMode);
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TIMELINE HEADER
                  Row(
                    children: [
                      Container(
                        width: 150,
                        height: 45,
                        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
                        child: const Center(child: Text('Resources', style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      ...timeSlots.map(
                        (min) => Container(
                          width: slotWidth,
                          height: 45,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                            border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                          ),
                          child: Center(child: Text(_formatMinutesToTime(min), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ],
                  ),
                  // ROWS
                  ...resources.map((res) {
                    return Row(
                      children: [
                        Container(
                          width: 150,
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                            border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                          ),
                          child: Align(alignment: Alignment.centerLeft, child: Text(res.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        ),
                        ...timeSlots.map((slotMin) {
                          final booking = bookings.firstWhere(
                            (b) => b.resourceId == res.id && b.startMinuteFrom8AM == slotMin,
                            orElse: () => ScheduleBooking(id: '', title: '', resourceId: '', startMinuteFrom8AM: -1, durationMinutes: 0, color: Colors.transparent),
                          );

                          return DragTarget<ScheduleBooking>(
                            onWillAcceptWithDetails: (details) => widget.session.isAdmin,
                            onAcceptWithDetails: (details) {
                              if (!widget.session.isAdmin) return;

                              if (_hasConflict(details.data, res.id, slotMin, details.data.durationMinutes)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('⚠️ Επικάλυψη! Η μετακίνηση ακυρώθηκε.'), backgroundColor: Colors.redAccent),
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
                                width: slotWidth,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: candidateData.isNotEmpty
                                      ? (isDarkMode ? Colors.indigo.shade900 : Colors.indigo.shade50)
                                      : (isDarkMode ? const Color(0xFF121212) : Colors.white),
                                  border: Border.all(color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200),
                                ),
                                child: booking.id.isNotEmpty
                                    ? (widget.session.isAdmin
                                        ? Draggable<ScheduleBooking>(
                                            data: booking,
                                            feedback: Material(
                                              elevation: 6,
                                              child: Container(
                                                width: (booking.durationMinutes / widget.slotMinutes) * slotWidth,
                                                height: 45,
                                                padding: const EdgeInsets.all(6),
                                                color: booking.color.withOpacity(0.85),
                                                child: Text(booking.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                              ),
                                            ),
                                            childWhenDragging: Container(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
                                            child: InkWell(
                                              onDoubleTap: () => _showResizeDialog(booking),
                                              child: _buildBookingTile(booking),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('🔒 Read-Only: Δεν έχετε δικαιώματα αλλαγών.')),
                                              );
                                            },
                                            child: _buildBookingTile(booking),
                                          ))
                                    : null,
                              );
                            },
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),

              // CURRENT TIME INDICATOR
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
    );
  }

  Widget _buildBookingTile(ScheduleBooking booking) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: booking.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.title,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${booking.durationMinutes}m',
            style: const TextStyle(color: Colors.white70, fontSize: 9),
          ),
        ],
      ),
    );
  }
}