# Smart Resource Scheduler - Architecture & Algorithm Spec

## 1. Βασικές Λειτουργίες (Core Features)

* **RBAC Engine (Role-Based Access Control):**
  * **Admin:** Πλήρη δικαιώματα CRUD σε κατηγορίες/πόρους, Drag & Drop μετακίνηση κρατήσεων και Resizing διάρκειας.
  * **Viewer:** Read-Only προβολή του Grid χωρίς δυνατότητα τροποποίησης δεδομένων.

* **Category & Resource Management:**
  * Ιεραρχική οργάνωση 2 επιπέδων: `Category` -> `Resource`.
  * Δυναμική προσθήκη, επεξεργασία και διαγραφή κατηγοριών/πόρων με UI dialogs.

* **Setup Wizard Configuration:**
  * Προσαρμογή Domain (*Aviation, Parking, Training*).
  * Ρύθμιση βήματος χρόνου Grid (*15m, 30m, 60m*).
  * Ενεργοποίηση/Απενεργοποίηση κανόνων επικάλυψης (Prevent Overlaps).

* **Global Dynamic Theme Engine:**
  * Ακαριαία εναλλαγή Light/Dark (Night) mode με χρήση `ValueNotifier<ThemeMode>`.

---

## 2. Υπολειτουργίες & Αλγόριθμοι (Sub-systems & Algorithms)

### Α. Conflict Validation Engine (Αλγόριθμος Ελέγχου Επικαλύψεων)
Ο αλγόριθμος ελέγχει αν μια νέα/μετακινούμενη κράτηση $T$ τέμνει κάποια υπάρχουσα κράτηση $B$ στον ίδιο πόρο.

* **Μαθηματικός Τύπος Тоμής Διαστημάτων:**
  Δύο διαστήματα $[T_{start}, T_{end}]$ και $[B_{start}, B_{end}]$ επικαλύπτονται αν και μόνο αν:
  $$T_{start} < B_{end} \quad \text{AND} \quad T_{end} > B_{start}$$

* **Υλοποίηση στο Flutter:**
  ```dart
  bool _hasConflict(ScheduleBooking booking, String targetResourceId, int targetStartMin, int durationMin) {
    if (!preventOverlaps) return false;
    int targetEndMin = targetStartMin + durationMin;

    for (var b in bookings) {
      if (b.id == booking.id || b.resourceId != targetResourceId) continue;
      if (targetStartMin < (b.startMinuteFrom8AM + b.durationMinutes) && 
          targetEndMin > b.startMinuteFrom8AM) {
        return true; // Εντοπίστηκε επικάλυψη!
      }
    }
    return false;
  }
  Β. Real-Time Current Time Indicator Line
Υπολογίζει τη σχετική θέση της τρέχουσας ώρας του συστήματος πάνω στο Grid και σχεδιάζει μια κόκκινη γραμμή.
Υπολογισμός Θέσης (Offset):
CurrentMinutes=(Now.hour×60+Now.minute)−(8×60)
PixelsPerMinute= 
SlotMinutes
SlotWidth
​	
 
Offset=HeaderWidth+(CurrentMinutes×PixelsPerMinute)
Auto Update: Timer.periodic κάθε 60 δευτερόλεπτα για αυτόματη μετακίνηση της γραμμής.
Γ. Resizing Engine
Αλληλεπίδραση μέσω onDoubleTap πάνω στο block της κράτησης.
Modal Dialog με αυξομείωση διάρκειας σε βήματα ίσα με το slotMinutes.
Real-time validation πριν την αποθήκευση: αν η νέα διάρκεια προκαλεί conflict, το κουμπί Αποθήκευση απενεργοποιείται αυτόματα.