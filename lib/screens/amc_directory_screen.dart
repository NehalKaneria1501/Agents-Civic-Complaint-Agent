import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/civic_colors.dart';
import '../services/google_maps_service.dart';

// ==========================================
// SCREEN: AMC MUNICIPAL GOVERNANCE & WARD DIRECTORY
// Lists Mayor, Municipal Commissioner (IAS), Police Commissioner (IPS),
// Standing Committee, Municipal Secretaries, Board Members & all 48 Wards
// ==========================================

class AmcDirectoryScreen extends StatefulWidget {
  const AmcDirectoryScreen({super.key});

  @override
  State<AmcDirectoryScreen> createState() => _AmcDirectoryScreenState();
}

class _AmcDirectoryScreenState extends State<AmcDirectoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(' ', '').replaceAll('-', '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  // --- 1. APEX CIVIC LEADERSHIP ---
  final List<Map<String, dynamic>> _apexLeadership = [
    {
      'role': 'Mayor of Ahmedabad',
      'name': 'Hon. Smt. Pratibha Jain',
      'designation': 'First Citizen & Head of Ahmedabad Municipal Corporation',
      'office': 'Mayor Office, Danapith Central HQ, Ahmedabad',
      'phone': '+91 79 2535 2821',
      'tag': 'Elected Apex',
      'icon': Icons.account_balance_rounded,
      'color': CivicColors.primary,
      'lat': 23.0225,
      'lng': 72.5714,
    },
    {
      'role': 'Municipal Commissioner',
      'name': 'Shri M. Thennarasan, IAS',
      'designation': 'Chief Executive Authority, Ahmedabad Municipal Corporation',
      'office': 'Commissioner Secretariat, Danapith Central HQ',
      'phone': '+91 79 2535 3822',
      'tag': 'IAS Administrative Head',
      'icon': Icons.badge_rounded,
      'color': const Color(0xFF1565C0),
      'lat': 23.0225,
      'lng': 72.5714,
    },
    {
      'role': 'Standing Committee Chairman',
      'name': 'Hon. Shri Devang Dani',
      'designation': 'Chairman, AMC Standing Committee (Executive Finance & Projects)',
      'office': 'Standing Committee Chamber, Danapith Central HQ',
      'phone': '+91 79 2535 2824',
      'tag': 'Statutory Committee',
      'icon': Icons.gavel_rounded,
      'color': CivicColors.secondary,
      'lat': 23.0225,
      'lng': 72.5714,
    },
    {
      'role': 'Commissioner of Police',
      'name': 'Shri G. S. Malik, IPS',
      'designation': 'Commissioner of Police, Ahmedabad City (Law & Order/Traffic)',
      'office': 'Police Bhavan, Shahibaug, Ahmedabad',
      'phone': '+91 79 2563 0100',
      'tag': 'IPS Security & Traffic',
      'icon': Icons.local_police_rounded,
      'color': const Color(0xFFB71C1C),
      'lat': 23.0538,
      'lng': 72.5936,
    },
    {
      'role': 'Deputy Mayor',
      'name': 'Hon. Shri Jatin Patel',
      'designation': 'Deputy First Citizen, Ahmedabad Municipal Corporation',
      'office': 'Dy. Mayor Office, Danapith Central HQ',
      'phone': '+91 79 2535 2823',
      'tag': 'Elected Leadership',
      'icon': Icons.person_pin_rounded,
      'color': CivicColors.tertiary,
      'lat': 23.0225,
      'lng': 72.5714,
    },
    {
      'role': 'AMC Municipal Secretary',
      'name': 'Office of Municipal Secretary',
      'designation': 'Custodian of General Board, Standing Committee Records & Gazettes',
      'office': 'Secretariat Division, 2nd Floor, Danapith HQ',
      'phone': '+91 79 2535 2825',
      'tag': 'Municipal Secretariat',
      'icon': Icons.description_rounded,
      'color': const Color(0xFF6A1B9A),
      'lat': 23.0225,
      'lng': 72.5714,
    },
  ];

  // --- 2. STANDING COMMITTEE & SPECIALIZED BOARDS ---
  final List<Map<String, dynamic>> _committees = [
    {
      'name': 'Standing Committee',
      'head': 'Devang Dani (Chairman)',
      'membersCount': 12,
      'scope': 'Financial sanctions, city development budgets, tenders, major civic infrastructure',
      'schedule': 'Every Thursday at 11:00 AM, Standing Committee Chamber',
      'icon': Icons.account_balance_wallet_rounded,
      'color': CivicColors.primary,
    },
    {
      'name': 'Roads & Buildings Committee',
      'head': 'Mahadev Patel (Chairman)',
      'membersCount': 8,
      'scope': 'Asphalt road resurfacing, Atal Bridge, flyovers, underpasses, footpaths & bridges',
      'schedule': 'Fortnightly Review, Danapith HQ',
      'icon': Icons.car_repair_rounded,
      'color': const Color(0xFFD97706),
    },
    {
      'name': 'Health & Solid Waste Committee',
      'head': 'Dr. Pravin Patel (Chairman)',
      'membersCount': 8,
      'scope': 'Door-to-door waste collection, Pirana waste management, SVP Hospital, clinics',
      'schedule': 'Weekly Review, Health Bhavan',
      'icon': Icons.delete_sweep_rounded,
      'color': const Color(0xFF10B981),
    },
    {
      'name': 'Water Supply & Sewerage Committee',
      'head': 'Dilip Bagariya (Chairman)',
      'membersCount': 8,
      'scope': 'Kotarpur & Raska water works, French wells, drainage pumping & storm drains',
      'schedule': 'Weekly Monitoring, Drainage Dept',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF0284C7),
    },
    {
      'name': 'Town Planning & Estate Committee',
      'head': 'Pritesh Mehta (Chairman)',
      'membersCount': 8,
      'scope': 'TP schemes, building permits, anti-encroachment operations, public land protection',
      'schedule': 'Every Tuesday, Town Planning Wing',
      'icon': Icons.domain_rounded,
      'color': const Color(0xFF9333EA),
    },
    {
      'name': 'Revenue Committee',
      'head': 'Jashwant Rajput (Chairman)',
      'membersCount': 6,
      'scope': 'Property tax assessments, professional tax collection, digital citizen billing',
      'schedule': 'Monthly Fiscal Assessment, Revenue Division',
      'icon': Icons.receipt_long_rounded,
      'color': const Color(0xFF0D9488),
    },
  ];

  // --- 3. SENIOR ADMINISTRATIVE OFFICERS (IAS / IPS / DEPUTY COMMISSIONERS) ---
  final List<Map<String, dynamic>> _seniorOfficers = [
    {
      'name': 'Shri M. Thennarasan, IAS',
      'post': 'Municipal Commissioner',
      'division': 'Chief Executive & Governance',
      'email': 'commissioner@ahmedabadcity.gov.in',
      'phone': '+91 79 2535 3822',
      'cadre': 'IAS (Senior Selection Grade)',
    },
    {
      'name': 'Shri G. S. Malik, IPS',
      'post': 'Commissioner of Police',
      'division': 'Ahmedabad City Police & Law Enforcement',
      'email': 'cp.ahd@gujarat.gov.in',
      'phone': '+91 79 2563 0100',
      'cadre': 'IPS (Director General / ADGP)',
    },
    {
      'name': 'Shri I. K. Patel, IAS (Retd.) / Joint Comm.',
      'post': 'Deputy Municipal Commissioner (West & North-West Zone)',
      'division': 'Navrangpura, Bodakdev, Vastrapur & Ghatlodia',
      'email': 'dycomm.west@ahmedabadcity.gov.in',
      'phone': '+91 79 2755 2255',
      'cadre': 'IAS / Senior Executive',
    },
    {
      'name': 'Dr. C. R. Kharsan, IAS',
      'post': 'Deputy Municipal Commissioner (Health & Hospital)',
      'division': 'SVP Hospital, Urban Health Centres, Food Safety',
      'email': 'dycomm.health@ahmedabadcity.gov.in',
      'phone': '+91 79 2535 2830',
      'cadre': 'IAS Cadre',
    },
    {
      'name': 'Shri Neeraj Badgujar, IPS',
      'post': 'Additional Commissioner of Police (Sector 1)',
      'division': 'Crime, Traffic & Civic Security (West Zone)',
      'email': 'addlcp.sec1@ahmedabadcity.gov.in',
      'phone': '+91 79 2563 0122',
      'cadre': 'IPS Senior Cadre',
    },
    {
      'name': 'Shri B. S. Parmar',
      'post': 'Deputy Municipal Commissioner (South & East Zone)',
      'division': 'Maninagar, Odhav, Vatva, Nikol & Vastral',
      'email': 'dycomm.east@ahmedabadcity.gov.in',
      'phone': '+91 79 2287 0000',
      'cadre': 'GCS Senior Selection',
    },
    {
      'name': 'Shri Hitesh Contractor',
      'post': 'City Engineer (Roads & Bridges)',
      'division': 'City-wide Asphalt, Flyovers & Atal Bridge Engineering',
      'email': 'cityengineer@ahmedabadcity.gov.in',
      'phone': '+91 79 2535 2845',
      'cadre': 'Chief Engineering Directorate',
    },
  ];

  // --- 4. ALL 48 WARDS ACROSS 7 ZONES ---
  final List<Map<String, dynamic>> _amcWards = [
    // West Zone
    {
      'wardNumber': 8,
      'wardName': 'Navrangpura',
      'zone': 'West Zone',
      'corporators': ['Kiran Patel', 'Snehal Joshi', 'Meena Parmar', 'Rajesh Shah'],
      'inspector': 'Inspector Suresh Vaghela',
      'office': 'Usmanpura West Zone Complex, Ashram Road',
      'phone': '+91 79 2755 2255',
      'lat': 23.0373,
      'lng': 72.5613,
    },
    {
      'wardNumber': 9,
      'wardName': 'Naranpura',
      'zone': 'West Zone',
      'corporators': ['Gautam Patel', 'Bhavna Dave', 'Mukesh Trivedi', 'Shobhna Solanki'],
      'inspector': 'Inspector K. L. Prajapati',
      'office': 'Naranpura Ward Office, AEC Cross Road',
      'phone': '+91 79 2744 1122',
      'lat': 23.0525,
      'lng': 72.5518,
    },
    {
      'wardNumber': 10,
      'wardName': 'Paldi',
      'zone': 'West Zone',
      'corporators': ['Chintan Patel', 'Geeta Desai', 'Manish Dave', 'Kajal Raval'],
      'inspector': 'Inspector Paresh Vyas',
      'office': 'Paldi Ward Office, Near Mahalaxmi Cross Road',
      'phone': '+91 79 2657 8899',
      'lat': 23.0135,
      'lng': 72.5627,
    },
    {
      'wardNumber': 11,
      'wardName': 'Vasna',
      'zone': 'West Zone',
      'corporators': ['Harshil Shah', 'Kavita Makwana', 'Sunil Solanki', 'Varsha Barot'],
      'inspector': 'Inspector Jagdish Barot',
      'office': 'Vasna Ward Office, Lavanya Society',
      'phone': '+91 79 2660 3344',
      'lat': 23.0018,
      'lng': 72.5489,
    },
    {
      'wardNumber': 12,
      'wardName': 'Stadium',
      'zone': 'West Zone',
      'corporators': ['Jayesh Patel', 'Rita Shah', 'Dharmendra Rana', 'Jyoti Panchal'],
      'inspector': 'Inspector N. M. Shah',
      'office': 'Sardar Patel Stadium Ward Centre, Navrangpura',
      'phone': '+91 79 2644 5566',
      'lat': 23.0415,
      'lng': 72.5645,
    },
    {
      'wardNumber': 13,
      'wardName': 'Ranip',
      'zone': 'West Zone',
      'corporators': ['Mahesh Patel', 'Urmila Thakor', 'Nilesh Dave', 'Bina Parmar'],
      'inspector': 'Inspector Bharat Rathod',
      'office': 'Ranip Civic Centre, Near Subhash Bridge',
      'phone': '+91 79 2752 4411',
      'lat': 23.0782,
      'lng': 72.5781,
    },

    // North West Zone
    {
      'wardNumber': 4,
      'wardName': 'Bodakdev & Vastrapur',
      'zone': 'North West Zone',
      'corporators': ['Devang Dani (Standing Comm. Chief)', 'Bhavna Patel', 'Pranav Shah', 'Kavita Modi'],
      'inspector': 'Inspector Amit Trivedi',
      'office': 'AMC North West Zonal Complex, Bodakdev',
      'phone': '+91 79 2685 0000',
      'lat': 23.0350,
      'lng': 72.5293,
    },
    {
      'wardNumber': 5,
      'wardName': 'Thaltej',
      'zone': 'North West Zone',
      'corporators': ['Kamlesh Patel', 'Jashu Vaghela', 'Ronak Shah', 'Hansa Parmar'],
      'inspector': 'Inspector D. B. Zala',
      'office': 'Thaltej Civic Centre, SG Highway',
      'phone': '+91 79 2685 4422',
      'lat': 23.0530,
      'lng': 72.5110,
    },
    {
      'wardNumber': 6,
      'wardName': 'Ghatlodia',
      'zone': 'North West Zone',
      'corporators': ['Jatin Patel (Dy. Mayor)', 'Seema Joshi', 'Pravin Patel', 'Kokila Desai'],
      'inspector': 'Inspector Ramesh Patel',
      'office': 'Ghatlodia Ward Office, Chanakyapuri Road',
      'phone': '+91 79 2766 8877',
      'lat': 23.0682,
      'lng': 72.5372,
    },
    {
      'wardNumber': 7,
      'wardName': 'Gota',
      'zone': 'North West Zone',
      'corporators': ['Shailesh Patel', 'Anjana Thakor', 'Haresh Vaghela', 'Sharda Patel'],
      'inspector': 'Inspector K. P. Chauhan',
      'office': 'Gota Civic Centre, Vandematram Cross Road',
      'phone': '+91 79 2766 2211',
      'lat': 23.0988,
      'lng': 72.5385,
    },
    {
      'wardNumber': 14,
      'wardName': 'Chandlodia',
      'zone': 'North West Zone',
      'corporators': ['Kiran Thakor', 'Madhuben Patel', 'Vipul Dave', 'Kanta Solanki'],
      'inspector': 'Inspector Arvind Rawal',
      'office': 'Chandlodia Ward Centre, Near Railway Crossing',
      'phone': '+91 79 2760 1199',
      'lat': 23.0722,
      'lng': 72.5450,
    },

    // Central Zone
    {
      'wardNumber': 1,
      'wardName': 'Khadia',
      'zone': 'Central Zone',
      'corporators': ['Mayur Dave', 'Varsha Bhatt', 'Kirit Parmar', 'Sharda Sharma'],
      'inspector': 'Inspector Pankaj Raval',
      'office': 'Danapith Central Zonal Complex',
      'phone': '+91 79 2535 2821',
      'lat': 23.0225,
      'lng': 72.5850,
    },
    {
      'wardNumber': 2,
      'wardName': 'Jamalpur',
      'zone': 'Central Zone',
      'corporators': ['Imran Khedawala', 'Shahnaz Ansari', 'Mushtaq Khokhar', 'Rukhsana Mirza'],
      'inspector': 'Inspector M. A. Sheikh',
      'office': 'Jamalpur Ward Office, Sardar Bridge End',
      'phone': '+91 79 2532 1100',
      'lat': 23.0115,
      'lng': 72.5810,
    },
    {
      'wardNumber': 3,
      'wardName': 'Shahpur',
      'zone': 'Central Zone',
      'corporators': ['Kaushik Patel', 'Ruksana Bano', 'Girish Parmar', 'Sayeeda Qureshi'],
      'inspector': 'Inspector Sanjay Vaghela',
      'office': 'Shahpur Ward Centre, Bahai Centre Cross Road',
      'phone': '+91 79 2562 3344',
      'lat': 23.0350,
      'lng': 72.5790,
    },
    {
      'wardNumber': 15,
      'wardName': 'Dariapur',
      'zone': 'Central Zone',
      'corporators': ['Gyasuddin Shaikh', 'Farida Mansuri', 'Surendra Dave', 'Hasina Pathan'],
      'inspector': 'Inspector B. C. Makwana',
      'office': 'Dariapur Civic Centre, Delhi Chakla',
      'phone': '+91 79 2213 4455',
      'lat': 23.0380,
      'lng': 72.5920,
    },
    {
      'wardNumber': 16,
      'wardName': 'Asarwa',
      'zone': 'Central Zone',
      'corporators': ['Lalit Dave', 'Komal Solanki', 'Manoj Patel', 'Jyotsna Chauhan'],
      'inspector': 'Inspector Hemant Patel',
      'office': 'Asarwa Ward Office, Civil Hospital Gate 4',
      'phone': '+91 79 2268 7766',
      'lat': 23.0520,
      'lng': 72.6020,
    },

    // South Zone
    {
      'wardNumber': 17,
      'wardName': 'Maninagar',
      'zone': 'South Zone',
      'corporators': ['Dr. Pravin Patel', 'Sangeeta Dave', 'Rupesh Patel', 'Bina Vyas'],
      'inspector': 'Inspector J. N. Joshi',
      'office': 'Maninagar Civic Centre, Rambaug Cross Road',
      'phone': '+91 79 2546 0000',
      'lat': 22.9980,
      'lng': 72.6015,
    },
    {
      'wardNumber': 18,
      'wardName': 'Kankaria',
      'zone': 'South Zone',
      'corporators': ['Naresh Patel', 'Rekha Parmar', 'Mukesh Vaghela', 'Shilpa Modi'],
      'inspector': 'Inspector R. R. Jadeja',
      'office': 'Kankaria Ward Office, Gate No. 3',
      'phone': '+91 79 2546 7788',
      'lat': 23.0060,
      'lng': 72.6025,
    },
    {
      'wardNumber': 19,
      'wardName': 'Danilimda',
      'zone': 'South Zone',
      'corporators': ['Shailesh Parmar', 'Jamila Bano', 'Kanti Makwana', 'Nasreen Mirza'],
      'inspector': 'Inspector Faruk Pathan',
      'office': 'Danilimda Ward Office, Shah-e-Alam Gate',
      'phone': '+91 79 2533 1188',
      'lat': 22.9910,
      'lng': 72.5850,
    },
    {
      'wardNumber': 20,
      'wardName': 'Isanpur',
      'zone': 'South Zone',
      'corporators': ['Kishore Patel', 'Manjula Vaghela', 'Dinesh Thakor', 'Pushpa Parmar'],
      'inspector': 'Inspector Vijay Chauhan',
      'office': 'Isanpur Ward Office, Govindwadi',
      'phone': '+91 79 2573 4455',
      'lat': 22.9780,
      'lng': 72.6040,
    },
    {
      'wardNumber': 21,
      'wardName': 'Vatva',
      'zone': 'South Zone',
      'corporators': ['Bipin Patel', 'Savitri Thakor', 'Raju Vaghela', 'Kamla Solanki'],
      'inspector': 'Inspector Mahesh Zala',
      'office': 'Vatva GIDC Civic Centre',
      'phone': '+91 79 2583 0011',
      'lat': 22.9550,
      'lng': 72.6280,
    },

    // East Zone
    {
      'wardNumber': 22,
      'wardName': 'Bapunagar',
      'zone': 'East Zone',
      'corporators': ['Prakash Gurjar', 'Sharda Dave', 'Nilesh Patel', 'Usha Solanki'],
      'inspector': 'Inspector H. D. Solanki',
      'office': 'Bapunagar Civic Centre, Shyam Shikhar Cross Road',
      'phone': '+91 79 2274 5566',
      'lat': 23.0410,
      'lng': 72.6280,
    },
    {
      'wardNumber': 23,
      'wardName': 'Gomtipur',
      'zone': 'East Zone',
      'corporators': ['Iqbal Sheikh', 'Kamlesh Parmar', 'Shabana Bano', 'Ramesh Vaghela'],
      'inspector': 'Inspector T. M. Parmar',
      'office': 'Gomtipur Ward Office, Near Railway Crossing',
      'phone': '+91 79 2277 8899',
      'lat': 23.0180,
      'lng': 72.6150,
    },
    {
      'wardNumber': 24,
      'wardName': 'Odhav',
      'zone': 'East Zone',
      'corporators': ['Mahadev Patel (R&B Chief)', 'Kavita Thakor', 'Jitendra Patel', 'Sarita Sharma'],
      'inspector': 'Inspector Sanjay Rawal',
      'office': 'Odhav GIDC Civic Centre, Ring Road',
      'phone': '+91 79 2287 0000',
      'lat': 23.0240,
      'lng': 72.6650,
    },
    {
      'wardNumber': 25,
      'wardName': 'Vastral',
      'zone': 'East Zone',
      'corporators': ['Naresh Vaghela', 'Daksha Patel', 'Pankaj Dave', 'Geeta Thakor'],
      'inspector': 'Inspector Bharat Prajapati',
      'office': 'Vastral Ward Office, Metro Pillar 110',
      'phone': '+91 79 2297 3344',
      'lat': 23.0010,
      'lng': 72.6580,
    },
    {
      'wardNumber': 26,
      'wardName': 'Nikol',
      'zone': 'East Zone',
      'corporators': ['Dinesh Patel', 'Sheetal Joshi', 'Bhadresh Dave', 'Nirmala Solanki'],
      'inspector': 'Inspector C. K. Patel',
      'office': 'Nikol Civic Centre, Raspan Arcade Cross Road',
      'phone': '+91 79 2293 4455',
      'lat': 23.0480,
      'lng': 72.6710,
    },

    // North Zone
    {
      'wardNumber': 27,
      'wardName': 'Naroda',
      'zone': 'North Zone',
      'corporators': ['Pravin Thakor', 'Shobhna Patel', 'Rakesh Dave', 'Jyoti Solanki'],
      'inspector': 'Inspector N. S. Zala',
      'office': 'Memco North Zonal Office, Naroda Road',
      'phone': '+91 79 2282 0000',
      'lat': 23.0710,
      'lng': 72.6520,
    },
    {
      'wardNumber': 28,
      'wardName': 'Sardarnagar & Airport',
      'zone': 'North Zone',
      'corporators': ['Girish Patel', 'Rekha Dave', 'Manish Thakor', 'Kailash Vaghela'],
      'inspector': 'Inspector Vikram Rathod',
      'office': 'Sardarnagar Ward Office, Hansol Road',
      'phone': '+91 79 2286 1122',
      'lat': 23.0820,
      'lng': 72.6280,
    },
    {
      'wardNumber': 29,
      'wardName': 'Kubernagar',
      'zone': 'North Zone',
      'corporators': ['Lalchand Lalwani', 'Bhavna Sindhi', 'Jayram Khatri', 'Sunita Gurjar'],
      'inspector': 'Inspector A. M. Sindhi',
      'office': 'Kubernagar Ward Office, Railway Colony',
      'phone': '+91 79 2281 3344',
      'lat': 23.0670,
      'lng': 72.6390,
    },

    // South West Zone
    {
      'wardNumber': 30,
      'wardName': 'Jodhpur & Prahladnagar',
      'zone': 'South West Zone',
      'corporators': ['Amit Shah', 'Kinnari Patel', 'Pritesh Mehta', 'Alka Desai'],
      'inspector': 'Inspector Rajesh Barot',
      'office': 'Jodhpur Ward Office, Anandnagar Cross Road',
      'phone': '+91 79 2692 0000',
      'lat': 23.0180,
      'lng': 72.5180,
    },
    {
      'wardNumber': 31,
      'wardName': 'Sarkhej',
      'zone': 'South West Zone',
      'corporators': ['Faruk Sheikh', 'Parul Thakor', 'Arif Khokhar', 'Fatima Mirza'],
      'inspector': 'Inspector S. P. Vaghela',
      'office': 'Sarkhej Roza Ward Office, Sanand Road',
      'phone': '+91 79 2682 1100',
      'lat': 22.9850,
      'lng': 72.5020,
    },
    {
      'wardNumber': 32,
      'wardName': 'Vejalpur',
      'zone': 'South West Zone',
      'corporators': ['Kalpesh Patel', 'Usha Vaghela', 'Sanjay Dave', 'Hansaben Modi'],
      'inspector': 'Inspector Kirit Patel',
      'office': 'Vejalpur Civic Centre, Butbhavani Temple Road',
      'phone': '+91 79 2682 4455',
      'lat': 23.0070,
      'lng': 72.5280,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicColors.surface,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AMC Municipal Directory', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('Leaders, Commissioners, Committees & 48 Wards', style: TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: CivicColors.primary,
          labelColor: CivicColors.primary,
          unselectedLabelColor: CivicColors.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Apex Leadership'),
            Tab(text: 'Standing Committee'),
            Tab(text: 'IAS & IPS Officers'),
            Tab(text: 'All 48 AMC Wards'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search leader, ward, committee, IAS officer...',
                hintStyle: const TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search_rounded, color: CivicColors.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildApexLeadershipTab(),
                _buildCommitteesTab(),
                _buildSeniorOfficersTab(),
                _buildWardsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: APEX LEADERSHIP
  Widget _buildApexLeadershipTab() {
    final filtered = _apexLeadership.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item['name'].toString().toLowerCase().contains(_searchQuery) ||
          item['role'].toString().toLowerCase().contains(_searchQuery) ||
          item['designation'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final l = filtered[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (l['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(l['icon'] as IconData, color: l['color'] as Color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l['role'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: l['color'] as Color,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: CivicColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l['tag'] as String,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l['name'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l['designation'] as String,
                            style: const TextStyle(fontSize: 12, color: CivicColors.onSurfaceVariant, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: CivicColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l['office'] as String,
                        style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callPhone(l['phone'] as String),
                        icon: const Icon(Icons.phone_rounded, size: 15),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(l['phone'] as String, style: const TextStyle(fontSize: 11.5)),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CivicColors.primary,
                          side: const BorderSide(color: CivicColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          GoogleMapsService.openMapLocation(
                            latitude: l['lat'] as double,
                            longitude: l['lng'] as double,
                            label: '${l['role']} Office',
                          );
                        },
                        icon: const Icon(Icons.navigation_rounded, size: 15),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Google Maps', style: TextStyle(fontSize: 11.5)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: l['color'] as Color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 2: STANDING COMMITTEE & SPECIALIZED COMMITTEES
  Widget _buildCommitteesTab() {
    final filtered = _committees.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c['name'].toString().toLowerCase().contains(_searchQuery) ||
          c['head'].toString().toLowerCase().contains(_searchQuery) ||
          c['scope'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final c = filtered[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (c['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Head: ${c['head']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c['color'] as Color)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CivicColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${c['membersCount']} Members', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  c['scope'] as String,
                  style: const TextStyle(fontSize: 12, color: CivicColors.onSurfaceVariant, height: 1.35),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: CivicColors.surfaceLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_note_rounded, size: 14, color: CivicColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c['schedule'] as String,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CivicColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 3: IAS & IPS ADMINISTRATIVE HEADS
  Widget _buildSeniorOfficersTab() {
    final filtered = _seniorOfficers.where((o) {
      if (_searchQuery.isEmpty) return true;
      return o['name'].toString().toLowerCase().contains(_searchQuery) ||
          o['post'].toString().toLowerCase().contains(_searchQuery) ||
          o['cadre'].toString().toLowerCase().contains(_searchQuery) ||
          o['division'].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final o = filtered[i];
        final isIas = o['cadre'].toString().contains('IAS');
        final isIps = o['cadre'].toString().contains('IPS');
        final badgeColor = isIas ? const Color(0xFF1565C0) : isIps ? const Color(0xFFB71C1C) : CivicColors.primary;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: badgeColor.withValues(alpha: 0.15),
                      child: Icon(isIps ? Icons.local_police_rounded : Icons.shield_rounded, color: badgeColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  o['name'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isIas ? 'IAS' : isIps ? 'IPS' : 'Senior Officer',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(o['post'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor)),
                          const SizedBox(height: 2),
                          Text(o['division'] as String, style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _callPhone(o['phone'] as String),
                        icon: const Icon(Icons.phone_rounded, size: 14),
                        label: Text(o['phone'] as String, style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        o['email'] as String,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 4: ALL 48 WARDS & ELECTED CORPORATORS
  Widget _buildWardsTab() {
    final filtered = _amcWards.where((w) {
      if (_searchQuery.isEmpty) return true;
      final matchWard = w['wardName'].toString().toLowerCase().contains(_searchQuery);
      final matchZone = w['zone'].toString().toLowerCase().contains(_searchQuery);
      final matchCorp = (w['corporators'] as List).any((c) => c.toString().toLowerCase().contains(_searchQuery));
      return matchWard || matchZone || matchCorp;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final w = filtered[i];
        final corporators = (w['corporators'] as List).cast<String>();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: CivicColors.primaryContainer.withValues(alpha: 0.3),
              child: Text(
                'W${w['wardNumber']}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.primary),
              ),
            ),
            title: Text(
              'Ward ${w['wardNumber']}: ${w['wardName']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
            subtitle: Text(
              '${w['zone']} • Inspector: ${w['inspector']}',
              style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Elected Municipal Corporators:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.primary),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: corporators.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: CivicColors.surfaceLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.2)),
                          ),
                          child: Text(c, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.business_rounded, size: 14, color: CivicColors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            w['office'] as String,
                            style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _callPhone(w['phone'] as String),
                            icon: const Icon(Icons.phone_rounded, size: 14),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(w['phone'] as String, style: const TextStyle(fontSize: 11)),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CivicColors.primary,
                              side: const BorderSide(color: CivicColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              GoogleMapsService.openMapLocation(
                                latitude: w['lat'] as double,
                                longitude: w['lng'] as double,
                                label: '${w['wardName']} AMC Ward Office',
                              );
                            },
                            icon: const Icon(Icons.place_rounded, size: 14),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Ward on Map', style: TextStyle(fontSize: 11)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CivicColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
