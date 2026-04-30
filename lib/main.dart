import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Work Hour Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4ECDC4),
          secondary: Color(0xFF23D18B),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Models ───────────────────────────────────────
class Company {
  int id;
  String name;
  Color color;
  double rate;
  Company({required this.id, required this.name, 
           required this.color, required this.rate});
}

class WorkEntry {
  int id;
  int companyId;
  String date;
  TimeOfDay clockIn;
  TimeOfDay clockOut;
  int breakMin;
  WorkEntry({required this.id, required this.companyId,
             required this.date, required this.clockIn,
             required this.clockOut, required this.breakMin});
}

// ─── Home Screen ──────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Company> companies = [
    Company(id: 1, name: 'Google', 
            color: const Color(0xFF4ECDC4), rate: 15),
    Company(id: 2, name: 'Amazon', 
            color: const Color(0xFFFF6B6B), rate: 18),
  ];

  final List<WorkEntry> entries = [
    WorkEntry(id: 1, companyId: 1, date: '2026-04-28',
              clockIn: const TimeOfDay(hour: 9, minute: 0),
              clockOut: const TimeOfDay(hour: 17, minute: 30),
              breakMin: 30),
    WorkEntry(id: 2, companyId: 2, date: '2026-04-29',
              clockIn: const TimeOfDay(hour: 10, minute: 0),
              clockOut: const TimeOfDay(hour: 15, minute: 0),
              breakMin: 15),
  ];

  double calcHours(WorkEntry e) {
    int startMin = e.clockIn.hour * 60 + e.clockIn.minute;
    int endMin = e.clockOut.hour * 60 + e.clockOut.minute;
    int mins = endMin - startMin - e.breakMin;
    return mins > 0 ? mins / 60.0 : 0;
  }

  double companyHours(int cid) => entries
      .where((e) => e.companyId == cid)
      .fold(0, (s, e) => s + calcHours(e));

  double companyPay(int cid) {
    final co = companies.firstWhere((c) => c.id == cid);
    return companyHours(cid) * co.rate;
  }

  double totalHours() => 
      companies.fold(0, (s, c) => s + companyHours(c.id));
  double totalPay() => 
      companies.fold(0, (s, c) => s + companyPay(c.id));

  void addCompany(String name, double rate, Color color) {
    setState(() {
      companies.add(Company(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name, color: color, rate: rate,
      ));
    });
  }

  void addEntry(WorkEntry entry) {
    setState(() => entries.add(entry));
  }

  void deleteEntry(int id) {
    setState(() => entries.removeWhere((e) => e.id == id));
  }

  void deleteCompany(int id) {
    setState(() {
      companies.removeWhere((c) => c.id == id);
      entries.removeWhere((e) => e.companyId == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(
        companies: companies, entries: entries,
        companyHours: companyHours, companyPay: companyPay,
        totalHours: totalHours(), totalPay: totalPay(),
        onAddCompany: () => _showAddCompany(context),
        onCompanyTap: (c) => Navigator.push(context,
          MaterialPageRoute(builder: (_) => CompanyDetailScreen(
            company: c,
            entries: entries.where((e) => 
                e.companyId == c.id).toList(),
            calcHours: calcHours,
            onDeleteEntry: deleteEntry,
            onDeleteCompany: deleteCompany,
            onAddEntry: () => _showAddEntry(context),
          ))),
      ),
      _SummaryTab(
        companies: companies,
        companyHours: companyHours,
        companyPay: companyPay,
        totalHours: totalHours(),
        totalPay: totalPay(),
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntry(context),
        backgroundColor: const Color(0xFF4ECDC4),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: 
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1A1A2E),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home, label: 'Home',
              active: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0)),
            const SizedBox(width: 40),
            _NavItem(icon: Icons.bar_chart, label: 'Pay',
              active: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1)),
          ],
        ),
      ),
    );
  }

  void _showAddCompany(BuildContext context) {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    Color selectedColor = const Color(0xFF4ECDC4);
    final colors = [
      const Color(0xFF4ECDC4), const Color(0xFFFF6B6B),
      const Color(0xFF45B7D1), const Color(0xFF96CEB4),
      const Color(0xFFFFEAA7), const Color(0xFFDDA0DD),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Company',
                style: TextStyle(fontSize: 20, 
                    fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              _TextField(controller: nameCtrl, 
                  label: 'Company Name'),
              const SizedBox(height: 12),
              _TextField(controller: rateCtrl, 
                  label: 'Hourly Rate (\$)',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              const Text('Color', 
                style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Row(children: colors.map((c) => GestureDetector(
                onTap: () => setS(() => selectedColor = c),
                child: Container(
                  width: 36, height: 36, margin: 
                      const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: c, shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor == c 
                          ? Colors.white : Colors.transparent,
                      width: 3)),
                ),
              )).toList()),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      addCompany(nameCtrl.text,
                        double.tryParse(rateCtrl.text) ?? 0,
                        selectedColor);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Company',
                    style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.w800)),
                )),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEntry(BuildContext context) {
    Company? selectedCo;
    DateTime selectedDate = DateTime.now();
    TimeOfDay clockIn = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay clockOut = const TimeOfDay(hour: 17, minute: 0);
    int breakMin = 30;
    final breakCtrl = TextEditingController(text: '30');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Work Entry',
                style: TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              const Text('Company', 
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<Company>(
                  value: selectedCo,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1A1A2E),
                  underline: const SizedBox(),
                  hint: const Text('Select company',
                      style: TextStyle(color: Colors.grey)),
                  items: companies.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
                  )).toList(),
                  onChanged: (c) => setS(() => selectedCo = c),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _TimeButton(
                  label: 'Clock In',
                  time: clockIn,
                  onTap: () async {
                    final t = await showTimePicker(
                        context: ctx, initialTime: clockIn);
                    if (t != null) setS(() => clockIn = t);
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: _TimeButton(
                  label: 'Clock Out',
                  time: clockOut,
                  onTap: () async {
                    final t = await showTimePicker(
                        context: ctx, initialTime: clockOut);
                    if (t != null) setS(() => clockOut = t);
                  },
                )),
              ]),
              const SizedBox(height: 12),
              _TextField(controller: breakCtrl,
                label: 'Break (minutes)',
                keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                  onPressed: () {
                    if (selectedCo != null) {
                      addEntry(WorkEntry(
                        id: DateTime.now().millisecondsSinceEpoch,
                        companyId: selectedCo!.id,
                        date: selectedDate.toString().split(' ')[0],
                        clockIn: clockIn,
                        clockOut: clockOut,
                        breakMin: int.tryParse(breakCtrl.text) ?? 0,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Entry',
                    style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.w800)),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final List<Company> companies;
  final List<WorkEntry> entries;
  final double Function(int) companyHours;
  final double Function(int) companyPay;
  final double totalHours;
  final double totalPay;
  final VoidCallback onAddCompany;
  final Function(Company) onCompanyTap;

  const _HomeTab({
    required this.companies, required this.entries,
    required this.companyHours, required this.companyPay,
    required this.totalHours, required this.totalPay,
    required this.onAddCompany, required this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WORK HOURS', style: TextStyle(
            fontSize: 11, letterSpacing: 3,
            color: Color(0xFF4ECDC4), fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('My Companies', style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          // Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL HOURS', style: TextStyle(
                    fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${totalHours.toStringAsFixed(1)} hrs',
                    style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4ECDC4))),
                ],
              )),
              Container(width: 1, height: 40, 
                  color: Colors.white12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL PAY', style: TextStyle(
                      fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('\$${totalPay.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF23D18B))),
                  ],
                ),
              )),
            ]),
          ),
          const SizedBox(height: 24),
          // Company List
          ...companies.map((c) => GestureDetector(
            onTap: () => onCompanyTap(c),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: c.color.withOpacity(0.2))),
              child: Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: c.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: c.color.withOpacity(0.3))),
                  child: const Icon(Icons.business, 
                      color: Colors.white70)),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('\$${c.rate}/hr • '
                      '${entries.where((e) => e.companyId == c.id).length}'
                      ' entries',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${companyHours(c.id).toStringAsFixed(1)} hrs',
                      style: TextStyle(fontWeight: FontWeight.w700,
                          fontSize: 15, color: c.color)),
                    Text('\$${companyPay(c.id).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12,
                          color: Color(0xFF23D18B))),
                  ]),
              ]),
            ),
          )),
          // Add Company
          GestureDetector(
            onTap: onAddCompany,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(18)),
              child: const Row(children: [
                Icon(Icons.add_circle_outline, color: Colors.grey),
                SizedBox(width: 12),
                Text('Add Company', style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    ));
  }
}

// ─── Summary Tab ──────────────────────────────────
class _SummaryTab extends StatelessWidget {
  final List<Company> companies;
  final double Function(int) companyHours;
  final double Function(int) companyPay;
  final double totalHours;
  final double totalPay;

  const _SummaryTab({
    required this.companies, required this.companyHours,
    required this.companyPay, required this.totalHours,
    required this.totalPay,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OVERVIEW', style: TextStyle(
            fontSize: 11, letterSpacing: 3,
            color: Color(0xFF23D18B), fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Pay Summary', style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          ...companies.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(width: 12, height: 12,
                decoration: BoxDecoration(
                    color: c.color, shape: BoxShape.circle)),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: const TextStyle(
                      fontWeight: FontWeight.w700)),
                  Text('${companyHours(c.id).toStringAsFixed(1)}'
                    ' hrs × \$${c.rate}/hr',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                ],
              )),
              Text('\$${companyPay(c.id).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF23D18B))),
            ]),
          )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF23D18B).withOpacity(0.15),
                const Color(0xFF4ECDC4).withOpacity(0.15),
              ]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF23D18B).withOpacity(0.3))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Hours',
                      style: TextStyle(color: Colors.grey)),
                  Text('${totalHours.toStringAsFixed(1)} hrs',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4ECDC4))),
                ]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Earnings',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('\$${totalPay.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF23D18B))),
                ]),
            ]),
          ),
          if (totalHours > 40) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFFF6B6B).withOpacity(0.3))),
              child: Row(children: [
                const Text('⚠️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Overtime Alert!',
                      style: TextStyle(fontWeight: FontWeight.w700,
                          color: Color(0xFFFF6B6B))),
                    Text('${(totalHours - 40).toStringAsFixed(1)}'
                      ' hrs overtime this week',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  ],
                )),
              ]),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    ));
  }
}

// ─── Company Detail Screen ────────────────────────
class CompanyDetailScreen extends StatelessWidget {
  final Company company;
  final List<WorkEntry> entries;
  final double Function(WorkEntry) calcHours;
  final Function(int) onDeleteEntry;
  final Function(int) onDeleteCompany;
  final VoidCallback onAddEntry;

  const CompanyDetailScreen({
    super.key, required this.company, required this.entries,
    required this.calcHours, required this.onDeleteEntry,
    required this.onDeleteCompany, required this.onAddEntry,
  });

  @override
  Widget build(BuildContext context) {
    double totalH = entries.fold(0, (s, e) => s + calcHours(e));
    double totalP = totalH * company.rate;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(company.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, 
                color: Color(0xFFFF6B6B)),
            onPressed: () {
              onDeleteCompany(company.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Stats Row
          Row(children: [
            _StatCard(label: 'Hours',
              value: '${totalH.toStringAsFixed(1)} hrs',
              color: company.color),
            const SizedBox(width: 12),
            _StatCard(label: 'Earned',
              value: '\$${totalP.toStringAsFixed(2)}',
              color: const Color(0xFF23D18B)),
            const SizedBox(width: 12),
            _StatCard(label: 'Rate',
              value: '\$${company.rate}/hr',
              color: const Color(0xFFFFEAA7)),
          ]),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft,
            child: Text('WORK ENTRIES', style: TextStyle(
              fontSize: 11, letterSpacing: 2, color: Colors.grey,
              fontWeight: FontWeight.w700))),
          const SizedBox(height: 12),
          ...entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: company.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Text(e.date.split('-')[2],
                    style: TextStyle(fontWeight: FontWeight.w700,
                        color: company.color, fontSize: 16)),
                  Text(e.date.split('-')[1],
                    style: const TextStyle(
                        fontSize: 10, color: Colors.grey)),
                ]),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${e.clockIn.format(context)} – '
                    '${e.clockOut.format(context)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Break: ${e.breakMin} min',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                ],
              )),
              Column(crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${calcHours(e).toStringAsFixed(1)} hrs',
                    style: TextStyle(fontWeight: FontWeight.w700,
                        color: company.color)),
                  Text('\$${(calcHours(e) * company.rate).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12,
                        color: Color(0xFF23D18B))),
                ]),
              IconButton(
                icon: const Icon(Icons.close, 
                    size: 18, color: Colors.grey),
                onPressed: () => onDeleteEntry(e.id),
              ),
            ]),
          )),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text('No entries yet',
                  style: TextStyle(color: Colors.grey))),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddEntry,
        backgroundColor: company.color,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, 
      required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
              fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    ));
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  const _TextField({required this.controller, 
      required this.label, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true, fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeButton({required this.label, 
      required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(label, style: const TextStyle(
              fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(time.format(context),
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label,
      required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: active 
            ? const Color(0xFF4ECDC4) : Colors.grey),
        Text(label, style: TextStyle(fontSize: 10,
          color: active 
              ? const Color(0xFF4ECDC4) : Colors.grey)),
      ]),
    );
  }
}
