import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/quick_dial_button.dart';
import '../utils/phone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Police',
      number: '100',
      icon: Icons.local_police,
      color: Colors.blue,
      description: 'Report crimes, accidents, and emergencies',
    ),
    EmergencyContact(
      name: 'Ambulance',
      number: '108',
      icon: Icons.medical_services,
      color: Colors.red,
      description: 'Medical emergencies and ambulance services',
    ),
    EmergencyContact(
      name: 'Fire Department',
      number: '101',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      description: 'Fire emergencies and rescue services',
    ),
    EmergencyContact(
      name: 'Women Helpline',
      number: '1091',
      icon: Icons.female,
      color: Colors.purple,
      description: '24/7 helpline for women in distress',
    ),
    EmergencyContact(
      name: 'Child Helpline',
      number: '1098',
      icon: Icons.child_care,
      color: Colors.green,
      description: 'Emergency helpline for children',
    ),
    EmergencyContact(
      name: 'Disaster Management',
      number: '108',
      icon: Icons.warning,
      color: Colors.red[800]!,
      description: 'Natural disasters and emergency response',
    ),
  ];

  final List<QuickDialContact> _quickDialContacts = [
    QuickDialContact(
      name: 'Family',
      number: '+91 98765 43210',
      icon: Icons.family_restroom,
      color: Colors.teal,
    ),
    QuickDialContact(
      name: 'Doctor',
      number: '+91 98765 43211',
      icon: Icons.person,
      color: Colors.green,
    ),
    QuickDialContact(
      name: 'Friend',
      number: '+91 98765 43212',
      icon: Icons.person_outline,
      color: Colors.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCustomContact,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Dial Section
            Text(
              'Quick Dial',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your personal emergency contacts',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            AnimationLimiter(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _quickDialContacts.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: QuickDialButton(
                          contact: _quickDialContacts[index],
                          onTap: () => _makeCall(_quickDialContacts[index].number),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Emergency Services Section
            Text(
              'Emergency Services',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Official emergency service numbers',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            AnimationLimiter(
              child: Column(
                children: _emergencyContacts.asMap().entries.map((entry) {
                  int index = entry.key;
                  EmergencyContact contact = entry.value;
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: EmergencyContactCard(
                          contact: contact,
                          onCall: () => _makeCall(contact.number),
                          onInfo: () => _showContactInfo(contact),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Safety Tips Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Safety Tips',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Stay calm and speak clearly when calling emergency services\n'
                      '• Provide your exact location and describe the situation\n'
                      '• Follow the operator\'s instructions\n'
                      '• Keep emergency numbers saved in your phone\n'
                      '• Know your location and nearby landmarks',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makeCall(String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call $number?'),
        content: const Text('This will dial the number immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final ok = await PhoneUtils.callNumber(number);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Unable to place call to $number'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showContactInfo(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(contact.icon, color: contact.color),
            const SizedBox(width: 8),
            Text(contact.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number: ${contact.number}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(contact.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final ok = await PhoneUtils.callNumber(contact.number);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Unable to place call to ${contact.number}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _addCustomContact() {
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: numberCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final number = numberCtrl.text.trim();
              if (name.isEmpty || number.isEmpty) return;
              setState(() {
                _quickDialContacts.add(QuickDialContact(
                  name: name,
                  number: number,
                  icon: Icons.person,
                  color: Colors.teal,
                ));
              });
              await _saveCustomContacts();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Future<void> _saveCustomContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final builtIns = 3; // first 3 are default entries in this demo
    final custom = _quickDialContacts.skip(builtIns).map((c) => {
      'name': c.name,
      'number': c.number,
      'icon': c.icon.codePoint,
      'color': c.color.value,
    }).toList();
    await prefs.setString('custom_quick_dial_v1', custom.toString());
  }

  Future<void> _loadCustomContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('custom_quick_dial_v1');
    if (s == null || s.isEmpty) return;
    try {
      final list = (await Future.value(s)).toString();
      // quick parse for the simple toString serialization above
      final matches = RegExp(r"\{([^}]+)\}").allMatches(list);
      for (final m in matches) {
        final kv = m.group(1)!;
        String getVal(String key) {
          final r = RegExp(key + r": ([^,]+)").firstMatch(kv);
          return r != null ? r.group(1)!.trim() : '';
        }
        final name = getVal('name').replaceAll("'", '');
        final number = getVal('number').replaceAll("'", '');
        final icon = int.tryParse(getVal('icon')) ?? Icons.person.codePoint;
        final color = int.tryParse(getVal('color')) ?? Colors.teal.value;
        _quickDialContacts.add(QuickDialContact(
          name: name,
          number: number,
          icon: IconData(icon, fontFamily: 'MaterialIcons'),
          color: Color(color),
        ));
      }
      if (mounted) setState(() {});
    } catch (_) {
      // ignore
    }
  }
}

class EmergencyContact {
  final String name;
  final String number;
  final IconData icon;
  final Color color;
  final String description;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class QuickDialContact {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  QuickDialContact({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });
}
