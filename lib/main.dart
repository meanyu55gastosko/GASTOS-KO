import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // Siguraduhing imported ito para sa DateFormat
import 'dart:ui'
    as ui; // 🔥 SULUSYON: Nilagyan ng 'as ui' para mawala ang conflict sa TextDirection!

void main() => runApp(const GastosKoApp());

class GastosKoApp extends StatelessWidget {
  const GastosKoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark()
            .copyWith(scaffoldBackgroundColor: const Color(0xFF121212)),
        home: const SplashScreen());
  }
}

class CommaFormatter extends TextInputFormatter {
  final NumberFormat _fmt = NumberFormat('#,##0');
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String clean = newValue.text
        .replaceAll(',', '')
        .replaceAll('₱', '')
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return const TextEditingValue(text: '');
    int val = int.tryParse(clean) ?? 0;
    return TextEditingValue(
        text: _fmt.format(val),
        selection: TextSelection.collapsed(offset: _fmt.format(val).length));
  }
}

class AppTourScreen extends StatefulWidget {
  const AppTourScreen({super.key});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final PageController _pageController = PageController();
  int _currentTourPage = 0;
  String _selectedLocale = ""; // "" kapag hindi pa pumipili ang user

  final Map<String, List<Map<String, String>>> _localizedTourData = {
    "en": [
      {
        "title": "WELCOME! 👋",
        "desc":
            "GASTOS KO is your personal companion for smart budgeting and daily fund monitoring.",
        "icon": "📱"
      },
      {
        "title": "MULTI-WALLET MANAGER 💼",
        "desc":
            "Tap the Gold Wallet icon (🪙/💼) at the top right to add new wallets, change national currencies, or manage your budgets easily.",
        "icon": "💳"
      },
      {
        "title": "KEYBOARD EMOJI ICONS 🍔",
        "desc":
            "Customize your entries! Choose any raw emoji icon (🍔, 🚗, 🛍️) directly from your keyboard via the floating circular (+) button.",
        "icon": "✨"
      },
      {
        "title": "EXPENSE TRENDS 📊",
        "desc":
            "Use the interactive Bar Charts and step buttons (➖/➕) or type directly inside the input box to decrease your target limit and compute simulated projected gains.",
        "icon": "📊"
      },
      {
        "title": "PRIVACY SHIELD MODE 🕶️",
        "desc":
            "Open the app safely in public! Toggle the 'Hide All Numbers' switch in settings to instantly mask balances into '••••'.",
        "icon": "🔒"
      }
    ],
    "tl": [
      {
        "title": "MALIGAYANG PAGDATING! 👋",
        "desc":
            "Ang GASTOS KO ay ang iyong personal na katuwang sa matalinong pagbabadyet at pag-monitor ng pondo araw-araw.",
        "icon": "📱"
      },
      {
        "title": "MULTI-WALLET MANAGER 💼",
        "desc":
            "I-tap ang kulay-gintong wallet icon (🪙/💼) sa kanang itaas para mag-add ng bagong wallet, magpalit ng pambansang currency, o magbago ng badyet.",
        "icon": "💳"
      },
      {
        "title": "KEYBOARD EMOJI ICONS 🍔",
        "desc":
            "Gawing kakaiba ang kategorya! Pumili ng kahit anong emoji icon (🍔, 🚗, 🛍️) direkta mula sa keyboard ng cellphone gamit ang bilog na (+) button.",
        "icon": "✨"
      },
      {
        "title": "GASTOS TRENDS 📊",
        "desc":
            "Gamitin ang interactive Bar Chart at mga pindutan (➖/➕) o direktang i-type sa loob ng kahon ang target limit upang makalkula ang maaari mong maipon o matipid.",
        "icon": "📊"
      },
      {
        "title": "PRIVACY SHIELD MODE 🕶️",
        "desc":
            "Ligtas na buksan ang app sa pampublikong lugar! I-on ang 'Ika-atake ng Privacy' sa settings upang agarang gawing '••••' ang mga numero.",
        "icon": "🔒"
      }
    ],
    "id": [
      {
        "title": "SELAMAT DATANG! 👋",
        "desc":
            "GASTOS KO adalah mitra pribadi Anda untuk penganggaran cerdas dan pemantauan dana harian.",
        "icon": "📱"
      },
      {
        "title": "PENGELOLA BANYAK DOMPET 💼",
        "desc":
            "Ketuk ikon dompet emas (🪙/💼) di kanan atas untuk menambah dompet baru, mengubah mata uang nasional, atau mengelola anggaran dengan mudah.",
        "icon": "💳"
      },
      {
        "title": "IKON EMOJI KEYBOARD 🍔",
        "desc":
            "Sesuaikan catatan Anda! Pilih ikon emoji apa saja (🍔, 🚗, 🛍️) langsung dari keyboard ponsel Anda melalui tombol lingkaran (+) terapung.",
        "icon": "✨"
      },
      {
        "title": "TREN PENGELUARAN 📊",
        "desc":
            "Gunakan Grafik Batang interaktif dan tombol langkah (➖/➕) atau ketik langsung di dalam kotak untuk menurunkan batas target Anda dan menghitung simulasi keuntungan.",
        "icon": "📊"
      },
      {
        "title": "MODE PERISAI PRIVASI 🕶️",
        "desc":
            "Buka aplikasi dengan aman di tempat umum! Aktifkan sakelar 'Sembunyikan Semua Angka' di pengaturan untuk langsung menyamarkan saldo menjadi '••••'.",
        "icon": "🔒"
      }
    ]
  };

  @override
  Widget build(BuildContext context) {
    // 1. KUNG WALA PANG NAPIPILING WIKA, IPAKITA ANG SELECTION SCREEN INTERFACE
    if (_selectedLocale.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.language_rounded,
                    size: 70, color: Color(0xFFFFD700)),
                const SizedBox(height: 24),
                const Text(
                  "CHOOSE APP LANGUAGE\nPUMILI NG WIKA NG APP\nPILIH BAHASA APLIKASI",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5),
                ),
                const SizedBox(height: 40),
                _buildLanguageButton("🇺🇸 English", "en"),
                const SizedBox(height: 12),
                _buildLanguageButton("🇵🇭 Tagalog / Filipino", "tl"),
                const SizedBox(height: 12),
                _buildLanguageButton("🇮🇩 Bahasa Indonesia", "id"),
              ],
            ),
          ),
        ),
      );
    }

    // 2. KUNG MAY NAPILI NANG WIKA, DIRETSO NA ITO SA TRANSLATED SLIDES TOUR
    final tourData = _localizedTourData[_selectedLocale]!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishTourAndGoRegister,
                  child: Text(
                    _selectedLocale == 'en'
                        ? "SKIP"
                        : (_selectedLocale == 'id' ? "LEWATI" : "LAKTAWAN"),
                    style: const TextStyle(
                        color: Colors.white38, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Slidable Page Body
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: tourData.length,
                  onPageChanged: (idx) {
                    setState(() {
                      _currentTourPage = idx;
                    });
                  },
                  itemBuilder: (context, idx) {
                    final item = tourData[idx];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item["icon"]!,
                            style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 32),
                        Text(
                          item["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD700),
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            item["desc"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                height: 1.4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Progress Dots and Navigation Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators Dots Loop
                  Row(
                    children: List.generate(tourData.length, (idx) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentTourPage == idx ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentTourPage == idx
                              ? const Color(0xFFFFD700)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),

                  // Action Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentTourPage < tourData.length - 1) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      } else {
                        _finishTourAndGoRegister();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _currentTourPage == tourData.length - 1
                          ? (_selectedLocale == 'en'
                              ? "START"
                              : (_selectedLocale == 'id'
                                  ? "MULAI"
                                  : "MAGSIMULA"))
                          : (_selectedLocale == 'en'
                              ? "NEXT"
                              : (_selectedLocale == 'id' ? "LANJUT" : "SUNOD")),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper widget builder para sa makikinis na mga pindutan ng wika
  Widget _buildLanguageButton(String title, String localeCode) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedLocale = localeCode;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: const Color(0xFFFFD700),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // 🔥 NAITAMA: Ginamit ang 'side: BorderSide' sa halip na 'border: Border.all'
          side: const BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  void _finishTourAndGoRegister() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. 🔥 MAHALAGANG-MAHALAGA: I-save agad ang piniling wika ng user sa database disk file registry
    await prefs.setBool('is_app_quick_tour_done', true);
    await prefs.setString('app_lang_locale', _selectedLocale);

    // 2. AUTOMATION ENGINE: Itugma ang paunang currency ng default wallet sa wika na pinili ng user
    String initialCurrency = "\$"; // Default fallback
    if (_selectedLocale == 'tl') {
      initialCurrency = "₱"; // Philippine Peso para sa Tagalog
    } else if (_selectedLocale == 'id') {
      initialCurrency = "Rp"; // Indonesian Rupiah para sa Bahasa Indonesia
    }

    // 3. Gumawa ng fresh initialized wallet list gamit ang tamang localized symbol profile
    List<AppWallet> initialWallets = [
      AppWallet(
        id: "default",
        name: _selectedLocale == 'tl'
            ? "Pangunahing Wallet"
            : (_selectedLocale == 'id' ? "Dompet Utama" : "Main Wallet"),
        budget: 0.0,
        currency: initialCurrency,
      )
    ];

    // 4. I-save agad ang setup sa shared preferences para sumunod ang main dashboard frame pagkagising ng screen matrix
    await prefs.setString('app_wallets',
        jsonEncode(initialWallets.map((w) => w.toJson()).toList()));
    await prefs.setString('active_wallet_id', "default");
    await prefs.setString('app_currency_symbol', initialCurrency);

    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const RegistrationScreen()));
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _glow;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.15)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 25, end: 70)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    // 🔥 TIGNAN KUNG BAGONG INSTALL PARA SA QUICK TOUR
    bool isTourDone = prefs.getBool('is_app_quick_tour_done') ?? false;
    if (!isTourDone) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AppTourScreen()));
      return;
    }

    String? installDateStr = prefs.getString('app_install_date');
    DateTime now = DateTime.now();
    bool isExpired = false;

    if (installDateStr == null) {
      await prefs.setString('app_install_date', now.toIso8601String());
    } else {
      DateTime installDate = DateTime.parse(installDateStr);
      int daysUsed = now.difference(installDate).inDays;
      bool isPremium = prefs.getBool('is_premium_user') ?? false;

      if (daysUsed >= 30 && !isPremium) {
        isExpired = true;
      }
    }

    final savedPin = prefs.getString('user_pincode');

    if (savedPin == null || savedPin.isEmpty) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RegistrationScreen()));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PinCodeScreen(
                    isRegistration: false,
                    isTrialExpiredMode: isExpired,
                  )));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) =>
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                      blurRadius: _glow.value,
                      spreadRadius: 5),
                  BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: _glow.value * 1.8,
                      spreadRadius: 15)
                ]),
                child: Image.asset('assets/icon.png', width: 130, height: 130),
              ),
            ),
            const SizedBox(height: 30),
            const Text('GASTOS KO',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('by RAS Mobilelabs',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.5)),
          ]),
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PinCodeScreen(isRegistration: true);
  }
}

class PinCodeScreen extends StatefulWidget {
  final bool isRegistration;
  final bool isTrialExpiredMode;
  const PinCodeScreen({
    super.key,
    required this.isRegistration,
    this.isTrialExpiredMode = false,
  });

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  String _savedPin = "";
  String _errorText = "";
  bool _isRecovering = false;
  bool _isUpdatingPin = false;
  String _currentLocale = "en";

  int _failedAttempts = 0;
  final int _maxAttempts = 3;

  final Map<String, Map<String, String>> _pinLocalization = {
    'en': {
      'set_pin': 'SET YOUR PINCODE',
      'enter_pin': 'ENTER YOUR PINCODE',
      'trial_expired_title': '🔒 TRIAL EXPIRED LOCK',
      'trial_expired_info':
          'Your 30-day free trial has expired. Enter PIN to view limited historical data.',
      'pin_len_err': 'PIN code must be 4 digits.',
      'pin_success': 'Your PIN has been successfully updated!',
      'security_title': '🔒 SECURITY QUESTION',
      'security_question': 'What is the name of your first Pet?',
      'security_hint': 'Your answer here...',
      'setup_success': 'PIN and Security Recovery successfully set!',
      'btn_save': 'SAVE',
      'recover_title': 'RECOVER PIN CODE',
      'max_attempts': '🔒 Attempts exhausted! Here is the recovery layer.',
      'wrong_pin': 'Wrong PIN Code! ({left}/{max} attempts left)',
      'recovery_instruction':
          'Answer the question below:\nWhat is the name of your first Pet?',
      'reg_info':
          'You will use this PIN every time you open the app for your security.',
      'lock_info': 'Enter your 4-digit code to unlock.',
      'type_ans': 'Type your answer...',
      'correct_ans': 'Correct answer! Please set a new PIN.',
      'wrong_ans': 'Wrong answer! Think carefully.',
      'btn_verify': 'VERIFY ANSWER',
      'btn_confirm': 'CONFIRM & SAVE',
      'btn_unlock': 'UNLOCK',
      'forgot_pin': 'Forgot PIN Code?',
      'back_lock': 'Back to Lock Screen',
      'Only 4 digits allowed!': 'Only 4 digits allowed!',
      'Pin successfully changed!': 'PIN successfully changed!',
    },
    'tl': {
      'set_pin': 'MAG-SET NG IYONG PINCODE',
      'enter_pin': 'I-ENTER ANG IYONG PINCODE',
      'trial_expired_title': '🔒 LOCK SCREEN PARA SA PAG-EXPIRE',
      'trial_expired_info':
          'Tapos na ang iyong 30-day free trial. Ipasok ang PIN para mabuksan ang app sa limitadong mode.',
      'pin_len_err': 'Dapat ay may 4-digits ang PIN code.',
      'pin_success': 'Matagumpay na na-update ang iyong PIN!',
      'security_title': '🔒 TANONG PANGSEGURIDAD',
      'security_question':
          'Ano ang pangalan ng iyong unang naging Alagang Hayop (Pet)?',
      'security_hint': 'Sagot mo dito...',
      'setup_success':
          'Matagumpay na nai-set ang iyong PIN at Security Recovery!',
      'btn_save': 'I-SAVE',
      'recover_title': 'IREKOBER ANG PIN CODE',
      'max_attempts': '🔒 Naubos na ang attempts mo! Heto ang recovery layer.',
      'wrong_pin': 'Maling PIN Code! ({left}/{max} attempts left)',
      'recovery_instruction':
          'Sagutin ang tanong sa ibaba:\nAno ang pangalan ng iyong unang naging Alagang Hayop (Pet)?',
      'reg_info':
          'Gagamitin mo ang PIN na ito tuwing bubuksan ang app para sa iyong seguridad.',
      'lock_info': 'Ipasok ang iyong 4-digit code para mag-unlock.',
      'type_ans': 'I-type ang iyong sagot...',
      'correct_ans': 'Tama ang sagot mo! Mag-set ka na ng bagong PIN.',
      'wrong_ans': 'Maling sagot! Isiping mabuti.',
      'btn_verify': 'I-VERIFY ANG SAGOT',
      'btn_confirm': 'I-CONFIRM AT I-SAVE',
      'btn_unlock': 'I-UNLOCK',
      'forgot_pin': 'Nakalimutan ang PIN Code?',
      'back_lock': 'Bumalik sa Lock Screen',
      'Only 4 digits allowed!': '4 na numero lamang ang pinapayagan!',
      'Pin successfully changed!': 'Matagumpay na naitakda ang bagong PIN!',
    },
    'id': {
      'set_pin': 'ATUR PINCODE ANDA',
      'enter_pin': 'MASUKKAN PINCODE ANDA',
      'trial_expired_title': '🔒 MASA UJI COBA BERAKHIR',
      'trial_expired_info':
          'Masa uji coba 30 hari Anda telah berakhir. Masukkan PIN untuk melihat data riwayat terbatas.',
      'pin_len_err': 'Kode PIN harus 4 digit.',
      'pin_success': 'PIN Anda berhasil diperbarui!',
      'security_title': '🔒 PERTANYAAN KEAMANAN',
      'security_question': 'Siapa nama Hewan Peliharaan pertama Anda?',
      'security_hint': 'Jawaban Anda di sini...',
      'setup_success': 'PIN and Pemulihan Keamanan berhasil diatur!',
      'btn_save': 'SIMPAN',
      'recover_title': 'PULIHKAN KODE PIN',
      'max_attempts': '🔒 Kesempatan habis! Ini adalah lapisan pemulihan.',
      'wrong_pin': 'Kode PIN Salah! (Tersisa {left}/{max} kesempatan)',
      'recovery_instruction':
          'Jawab pertanyaan di bawah ini:\nSiapa nama Hewan Peliharaan pertama Anda?',
      'reg_info':
          'Anda akan menggunakan PIN ini setiap kali membuka aplikasi demi keamanan Anda.',
      'lock_info': 'Masukkan 4 digit kode Anda untuk membuka kunci.',
      'type_ans': 'Ketik jawaban Anda...',
      'correct_ans': 'Jawaban benar! Silakan atur PIN baru.',
      'wrong_ans': 'Jawaban salah! Pikirkan baik-baik.',
      'btn_verify': 'VERIFIKASI JAWABAN',
      'btn_confirm': 'KONFIRMASI & SIMPAN',
      'btn_unlock': 'BUKA KUNCI',
      'forgot_pin': 'Lupa Kode PIN?',
      'back_lock': 'Kembali ke Layar Kunci',
      'Only 4 digits allowed!': 'Hanya diperbolehkan 4 digit!',
      'Pin successfully changed!': 'PIN berhasil diubah!',
    },
  };
  String _getTxt(String key) => _pinLocalization[_currentLocale]?[key] ?? key;
  @override
  void initState() {
    super.initState();
    _loadSavedPinAndLocale();
  }

  Future _loadSavedPinAndLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String deviceLanguage =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    String defaultLocale = 'en';
    if (deviceLanguage == 'tl' || deviceLanguage == 'fil') {
      defaultLocale = 'tl';
    } else if (deviceLanguage == 'id') {
      defaultLocale = 'id';
    }
    setState(() {
      _savedPin = prefs.getString('user_pincode') ?? "";
      String savedLocale = prefs.getString('app_lang_locale') ?? defaultLocale;
      if (savedLocale != 'en' && savedLocale != 'tl' && savedLocale != 'id') {
        _currentLocale = defaultLocale;
      } else {
        _currentLocale = savedLocale;
      }
    });
  }

  Future _handlePinSubmit(String pin) async {
    if (pin.length < 4) {
      setState(() {
        _errorText = _getTxt('pin_len_err');
      });
      return;
    }
    if (_isUpdatingPin) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pincode', pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getTxt('pin_success'))),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else if (widget.isRegistration) {
      _showSecurityQuestionSetupDialog(pin);
    } else {
      if (pin == _savedPin) {
        setState(() {
          _failedAttempts = 0;
        });
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      } else {
        setState(() {
          _failedAttempts++;
          _pinController.clear();
          if (_failedAttempts >= _maxAttempts) {
            _isRecovering = true;
            _errorText = _getTxt('max_attempts');
          } else {
            int natitira = _maxAttempts - _failedAttempts;
            _errorText = _getTxt('wrong_pin')
                .replaceAll('{left}', natitira.toString())
                .replaceAll('{max}', _maxAttempts.toString());
          }
        });
      }
    }
  }

  void _showSecurityQuestionSetupDialog(String targetPin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(_getTxt('security_title'),
            style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getTxt('security_question'),
                style: const TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: _answerController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  hintText: _getTxt('security_hint'),
                  hintStyle: const TextStyle(color: Colors.white30)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (_answerController.text.trim().isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_pincode', targetPin);
                await prefs.setString('security_answer',
                    _answerController.text.trim().toLowerCase());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_getTxt('setup_success'))),
                  );
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black),
            child: Text(_getTxt('btn_save'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Future _handleRecoverySubmit() async {
    final prefs = await SharedPreferences.getInstance();
    String savedAnswer = prefs.getString('security_answer') ?? "";
    String inputAnswer = _answerController.text.trim().toLowerCase();
    if (inputAnswer == savedAnswer && savedAnswer.isNotEmpty) {
      setState(() {
        _isRecovering = false;
        _isUpdatingPin = true;
        _errorText = "";
        _pinController.clear();
        _answerController.clear();
      });
      await prefs.remove('user_pincode');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_getTxt('correct_ans')),
              backgroundColor: Colors.green),
        );
      }
    } else {
      setState(() {
        _errorText = _getTxt('wrong_ans');
        _answerController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentTitle =
        widget.isRegistration ? _getTxt('set_pin') : _getTxt('enter_pin');
    if (widget.isTrialExpiredMode) {
      currentTitle = _getTxt('trial_expired_title');
    }
    if (_isUpdatingPin) currentTitle = _getTxt('set_pin');
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isRecovering
                      ? Icons.help_outline_rounded
                      : (widget.isTrialExpiredMode
                          ? Icons.timer_off_outlined
                          : ((widget.isRegistration || _isUpdatingPin)
                              ? Icons.lock_open_rounded
                              : Icons.lock_outline_rounded)),
                  size: 80,
                  color: widget.isTrialExpiredMode
                      ? Colors.redAccent
                      : const Color(0xFFFFD700),
                ),
                const SizedBox(height: 24),
                Text(
                  _isRecovering ? _getTxt('recover_title') : currentTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isTrialExpiredMode
                          ? Colors.redAccent
                          : Colors.white,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  _isRecovering
                      ? _getTxt('recovery_instruction')
                      : (widget.isTrialExpiredMode
                          ? _getTxt('trial_expired_info')
                          : ((widget.isRegistration || _isUpdatingPin)
                              ? _getTxt('reg_info')
                              : _getTxt('lock_info'))),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.white54),
                ),
                const SizedBox(height: 32),
                if (!_isRecovering)
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      maxLength: 4,
                      style: TextStyle(
                          fontSize: 28,
                          letterSpacing: 20,
                          color: widget.isTrialExpiredMode
                              ? Colors.redAccent
                              : const Color(0xFFFFD700)),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "••••",
                        hintStyle: const TextStyle(
                            color: Colors.white24, letterSpacing: 8),
                        labelText: _currentLocale == 'tl'
                            ? ''
                            : (_currentLocale == 'id' ? '' : ''),
                        labelStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                            letterSpacing: 0),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFD700)),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.length == 4) {
                          _handlePinSubmit(val);
                        }
                      },
                    ),
                  )
                else
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: _answerController,
                      textCapitalization: TextCapitalization.words,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: _getTxt('type_ans'),
                        hintStyle: const TextStyle(
                            color: Colors.white24, fontSize: 14),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white30, width: 2)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFFFD700), width: 2)),
                      ),
                    ),
                  ),
                if (_errorText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _isRecovering
                      ? _handleRecoverySubmit()
                      : _handlePinSubmit(_pinController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isTrialExpiredMode
                        ? Colors.redAccent
                        : const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _isRecovering
                        ? _getTxt('btn_verify')
                        : ((widget.isRegistration || _isUpdatingPin)
                            ? _getTxt('btn_confirm')
                            : _getTxt('btn_unlock')),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!widget.isRegistration &&
                    !_isRecovering &&
                    !_isUpdatingPin) ...[
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRecovering = true;
                        _errorText = "";
                      });
                    },
                    child: Text(
                      _getTxt('forgot_pin'),
                      style: TextStyle(
                          color: widget.isTrialExpiredMode
                              ? Colors.redAccent
                              : const Color(0xFFFFD700),
                          fontSize: 13,
                          decoration: TextDecoration.underline),
                    ),
                  )
                ] else if (_isRecovering && _failedAttempts < _maxAttempts) ...[
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRecovering = false;
                        _errorText = "";
                      });
                    },
                    child: Text(
                      _getTxt('back_lock'),
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoalDeposit {
  double amount;
  DateTime date;

  GoalDeposit({required this.amount, required this.date});

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory GoalDeposit.fromJson(Map<String, dynamic> j) => GoalDeposit(
        amount: (j['amount'] as num).toDouble(),
        date: DateTime.parse(j['date']),
      );
}

class SavingsGoal {
  String id;
  String name;
  double targetAmount;
  double savedAmount;
  DateTime deadline;
  List<GoalDeposit> deposits;
  String
      currencySymbol; // 🔥 SULUSYON: Idinagdag para permanenteng matandaan ang currency ng goal na ito!

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.deposits,
    this.currencySymbol =
        "₱", // Default fallback symbol profile structure core registry data block
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'deadline': deadline.toIso8601String(),
        'deposits': deposits.map((d) => d.toJson()).toList(),
        'currencySymbol': currencySymbol, // 🔥 Isasama sa JSON writing package
      };

  factory SavingsGoal.fromJson(Map<String, dynamic> j) => SavingsGoal(
        id: j['id'] ?? "",
        name: j['name'] ?? "Savings Goal",
        targetAmount: (j['targetAmount'] as num? ?? 10000.0).toDouble(),
        savedAmount: (j['savedAmount'] as num? ?? 0.0).toDouble(),
        deadline:
            DateTime.parse(j['deadline'] ?? DateTime.now().toIso8601String()),
        deposits: j['deposits'] != null
            ? (j['deposits'] as List)
                .map((d) => GoalDeposit.fromJson(d))
                .toList()
            : [],
        currencySymbol: j['currencySymbol'] ??
            "₱", // 🔥 I-restore mula sa database preferences preference memory registry disk file map node
      );
}

class Expense {
  String id;
  String title;
  double amount;
  DateTime date;
  Color color;
  String iconEmoji; // 💰 Holds the raw emoji string from the keyboard

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.color,
    this.iconEmoji = "💰", // Default fallback emoji
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'color': color.toARGB32(),
        'iconEmoji': iconEmoji,
      };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'],
        title: j['title'],
        amount: (j['amount'] as num).toDouble(),
        date: DateTime.parse(j['date']),
        color: Color(j['color']),
        iconEmoji: j['iconEmoji'] ?? "💰",
      );
}

class AppWallet {
  String id;
  String name;
  double budget;
  String currency; // Idinagdag para sa custom currency ng wallet

  AppWallet({
    required this.id,
    required this.name,
    required this.budget,
    this.currency = "₱", // Default ay Peso para sa mga lumang wallet data
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'budget': budget,
        'currency': currency,
      };

  factory AppWallet.fromJson(Map<String, dynamic> j) => AppWallet(
        id: j['id'],
        name: j['name'],
        budget: (j['budget'] as num).toDouble(),
        currency: j['currency'] ?? "₱",
      );
}

class GroupedExpense {
  String title;
  double total;
  Color color;
  int count;
  String iconEmoji; // 🔥 Idinagdag para maipasa ang emoji sa chart legends

  GroupedExpense({
    required this.title,
    required this.total,
    required this.color,
    required this.count,
    this.iconEmoji = "💰", // Default fallback emoji
  });
}

class PiePainter extends CustomPainter {
  final List data;
  final double total;
  final int? selectedIndex;
  PiePainter({required this.data, required this.total, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double radius = math.min(size.width, size.height) / 2;

    // 🔥 BAGONG LOGIC: Kung walang entries, gumuhit ng magandang Empty Placeholder Circle
    if (total <= 0 || data.isEmpty) {
      final paintEmpty = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2, 2 * math.pi, true, paintEmpty);
      canvas.drawCircle(
          center, radius * 0.55, Paint()..color = const Color(0xFF1E1E1E));
      return;
    }

    double start = -math.pi / 2;
    for (int i = 0; i < data.length; i++) {
      var g = data[i];
      double sweep = (g.total / total) * 2 * math.pi;
      bool sel = i == selectedIndex;
      Offset off = Offset.zero;
      if (sel) {
        double mid = start + sweep / 2;
        off = Offset(math.cos(mid) * 15, math.sin(mid) * 15);
      }
      final paint = Paint()
        ..color = sel ? g.color : g.color.withValues(alpha: 0.70)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
          Rect.fromCircle(center: center + off, radius: radius + (sel ? 8 : 0)),
          start,
          sweep,
          true,
          paint);
      start += sweep;
    }
    canvas.drawCircle(
        center, radius * 0.55, Paint()..color = const Color(0xFF1E1E1E));
  }

  @override
  bool shouldRepaint(covariant PiePainter oldDelegate) => true;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State with WidgetsBindingObserver {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription? _subscription;
  List _products = [];
  bool _isPremiumUser = false;
  bool _isTrialExpired = false;
  bool _isCompactMode = false;
  bool _isPrivacyHideMode = false;
  bool _isInteractiveTourActive = false;
  int _currentTourStep = 0;
  int _trialDaysLeft = 30;
  int _currentTabIndex = 0;
  String _purchasedPlanTitle = "";
  String _currentCurrency = "₱";
  List wallets = [];
  String activeWalletId = "default";
  double budget = 0;
  List all = [];
  String searchQuery = "";
  String _activeSortFilter = "latest";
  double _savingsGoalPercentage = 20.0;
  String _selectedReportCategory = "";
  Map<String, double> _customCategoryTargets = {};
  final TextEditingController _searchController = TextEditingController();
  int? selectedIndex;
  List<SavingsGoal> savingsGoals = [];

  final NumberFormat commaFormat = NumberFormat('#,##0');
  String fmt(num n) => commaFormat.format(n.toInt());
  String peso(num n) {
    if (_isPrivacyHideMode) {
      return '$_currentCurrency••••'; // 🔥 Itatago ang numero kapag naka-on ang Privacy setting
    }
    return '$_currentCurrency${fmt(n)}';
  }

  final List dynamicColors = [
    const Color(0xFF00E676),
    const Color(0xFF00BFA5),
    const Color(0xFF29B6F6),
    const Color(0xFFFF9800),
    const Color(0xFFAB47BC),
    const Color(0xFF26A69A),
  ];
  Map<String, Color> colorMap = {};
  Timer? _bgSessionTimer;
  final Duration _sessionTimeoutDuration = const Duration(minutes: 5);
  String _currentLocale = "en";
  String _activeDateFilter = "all";
  DateTimeRange? _selectedDateRange;
  Color _appBgColor = const Color(0xFF121212);
  Color _appFontColor = Colors.white;
  Color _boxBgColor = const Color(0xFF1E1E1E);
  final List<Map<String, String>> globalCurrencies = [
    {
      "code": "PHP",
      "symbol": "₱",
      "name": "Philippine Peso",
      "country": "Philippines 🇵🇭"
    },
    {
      "code": "IDR",
      "symbol": "Rp",
      "name": "Indonesian Rupiah",
      "country": "Indonesia 🇮🇩"
    },
    {
      "code": "USD",
      "symbol": "\$",
      "name": "US Dollar",
      "country": "United States 🇺🇸"
    },
    {"code": "EUR", "symbol": "€", "name": "Euro", "country": "Eurozone 🇪🇺"},
    {
      "code": "JPY",
      "symbol": "¥",
      "name": "Japanese Yen",
      "country": "Japan 🇯🇵"
    },
    {
      "code": "GBP",
      "symbol": "£",
      "name": "British Pound",
      "country": "United Kingdom 🇬🇧"
    },
    {
      "code": "AUD",
      "symbol": "A\$",
      "name": "Australian Dollar",
      "country": "Australia 🇦🇺"
    },
    {
      "code": "CAD",
      "symbol": "C\$",
      "name": "Canadian Dollar",
      "country": "Canada 🇨🇦"
    },
    {
      "code": "SGD",
      "symbol": "S\$",
      "name": "Singapore Dollar",
      "country": "Singapore 🇸🇬"
    },
    {
      "code": "MYR",
      "symbol": "RM",
      "name": "Malaysian Ringgit",
      "country": "Malaysia 🇲🇾"
    },
    {
      "code": "THB",
      "symbol": "฿",
      "name": "Thai Baht",
      "country": "Thailand 🇹🇭"
    },
    {
      "code": "VND",
      "symbol": "₫",
      "name": "Vietnamese Dong",
      "country": "Vietnam 🇻🇳"
    },
    {
      "code": "KRW",
      "symbol": "₩",
      "name": "South Korean Won",
      "country": "South Korea 🇰🇷"
    },
    {
      "code": "CNY",
      "symbol": "¥",
      "name": "Chinese Yuan",
      "country": "China 🇨🇳"
    },
    {
      "code": "INR",
      "symbol": "₹",
      "name": "Indian Rupee",
      "country": "India 🇮🇳"
    },
    {
      "code": "AED",
      "symbol": "د.إ",
      "name": "UAE Dirham",
      "country": "United Arab Emirates 🇦🇪"
    },
    {
      "code": "SAR",
      "symbol": "ر.س",
      "name": "Saudi Riyal",
      "country": "Saudi Arabia 🇸🇦"
    },
    {
      "code": "TWD",
      "symbol": "NT\$",
      "name": "New Taiwan Dollar",
      "country": "Taiwan 🇹🇼"
    },
    {
      "code": "HKD",
      "symbol": "HK\$",
      "name": "Hong Kong Dollar",
      "country": "Hong Kong 🇭🇰"
    },
    {
      "code": "NZD",
      "symbol": "NZ\$",
      "name": "New Zealand Dollar",
      "country": "New Zealand 🇳🇿"
    },
  ];

  Widget _buildMultiSavingsGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _currentLocale == 'en'
                  ? "SAVINGS MILESTONES 🎯"
                  : (_currentLocale == 'id'
                      ? "TARGET TABUNGAN 🎯"
                      : "MGA LAYUNIN SA PAG-IIPON 🎯"),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _appFontColor.withValues(alpha: 0.7)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle,
                  color: Color(0xFFFFD700), size: 24),
              onPressed: _showCreateNewGoalDialog,
            )
          ],
        ),
        const SizedBox(height: 10),
        if (savingsGoals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                _currentLocale == 'en'
                    ? "No active goals. Tap (+) to create one!"
                    : (_currentLocale == 'id'
                        ? "Belum ada target aktif. Ketuk (+) para menambahkan!"
                        : "Walang aktibong layunin. I-click ang (+) para magdagdag!"),
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savingsGoals.length,
            itemBuilder: (context, index) {
              final goal = savingsGoals[index];
              int daysRemaining =
                  goal.deadline.difference(DateTime.now()).inDays;
              if (daysRemaining < 0) daysRemaining = 0;

              double progress = goal.targetAmount > 0
                  ? (goal.savedAmount / goal.targetAmount) * 100
                  : 0.0;
              if (progress > 100) progress = 100;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _boxBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER ROW INYONG MALINIS NA 3 DOTS VERTICAL MENU ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          goal.name.toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xfffff2a1)),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              color: Colors.white30, size: 18),
                          color: const Color(0xFF252525),
                          onSelected: (String action) {
                            if (action == 'edit')
                              _showEditSingleGoalDialog(goal);
                            if (action == 'delete')
                              _showDeleteGoalConfirm(goal);
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_note,
                                      color: Color(0xFFFFD700), size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _currentLocale == 'en'
                                        ? "Edit Milestone"
                                        : (_currentLocale == 'id'
                                            ? "Ubah Target"
                                            : "I-adjust ang Ipon"),
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline,
                                      color: Colors.redAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _currentLocale == 'en'
                                        ? "Delete"
                                        : (_currentLocale == 'id'
                                            ? "Hapus"
                                            : "Burahin"),
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ── PROGRESS ROW: GUMAGAMIT NG DYNAMIC PESO() FORMATTER ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_currentLocale == 'en' ? 'Saved: ' : (_currentLocale == 'id' ? 'Terkumpul: ' : 'Naipon: ')}${peso(goal.savedAmount)}",
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00E676)),
                        ),
                        Text(
                          "${_currentLocale == 'en' ? 'Target: ' : (_currentLocale == 'id' ? 'Target: ' : 'Target: ')}${peso(goal.targetAmount)}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ── TIME ROW (DEADLINE LABELS) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Deadline: ${DateFormat('yyyy-MM-dd').format(goal.deadline)}",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white38),
                        ),
                        Text(
                          _currentLocale == 'en'
                              ? "$daysRemaining days left"
                              : (_currentLocale == 'id'
                                  ? "$daysRemaining hari lagi"
                                  : "$daysRemaining araw na lang"),
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // ── PROGRESS INDICATOR TRACKBAR ──
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFD700)),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text("${progress.toStringAsFixed(0)}%",
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFD700))),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<DebtItemV2> debts = [];
  // I-load ang mga utang mula sa disk preference module
  Future<void> _loadDebtsData() async {
    final p = await SharedPreferences.getInstance();
    String? raw = p.getString('app_debts_tracker_data');
    if (raw != null) {
      setState(() {
        List decoded = jsonDecode(raw);
        debts = decoded.map((e) => DebtItemV2.fromJson(e)).toList();
      });
    }
  }

  // I-save ang mga utang sa disk preferences module
  Future<void> _saveDebtsData() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('app_debts_tracker_data',
        jsonEncode(debts.map((e) => e.toJson()).toList()));
  }

  // Idagdag itong tawag sa loob ng iyong initState() function:
  // _loadDebtsData();

  Future<void> _searchEmojiForCategory({
    required String val,
    required TextEditingController emojiCtrl,
    required StateSetter setModalState,
  }) async {
    final String typedCategory = val.trim().toLowerCase();
    try {
      final p = await SharedPreferences.getInstance();
      String? foundEmoji;

      for (var w in wallets) {
        String? walletExpenseData = p.getString('expenses${w.id}');
        if (walletExpenseData != null) {
          List parsedList = jsonDecode(walletExpenseData);
          var match = parsedList.lastWhere(
            (e) => e['title'].toString().toLowerCase().trim() == typedCategory,
            orElse: () => null,
          );
          if (match != null && match['iconEmoji'] != null) {
            foundEmoji = match['iconEmoji'];
            break;
          }
        }
      }

      if (foundEmoji != null) {
        setModalState(() {
          emojiCtrl.text = foundEmoji!;
        });
      }
    } catch (_) {}
  }

  // Idagdag ang argument na ito sa function definition mo:
  // Idagdag ang argument na ito sa function definition mo:
  void _showCreateNewGoalDialog({VoidCallback? onSaveSuccess}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    // 🔥 AUTOMATION LAYER: Gamitin ang kasalukuyang currency ng active wallet bilang default fallback selection choice
    String selectedGoalCurrencySymbol = _currentCurrency;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Kunin ang kumpletong detalye ng active currency flag icon indicator profile
            final currentCurrencyDetails = globalCurrencies.firstWhere(
              (c) => c["symbol"] == selectedGoalCurrencySymbol,
              orElse: () =>
                  {"country": "Philippines 🇵🇭", "code": "PHP", "symbol": "₱"},
            );

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                _currentLocale == 'en'
                    ? "Create New Goal"
                    : (_currentLocale == 'id'
                        ? "Buat Target Baru"
                        : "Gumawa ng Bagong Layunin"),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: _currentLocale == 'en'
                          ? "Goal Name"
                          : (_currentLocale == 'id'
                              ? "Nama Target"
                              : "Pangalan ng Layunin"),
                      labelStyle: const TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔥 IDINAGDAG: CLICKABLE INTERACTIVE LINE PARA MAG-EDIT/PUMILI NG CURRENCY NG TARGET GOAL
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      _currentLocale == 'tl'
                          ? 'Pumili ng Currency'
                          : 'Select Goal Currency',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                    subtitle: Text(
                      "${currentCurrencyDetails["country"]} (${currentCurrencyDetails["code"]}) [${currentCurrencyDetails["symbol"]}]",
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700)),
                    ),
                    trailing: const Icon(Icons.arrow_drop_down,
                        color: Colors.white54, size: 20),
                    onTap: () {
                      _openCurrencySearchPicker((chosen) {
                        setDialogState(() {
                          selectedGoalCurrencySymbol = chosen["symbol"]!;
                        });
                      });
                    },
                  ),
                  const SizedBox(height: 6),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CommaFormatter()
                    ],
                    decoration: InputDecoration(
                      prefixText:
                          '$selectedGoalCurrencySymbol ', // Gagamitin ang piniling dynamic currency profile indicator array box
                      prefixStyle: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold),
                      labelText: _currentLocale == 'en'
                          ? "Target Amount"
                          : (_currentLocale == 'id'
                              ? "Jumlah Target"
                              : "Target na Halaga"),
                      labelStyle: const TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              _currentLocale == 'en'
                                  ? "Deadline Date"
                                  : (_currentLocale == 'id'
                                      ? "Tanggal Tenggat Waktu"
                                      : "Petsa ng Deadline"),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                          const SizedBox(height: 4),
                          Text(DateFormat('yyyy-MM-dd').format(selectedDate),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month,
                            color: Color(0xFFFFD700)),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_currentLocale == 'en'
                      ? "Cancel"
                      : (_currentLocale == 'id' ? "Batal" : "Kanselahin")),
                ),
                TextButton(
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    final double? targetAmount = double.tryParse(
                        amountController.text.replaceAll(',', ''));

                    if (name.isEmpty ||
                        targetAmount == null ||
                        targetAmount <= 0) return;

                    setState(() {
                      savingsGoals.add(SavingsGoal(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          targetAmount: targetAmount,
                          savedAmount: 0.0,
                          deadline: selectedDate,
                          deposits: [],
                          currencySymbol: selectedGoalCurrencySymbol));
                    });

                    final p = await SharedPreferences.getInstance();
                    await p.setString(
                        'app_savings_goals',
                        jsonEncode(
                            savingsGoals.map((g) => g.toJson()).toList()));

                    if (onSaveSuccess != null) onSaveSuccess();

                    Navigator.pop(
                        context); // Isasara ang Create Input Dialog window

                    // 🎉 MULTILINGUAL SUCCESS PROMPT: Lalabas pagkatapos ma-save ang bagong layunin
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("🎯✨", style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text(
                              _currentLocale == 'en'
                                  ? "GOAL CREATED!"
                                  : (_currentLocale == 'id'
                                      ? "TARGET DIBUAT!"
                                      : "NAIDAGDAG ANG LAYUNIN!"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentLocale == 'en'
                                  ? "Successfully created a new savings goal for ${name.toUpperCase()}!"
                                  : (_currentLocale == 'id'
                                      ? "Berhasil membuat target tabungan baru untuk ${name.toUpperCase()}!"
                                      : "Matagumpay na nagawa ang bagong layunin sa ipon para sa ${name.toUpperCase()}!"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                              ),
                              child: Text(
                                _currentLocale == 'en'
                                    ? "OKAY"
                                    : (_currentLocale == 'id' ? "OK" : "SIGE"),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Text(
                      _currentLocale == 'en'
                          ? "Save"
                          : (_currentLocale == 'id' ? "Simpan" : "I-save"),
                      style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showEditSingleGoalDialog(SavingsGoal goal) {
    final nameCtrl = TextEditingController(text: goal.name);
    final targetCtrl = TextEditingController(
        text: commaFormat.format(goal.targetAmount.toInt()));
    DateTime pickedDate = goal.deadline;
    String goalCurrencySymbol = goal.currencySymbol;
    double kasalukuyangNaipon = goal.savedAmount;
    String internalErrorText = "";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              // 🔥 MULTILINGUAL TITLE SUPPORT
              _currentLocale == 'en'
                  ? "Edit Savings Goal"
                  : (_currentLocale == 'id'
                      ? "Ubah Target Tabungan"
                      : "I-edit ang Layunin sa Ipon"),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      // 🔥 MULTILINGUAL LABEL
                      labelText: _currentLocale == 'en'
                          ? "Goal Name"
                          : (_currentLocale == 'id'
                              ? "Nama Target"
                              : "Pangalan ng Layunin"),
                      labelStyle:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CommaFormatter()
                    ],
                    decoration: InputDecoration(
                      prefixText: '$goalCurrencySymbol ',
                      prefixStyle: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold),
                      // 🔥 MULTILINGUAL LABEL
                      labelText: _currentLocale == 'en'
                          ? "Target Amount"
                          : (_currentLocale == 'id'
                              ? "Jumlah Target"
                              : "Target na Halaga"),
                      labelStyle:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    // 🔥 MULTILINGUAL LABEL
                    _currentLocale == 'en'
                        ? "Current Saved Amount"
                        : (_currentLocale == 'id'
                            ? "Jumlah Terkumpul Saat Ini"
                            : "Kasalukuyang Naipon"),
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$goalCurrencySymbol ${commaFormat.format(kasalukuyangNaipon.toInt())}",
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // 🔥 MULTILINGUAL LABEL
                            _currentLocale == 'en'
                                ? "Deadline Date"
                                : (_currentLocale == 'id'
                                    ? "Tanggal Tenggat Waktu"
                                    : "Petsa ng Deadline"),
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy-MM-dd').format(pickedDate),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month,
                            color: Color(0xFFFFD700)),
                        onPressed: () async {
                          final DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: pickedDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) {
                            setDialogState(() {
                              pickedDate = date;
                            });
                          }
                        },
                      )
                    ],
                  ),
                  if (internalErrorText.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.5),
                            width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              internalErrorText,
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                // 🔥 MULTILINGUAL ACTIONS BUTTON
                child: Text(
                  _currentLocale == 'en'
                      ? "Cancel"
                      : (_currentLocale == 'id' ? "Batal" : "Kanselahin"),
                  style: const TextStyle(color: Colors.white38),
                ),
              ),
              TextButton(
                onPressed: () {
                  final String cleanText =
                      targetCtrl.text.replaceAll(',', '').trim();
                  final double? parsedTarget = double.tryParse(cleanText);

                  if (nameCtrl.text.trim().isEmpty ||
                      parsedTarget == null ||
                      parsedTarget <= 0) return;

                  if (parsedTarget < goal.savedAmount) {
                    setDialogState(() {
                      if (_currentLocale == 'en') {
                        internalErrorText =
                            "Target cannot be lower than the already saved amount!";
                      } else if (_currentLocale == 'id') {
                        internalErrorText =
                            "Batas target tidak boleh lebih rendah dari jumlah terkumpul!";
                      } else {
                        internalErrorText =
                            "Ang target ay hindi maaaring mas mababa sa naipon na pondo!";
                      }
                    });
                    return;
                  }

                  setState(() {
                    goal.name = nameCtrl.text.trim();
                    goal.targetAmount = parsedTarget;
                    goal.deadline = pickedDate;
                    saveData();
                  });

                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("📝✨", style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text(
                            _currentLocale == 'en'
                                ? "GOAL UPDATED!"
                                : (_currentLocale == 'id'
                                    ? "TARGET DIPERBARUI!"
                                    : "NA-UPDATE ANG LAYUNIN!"),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentLocale == 'en'
                                ? "Successfully updated the target amount for ${goal.name.toUpperCase()}!"
                                : (_currentLocale == 'id'
                                    ? "Berhasil memperbarui jumlah target untuk ${goal.name.toUpperCase()}!"
                                    : "Matagumpay na na-update ang target na halaga para sa ${goal.name.toUpperCase()}!"),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                            ),
                            child: Text(
                              _currentLocale == 'en'
                                  ? "OKAY"
                                  : (_currentLocale == 'id' ? "OK" : "SIGE"),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
// 🔥 MULTILINGUAL ACTIONS BUTTON
                child: Text(
                  _currentLocale == 'en'
                      ? "Save"
                      : (_currentLocale == 'id' ? "Simpan" : "I-save"),
                  style: const TextStyle(
                      color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _showDeleteGoalConfirm(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _currentLocale == 'en'
              ? "Delete Goal?"
              : (_currentLocale == 'id'
                  ? "Hapus Target?"
                  : "Burahin ang Layunin?"),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          _currentLocale == 'en'
              ? "Are you sure you want to permanently remove \"${goal.name.toUpperCase()}\"?"
              : (_currentLocale == 'id'
                  ? "Apakah Anda yakin ingin menghapus \"${goal.name.toUpperCase()}\" secara permanen?"
                  : "Sigurado ka bang gusto mong burahin nang tuluyan ang \"${goal.name.toUpperCase()}\"?"),
          style:
              const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                _currentLocale == 'en'
                    ? "Cancel"
                    : (_currentLocale == 'id' ? "Batal" : "Kanselahin"),
                style: const TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                savingsGoals.removeWhere((g) => g.id == goal.id);
              });

              final p = await SharedPreferences.getInstance();
              await p.setString('app_savings_goals',
                  jsonEncode(savingsGoals.map((g) => g.toJson()).toList()));

              Navigator.pop(context);

              if (mounted) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🗑️✨", style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          _currentLocale == 'en'
                              ? "GOAL DELETED!"
                              : (_currentLocale == 'id'
                                  ? "TARGET DIHAPUS!"
                                  : "NABURA ANG LAYUNIN!"),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentLocale == 'en'
                              ? "The savings milestone has been permanently removed."
                              : (_currentLocale == 'id'
                                  ? "Catatan target tabungan telah berhasil dihapus secara permanen."
                                  : "Ang talaan ng layunin sa ipon ay matagumpay na nabura nang tuluyan."),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                          ),
                          child: Text(
                              _currentLocale == 'en'
                                  ? "OKAY"
                                  : (_currentLocale == 'id' ? "OK" : "SIGE"),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            child: Text(
                _currentLocale == 'en'
                    ? "Delete"
                    : (_currentLocale == 'id' ? "Hapus" : "Burahin"),
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // 🔥 1. POP-UP PROMPT: Nagtatanong kung gustong mag-tour bago magsimula
  // 🔥 1. POP-UP PROMPT: Nagtatanong kung gustong mag-tour bago magsimula
  // 🔥 MULTILINGGWAL PROMPT DIALOG PARA SA DASHBOARD INTERACTIVE TOUR
  void _showStartTourPromptDialog() {
    String dialogTitle = "";
    String dialogContent = "";
    String btnCancelLabel = "";
    String btnStartLabel = "";

    // Sinasala ang mga teksto base sa aktibong wika ng app session
    if (_currentLocale == 'en') {
      dialogTitle = "🎯 Quick Dashboard Tour";
      dialogContent =
          "Would you like to take a quick tour of your main screen features to understand how each button works?";
      btnCancelLabel = "CANCEL";
      btnStartLabel = "LET'S START";
    } else if (_currentLocale == 'id') {
      dialogTitle = "🎯 Tur Dasbor Ringkas";
      dialogContent =
          "Apakah Anda ingin berkeliling cepat melihat fitur-fitur layar utama untuk mengetahui fungsi setiap tombol?";
      btnCancelLabel = "BATAL";
      btnStartLabel = "MULAI TUR";
    } else {
      // Default ay Tagalog ('tl')
      dialogTitle = "🎯 Quick Dashboard Tour";
      dialogContent =
          "Gusto mo bang libutin natin nang mabilis ang mga feature ng iyong main screen para malaman ang gamit ng bawat button?";
      btnCancelLabel = "BATAL";
      btnStartLabel = "LET'S START";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          dialogTitle,
          style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        content: Text(dialogContent),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_main_dashboard_tour_done', true);
            },
            child: Text(
              btnCancelLabel,
              style: const TextStyle(
                  color: Colors.white30, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isInteractiveTourActive = true;
                _currentTourStep =
                    1; // Awtomatikong mag-a-activate ang Step 1 ng overlay box
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black),
            child: Text(
              btnStartLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 2. TOUR FINISHER: Sine-save sa memory na tapos na ang user
  // 🔥 MULTILINGGWAL SNACKBAR NOTIFICATION PAGKATAPOS NG TOUR
  void _finishDashboardInteractiveTour() async {
    setState(() {
      _isInteractiveTourActive = false;
      _currentTourStep = 0;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_main_dashboard_tour_done', true);

    if (mounted) {
      String snackBarMsg = "";

      // Sinasala ang mensahe depende sa piniling wika ng user
      if (_currentLocale == 'en') {
        snackBarMsg = "🎉 Awesome! You are now ready to use Gastos Ko!";
      } else if (_currentLocale == 'id') {
        snackBarMsg =
            "🎉 Luar biasa! Anda sekarang siap menggunakan Gastos Ko!";
      } else {
        // Default ay Tagalog ('tl')
        snackBarMsg = "🎉 Mahusay! Handa ka nang gamitin ang Gastos Ko!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            snackBarMsg,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior
              .floating, // Binigyan ng lumulutang na anyo para mas makinis tingnan
        ),
      );
    }
  }

  // 🔥 3. OVERLAY BOX GENERATOR: Tagagawa ng lumulutang na helper description box
  // 🔥 TAGAGAWA NG LUMULUTANG NA INTERACTIVE HELPER BOX SCREEN
  Widget _buildTourOverlayOverlay() {
    if (!_isInteractiveTourActive) return const SizedBox();

    String stepTitle = "";
    String stepDesc = "";
    Alignment boxAlignment = Alignment.center;

    // 🔥 PINALAWAK NA MULTILINGGWAL ENGINE (6 HAKBANG - KASAMA ANG BURGER MENU)
    switch (_currentTourStep) {
      case 1:
        boxAlignment = Alignment.topLeft;
        if (_currentLocale == 'en') {
          stepTitle = "Main Menu (Burger Menu) ☰";
          stepDesc =
              "Tap the menu button at the top left to change languages, choose custom color themes, check privacy policies, or reset application data.";
        } else if (_currentLocale == 'id') {
          stepTitle = "Menu Utama (Menu Burger) ☰";
          stepDesc =
              "Ketuk tombol menu di kiri atas untuk mengubah bahasa, memilih tema warna khusus, melihat kebijakan privasi, atau mengatur ulang data aplikasi.";
        } else {
          // Default: Tagalog ('tl')
          stepTitle = "Main Menu (Burger Menu) ☰";
          stepDesc =
              "I-tap ang menu button sa kaliwang itaas upang magpalit ng wika, pumili ng custom color themes, basahin ang privacy policy, o mag-reset ng app.";
        }
        break;

      case 2:
        boxAlignment = Alignment.topCenter;
        if (_currentLocale == 'en') {
          stepTitle = "Wallet Manager 💼";
          stepDesc =
              "Tap the wallet icon at the top right to add a new wallet, change national currencies (₱, Rp, \$), or update your budget.";
        } else if (_currentLocale == 'id') {
          stepTitle = "Pengelola Dompet 💼";
          stepDesc =
              "Ketuk ikon dompet di kanan atas untuk menambahkan dompet baru, mengubah mata uang (₱, Rp, \$), atau memperbarui anggaran.";
        } else {
          stepTitle = "Wallet Manager 💼";
          stepDesc =
              "I-tap ang wallet icon sa kanang itaas para mag-add ng bagong wallet, magpalit ng pambansang currency (₱, Rp, \$), o mag-bago ng budget.";
        }
        break;

      case 3:
        boxAlignment = Alignment.topRight;
        if (_currentLocale == 'en') {
          stepTitle = "Export Reports 📑";
          stepDesc =
              "Use the share button at the top to export and download your expense list into PDF or Excel-ready CSV reports.";
        } else if (_currentLocale == 'id') {
          stepTitle = "Ekspor Laporan 📑";
          stepDesc =
              "Gunakan tombol bagikan di atas untuk mengekspor dan mengunduh daftar pengeluaran Anda ke laporan PDF atau CSV siap-Excel.";
        } else {
          stepTitle = "Export Reports 📑";
          stepDesc =
              "Gamitin ang share button sa itaas upang i-export at i-download ang iyong listahan patungong PDF o Excel-ready CSV report.";
        }
        break;

      case 4:
        boxAlignment = Alignment.center;
        if (_currentLocale == 'en') {
          stepTitle = "Visual Trends & Goals 📊";
          stepDesc =
              "Here you can see the percentage Pie Chart, along with the Bar Report and Slider where you can shrink your target limit to save.";
        } else if (_currentLocale == 'id') {
          stepTitle = "Tren & Target Visual 📊";
          stepDesc =
              "Di sini terhampar Diagram Lingkaran persentase, serta Laporan Batang dan Slider di mana Anda dapat memperkecil batas target untuk menghemat.";
        } else {
          stepTitle = "Visual Trends & Goals 📊";
          stepDesc =
              "Dito nakalatag ang Pie Chart ng porsyento, pati ang Bar Report at Slider kung saan pwede mong paliitin ang target limit upang makatipid.";
        }
        break;

      case 5:
        boxAlignment = Alignment.bottomCenter;
        if (_currentLocale == 'en') {
          stepTitle = "History & Sorting 🔍";
          stepDesc =
              "Your transactions are listed here. You can use the gold-colored chips to sort them from highest, lowest, latest, or oldest.";
        } else if (_currentLocale == 'id') {
          stepTitle = "Riwayat & Pengurutan 🔍";
          stepDesc =
              "Daftar catatan Anda ada di sini. Anda dapat menggunakan chip berwarna emas untuk mengurutkannya dari yang tertinggi, terendah, terbaru, atau terlama.";
        } else {
          stepTitle = "History & Sorting 🔍";
          stepDesc =
              "Dito nakalista ang iyong mga entries. Pwede mong gamitin ang mga kulay-gintong chips upang i-sort ito mula sa pinakamataas o pinakababa.";
        }
        break;

      case 6:
        boxAlignment = Alignment.bottomRight;
        if (_currentLocale == 'en') {
          stepTitle = "Add Expense ➕";
          stepDesc =
              "Tap this floating circular button to log a new expense and select a custom emoji directly from your native keyboard.";
        } else if (_currentLocale == 'id') {
          stepTitle = "Tambah Pengeluaran ➕";
          stepDesc =
              "Ketuk tombol lingkaran melayang ini untuk mencatat pengeluaran baru dan memilih emoji khusus langsung dari keyboard bawaan Anda.";
        } else {
          stepTitle = "Magdagdag ng Gastos ➕";
          stepDesc =
              "I-tap ang lumulutang na bilog na button na ito para mag-encode ng bagong gastos at pumili ng custom emoji mula sa iyong native keyboard.";
        }
        break;

      default:
        return const SizedBox();
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.black.withOpacity(0.75),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: boxAlignment,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.88,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black54, blurRadius: 12, spreadRadius: 3)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars,
                          color: Color(0xFFFFD700), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(stepTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(stepDesc,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12.5, height: 1.4)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentLocale == 'en'
                            ? "Step $_currentTourStep of 6"
                            : (_currentLocale == 'id'
                                ? "Langkah $_currentTourStep dari 6"
                                : "Hakbang $_currentTourStep ng 6"),
                        style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentTourStep < 6) {
                            setState(() {
                              _currentTourStep++;
                            });
                          } else {
                            _finishDashboardInteractiveTour();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _currentTourStep == 6
                              ? (_currentLocale == 'en'
                                  ? "DONE"
                                  : (_currentLocale == 'id'
                                      ? "SELESAI"
                                      : "TAPOS"))
                              : (_currentLocale == 'en'
                                  ? "NEXT"
                                  : (_currentLocale == 'id'
                                      ? "LANJUT"
                                      : "SUNOD")),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveBarChartReport(List chartData) {
    if (chartData.isEmpty) return const SizedBox();

    if (_selectedReportCategory.isEmpty ||
        !chartData.any((e) =>
            e.title.toLowerCase().trim() ==
            _selectedReportCategory.toLowerCase().trim())) {
      _selectedReportCategory = chartData.first.title.toLowerCase().trim();
    }

    double kabuuangGastos =
        chartData.fold(0.0, (sum, item) => sum + item.total);
    double kabuuangTarget = 0.0;

    for (var item in chartData) {
      String key = item.title.toLowerCase().trim();
      double targetLimit = _customCategoryTargets[key] ?? (item.total * 0.9);
      kabuuangTarget += targetLimit;
    }

    double kabuuangMaiipon = kabuuangGastos - kabuuangTarget;

    var activeGroupedItem = chartData.firstWhere(
      (e) => e.title.toLowerCase().trim() == _selectedReportCategory,
      orElse: () => chartData.first,
    );

    String activeKey = activeGroupedItem.title.toLowerCase().trim();
    double currentSpendingVal = activeGroupedItem.total;
    double currentTargetVal =
        _customCategoryTargets[activeKey] ?? (currentSpendingVal * 0.9);

    String dynamicInsightMsg = "";
    if (currentTargetVal < currentSpendingVal) {
      // 1. CASE: NAKAKATIPID (Mas mababa ang target kaysa sa nagastos)
      double natipid = currentSpendingVal - currentTargetVal;
      dynamicInsightMsg = _currentLocale == 'tl'
          ? "Magaling! Sa pagbabawas ng gastos sa ${activeGroupedItem.title} nang ${peso(natipid)}, makakatipid ka ng karagdagang pondo."
          : (_currentLocale == 'id'
              ? "Luar biasa! Mengurangi pengeluaran ${activeGroupedItem.title} sebesar ${peso(natipid)} akan menyisakan lebih banyak dana."
              : "Awesome! Cutting down on ${activeGroupedItem.title} by ${peso(natipid)} will free up more funds.");
    } else if (currentTargetVal > currentSpendingVal) {
      // 🎯 2. CASE: HIGHER VALUE PROMPT (Mas mataas ang target limit kaysa sa totoong nagastos)
      double overAmount = currentTargetVal - currentSpendingVal;
      dynamicInsightMsg = _currentLocale == 'tl'
          ? "Babala! Ang iyong target limit ay mas mataas nang ${peso(overAmount)} kaysa sa kasalukuyang nagastos. Subukang ibaba ito."
          : (_currentLocale == 'id'
              ? "Peringatan! Target anggaran Anda lebih tinggi ${peso(overAmount)} dari pengeluaran saat ini. Coba turunkan nilainya."
              : "Allocation Warning! Your target budget is ${peso(overAmount)} higher than current spending. Try lowering it to optimize.");
    } else {
      // 3. CASE: SAKTONG PANTAY (Equal values fallback)
      dynamicInsightMsg = _currentLocale == 'tl'
          ? "Naka-set ang pondo sa normal o pantay. Subukang ibaba ang halaga upang makahanap ng pwedeng maipon."
          : (_currentLocale == 'id'
              ? "Anggaran target diatur standar atau sama. Coba turunkan nilai untuk melihat potensi hemat."
              : "Target budget is set to standard or equal. Try lowering the value to explore optimization opportunities.");
    }

    double maxBarVal = budget > 0 ? budget : 1.0;
    for (var item in chartData) {
      if (item.total > maxBarVal) maxBarVal = item.total;
    }
    final formatter = NumberFormat('#,##0', 'en_US');
    // 🔥 AUTOMATION CONTROLLER: Gumagawa ng pansamantalang controller na may fixed selection upang hindi maputol ang tinatype ng user
    // 🔥 NAITAMA: Ginamit ang commaFormat.format() para awtomatikong magkaroon ng kuwit (comma) ang value habang nilo-load
    final String textValue = _isPrivacyHideMode
        ? "••••"
        : commaFormat
            .format(currentTargetVal.toInt()); // <-- DITO ANG PAGBABAGO

    final TextEditingController targetInputCtrl =
        TextEditingController(text: textValue);
    targetInputCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: targetInputCtrl.text.length));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_isCompactMode ? 12 : 16),
      decoration: BoxDecoration(
        color: _boxBgColor,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.take(5).map<Widget>((item) {
                String itemKey = item.title.toLowerCase().trim();
                double itemTarget =
                    _customCategoryTargets[itemKey] ?? (item.total * 0.9);

                double spendBarHeight = (item.total / maxBarVal) * 110;
                double targetBarHeight = (itemTarget / maxBarVal) * 110;

                if (spendBarHeight < 5) spendBarHeight = 5;
                if (targetBarHeight < 5) targetBarHeight = 5;

                bool isItemActive = itemKey == _selectedReportCategory;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: _isCompactMode ? 10 : 14,
                            height: spendBarHeight,
                            decoration: BoxDecoration(
                              color: item.color
                                  .withValues(alpha: isItemActive ? 0.8 : 0.4),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 3),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: _isCompactMode ? 10 : 14,
                            height: targetBarHeight,
                            decoration: BoxDecoration(
                              color: isItemActive
                                  ? const Color(0xFFFFD700)
                                  : item.color,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: isItemActive
                              ? const Color(0xFFFFD700)
                              : Colors.white38,
                          fontWeight: isItemActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricsColumn(
                  _currentLocale == 'tl' ? "Kabuuang Gastos" : "Total Cost",
                  peso(kabuuangGastos),
                  Colors.white60),
              _buildMetricsColumn(
                  _currentLocale == 'tl' ? "Target na Gastos" : "Target Limit",
                  peso(kabuuangTarget),
                  const Color(0xFFFFD700)),
              _buildMetricsColumn(
                  _currentLocale == 'tl'
                      ? "Maiipon (Gains)"
                      : "Projected Gains",
                  "${kabuuangMaiipon >= 0 ? '+' : ''}${peso(kabuuangMaiipon)}",
                  kabuuangMaiipon >= 0
                      ? const Color(0xFF00E676)
                      : Colors.redAccent),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentLocale == 'tl'
                ? "Pumili ng Kategorya ng Gastos upang I-adjust:"
                : "Select Category to Optimize:",
            style: const TextStyle(
                fontSize: 11,
                color: Colors.white38,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 🔥 NAITAMA: Pinalitan ang SingleChildScrollView ng Wrap widget para awtomatikong mag-fit lahat sa screen
          Wrap(
            spacing: 6, // Agwat ng mga chips pakaliwa-pakanan (horizontal)
            runSpacing:
                6, // Agwat kapag gumulong na sa susunod na linya (vertical)
            alignment: WrapAlignment.start,
            children: chartData.map<Widget>((item) {
              String itemKey = item.title.toLowerCase().trim();
              bool isSelected = itemKey == _selectedReportCategory;
              return ChoiceChip(
                visualDensity: VisualDensity.compact,
                label: Text(item.title, style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                selectedColor: const Color(0xFFFFD700),
                labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70),
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _selectedReportCategory = itemKey;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentLocale == 'tl'
                    ? "Target na Layunin"
                    : "Adjust Optimization Target",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "${_currentLocale == 'tl' ? 'Kasalukuyan: ' : 'Current: '}${peso(currentSpendingVal)}",
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ➖ MINUS BUTTON (Tig-1 Bawas)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.remove_circle_outline,
                    color: Color(0xFFFFD700), size: 26),
                onPressed: currentTargetVal > 0
                    ? () async {
                        double newVal = currentTargetVal - 1.0;
                        if (newVal < 0) newVal = 0.0;
                        setState(() {
                          _customCategoryTargets[activeKey] = newVal;
                        });
                        final p = await SharedPreferences.getInstance();
                        await p.setString(
                            'user_custom_category_targets$activeWalletId',
                            jsonEncode(_customCategoryTargets));
                      }
                    : null,
              ),
              const SizedBox(width: 16),
// 🔥 SINKRONAYS NA MANUWAL INPUT BOX FIELD (Hindi nawawala ang focus)
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: TextFormField(
                    controller: targetInputCtrl,
                    readOnly: _isPrivacyHideMode,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700)),
                    textAlign: TextAlign.center,
                    // 🔥 NAITAMA: Pinapayagan na ang parehong numero at kuwit (comma) habang nag-ta-type
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                    ],
                    decoration: InputDecoration(
                      prefixText:
                          _isPrivacyHideMode ? "" : '$_currentCurrency ',
                      prefixStyle: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 2),
                    ),
                    onChanged: (val) async {
                      if (!_isPrivacyHideMode && val.trim().isNotEmpty) {
                        // 🔥 TAMA: Tinatanggal muna ang lahat ng kuwit bago i-parse sa double para hindi mag-error ang math
                        double typedVal =
                            double.tryParse(val.replaceAll(',', '').trim()) ??
                                0.0;
                        double maxLimit = currentSpendingVal * 1.5 == 0
                            ? 1000000.0
                            : currentSpendingVal * 1.5;
                        if (typedVal > maxLimit) typedVal = maxLimit;

                        setState(() {
                          _customCategoryTargets[activeKey] = typedVal;
                        });

                        final p = await SharedPreferences.getInstance();
                        await p.setString(
                            'user_custom_category_targets$activeWalletId',
                            jsonEncode(_customCategoryTargets));
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
// ➕ PLUS BUTTON (Tig-1 Dagdag)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.add_circle_outline,
                    color: Color(0xFFFFD700), size: 26),
                onPressed: () async {
                  double maxLimit = currentSpendingVal * 1.5 == 0
                      ? 1000000.0
                      : currentSpendingVal * 1.5;
                  double newVal = currentTargetVal + 1.0;
                  if (newVal > maxLimit) newVal = maxLimit;
                  setState(() {
                    _customCategoryTargets[activeKey] = newVal;
                  });
                  final p = await SharedPreferences.getInstance();
                  await p.setString(
                      'user_custom_category_targets$activeWalletId',
                      jsonEncode(_customCategoryTargets));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF29B6F6), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dynamicInsightMsg,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white70, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper widget para sa alignment ng matrix columns
  Widget _buildMetricsColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.white38)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  // 🔥 NAITAMA NA BERSYON: Ganap na Multilinggwal na Savings Target Popup Prompt Dialog Window Card
  void _showSetSavingsGoalDialog() {
    final goalCtrl =
        TextEditingController(text: _savingsGoalPercentage.toStringAsFixed(0));

    String popupTitle = "";
    String popupDesc = "";
    String snackSuccessMsg = "";

    if (_currentLocale == 'en') {
      popupTitle = "🎯 Set Savings Target";
      popupDesc =
          "What percentage (%) of your total budget do you want to secure as net savings?";
      snackSuccessMsg = "Savings target successfully updated!";
    } else if (_currentLocale == 'id') {
      popupTitle = "🎯 Atur Target Tabungan";
      popupDesc =
          "Berapa persentase (%) dari total anggaran yang ingin Anda amankan sebagai tabungan bersih?";
      snackSuccessMsg = "Target tabungan berhasil diperbarui!";
    } else {
      // Default ay Tagalog ('tl')
      popupTitle = "🎯 I-set ang Savings Target";
      popupDesc =
          "Ilang porsyento (%) ng kabuuang badyet ang gusto mong maitabi bilang permanenteng ipon?";
      snackSuccessMsg = "Matagumpay na na-update ang target ipon!";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          popupTitle,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              popupDesc,
              style: const TextStyle(
                  fontSize: 12, color: Colors.white54, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: goalCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700)),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                suffixText: '%',
                suffixStyle: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFFFFD700), width: 1.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTxt('btn_cancel'),
                style: const TextStyle(
                    color: Colors.white30, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              double chosenPercentage =
                  double.tryParse(goalCtrl.text.trim()) ?? 20.0;
              if (chosenPercentage > 100)
                chosenPercentage =
                    100; // Safe boundary limit protection cap roof block

              setState(() {
                _savingsGoalPercentage = chosenPercentage;
              });

              final p = await SharedPreferences.getInstance();
              await p.setDouble(
                  'user_savings_goal_percentage', chosenPercentage);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(snackSuccessMsg,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFF00E676),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(_getTxt('btn_save'),
                style: const TextStyle(
                    color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🔥 HELPER WIDGET: Tagagawa ng Automated Financial Insights at Layunin (Goals)
  Widget _buildFinancialTrendsAndGoalsCard(
      double totalGastos, double natirangBudget) {
    if (budget <= 0) return const SizedBox();

    double expensePercentage = (totalGastos / budget) * 100;
    double targetSavingsAmount = budget * (_savingsGoalPercentage / 100);
    bool isGoalAchieved = natirangBudget >= targetSavingsAmount;

    String statusTitle = "";
    String statusAdvice = "";
    Color statusColor = const Color(0xFF00E676);
    IconData statusIcon = Icons.check_circle_outline_rounded;

    if (expensePercentage == 0) {
      statusTitle =
          _currentLocale == 'tl' ? "Malinis na Simula! 🎯" : "Fresh Start! 🎯";
      statusAdvice = _currentLocale == 'tl'
          ? "Hindi mo pa nagagalaw ang iyong badyet. Target na ipon: ${peso(targetSavingsAmount)} ($_savingsGoalPercentage%)."
          : "You haven't spent anything yet. Your savings target is ${peso(targetSavingsAmount)} ($_savingsGoalPercentage%).";
    } else if (expensePercentage <= (100 - _savingsGoalPercentage)) {
      statusTitle = _currentLocale == 'tl' ? "Nasa Target! 🪙" : "On Track! 🪙";
      statusAdvice = _currentLocale == 'tl'
          ? "Maganda! Ang natitira mong pera ay pasok pa sa iyong target na ipon na ${peso(targetSavingsAmount)}."
          : "Great! Your remaining balance is secure within your personal savings goal of ${peso(targetSavingsAmount)}.";
    } else {
      statusTitle =
          _currentLocale == 'tl' ? "Alanganing Ipon ⚠️" : "Goal Endangered ⚠️";
      statusColor = Colors.orangeAccent;
      statusIcon = Icons.warning_amber_rounded;
      statusAdvice = _currentLocale == 'tl'
          ? "Babala! Lumalagpas ka na sa allowance mo. Ang natitirang pera ay mas mababa na sa target mong ipon."
          : "Warning! You have crossed your allowance buffer. Remaining funds are now below your savings goal.";
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_isCompactMode ? 12 : 16),
      decoration: BoxDecoration(
        color: _boxBgColor,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Interactive Target Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(statusIcon,
                      color: statusColor, size: _isCompactMode ? 18 : 22),
                  const SizedBox(width: 8),
                  Text(
                    statusTitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: _isCompactMode ? 12 : 14,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // 🔥 CLICKABLE SAVINGS TARGET BUTTON
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.track_changes_rounded,
                    color: Color(0xFFFFD700), size: 18),
                tooltip: _currentLocale == 'tl'
                    ? "I-set ang Target"
                    : "Set Savings Goal",
                onPressed: _showSetSavingsGoalDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusAdvice,
            style: TextStyle(
              fontSize: _isCompactMode ? 11 : 13,
              color: _appFontColor.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          // Progress bar indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentLocale == 'tl'
                    ? "Bilis ng Paggastos (Velocity)"
                    : "Spending Velocity",
                style: TextStyle(
                    fontSize: _isCompactMode ? 10 : 11, color: Colors.white38),
              ),
              Text(
                _isPrivacyHideMode
                    ? '••%'
                    : '${expensePercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: _isCompactMode ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: expensePercentage > 100 ? 1.0 : (expensePercentage / 100),
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: _isCompactMode ? 5 : 7,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Preset list ng mga icons na madaling piliin ng user
  final Map<String, IconData> presetIcons = {
    "payments": Icons.payments,
    "fastfood": Icons.fastfood,
    "directions_car": Icons.directions_car,
    "shopping_bag": Icons.shopping_bag,
    "home": Icons.home,
    "movie": Icons.movie,
    "medical_services": Icons.medical_services,
    "school": Icons.school,
    "flight": Icons.flight,
    "electrical_services": Icons.electrical_services,
    "fitness_center": Icons.fitness_center,
    "card_giftcard": Icons.card_giftcard,
    "local_laundry_service": Icons.local_laundry_service,
    "construction": Icons.construction,
  };

  // 🔥 Helper para makuha ang IconData mula sa pangalan nito
  IconData _getIconData(String name) {
    return presetIcons[name] ?? Icons.payments;
  }

  // 🔥 HELPER WIDGET PARA SA HINDI NAPIPITPIT NA SORT CHIPS
  Widget _buildSortChip(
      {required String filterValue,
      required IconData icon,
      required String label}) {
    final bool isSelected = _activeSortFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeSortFilter = filterValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : _boxBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white10,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Kinukuha lang ang saktong haba ng text
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.black : const Color(0xFFFFD700),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.black
                    : Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Bottom Sheet Interface para sa pagpili ng Icon
  void _openIconPickerSheet(Function(String) onIconSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Text(
                _currentLocale == 'tl' ? 'PUMILI NG ICON' : 'SELECT ITEM ICON',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700)),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: presetIcons.length,
                  itemBuilder: (context, index) {
                    String key = presetIcons.keys.elementAt(index);
                    IconData icon = presetIcons[key]!;
                    return InkWell(
                      onTap: () {
                        onIconSelected(key);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon,
                            color: const Color(0xFFFFD700), size: 28),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final Map<String, Map<String, String>> _localizedText = {
    'en': {
      'total_budget': 'TOTAL BUDGET',
      'total_expenses': 'TOTAL EXPENSES',
      'remaining_budget': 'REMAINING BUDGET',
      'chart_title': 'Visual Expense Chart',
      'history_title': 'Expense Entry History',
      'no_items': 'No encoded expenses. Tap + below!',
      'search_hint': 'Search category (e.g., Food)...',
      'search_disabled_hint': 'Search disabled (Trial Expired)',
      'no_match': 'No matching category found.',
      'add_expense': 'Add Expense',
      'edit_expense': 'Edit Entry',
      'category_label': 'Category (e.g., Food)',
      'amount_label': 'Amount / Cost',
      'date_label': 'Transaction Date',
      'filter_all': 'All',
      'filter_today': 'Today',
      'btn_cancel': 'Cancel',
      'btn_save': 'Save',
      'btn_update': 'Update',
      'btn_add': 'Add',
      'wallet_manager': 'YOUR WALLETS',
      'btn_add_wallet': 'ADD NEW WALLET',
      'reset_data': 'Reset App Data',
      'reset_subtitle': 'Will delete all app data..',
      'upgrade_title': 'Upgrade to PRO version',
      'upgrade_subtitle': 'To unlock all features',
      'no_exp_err': 'No expenses to export!',
      'file_sheet_web_warn':
          'The file sharing sheet only works when installed on a physical phone!',
      'csv_hdr_wallet': 'Wallet Name',
      'csv_hdr_budget': 'Current Budget',
      'csv_hdr_id': 'Expense ID',
      'csv_hdr_cat': 'Category / Title',
      'csv_hdr_amt': 'Amount',
      'csv_hdr_date': 'Date and Time',
      'csv_share_txt': 'Here is my export file from the Gastos Ko App!',
      'csv_err': 'Error exporting data: ',
      'billing_err': 'Transaction error. Please try again.',
      'billing_success': 'Thank you! Your PRO Activation was successful! 🎉',
      'google_store_err': 'Product from Google Store is not ready yet.',
      'congrats_title': 'CONGRATULATIONS!',
      'congrats_desc':
          'Your new wallet "{name}" has been created with a budget of {budget}.',
      'email_app_err': 'No email app found or could not be opened.',
      'email_open_err': 'Error opening email app: ',
      'edit_wallet_title': 'Edit Name: {name}',
      'new_budget_lbl': 'New Wallet Name',
      'add_fund_title': 'Add Funds: {name}',
      'current_budget_lbl': 'Current Budget: ',
      'add_fund_lbl': 'How much to add?',
      'add_fund_success': 'Successfully added {amount} to your budget!',
      'btn_add_fund': 'ADD',
      'main_wallet_del_err': '⚠️ Cannot delete the Main Wallet!',
      'del_wallet_title': 'Delete Wallet?',
      'del_wallet_desc':
          'Are you sure? The wallet "{name}" and ALL its expense history will be permanently lost from the database!',
      'btn_delete': 'DELETE',
      'no_wallet_found': 'No wallets found.',
      'add_fund_tooltip': 'Manage Funds',
      'edit_wallet_tooltip': 'Edit Name or Currency',
      'del_wallet_tooltip': 'Delete Wallet',
      'create_wallet_title': 'Create New Wallet',
      'wallet_name_lbl': 'Wallet Name (e.g., Salary)',
      'wallet_budget_lbl': 'How much is the budget?',
      'near_limit_title': 'NEARLY EXHAUSTED!',
      'near_limit_desc':
          'Warning! You have spent over 90% of your budget!\n\nAdded Amount: {amount}\n\nYour Maximum Budget is only {budget}.',
      'btn_near_limit': 'I CAN HANDLE IT',
      'exhausted_title': 'BUDGET EXHAUSTED!',
      'exhausted_desc': 'Your budget is completely used up. Add funds or not?',
      'btn_no': 'NO',
      'pre_add_budget_title': 'Please add a budget first!',
      'btn_set_budget': 'SET BUDGET',
      'pro_plan_title': 'SELECT A PRO PLAN',
      'pro_plan_desc':
          'Choose the right package. Supports GCash, Cards, etc. via Google Play Console Secure Checkout.',
      'lang_lbl': 'App Language',
      'reset_confirm_title': 'Reset all data?',
      'reset_confirm_desc':
          'Are you sure? This will delete all your saved data including your PIN code.',
      'btn_reset': 'RESET',
      'edit_entry_tooltip': 'Edit entry',
      'del_entry_tooltip': 'Delete entry',
      'settings_menu_lbl': 'Settings',
      'preset_themes_lbl': 'Preset Color Themes',
    },
    'tl': {
      'total_budget': 'TOTAL BADGET',
      'total_expenses': 'TOTAL GASTOS',
      'remaining_budget': 'NATITIRANG BADGET',
      'chart_title': 'Gastos Biswal Chart',
      'history_title': 'History ng mga Ginastos',
      'no_items': 'Walang pang ginastos. I-tap ang + sa ibaba!',
      'search_hint': 'Maghanap ng kategorya (e.g. Pagkain)...',
      'search_disabled_hint': 'Bawal maghanap (Expired na ang Trial)',
      'no_match': 'Walang nahanap na tugmang kategorya.',
      'add_expense': 'Magdagdag ng Gastos',
      'edit_expense': 'I-Edit ang Entry',
      'category_label': 'Kategorya (e.g. Pagkain)',
      'amount_label': 'Magkano / Halaga',
      'date_label': 'Petsa ng Transaksyon',
      'filter_all': 'Lahat',
      'filter_today': 'Ngayon',
      'btn_cancel': 'I-Kansela',
      'btn_save': 'I-Save',
      'btn_update': 'I-Update',
      'btn_add': 'Idagdag',
      'wallet_manager': 'IYONG MGA PITAKA',
      'btn_add_wallet': 'MAGDAGDAG',
      'reset_data': 'I-Reset ang App',
      'reset_subtitle': 'Buburahin lahat ng datos.',
      'upgrade_title': 'Mag-upgrade sa PRO version',
      'upgrade_subtitle': 'Para ma-unlock ang lahat ng features',
      'no_exp_err': 'Walang mga gastos na maie-export!',
      'file_sheet_web_warn':
          'Ang file sharing sheet ay gumagana lang kapag naka-install na sa totoong CP!',
      'csv_hdr_wallet': 'Pangalan ng Wallet',
      'csv_hdr_budget': 'Kasalukuyang Badyet',
      'csv_hdr_id': 'ID ng Gastos',
      'csv_hdr_cat': 'Kategorya / Pamagat',
      'csv_hdr_amt': 'Halaga',
      'csv_hdr_date': 'Petsa at Oras',
      'csv_share_txt': 'Narito ang aking export file galing sa Gastos Ko App!',
      'csv_err': 'May error sa pag-export: ',
      'billing_err': 'May error sa transaksyon. Subukan muli.',
      'billing_success': 'Salamat! Matagumpay ang iyong PRO Activation! 🎉',
      'google_store_err': 'Hindi pa handa ang produkto mula sa Google Store.',
      'congrats_title': 'MAHUSAY!',
      'congrats_desc':
          'Ang iyong bagong wallet "{name}" ay nagawa na at may budget na {budget}.',
      'email_app_err': 'Walang nahanap na email app o hindi mabuksan.',
      'email_open_err': 'May error sa pagbubukas ng email app: ',
      'edit_wallet_title': 'I-edit Pangalan: {name}',
      'new_budget_lbl': 'Bagong Pangalan ng Wallet',
      'add_fund_title': 'Magdagdag Pondo: {name}',
      'current_budget_lbl': 'Kasalukuyang Budget: ',
      'add_fund_lbl': 'Magkano ang idadagdag?',
      'add_fund_success':
          'Matagumpay na nakapagdagdag ng {amount} sa iyong budget!',
      'btn_add_fund': 'I-DAGDAG',
      'main_wallet_del_err': '⚠️ Hindi pwedeng burahin ang Main Wallet!',
      'del_wallet_title': 'Burahin ang Wallet?',
      'del_wallet_desc':
          'Sigurado ka ba? Permanenteng mawawala ang wallet na "{name}" pati ang LAHAT ng history ng expenses nito sa database!',
      'btn_delete': 'I-DELETE',
      'no_wallet_found': 'Walang nahanap na wallet.',
      'add_fund_tooltip': 'I-manage ang Pondo',
      'edit_wallet_tooltip': 'I-edit ang Pangalan o Pera',
      'del_wallet_tooltip': 'Burahin ang Wallet',
      'create_wallet_title': 'Gumawa ng Bagong Wallet',
      'wallet_name_lbl': 'Pangalan ng Wallet (e.g. Sweldo)',
      'wallet_budget_lbl': 'Magkano ang Budget?',
      'near_limit_title': 'MALAPIT NA MAUBOS!',
      'near_limit_desc':
          'Babala! nasa mahigit 90% na ang iyong nagagastos!\n\nIdaragdag na Halaga: {amount}\n\nAng iyong Maximum Budget lamang ay {budget}.',
      'btn_near_limit': 'KAYANG-KAYA PA',
      'exhausted_title': 'UBOS NA ANG BUDGET!',
      'exhausted_desc': 'Ubos na ang iyong budget. Magdagdag o hindi?',
      'btn_no': 'HINDI',
      'pre_add_budget_title': 'Mag-add ka muna ng budget!',
      'btn_set_budget': 'I-SET BUDGET',
      'pro_plan_title': 'PUMILI NG PRO PLAN',
      'pro_plan_desc':
          'Piliin ang tamang package. Sinusuportahan nito ang GCash, Cards, atbp. sa pamamagitan ng Google Play Console Secure Checkout.',
      'lang_lbl': 'Wika ng App',
      'reset_confirm_title': 'I-reset lahat ng data?',
      'reset_confirm_desc':
          'Sigurado ka ba? Buburahin nito ang lahat ng na-save mong data pati ang iyong PIN code.',
      'btn_reset': 'I-RESET',
      'edit_entry_tooltip': 'I-edit ang entry',
      'del_entry_tooltip': 'Burahin ang entry',
      'settings_menu_lbl': 'Mga Setting',
      'preset_themes_lbl': 'Mga Preset Color Theme',
    },
    'id': {
      'total_budget': 'ANGGARAN',
      'total_expenses': 'PENGELUARAN',
      'remaining_budget': 'SISA ANGGARAN',
      'chart_title': 'Grafik Pengeluaran Visual',
      'history_title': 'Riwayat Catatan Pengeluaran',
      'no_items': 'Belum ada pengeluaran. Ketuk + di bawah!',
      'search_hint': 'Cari kategori (misal: Makanan)...',
      'search_disabled_hint':
          'Pencarian dinonaktifkan (Masa Uji Coba Berakhir)',
      'no_match': 'Kategori yang cocok tidak ditemukan.',
      'add_expense': 'Tambah Pengeluaran',
      'edit_expense': 'Ubah Catatan',
      'category_label': 'Kategori (misal: Makanan)',
      'amount_label': 'Jumlah / Biaya',
      'date_label': 'Tanggal Transaksi',
      'filter_all': 'Semua',
      'filter_today': 'Hari Ini',
      'btn_cancel': 'Batal',
      'btn_save': 'Simpan',
      'btn_update': 'Perbarui',
      'btn_add': 'Tambah',
      'wallet_manager': 'DOMPET ANDA',
      'btn_add_wallet': 'TAMBAH DOMPET BARU',
      'reset_data': 'Atur Ulang Data Aplikasi',
      'reset_subtitle': 'Akan menghapus semua data aplikasi.',
      'upgrade_title': 'Upgrade ke versi PRO',
      'upgrade_subtitle': 'Untuk membuka semua fitur',
      'no_exp_err': 'Tidak ada pengeluaran untuk diekspor!',
      'file_sheet_web_warn':
          'Lembar berbagi file hanya berfungsi jika diinstal pada ponsel fisik!',
      'csv_hdr_wallet': 'Nama Dompet',
      'csv_hdr_budget': 'Anggaran Saat Ini',
      'csv_hdr_id': 'ID Pengeluaran',
      'csv_hdr_cat': 'Kategori / Judul',
      'csv_hdr_amt': 'Jumlah',
      'csv_hdr_date': 'Tanggal dan Waktu',
      'csv_share_txt': 'Ini adalah file ekspor saya dari Aplikasi Gastos Ko!',
      'csv_err': 'Kesalahan saat mengekspor data: ',
      'billing_err': 'Kesalahan transaksi. Silakan coba lagi.',
      'billing_success': 'Terima kasih! Aktivasi PRO Anda berhasil! 🎉',
      'google_store_err': 'Produk dari Google Store belum siap.',
      'congrats_title': 'SELAMAT!',
      'congrats_desc':
          'Dompet baru Anda "{name}" telah dibuat dengan anggaran {budget}.',
      'email_app_err':
          'Aplikasi email tidak ditemukan atau tidak dapat dibuka.',
      'email_open_err': 'Kesalahan saat membuka aplikasi email: ',
      'edit_wallet_title': 'Ubah Nama: {name}',
      'new_budget_lbl': 'Nama Dompet Baru',
      'add_fund_title': 'Tambah Dana: {name}',
      'current_budget_lbl': 'Anggaran Saat Ini: ',
      'add_fund_lbl': 'Berapa banyak yang ingin ditambahkan?',
      'add_fund_success': 'Berhasil menambahkan {amount} ke anggaran Anda!',
      'btn_add_fund': 'TAMBAH',
      'main_wallet_del_err': '⚠️ Tidak dapat menghapus Dompet Utama!',
      'del_wallet_title': 'Hapus Dompet?',
      'del_wallet_desc':
          'Apakah Anda yakin? Dompet "{name}" dan SEMUA riwayat pengeluarannya akan hilang permanen dari database!',
      'btn_delete': 'HAPUS',
      'no_wallet_found': 'Dompet tidak ditemukan.',
      'add_fund_tooltip': 'Mengelola Dana',
      'edit_wallet_tooltip': 'Ubah Nama atau Mata Uang',
      'del_wallet_tooltip': 'Hapus Dompet',
      'create_wallet_title': 'Buat Dompet Baru',
      'wallet_name_lbl': 'Nama Dompet (misal: Gaji)',
      'wallet_budget_lbl': 'Berapa jumlah anggarannya?',
      'near_limit_title': 'HAMPIR HABIS!',
      'near_limit_desc':
          'Peringatan! Anda telah menghabiskan lebih dari 90% anggaran Anda!\n\nJumlah yang Ditambahkan: {amount}\n\nAnggaran Maksimum Anda hanya {budget}.',
      'btn_near_limit': 'SAYA BISA MENGATASINYA',
      'exhausted_title': 'ANGGARAN HABIS!',
      'exhausted_desc':
          'Anggaran Anda benar-benar habis. Tambah dana atau tidak?',
      'btn_no': 'TIDAK',
      'pre_add_budget_title': 'Silakan tambahkan anggaran terlebih dahulu!',
      'btn_set_budget': 'ATUR ANGGARAN',
      'pro_plan_title': 'PILIH PAKET PRO',
      'pro_plan_desc':
          'Pilih paket yang tepat. Mendukung GCash, Kartu, dll. via Pembayaran Aman Google Play Console.',
      'lang_lbl': 'Bahasa Aplikasi',
      'reset_confirm_title': 'Atur ulang semua data?',
      'reset_confirm_desc':
          'Apakah Anda yakin? Ini akan menghapus semua data Anda yang tersimpan termasuk kode PIN Anda.',
      'btn_reset': 'ATUR ULANG',
      'edit_entry_tooltip': 'Ubah catatan',
      'del_entry_tooltip': 'Hapus catatan',
      'settings_menu_lbl': 'Pengaturan',
      'preset_themes_lbl': 'Preset Tema Warna',
    },
  };
  String _getTxt(String key) {
    return _localizedText[_currentLocale]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadData();
    _checkPremiumAndTrialState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((Duration timestamp) {
        _initializeBilling();
      });
    } else {
      setState(() {
        _isPremiumUser = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _bgSessionTimer?.cancel();
      _bgSessionTimer = Timer(_sessionTimeoutDuration, () {
        _lockAppSession();
      });
    } else if (state == AppLifecycleState.resumed) {
      _bgSessionTimer?.cancel();
    }
  }

  void _lockAppSession() {
    if (!mounted) return;
    SharedPreferences.getInstance().then((p) {
      String? installDateStr = p.getString('app_install_date');
      bool isExpired = false;
      if (installDateStr != null) {
        DateTime installDate = DateTime.parse(installDateStr);
        int daysUsed = DateTime.now().difference(installDate).inDays;
        bool isPremium = p.getBool('is_premium_user') ?? false;
        if (daysUsed >= 30 && !isPremium) {
          isExpired = true;
        }
      }
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => PinCodeScreen(
                  isRegistration: false, isTrialExpiredMode: isExpired)),
          (route) => false,
        );
      }
    });
  }

  void _openCurrencySearchPicker(Function(Map<String, String>) onSelected) {
    String searchKeyword = "";
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Sinasala ang mga bansa, code, o pangalan ng pera base sa tinype ni user
            final filteredList = globalCurrencies.where((c) {
              final query = searchKeyword.toLowerCase();
              return c["country"]!.toLowerCase().contains(query) ||
                  c["code"]!.toLowerCase().contains(query) ||
                  c["name"]!.toLowerCase().contains(query);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    16, // Iniiwasang matakpan ng keyboard
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Text(
                    _currentLocale == 'tl'
                        ? 'PUMILI NG CURRENCY'
                        : (_currentLocale == 'id'
                            ? 'PILIH MATA UANG'
                            : 'SELECT CURRENCY'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700)),
                  ),
                  const SizedBox(height: 12),
                  // 🔥 ANG SEARCH BAR
                  TextField(
                    autofocus: true,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _currentLocale == 'tl'
                          ? 'Maghanap ng bansa o currency...'
                          : 'Search country or currency...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFFFFD700), size: 20),
                      filled: true,
                      fillColor: const Color(0xFF252525),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFFFD700), width: 1)),
                    ),
                    onChanged: (val) {
                      setSheetState(() {
                        searchKeyword = val.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: filteredList.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                                child: Text("No country found.",
                                    style: TextStyle(color: Colors.white38))),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredList.length,
                            itemBuilder: (context, idx) {
                              final item = filteredList[idx];
                              return ListTile(
                                dense: true,
                                leading: Text(item["symbol"]!,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFD700))),
                                title: Text(
                                    "${item["country"]} (${item["code"]})",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(item["name"]!,
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 12)),
                                onTap: () {
                                  onSelected(item);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _initializeBilling() {
    if (kIsWeb) return;
    final Stream purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint("Billing engine bridge error: $error");
    });
    _loadProductsFromGoogleConsole();
  }

  Future _loadProductsFromGoogleConsole() async {
    if (kIsWeb) return;
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) return;
    final Set kIds = {
      'gastos_ko_monthly',
      'gastos_ko_semiannual',
      'gastos_ko_annual',
    };
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(kIds.cast());
    if (response.notFoundIDs.isEmpty) {
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  Future<void> _exportWalletToCSV(List filteredList) async {
    if (_isTrialExpired && !_isPremiumUser) {
      _showUpgradeOptionsBottomSheet();
      return;
    }
    if (filteredList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTxt('no_exp_err'))),
      );
      return;
    }

    // Prompt Box
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          _currentLocale == 'tl'
              ? 'I-export ang Listahan?'
              : (_currentLocale == 'id'
                  ? 'Ekspor Daftar?'
                  : 'Export Current List?'),
          style: const TextStyle(
              color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
        ),
        content: Text(
          _currentLocale == 'tl'
              ? 'I-eexport ang kasalukuyang ${filteredList.length} items sa listahan patungong CSV file. Ituloy?'
              : (_currentLocale == 'id'
                  ? 'Ekspor ${filteredList.length} item saat ini di daftar ke file CSV. Lanjutkan?'
                  : 'This will export the current ${filteredList.length} items in the list to a CSV file. Proceed?'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_getTxt('btn_cancel'),
                style: const TextStyle(color: Colors.white30)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _currentLocale == 'tl'
                  ? 'ITULOY'
                  : (_currentLocale == 'id' ? 'LANJUTKAN' : 'PROCEED'),
              style: const TextStyle(
                  color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getTxt('file_sheet_web_warn')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      String activeWalletName = "Main Wallet";
      double activeWalletBudget = budget;
      for (var w in wallets) {
        if (w.id == activeWalletId) {
          activeWalletName = w.name;
          activeWalletBudget = w.budget;
          break;
        }
      }

      // 🛠️ KALKULASYON NG KABUUANG GASTOS AT NATITIRANG BADYET
      final double totalExpenses =
          filteredList.fold(0.0, (sum, item) => sum + item.amount);
      final double remainingBudget = activeWalletBudget - totalExpenses;

      List<List> csvRows = [
        [
          _getTxt('csv_hdr_wallet'),
          _currentLocale == 'tl'
              ? 'Badyet ng Wallet ($_currentCurrency)'
              : (_currentLocale == 'id'
                  ? 'Anggaran Dompet ($_currentCurrency)'
                  : 'Wallet Budget ($_currentCurrency)'),
          // 🔥 IDINAGDAG ANG HEADER NG REMAINING BUDGET SA CSV
          _currentLocale == 'tl'
              ? 'Natitirang Budget ($_currentCurrency)'
              : (_currentLocale == 'id'
                  ? 'Sisa Anggaran ($_currentCurrency)'
                  : 'Remaining Budget ($_currentCurrency)'),
          _getTxt('csv_hdr_id'),
          _getTxt('csv_hdr_cat'),
          _currentLocale == 'tl'
              ? 'Halaga ($_currentCurrency)'
              : (_currentLocale == 'id'
                  ? 'Jumlah ($_currentCurrency)'
                  : 'Amount ($_currentCurrency)'),
          _getTxt('csv_hdr_date')
        ]
      ];

      for (var expense in filteredList) {
        csvRows.add([
          activeWalletName,
          activeWalletBudget,
          remainingBudget, // 🔥 IDINAGDAG ANG DATA NG REMAINING BUDGET SA ROW
          expense.id,
          expense.title,
          expense.amount,
          DateFormat('yyyy-MM-dd hh:mm a').format(expense.date),
        ]);
      }

      String csvData = '\uFEFF' + const ListToCsvConverter().convert(csvRows);
      final directory = await getTemporaryDirectory();
      String cleanFileName =
          activeWalletName.replaceAll(RegExp(r'[^\w\s]+'), '');
      final String filePath =
          '${directory.path}/GastosKo${cleanFileName}_Export.csv';
      final File file = File(filePath);
      await file.writeAsString(csvData, encoding: utf8);
      final XFile xFile = XFile(filePath);
      await Share.shareXFiles([xFile], text: _getTxt('csv_share_txt'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${_getTxt('csv_err')}$e")),
        );
      }
    }
  }

  Future<void> _exportWalletToPDF(List filteredList) async {
    final bool trialExpiredWithNoPremium = _isTrialExpired && !_isPremiumUser;
    if (trialExpiredWithNoPremium) {
      _showUpgradeOptionsBottomSheet();
      return;
    }
    if (filteredList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_currentLocale == 'tl'
              ? 'Walang mga gastos na maie-export!'
              : (_currentLocale == 'id'
                  ? 'Tidak ada pengeluaran untuk diekspor!'
                  : 'No expenses to export!')),
        ),
      );
      return;
    }

    // Confirm Dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          _currentLocale == 'tl'
              ? 'I-export ang Listahan?'
              : (_currentLocale == 'id'
                  ? 'Ekspor Daftar?'
                  : 'Export Current List?'),
          style: const TextStyle(
              color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
        ),
        content: Text(
          _currentLocale == 'tl'
              ? 'I-eexport ang kasalukuyang ${filteredList.length} items sa listahan patungong PDF file. Ituloy?'
              : (_currentLocale == 'id'
                  ? 'Ekspor ${filteredList.length} item saat ini di daftar ke file PDF. Lanjutkan?'
                  : 'This will export the current ${filteredList.length} items in the list to a PDF file. Proceed?'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_getTxt('btn_cancel'),
                style: const TextStyle(color: Colors.white30)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _currentLocale == 'tl'
                  ? 'ITULOY'
                  : (_currentLocale == 'id' ? 'LANJUTKAN' : 'PROCEED'),
              style: const TextStyle(
                  color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      String activeWalletName = "Main Wallet";
      for (var w in wallets) {
        if (w.id == activeWalletId) {
          activeWalletName = w.name;
          break;
        }
      }

      final pdf = pw.Document();
      final hWallet = _currentLocale == 'tl'
          ? 'Wallet'
          : (_currentLocale == 'id' ? 'Dompet' : 'Wallet');
      final hCategory = _currentLocale == 'tl'
          ? 'Kategorya'
          : (_currentLocale == 'id' ? 'Kategori' : 'Category');
      final hAmount = _currentLocale == 'tl'
          ? 'Halaga'
          : (_currentLocale == 'id' ? 'Jumlah' : 'Amount');
      final hDate = _currentLocale == 'tl'
          ? 'Petsa'
          : (_currentLocale == 'id' ? 'Tanggal' : 'Date');
      final reportTitle = _currentLocale == 'tl'
          ? 'ULAT NG GASTOS'
          : (_currentLocale == 'id' ? 'LAPORAN PENGELUARAN' : 'EXPENSE REPORT');

      String formatPdfCurrency(double value) {
        String originalFormatted = peso(value);
        if (_currentCurrency == 'PHP' || _currentCurrency == '₱') {
          final rawNumbers = originalFormatted
              .replaceAll(RegExp(r'[^\d.,-]'), '')
              .trim(); // Pinapayagan ang negative sign kung lumampas sa budget
          return 'P$rawNumbers';
        }
        return originalFormatted;
      }

      // 🛠️ KALKULASYON NG MGA DETALYE NG BUDGET
      final double totalExpenses =
          filteredList.fold(0.0, (sum, item) => sum + item.amount);
      final double remainingBudget = budget - totalExpenses;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(reportTitle,
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(activeWalletName.toUpperCase(),
                        style: pw.TextStyle(
                            fontSize: 14, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              // 🔥 BINAGONG BAHAGI: Naka-Row at Column para malinis tingnan ang tatlong detalye
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                          '${_currentLocale == 'tl' ? 'Kabuuang Budget' : (_currentLocale == 'id' ? 'Total Anggaran' : 'Total Budget')}: ${formatPdfCurrency(budget)}'),
                      pw.Text(
                          '${_currentLocale == 'tl' ? 'Kabuuang Gastos' : (_currentLocale == 'id' ? 'Total Pengeluaran' : 'Total Expenses')}: ${formatPdfCurrency(totalExpenses)}'),
                    ],
                  ),
                  // 🔥 IDINAGDAG NA NATITERANG BADYET
                  pw.Text(
                    '${_currentLocale == 'tl' ? 'Natitirang Budget' : (_currentLocale == 'id' ? 'Sisa Anggaran' : 'Remaining Budget')}: ${formatPdfCurrency(remainingBudget)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: remainingBudget < 0
                            ? PdfColors.red
                            : PdfColors.green),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [hWallet, hCategory, hAmount, hDate],
                data: filteredList.map((expense) {
                  return [
                    activeWalletName,
                    expense.title,
                    formatPdfCurrency(expense.amount),
                    DateFormat('yyyy-MM-dd hh:mm a').format(expense.date),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'GastosKo_${activeWalletName}_Report',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Error: $e')),
        );
      }
    }
  }

  void _listenToPurchaseUpdated(List purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_getTxt('billing_err'))),
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          String recognizedPlan = "Premium Plan";
          if (purchaseDetails.productID == 'gastos_ko_monthly') {
            recognizedPlan = "Monthly Plan";
          }
          if (purchaseDetails.productID == 'gastos_ko_semiannual') {
            recognizedPlan = "Semi-Annual Plan";
          }
          if (purchaseDetails.productID == 'gastos_ko_annual') {
            recognizedPlan = "Annual Plan";
          }
          _markAsPremiumUserFromSystem(recognizedPlan);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future _markAsPremiumUserFromSystem(String planName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium_user', true);
    await prefs.setString('purchased_plan_title', planName);
    setState(() {
      _isPremiumUser = true;
      _isTrialExpired = false;
      _purchasedPlanTitle = planName;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTxt('billing_success'))),
      );
    }
  }

  void _buyPlan(String productId) {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTxt('google_store_err'))),
      );
      return;
    }
    ProductDetails product = _products.firstWhere(
      (element) => element.id == productId,
      orElse: () => _products.first,
    );
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future _checkPremiumAndTrialState() async {
    final p = await SharedPreferences.getInstance();
    String? installDateStr = p.getString('app_install_date');
    int calculatedLeft = 30;
    bool expired = false;
    bool isPremium = kIsWeb ? false : (p.getBool('is_premium_user') ?? false);
    if (installDateStr != null) {
      DateTime installDate = DateTime.parse(installDateStr);
      int daysUsed = DateTime.now().difference(installDate).inDays;
      calculatedLeft = 30 - daysUsed;
      if (calculatedLeft <= 0) {
        calculatedLeft = 0;
        if (!isPremium) {
          expired = true;
        }
      }
    }
    String deviceLanguage =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    String defaultLocale = 'en';
    if (deviceLanguage == 'tl' || deviceLanguage == 'fil') {
      defaultLocale = 'tl';
    } else if (deviceLanguage == 'id') {
      defaultLocale = 'id';
    }
    setState(() {
      _isPremiumUser = isPremium;
      String tempLocale = p.getString('app_lang_locale') ?? defaultLocale;
      if (tempLocale != 'en' && tempLocale != 'tl' && tempLocale != 'id') {
        _currentLocale = defaultLocale;
      } else {
        _currentLocale = tempLocale;
      }
      _trialDaysLeft = calculatedLeft;
      _isTrialExpired = expired;
      _purchasedPlanTitle = p.getString('purchased_plan_title') ?? "Pro Plan";
      int? savedBgColorValue = p.getInt('app_background_color_value');
      _appBgColor = savedBgColorValue != null
          ? Color(savedBgColorValue)
          : const Color(0xFF121212);
      int? savedFontColorValue = p.getInt('app_font_color_value');
      _appFontColor = savedFontColorValue != null
          ? Color(savedFontColorValue)
          : Colors.white;
      int? savedBoxColorValue = p.getInt('app_box_color_value');
      _boxBgColor = savedBoxColorValue != null
          ? Color(savedBoxColorValue)
          : const Color(0xFF1E1E1E);
      if (expired) {
        activeWalletId = "default";
      }
    });
    if (expired) {
      loadData();
    }
  }

  Future loadData() async {
    final p = await SharedPreferences.getInstance();
    String deviceLanguage =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    String? deviceRegion =
        PlatformDispatcher.instance.locale.countryCode?.toUpperCase();

    String defaultLocale = 'en';
    if (deviceLanguage == 'tl' || deviceLanguage == 'fil') {
      defaultLocale = 'tl';
    } else if (deviceLanguage == 'id') {
      defaultLocale = 'id';
    }

    setState(() {
      _loadDebtsData();
      _isPrivacyHideMode = p.getBool('user_privacy_hide_mode') ?? false;

      // 1. I-load ang locale (wika) na ligtas
      String tempLocale = p.getString('app_lang_locale') ?? defaultLocale;
      if (tempLocale != 'en' && tempLocale != 'tl' && tempLocale != 'id') {
        _currentLocale = defaultLocale;
      } else {
        _currentLocale = tempLocale;
      }

      _savingsGoalPercentage =
          p.getDouble('user_savings_goal_percentage') ?? 20.0;

      // DYNAMIC RE-ALIGNMENT: Kalkulahin ang backup fallback currency base sa wika
      String initialCurrency = "\$";
      if (_currentLocale == 'tl') initialCurrency = "₱";
      if (_currentLocale == 'id') initialCurrency = "Rp";

      // 2. I-load ang wallets data
      String? wData = p.getString('app_wallets');
      if (wData != null) {
        List l = jsonDecode(wData);
        wallets = l.map((e) => AppWallet.fromJson(e)).toList();
      } else {
        wallets = [
          AppWallet(
              id: "default",
              name: "Main Wallet",
              budget: 0.0,
              currency: initialCurrency)
        ];
      }

      activeWalletId = _isTrialExpired
          ? "default"
          : (p.getString('active_wallet_id') ?? "default");

      AppWallet? selectedWallet;
      for (var w in wallets) {
        if (w.id == activeWalletId) {
          selectedWallet = w;
          break;
        }
      }

      AppWallet activeWallet = selectedWallet ??
          (wallets.isNotEmpty
              ? wallets.first
              : AppWallet(
                  id: "default",
                  name: "Main Wallet",
                  budget: 0.0,
                  currency: initialCurrency));

      activeWalletId = activeWallet.id;
      budget = activeWallet.budget;
      _currentCurrency = activeWallet.currency;

      String? goalsData = p.getString('app_savings_goals');
      if (goalsData != null) {
        List parsedList = jsonDecode(goalsData);
        savingsGoals = parsedList.map((e) => SavingsGoal.fromJson(e)).toList();
      } else {
        savingsGoals = []; // Magsisimulang blangko kung fresh install
      }

      String? savedTargets =
          p.getString('user_custom_category_targets_$activeWalletId');
      if (savedTargets != null) {
        Map<String, dynamic> decoded = jsonDecode(savedTargets);
        _customCategoryTargets = decoded
            .map((key, value) => MapEntry(key, (value as num).toDouble()));
      } else {
        _customCategoryTargets.clear();
      }

      // 3. I-LOAD ANG EXPENSES AT I-RESTORE ANG COLOR MAP PARA SA MGA KATEGORYA
      // 3. I-LOAD ANG EXPENSES AT I-RESTORE ANG COLOR MAP PARA SA MGA KATEGORYA
      String? d = p.getString('expenses$activeWalletId');
      if (d != null) {
        List l = jsonDecode(d);
        all = l.map((e) => Expense.fromJson(e)).toList();

        colorMap.clear();
        for (var item in all) {
          String key = item.title.toLowerCase().trim();
          if (!colorMap.containsKey(key)) {
            colorMap[key] =
                dynamicColors[colorMap.length % dynamicColors.length];
          }
          item.color = colorMap[key]!;

          // Siguraduhing may fallback emoji kung sakaling blangko ang na-load sa memory
          if (item.iconEmoji.isEmpty) {
            item.iconEmoji = "💰";
          }
        }
      } else {
        all.clear();
        colorMap.clear();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();
        bool mainTourDone =
            prefs.getBool('is_main_dashboard_tour_done') ?? false;
        if (!mainTourDone && mounted && !_isInteractiveTourActive) {
          _showStartTourPromptDialog();
        }
      });
    });
  }

  Future saveData() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('app_lang_locale', _currentLocale);
    await p.setString(
        'app_currency_symbol', _currentCurrency); // I-save ang currency
    await p.setString(
        'app_wallets', jsonEncode(wallets.map((w) => w.toJson()).toList()));
    await p.setString('active_wallet_id', activeWalletId);
    await p.setString('expenses$activeWalletId',
        jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  void _switchWallet(String id) async {
    if (_isTrialExpired && !_isPremiumUser) return;
    final p = await SharedPreferences.getInstance();
    await p.setString('active_wallet_id', id);
    setState(() {
      activeWalletId = id;
      selectedIndex = null;
      searchQuery = "";
      _searchController.clear();
      _activeDateFilter = "all";
      _selectedDateRange = null;
    });
    loadData();
  }

  void _showCongratulationsDialog(String name, double budgetAmt) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF00E676), size: 60),
            const SizedBox(height: 16),
            Text(
              _getTxt('congrats_title'),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getTxt('congrats_desc')
                  .replaceAll('{name}', name)
                  .replaceAll('{budget}', peso(budgetAmt)),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Navigator.canPop(context)
                ? ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('OKAY',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future _launchComplianceUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(
        url,
        mode: LaunchMode.platformDefault,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hindi mabuksan ang link: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future _sendSupportEmail(String subjectText) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'rasmobilelabs.support@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': subjectText,
      }),
    );
    try {
      bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getTxt('email_app_err'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${_getTxt('email_open_err')}$e")),
        );
      }
    }
  }

  Future clearAllApplicationData() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  // 🔥 ANG KULANG NA METHOD NA NAKAPAGDUDULOT NG ERROR
  void _showBackupAndRestoreOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          _currentLocale == 'tl'
              ? 'I-manage ang Iyong Data'
              : (_currentLocale == 'id'
                  ? 'Kelola Data Anda'
                  : 'Manage Your Data'),
          style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _currentLocale == 'tl'
                  ? 'Pumili ng aksyon para sa iyong mga pitaka, kasaysayan ng gastos, at app settings.'
                  : (_currentLocale == 'id'
                      ? 'Pilih tindakan untuk dompet, riwayat pengeluaran, dan pengaturan aplikasi Anda.'
                      : 'Select an action for your wallets, expense histories, and application settings.'),
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 16),

            // OPTION 1: GUMAWA NG BACKUP (EXPORT)
            ElevatedButton.icon(
              onPressed: () {
                // ✂️ TINANGGAL ANG Navigator.pop(context) DITO PARA HINDI MAGSARA AGAD
                _exportFullBackup();
              },
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: Text(
                _currentLocale == 'tl'
                    ? 'Gumawa ng Backup (Export)'
                    : (_currentLocale == 'id'
                        ? 'Buat Cadangan (Ekspor)'
                        : 'Create Full Backup (Export)'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF00E676).withValues(alpha: 0.15),
                foregroundColor: const Color(0xFF00E676),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // OPTION 2: I-RESTORE ANG BACKUP (IMPORT)
            ElevatedButton.icon(
              onPressed: () {
                // ✂️ TINANGGAL ANG Navigator.pop(context) DITO PARA HINDI MAGSARA AGAD
                _importFullBackup();
              },
              icon: const Icon(Icons.cloud_download_outlined, size: 18),
              label: Text(
                _currentLocale == 'tl'
                    ? 'I-restore ang Data (Import)'
                    : (_currentLocale == 'id'
                        ? 'Pulihkan Data (Impor)'
                        : 'Restore Data Backup (Import)'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF29B6F6).withValues(alpha: 0.15),
                foregroundColor: const Color(0xFF29B6F6),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 🚀 TAMA: Dahil hindi natin pinatay ang settings kanina,
              // ang pop na ito ay maayos na babalik patungo sa Settings window!
              Navigator.pop(context);
            },
            child: Text(
              _currentLocale == 'en'
                  ? 'CLOSE'
                  : (_currentLocale == 'id' ? 'TUTUP' : 'ISARA'),
              style: const TextStyle(
                  color: Colors.white38, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _exportFullBackup() async {
    final bool trialExpiredWithNoPremium = _isTrialExpired && !_isPremiumUser;
    if (trialExpiredWithNoPremium) {
      _showUpgradeOptionsBottomSheet();
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          _currentLocale == 'tl'
              ? 'Gumawa ng Buong Backup?'
              : (_currentLocale == 'id'
                  ? 'Buat Cadangan Penuh?'
                  : 'Create Full Backup?'),
          style: const TextStyle(
              color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
        ),
        content: Text(
          _currentLocale == 'tl'
              ? 'I-eexport ang lahat ng iyong wallets, expenses history, at app settings sa isang backup file. Ituloy?'
              : (_currentLocale == 'id'
                  ? 'Ekspor semua dompet, riwayat pengeluaran, dan pengaturan aplikasi Anda ke file cadangan. Lanjutkan?'
                  : 'This will export all your wallets, expense histories, and app configurations into a backup file. Proceed?'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_getTxt('btn_cancel'),
                style: const TextStyle(color: Colors.white30)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _currentLocale == 'tl'
                  ? 'ITULOY'
                  : (_currentLocale == 'id' ? 'LANJUTKAN' : 'PROCEED'),
              style: const TextStyle(
                  color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final p = await SharedPreferences.getInstance();
      Map<String, dynamic> backupData = {};

      backupData['app_lang_locale'] =
          p.getString('app_lang_locale') ?? _currentLocale;
      backupData['user_pincode'] = p.getString('user_pincode') ?? "";
      backupData['security_answer'] = p.getString('security_answer') ?? "";
      backupData['app_wallets'] = p.getString('app_wallets') ?? "[]";
      backupData['active_wallet_id'] =
          p.getString('active_wallet_id') ?? "default";

      if (wallets.isNotEmpty) {
        for (var w in wallets) {
          backupData['expenses${w.id}'] =
              p.getString('expenses${w.id}') ?? "[]";
        }
      }

      String jsonString = jsonEncode(backupData);

      // 🔥 WEB FALLBACK INTERFACE: Kung nasa FlutLab/Web UI, magpapakita ng text copy prompt box
      if (kIsWeb) {
        if (!mounted) return;
        final TextEditingController copyCtrl =
            TextEditingController(text: jsonString);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('FlutLab Web Backup Content',
                style: TextStyle(color: Color(0xFFFFD700))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                    'Dahil nasa web view ka, kopyahin (Copy) ang code sa ibaba at i-save sa iyong notes/notepad:',
                    style: TextStyle(fontSize: 12, color: Colors.white54)),
                const SizedBox(height: 10),
                TextField(
                  controller: copyCtrl,
                  maxLines: 5,
                  readOnly: true,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                      fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFF121212)),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: jsonString));
                    Navigator.pop(context);
                  },
                  child: const Text('COPY & CLOSE',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold))),
            ],
          ),
        );
        return;
      }

      // PHONE PLATFORM MODE: Ito ang gagana kapag binuod sa physical device
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/GastosKo_Full_Backup.json';
      final File file = File(filePath);
      await file.writeAsString(jsonString, encoding: utf8);

      final XFile xFile = XFile(filePath);
      final box = context.findRenderObject() as RenderBox?;

      await Share.shareXFiles(
        [xFile],
        text: 'My Gastos Ko Application Security Backup File',
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C1A1A),
            title: const Text('Backup Failed',
                style: TextStyle(color: Colors.redAccent)),
            content: Text('Error: $e'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'))
            ],
          ),
        );
      }
    }
  }

  Future<void> _importFullBackup() async {
    final bool trialExpiredWithNoPremium = _isTrialExpired && !_isPremiumUser;
    if (trialExpiredWithNoPremium) {
      _showUpgradeOptionsBottomSheet();
      return;
    }

    // 1. Security Warning Prompt Box
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          _currentLocale == 'tl'
              ? 'Mag-restore ng Data?'
              : (_currentLocale == 'id'
                  ? 'Pulihkan Data?'
                  : 'Restore Data Backup?'),
          style: const TextStyle(
              color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          _currentLocale == 'tl'
              ? 'BABALA: Mapapalitan at mabubura ang lahat ng kasalukuyang data ng app mo ng data mula sa ia-upload mong backup file. Sigurado ka ba?'
              : (_currentLocale == 'id'
                  ? 'PERINGATAN: Semua data aplikasi saat ini akan diganti dan dihapus oleh data dari file cadangan yang Anda unggah. Apakah Anda yakin?'
                  : 'WARNING: All current application data will be overwritten and permanently replaced by the data from the backup file you upload. Are you sure?'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_getTxt('btn_cancel'),
                style: const TextStyle(color: Colors.white30)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _currentLocale == 'tl'
                  ? 'ITULOY'
                  : (_currentLocale == 'id' ? 'LANJUTKAN' : 'PROCEED'),
              style: const TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // 2. 🔥 MAGBUBUKAS NG NATIVE FILE EXPLORER NG PHONE
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'json'
        ], // `.json` file lang ang pwedeng piliin ng user
      );

      // Kung kinansela ng user ang pagpili sa file explorer
      if (result == null || result.files.single.path == null) return;

      // 3. Basahin ang nilalaman ng napiling file
      final File file = File(result.files.single.path!);
      final String fileContent = await file.readAsString(encoding: utf8);

      // I-parse ang JSON string
      Map<String, dynamic> parsedData = jsonDecode(fileContent.trim());
      final p = await SharedPreferences.getInstance();

      // Pagsusuri kung valid na backup file ng Gastos Ko App ang ipinasok
      if (!parsedData.containsKey('app_wallets') ||
          !parsedData.containsKey('active_wallet_id')) {
        throw const FormatException("Invalid Gastos Ko backup format.");
      }

      // 4. Isulat ang bawat na-parse na data sa local memory database (SharedPreferences)
      await p.setString(
          'app_lang_locale', parsedData['app_lang_locale'] ?? 'en');
      if (parsedData.containsKey('user_pincode'))
        await p.setString('user_pincode', parsedData['user_pincode']);
      if (parsedData.containsKey('security_answer'))
        await p.setString('security_answer', parsedData['security_answer']);
      await p.setString('app_wallets', parsedData['app_wallets']);
      await p.setString('active_wallet_id', parsedData['active_wallet_id']);

      // I-restore ang bawat nakitang expense logs ng mga wallet
      parsedData.forEach((key, value) async {
        if (key.startsWith('expenses')) {
          await p.setString(key, value.toString());
        }
      });

      // 5. Success Banner at Auto-reload ng Dashboard state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_currentLocale == 'tl'
                ? 'Matagumpay na nai-restore ang data! Magre-refresh ang app...'
                : 'Backup successfully restored! App will reload...'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          loadData(); // Awtomatikong mag-re-refresh ang buong dashboard UI
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_currentLocale == 'tl'
                ? 'Maling format ng backup file: $e'
                : 'Invalid backup data format: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditWalletBudgetDialog(
      AppWallet wallet, StateSetter setModalState) {
    final nameCtrl = TextEditingController(text: wallet.name);

    final initialCurrencyDetails = globalCurrencies.firstWhere(
      (c) => c["symbol"] == wallet.currency,
      orElse: () =>
          {"country": "United States 🇺🇸", "code": "USD", "symbol": "\$"},
    );

    String selectedWalletCurrencyCode = initialCurrencyDetails["code"]!;

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currentCurrencyDetails = globalCurrencies.firstWhere(
            (c) => c["code"] == selectedWalletCurrencyCode,
            orElse: () => {
              "country": "United States 🇺🇸",
              "code": "USD",
              "symbol": "\$"
            },
          );

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              _currentLocale == 'tl'
                  ? 'I-edit Pangalan: ${wallet.name}'
                  : (_currentLocale == 'id'
                      ? 'Ubah Nama: ${wallet.name}'
                      : 'Edit Name: ${wallet.name}'),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      labelText: _currentLocale == 'tl'
                          ? 'Bagong Pangalan ng Wallet'
                          : (_currentLocale == 'id'
                              ? 'Nama Dompet Baru'
                              : 'New Wallet Name')),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _currentLocale == 'tl'
                        ? 'Pumili ng Pera (Currency)'
                        : (_currentLocale == 'id'
                            ? 'Pilih Mata Uang'
                            : 'Select Currency'),
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  subtitle: Text(
                    "${currentCurrencyDetails["country"]} (${currentCurrencyDetails["code"]}) [${currentCurrencyDetails["symbol"]}]",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  trailing:
                      const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  onTap: () {
                    _openCurrencySearchPicker((chosen) {
                      setDialogState(() {
                        selectedWalletCurrencyCode = chosen["code"]!;
                      });
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_getTxt('btn_cancel'),
                    style: const TextStyle(color: Colors.white30)),
              ),
              TextButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    String oldName = wallet.name;
                    String newName = nameCtrl.text.trim();
                    String finalSymbol = currentCurrencyDetails["symbol"]!;

                    setState(() {
                      wallet.name = newName;
                      wallet.currency = finalSymbol;

                      if (wallet.id == activeWalletId) {
                        _currentCurrency = finalSymbol;
                      }
                      saveData();
                    });

                    setModalState(() {});
                    Navigator.pop(context);

                    // 🔥 IDINAGDAG NA SUCCESS PROMPT MESSAGES
                    if (mounted) {
                      String walletEditSuccessMsg = _currentLocale == 'tl'
                          ? 'Matagumpay na na-update ang wallet patungong "$newName"!'
                          : (_currentLocale == 'id'
                              ? 'Dompet berhasil diperbarui menjadi "$newName"!'
                              : 'Wallet successfully updated to "$newName"!');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            walletEditSuccessMsg,
                            style: const TextStyle(color: Colors.black),
                          ),
                          backgroundColor: const Color(
                              0xFFFFD700), // Gold background matching standard update action
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                child: Text(_getTxt('btn_save'),
                    style: const TextStyle(
                        color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }

  void _showAddAmountToWalletDialog(dynamic w) {
    final TextEditingController amountController = TextEditingController();
    int selectedOperation = 0;

    // Format formatter para sa libu-libong comma input tracking
    final formatter = NumberFormat('#,##0', 'en_US');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String titleTxt = _currentLocale == 'tl'
                ? "I-MANAGE ANG PONDO NG WALLET"
                : (_currentLocale == 'id'
                    ? "KELOLA DANA DOMPET"
                    : "MANAGE WALLET FUNDS");

            String currentBalanceLabel = _currentLocale == 'tl'
                ? "Kasalukuyang Laman: "
                : (_currentLocale == 'id'
                    ? "Saldo Saat Ini: "
                    : "Current Balance: ");

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                titleTxt,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$currentBalanceLabel ${peso(w.budget)}",
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedOperation = 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedOperation == 0
                                  ? const Color(0xFF00E676)
                                      .withValues(alpha: 0.2)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selectedOperation == 0
                                      ? const Color(0xFF00E676)
                                      : Colors.transparent,
                                  width: 1.5),
                            ),
                            child: const Icon(Icons.add,
                                color: Color(0xFF00E676), size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedOperation = 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedOperation == 1
                                  ? Colors.redAccent.withValues(alpha: 0.2)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selectedOperation == 1
                                      ? Colors.redAccent
                                      : Colors.transparent,
                                  width: 1.5),
                            ),
                            child: const Icon(Icons.remove,
                                color: Colors.redAccent, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedOperation = 2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedOperation == 2
                                  ? const Color(0xFFFFD700)
                                      .withValues(alpha: 0.2)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selectedOperation == 2
                                      ? const Color(0xFFFFD700)
                                      : Colors.transparent,
                                  width: 1.5),
                            ),
                            child: const Icon(Icons.drag_handle_rounded,
                                color: Color(0xFFFFD700), size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: InputDecoration(
                      prefixText: '$_currentCurrency ',
                      prefixStyle: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold),
                      labelText: selectedOperation == 0
                          ? (_currentLocale == 'tl'
                              ? 'Halagang Idaragdag sa Pondo'
                              : (_currentLocale == 'id'
                                  ? 'Jumlah untuk Ditambahkan'
                                  : 'Amount to Add to Funds'))
                          : (selectedOperation == 1
                              ? (_currentLocale == 'tl'
                                  ? 'Halagang Ibabawas sa Pondo'
                                  : (_currentLocale == 'id'
                                      ? 'Jumlah untuk Dikurangi'
                                      : 'Amount to Deduct from Funds'))
                              : (_currentLocale == 'tl'
                                  ? 'Bagong Kabuuang Halaga ng Pondo'
                                  : (_currentLocale == 'id'
                                      ? 'Atur Saldo Baru'
                                      : 'Set New Total Funds Amount'))),
                      labelStyle:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white10)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFFFD700))),
                    ),
                    onChanged: (val) {
                      if (val.isEmpty) return;
                      String cleanString = val.replaceAll(',', '');
                      int? parsedNum = int.tryParse(cleanString);
                      if (parsedNum != null) {
                        String formattedText = formatter.format(parsedNum);
                        amountController.value = TextEditingValue(
                          text: formattedText,
                          selection: TextSelection.collapsed(
                              offset: formattedText.length),
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    _currentLocale == 'tl'
                        ? 'KANSELAHIN'
                        : (_currentLocale == 'id' ? 'BATAL' : 'CANCEL'),
                    style: const TextStyle(color: Colors.white38),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final String rawAmount =
                        amountController.text.replaceAll(',', '').trim();
                    final double? inputVal = double.tryParse(rawAmount);

                    if (inputVal == null || inputVal < 0) {
                      return;
                    }

                    String snackBarMessage = "";
                    Color snackBarColor = const Color(0xFF00E676);

                    setState(() {
                      if (selectedOperation == 0) {
                        w.budget += inputVal;
                        // Localized message para sa pagdaragdag (+)
                        if (_currentLocale == 'tl') {
                          snackBarMessage =
                              "Matagumpay na naidagdag ang $_currentCurrency${formatter.format(inputVal)} sa pondo!";
                        } else if (_currentLocale == 'id') {
                          snackBarMessage =
                              "Berhasil menambahkan $_currentCurrency${formatter.format(inputVal)} ke dana!";
                        } else {
                          snackBarMessage =
                              "Successfully added $_currentCurrency${formatter.format(inputVal)} to funds!";
                        }
                        snackBarColor =
                            const Color(0xFF00E676); // Berde para sa (+)
                      } else if (selectedOperation == 1) {
                        w.budget -= inputVal;
                        if (w.budget < 0) w.budget = 0.0;
// Localized message para sa pagbabawas (-)
                        if (_currentLocale == 'tl') {
                          snackBarMessage =
                              "Matagumpay na nabawasan ng $_currentCurrency${formatter.format(inputVal)} ang pondo!";
                        } else if (_currentLocale == 'id') {
                          snackBarMessage =
                              "Berhasil mengurangi $_currentCurrency${formatter.format(inputVal)} dari dana!";
                        } else {
                          snackBarMessage =
                              "Successfully deducted $_currentCurrency${formatter.format(inputVal)} from funds!";
                        }
                        snackBarColor = Colors.redAccent; // Pula para sa (-)
                      } else if (selectedOperation == 2) {
                        w.budget = inputVal;
// Localized message para sa pag-overwrite (=)
                        if (_currentLocale == 'tl') {
                          snackBarMessage =
                              "Naitakda ang pondo sa bagong kabuuang $_currentCurrency${formatter.format(inputVal)}!";
                        } else if (_currentLocale == 'id') {
                          snackBarMessage =
                              "Saldo berhasil diatur menjadi $_currentCurrency${formatter.format(inputVal)}!";
                        } else {
                          snackBarMessage =
                              "Funds successfully set to a new total of $_currentCurrency${formatter.format(inputVal)}!";
                        }
                        snackBarColor =
                            const Color(0xFFFFD700); // Ginto/Dilaw para sa (=)
                      }
                      if (w.id == activeWalletId) {
                        budget = w.budget;
                      }
                    });
                    saveData();
                    Navigator.pop(context);
// 🔥 AUTOMATION LAYER: Ipapakita ang dynamic pop-up notification banner
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            snackBarMessage,
                            style: TextStyle(
                              color: selectedOperation == 2
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: snackBarColor,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text(
                    _currentLocale == 'tl'
                        ? 'KUMPIRMAHIN'
                        : (_currentLocale == 'id' ? 'KONFIRASI' : 'CONFIRM'),
                    style: const TextStyle(
                        color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🔥 BAGONG IMPLEMENTASYON: DIALOG PARA MAG-RESET NG ISANG WALLET LANG
  void _showResetSingleWalletConfirmDialog(
      AppWallet wallet, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          _currentLocale == 'tl'
              ? 'I-reset ang Wallet?'
              : (_currentLocale == 'id'
                  ? 'Atur Ulang Dompet?'
                  : 'Reset Wallet Expenses?'),
          style: const TextStyle(
              color: Colors.orangeAccent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          _currentLocale == 'tl'
              ? 'Sigurado ka ba? Buburahin nito ang LAHAT ng kasaysayan ng gastos sa wallet na "${wallet.name}". Mananatili ang wallet ngunit babalik sa 0 ang kabuuang nagastos.'
              : (_currentLocale == 'id'
                  ? 'Apakah Anda yakin? Ini akan menghapus SEMUA riwayat pengeluaran di dompet "${wallet.name}". Dompet akan tetap ada tetapi total pengeluaran kembali ke 0.'
                  : 'Are you sure? This will delete ALL expense history inside the wallet "${wallet.name}". The wallet will remain but total expenses will return to 0.'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTxt('btn_cancel'),
                style: const TextStyle(color: Colors.white30)),
          ),
          TextButton(
            onPressed: () async {
              final p = await SharedPreferences.getInstance();

              // 1. Buburahin ang mga gastos ng partikular na wallet sa database
              await p.remove('expenses${wallet.id}');

              // 2. Kung ito ang kasalukuyang aktibong wallet, linisin din ang active screen list state
              if (wallet.id == activeWalletId) {
                setState(() {
                  all.clear();
                  selectedIndex = null;
                });
              }

              // 3. I-refresh ang layout
              setModalState(() {});
              await loadData();

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _currentLocale == 'tl'
                          ? 'Matagumpay na na-reset ang wallet na "${wallet.name}"!'
                          : 'Wallet "${wallet.name}" successfully reset!',
                    ),
                    backgroundColor: Colors.orangeAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              _currentLocale == 'tl'
                  ? 'I-RESET'
                  : (_currentLocale == 'id' ? 'ATUR ULANG' : 'RESET'),
              style: const TextStyle(
                  color: Colors.orangeAccent, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // 🔥 IBALIK ANG NAWALANG METHOD NG PAG-DELETE NG PITAKA
  // 🔥 INAYOS NA METHOD NG PAG-DELETE NG PITAKA NA MAY SUCCESS PROMPT
  void _showDeleteWalletConfirmDialog(
      AppWallet wallet, StateSetter setModalState) {
    if (wallet.id == "default") {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getTxt('main_wallet_del_err')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(_getTxt('del_wallet_title'),
            style: const TextStyle(color: Colors.redAccent)),
        content:
            Text(_getTxt('del_wallet_desc').replaceAll('{name}', wallet.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTxt('btn_cancel'),
                style: const TextStyle(color: Colors.white30)),
          ),
          TextButton(
            onPressed: () async {
              // 1. I-save muna ang pangalan ng wallet para sa notification bago burahin
              String deletedWalletName = wallet.name;

              final p = await SharedPreferences.getInstance();
              await p.remove('expenses${wallet.id}');

              String resetCurrency = "₱";
              if (_currentLocale == 'id') {
                resetCurrency = "Rp";
              } else if (_currentLocale == 'en') {
                resetCurrency = "\$";
              }

              setState(() {
                wallets.removeWhere((w) => w.id == wallet.id);
                if (activeWalletId == wallet.id) {
                  if (wallets.isNotEmpty) {
                    activeWalletId = wallets.first.id;
                    _currentCurrency = wallets.first.currency;
                  } else {
                    wallets = [
                      AppWallet(
                          id: "default",
                          name: "Main Wallet",
                          budget: 0.0,
                          currency: resetCurrency)
                    ];
                    activeWalletId = "default";
                    _currentCurrency = resetCurrency;
                  }
                }
              });
              await p.setString('app_wallets',
                  jsonEncode(wallets.map((w) => w.toJson()).toList()));
              await p.setString('active_wallet_id', activeWalletId);
              setModalState(() {});
              loadData();

              if (mounted) {
                Navigator.pop(context);

                // 🔥 IDINAGDAG NA SUCCESS PROMPT MESSAGES KAPAG NABURA ANG WALLET
                String walletDeleteSuccessMsg = _currentLocale == 'tl'
                    ? 'Matagumpay na nabura ang wallet na "$deletedWalletName"!'
                    : (_currentLocale == 'id'
                        ? 'Dompet "$deletedWalletName" berhasil dihapus!'
                        : 'Wallet "$deletedWalletName" successfully deleted!');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      walletDeleteSuccessMsg,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors
                        .redAccent, // Red background para sa delete action
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(_getTxt('btn_delete'),
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showWalletManagerDialog() {
    if (_isTrialExpired && !_isPremiumUser) {
      _showUpgradeOptionsBottomSheet();
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Color(0xFFFFD700)),
                  const SizedBox(width: 10),
                  Text(_getTxt('wallet_manager'),
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: wallets.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child:
                              Center(child: Text(_getTxt('no_wallet_found'))),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: wallets.length,
                          itemBuilder: (context, idx) {
                            final w = wallets[idx];
                            final isSelected = w.id == activeWalletId;
                            return Card(
                              color: isSelected
                                  ? const Color(0xFF252525)
                                  : Colors.transparent,
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                leading: Icon(Icons.wallet,
                                    color: isSelected
                                        ? const Color(0xFFFFD700)
                                        : Colors.white30),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        w.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFFFFD700)
                                                : _appFontColor,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal),
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.check_circle,
                                          color: Color(0xFF00E676), size: 16),
                                    ],
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    'Budget: ${w.currency}${fmt(w.budget)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white54),
                                  ),
                                ),
                                // 🚀 TAMA AT GUMAGANA: Dito nakalagay ang pag-select ng wallet kapag pinindot ang card o tile mismo
                                onTap: () {
                                  setModalState(() {
                                    activeWalletId = w.id;
                                  });
                                  Navigator.pop(context);

                                  // I-update ang global active currency symbol bago lumipat ng wallet
                                  setState(() {
                                    _currentCurrency = w.currency;
                                  });

                                  _switchWallet(w.id);
                                },
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.white54),
                                  color: const Color(0xFF252525),
                                  onSelected: (String action) {
                                    if (action == 'add') {
                                      Navigator.pop(context);
                                      _showAddAmountToWalletDialog(w);
                                    } else if (action == 'edit') {
                                      _showEditWalletBudgetDialog(
                                          w, setModalState);
                                    } else if (action == 'reset') {
                                      _showResetSingleWalletConfirmDialog(
                                          w, setModalState);
                                    } else if (action == 'delete') {
                                      _showDeleteWalletConfirmDialog(
                                          w, setModalState);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'add',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.add,
                                              color: Color(0xFFFFD700),
                                              size: 18),
                                          const SizedBox(width: 10),
                                          Text(_getTxt('add_fund_tooltip'),
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit,
                                              color: Colors.white70, size: 18),
                                          const SizedBox(width: 10),
                                          Text(_getTxt('edit_wallet_tooltip'),
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'reset',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.refresh_rounded,
                                              color: Colors.orangeAccent,
                                              size: 18),
                                          const SizedBox(width: 10),
                                          Text(
                                              _currentLocale == 'tl'
                                                  ? 'I-reset ang mga Gastos'
                                                  : 'Reset Wallet History',
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    if (w.id != "default")
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete_outline,
                                                color: Colors.redAccent,
                                                size: 18),
                                            const SizedBox(width: 10),
                                            Text(_getTxt('del_wallet_tooltip'),
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(color: Colors.white10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddWalletDialog();
                    },
                    icon: const Icon(Icons.add_card, size: 18),
                    label: Text(_getTxt('btn_add_wallet')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFFD700).withValues(alpha: 0.15),
                      foregroundColor: const Color(0xFFFFD700),
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddWalletDialog() {
    final nameCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();

    // Gagamit tayo ng unique 'code' (PHP) sa local state ng form para maiwasan ang collision ng ¥
    String selectedWalletCurrencyCode = "PHP";

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Hinahanap ang buong detalye gamit ang unique 'code' sa halip na 'symbol'
          final currentCurrencyDetails = globalCurrencies.firstWhere(
            (c) => c["code"] == selectedWalletCurrencyCode,
            orElse: () =>
                {"country": "Philippines 🇵🇭", "code": "PHP", "symbol": "₱"},
          );

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(_getTxt('create_wallet_title')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        InputDecoration(labelText: _getTxt('wallet_name_lbl')),
                  ),
                  const SizedBox(height: 12),
                  // SEARCH PICKER BUTTON ROW
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _currentLocale == 'tl'
                          ? 'Pumili ng Pera (Currency)'
                          : (_currentLocale == 'id'
                              ? 'Pilih Mata Uang'
                              : 'Select Currency'),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    subtitle: Text(
                      "${currentCurrencyDetails["country"]} (${currentCurrencyDetails["code"]}) [${currentCurrencyDetails["symbol"]}]",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    trailing: const Icon(Icons.arrow_drop_down,
                        color: Colors.white54),
                    onTap: () {
                      _openCurrencySearchPicker((chosen) {
                        setDialogState(() {
                          // 🔥 TAMA: Code na ang ini-store sa form controller para maging unique ang China (CNY) at Japan (JPY)
                          selectedWalletCurrencyCode = chosen["code"]!;
                        });
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: budgetCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CommaFormatter()
                    ],
                    decoration: InputDecoration(
                        prefixText: '${currentCurrencyDetails["symbol"]} ',
                        labelText: _getTxt('wallet_budget_lbl')),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_getTxt('btn_cancel'),
                      style: const TextStyle(color: Colors.white30))),
              TextButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && budgetCtrl.text.isNotEmpty) {
                    String wName = nameCtrl.text.trim();
                    double wBudget =
                        double.tryParse(budgetCtrl.text.replaceAll(',', '')) ??
                            0;
                    String wId =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    // Kunin ang katumbas na simbolo bago i-save sa wallet data model
                    String finalSymbol = currentCurrencyDetails["symbol"]!;

                    setState(() {
                      final newWallet = AppWallet(
                        id: wId,
                        name: wName,
                        budget: wBudget,
                        currency:
                            finalSymbol, // 🚀 LIGTAS: Simbolo pa rin ang naisave sa database para sa main dashboard
                      );
                      wallets.add(newWallet);
                      activeWalletId = wId;
                      budget = wBudget;
                      _currentCurrency =
                          finalSymbol; // Binabago ang global active symbol
                      all.clear();
                      saveData();
                    });
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 150), () {
                      _showCongratulationsDialog(wName, wBudget);
                    });
                  }
                },
                child: Text(_getTxt('btn_save'),
                    style: const TextStyle(
                        color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }

  void _showNearLimitBudgetDialog(double currentTotal, double newAmount) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF2C221A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.orangeAccent, width: 1.5)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.orangeAccent, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getTxt('near_limit_title'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          _getTxt('near_limit_desc')
              .replaceAll('{amount}', peso(newAmount))
              .replaceAll('{budget}', peso(budget)),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTxt('btn_near_limit'),
                style: const TextStyle(
                    color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showBudgetExhaustedAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF2C1A1A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 1.5)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getTxt('exhausted_title'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          _getTxt('exhausted_desc'),
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTxt('btn_no'),
                style: const TextStyle(
                    color: Colors.white38, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppWallet? currentWallet;
              for (var w in wallets) {
                if (w.id == activeWalletId) {
                  currentWallet = w;
                  break;
                }
              }
              if (currentWallet != null) {
                _showAddAmountToWalletDialog(currentWallet);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: Text(_getTxt('btn_add_fund').replaceAll('I-', ''),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _checkBudgetBeforeAdding() {
    if (budget <= 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actionsAlignment: MainAxisAlignment.end,
          title: Text(
            _getTxt('pre_add_budget_title'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_getTxt('btn_cancel'),
                  style: const TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                AppWallet? currentWallet;
                for (var w in wallets) {
                  if (w.id == activeWalletId) {
                    currentWallet = w;
                    break;
                  }
                }
                if (currentWallet != null) {
                  _showAddAmountToWalletDialog(currentWallet);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
              child: Text(_getTxt('btn_set_budget'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      _showCounselingAddExpenseDialog();
    }
  }

  void _showCounselingAddExpenseDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: "💰");
    DateTime napilingPetsa = DateTime.now();
    final List<String> quickPresets = [
      "💰",
      "🍔",
      "🚗",
      "🛍️",
      "🏠",
      "🎬",
      "💊",
      "🎓",
      "✈️",
      "⚡",
      "☕",
      "🎮",
      "🏋️",
      "🎁",
      "🥦",
      "🐾",
      "✂️",
    ];

    String titleError = "";
    String amountError = "";

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setModalState) {
          // 1. LOCALIZED DEFAULT CATEGORIES
          List<String> defaultPresets = [];
          if (_currentLocale == 'tl') {
            defaultPresets = [
              'Pagkain',
              'Pamasahe',
              'Kuryente',
              'Tubig',
              'Groceries',
              'Shopping',
              'Edukasyon',
              'Kalusugan'
            ];
          } else if (_currentLocale == 'id') {
            defaultPresets = [
              'Makanan',
              'Ongkos',
              'Listrik',
              'Air',
              'Belanjaan',
              'Belanja',
              'Edukasi',
              'Kesehatan'
            ];
          } else {
            defaultPresets = [
              'Food',
              'Transport',
              'Electricity',
              'Water',
              'Groceries',
              'Shopping',
              'Education',
              'Health'
            ];
          }

          final Map<String, String> emojiMapping = {
            'food': '🍔',
            'pagkain': '🍔',
            'makanan': '🍔',
            'transport': '🚗',
            'pamasahe': '🚗',
            'ongkos': '🚗',
            'electricity': '⚡',
            'kuryente': '⚡',
            'listrik': '⚡',
            'water': '💧',
            'tubig': '💧',
            'air': '💧',
            'groceries': '🥦',
            'belanjaan': '🥦',
            'shopping': '🛍️',
            'belanja': '🛍️',
            'education': '🎓',
            'edukasyon': '🎓',
            'edukasi': '🎓',
            'health': '💊',
            'kalusugan': '💊',
            'kesehatan': '💊',
          };

          return FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              List<String> activePresets = List.from(defaultPresets);

              if (snapshot.hasData) {
                final prefs = snapshot.data!;
                // I-load ang mga dating na-save na custom categories ng user
                List<String> savedCustom =
                    prefs.getStringList('user_custom_categories') ?? [];
                for (var cat in savedCustom) {
                  if (!activePresets
                      .any((e) => e.toLowerCase() == cat.toLowerCase())) {
                    activePresets.add(cat);
                  }
                }
              }

              return AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: Text(_getTxt('add_expense')),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final String typed = textEditingValue.text.trim();

                          if (typed.isEmpty) {
                            return activePresets;
                          }

                          final filtered = activePresets.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(typed.toLowerCase());
                          }).toList();

                          final String addCustomFlag =
                              '__ADD_CUSTOM_CATEGORY_FLAG__:$typed';
                          if (!activePresets.any((element) =>
                              element.toLowerCase() == typed.toLowerCase())) {
                            filtered.insert(0, addCustomFlag);
                          }

                          return filtered;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: const Color(0xFF1E1E1E),
                              elevation: 4.0,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.72,
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final String option =
                                        options.elementAt(index);
                                    final bool isCustomAddAction =
                                        option.startsWith(
                                            '__ADD_CUSTOM_CATEGORY_FLAG__:');

                                    if (isCustomAddAction) {
                                      final String rawTypedValue = option.split(
                                          '__ADD_CUSTOM_CATEGORY_FLAG__:')[1];
                                      final String displayBtnLabel =
                                          _currentLocale == 'tl'
                                              ? '➕ MAGDAGDAG NG BAGONG KATEGORYA'
                                              : (_currentLocale == 'id'
                                                  ? '➕ TAMBAH KATEGORI BARU'
                                                  : '➕ ADD NEW CATEGORY');

                                      return Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00E676)
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: const Color(0xFF00E676),
                                              width: 1),
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          title: Text(
                                            displayBtnLabel,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFF00E676),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '"$rawTypedValue"',
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 11),
                                          ),
                                          onTap: () {
                                            onSelected(rawTypedValue);
                                          },
                                        ),
                                      );
                                    }

                                    return ListTile(
                                      dense: true,
                                      leading: const Icon(
                                          Icons.label_important_outline,
                                          color: Color(0xFFFFD700),
                                          size: 16),
                                      title: Text(option,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13)),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        onSelected: (String selection) {
                          titleCtrl.text = selection;

                          final String normKey = selection.toLowerCase().trim();
                          if (emojiMapping.containsKey(normKey)) {
                            setModalState(() {
                              emojiCtrl.text = emojiMapping[normKey]!;
                            });
                          } else {
                            setModalState(() {
                              emojiCtrl.text = "💰";
                            });
                          }

                          _searchEmojiForCategory(
                            val: selection,
                            emojiCtrl: emojiCtrl,
                            setModalState: setModalState,
                          );
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          if (titleCtrl.text != textEditingController.text &&
                              textEditingController.text.isEmpty) {
                            textEditingController.text = titleCtrl.text;
                          }
                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: _getTxt('category_label'),
                              errorText: titleError.isEmpty ? null : titleError,
                              errorStyle: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                              focusedErrorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.redAccent, width: 1.5)),
                              suffixIcon: textEditingController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.white54, size: 18),
                                      onPressed: () {
                                        setModalState(() {
                                          textEditingController.clear();
                                          titleCtrl.clear();
                                        });
                                      },
                                    )
                                  : const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFFFFD700)),
                            ),
                            onChanged: (val) async {
                              titleCtrl.text = val;
                              setModalState(() {});
                              if (titleError.isNotEmpty) {
                                setModalState(() {
                                  titleError = "";
                                });
                              }
                              if (val.trim().isNotEmpty) {
                                _searchEmojiForCategory(
                                  val: val,
                                  emojiCtrl: emojiCtrl,
                                  setModalState: setModalState,
                                );
                              }
                            },
                          );
                        },
                      ),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CommaFormatter()
                        ],
                        decoration: InputDecoration(
                          prefixText: '$_currentCurrency ',
                          labelText: _getTxt('amount_label'),
                          errorText: amountError.isEmpty ? null : amountError,
                          errorStyle: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold),
                          focusedErrorBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.redAccent, width: 1.5)),
                        ),
                        onChanged: (val) {
                          if (amountError.isNotEmpty) {
                            setModalState(() {
                              amountError = "";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentLocale == 'tl'
                            ? 'Pumili ng Icon / Emoji para sa Kategorya:'
                            : 'Select Category Icon / Emoji:',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 8,
                        children: [
                          ...quickPresets.map((emoji) {
                            final bool isSelected = emojiCtrl.text == emoji;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  emojiCtrl.text = emoji;
                                });
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFD700)
                                          .withValues(alpha: 0.2)
                                      : const Color(0xFF252525),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFD700)
                                        : Colors.white10,
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                ),
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            );
                          }),
                          GestureDetector(
                            onTap: () {
                              final customEmojiCtrl = TextEditingController(
                                  text: !quickPresets.contains(emojiCtrl.text)
                                      ? emojiCtrl.text
                                      : "");
                              showDialog(
                                context: context,
                                builder: (subContext) => AlertDialog(
                                  backgroundColor: const Color(0xFF252525),
                                  title: Text(
                                    _currentLocale == 'tl'
                                        ? 'Mag-type ng Custom Emoji'
                                        : 'Type Custom Emoji',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFFFD700),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: TextField(
                                    controller: customEmojiCtrl,
                                    autofocus: true,
                                    maxLength: 1,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 26),
                                    decoration: const InputDecoration(
                                        counterText: "", hintText: "✨"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(subContext),
                                      child: Text(_getTxt('btn_cancel'),
                                          style: const TextStyle(
                                              color: Colors.white30)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (customEmojiCtrl.text
                                            .trim()
                                            .isNotEmpty) {
                                          setModalState(() {
                                            emojiCtrl.text =
                                                customEmojiCtrl.text.trim();
                                          });
                                        }
                                        Navigator.pop(subContext);
                                      },
                                      child: const Text('OK',
                                          style: TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !quickPresets.contains(emojiCtrl.text) &&
                                        emojiCtrl.text.isNotEmpty
                                    ? const Color(0xFFFFD700)
                                        .withValues(alpha: 0.2)
                                    : const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      !quickPresets.contains(emojiCtrl.text) &&
                                              emojiCtrl.text.isNotEmpty
                                          ? const Color(0xFFFFD700)
                                          : Colors.white30,
                                  width: 1.5,
                                ),
                              ),
                              child: !quickPresets.contains(emojiCtrl.text) &&
                                      emojiCtrl.text.isNotEmpty
                                  ? Text(emojiCtrl.text,
                                      style: const TextStyle(fontSize: 20))
                                  : const Icon(Icons.add,
                                      color: Color(0xFFFFD700), size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today,
                            color: Color(0xFFFFD700)),
                        title: Text(_getTxt('date_label'),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white54)),
                        subtitle: Text(
                            DateFormat('yyyy-MM-dd').format(napilingPetsa),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: napilingPetsa,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFFFD700),
                                  onPrimary: Colors.black,
                                  surface: Color(0xFF1E1E1E),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null && picked != napilingPetsa) {
                            setModalState(() {
                              napilingPetsa = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_getTxt('btn_cancel'),
                        style: const TextStyle(color: Colors.white30)),
                  ),
                  TextButton(
                    onPressed: () async {
                      final String inputTitle = titleCtrl.text.trim();
                      final String inputAmountRaw =
                          amountCtrl.text.replaceAll(',', '').trim();
                      bool hasValidationError = false;
                      setModalState(() {
                        if (inputTitle.isEmpty) {
                          hasValidationError = true;
                          titleError = _currentLocale == 'tl'
                              ? "Kulang ang pangalan!"
                              : (_currentLocale == 'id'
                                  ? "Nama tidak boleh kosong!"
                                  : "Required field!");
                        } else {
                          titleError = "";
                        }
                        if (inputAmountRaw.isEmpty) {
                          hasValidationError = true;
                          amountError = _currentLocale == 'tl'
                              ? "Kulang ang halaga!"
                              : (_currentLocale == 'id'
                                  ? "Jumlah tidak boleh kosong!"
                                  : "Required field!");
                        } else {
                          amountError = "";
                        }
                      });
                      if (hasValidationError) return;
                      String targetCategoryKey = inputTitle.toLowerCase();
                      double amt = double.tryParse(inputAmountRaw) ?? 0;
                      double kasalukuyangTotal =
                          all.fold(0, (sum, item) => sum + item.amount);
                      double bagongTotal = kasalukuyangTotal + amt;
                      double natitiraPagkatapos = budget - bagongTotal;
                      if (!colorMap.containsKey(targetCategoryKey)) {
                        colorMap[targetCategoryKey] = dynamicColors[
                            colorMap.length % dynamicColors.length];
                      }
                      Color itemColor = colorMap[targetCategoryKey]!;
                      String finalEmoji = emojiCtrl.text.trim().isEmpty
                          ? "💰"
                          : emojiCtrl.text.trim();
                      final p = await SharedPreferences.getInstance();
// 🔥 HIGHLIGHT: I-save nang permanente ang bagong kategorya kung wala pa ito sa default list
                      if (!defaultPresets.any(
                          (e) => e.toLowerCase() == inputTitle.toLowerCase())) {
                        // 🔥 NAITAMA: Idinagdag ang .cast<String>() o List<String>.from upang maging List<String> ang format nito
                        List<String> savedCustom = List<String>.from(
                            p.getStringList('user_custom_categories') ?? []);

                        if (!savedCustom.any((e) =>
                            e.toLowerCase() == inputTitle.toLowerCase())) {
                          savedCustom.add(inputTitle);
                          await p.setStringList(
                              'user_custom_categories', savedCustom);
                        }
                      }
                      setState(() {
                        final newExpense = Expense(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          amount: amt,
                          date: napilingPetsa,
                          color: itemColor,
                          iconEmoji: finalEmoji,
                        );
                        all.add(newExpense);
                        for (var expense in all) {
                          if (expense.title.toLowerCase().trim() ==
                              targetCategoryKey) {
                            expense.iconEmoji = finalEmoji;
                          }
                        }
                      });
                      try {
                        for (var w in wallets) {
                          String? walletExpenseData =
                              p.getString('expenses${w.id}');
                          if (walletExpenseData != null) {
                            List parsedList = jsonDecode(walletExpenseData);
                            bool chunkModified = false;
                            for (var rawExp in parsedList) {
                              if (rawExp['title']
                                      .toString()
                                      .toLowerCase()
                                      .trim() ==
                                  targetCategoryKey) {
                                rawExp['iconEmoji'] = finalEmoji;
                                chunkModified = true;
                              }
                            }
                            if (chunkModified) {
                              await p.setString(
                                  'expenses${w.id}', jsonEncode(parsedList));
                            }
                          }
                        }
                      } catch (_) {}
                      await saveData();
                      if (mounted) {
                        String addSuccessMsg = _currentLocale == 'tl'
                            ? 'Matagumpay na naidagdag ang kategorya!'
                            : (_currentLocale == 'id'
                                ? 'Catatan kustom berhasil ditambahkan!'
                                : 'Custom entry successfully added!');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(addSuccessMsg),
                            backgroundColor: const Color(0xFF00E676),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      Navigator.pop(context);
                      if (natitiraPagkatapos <= 0) {
                        Future.delayed(const Duration(milliseconds: 150), () {
                          _showBudgetExhaustedAlert();
                        });
                      } else if (bagongTotal >= (budget * 0.9)) {
                        Future.delayed(const Duration(milliseconds: 150), () {
                          _showNearLimitBudgetDialog(kasalukuyangTotal, amt);
                        });
                      }
                    },
                    child: Text(_getTxt('btn_add'),
                        style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold)),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showEditExpenseDialog(Expense item) {
    if (_isTrialExpired && !_isPremiumUser) {
      _showUpgradeOptionsBottomSheet();
      return;
    }
    final titleCtrl = TextEditingController(text: item.title);
    final amountCtrl = TextEditingController(text: fmt(item.amount));
    final emojiCtrl = TextEditingController(text: item.iconEmoji);
    DateTime napilingPetsa = item.date;
    final List<String> quickPresets = [
      "💰",
      "🍔",
      "🚗",
      "🛍️",
      "🏠",
      "🎬",
      "💊",
      "🎓",
      "✈️",
      "⚡",
      "☕",
      "🎮",
      "🏋️",
      "🎁",
      "🥦",
      "🐾",
      "✂️",
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setModalState) {
          // 1. LOCALIZED DEFAULT CATEGORIES
          List<String> defaultPresets = [];
          if (_currentLocale == 'tl') {
            defaultPresets = [
              'Pagkain',
              'Pamasahe',
              'Kuryente',
              'Tubig',
              'Groceries',
              'Shopping',
              'Edukasyon',
              'Kalusugan'
            ];
          } else if (_currentLocale == 'id') {
            defaultPresets = [
              'Makanan',
              'Ongkos',
              'Listrik',
              'Air',
              'Belanjaan',
              'Belanja',
              'Edukasi',
              'Kesehatan'
            ];
          } else {
            defaultPresets = [
              'Food',
              'Transport',
              'Electricity',
              'Water',
              'Groceries',
              'Shopping',
              'Education',
              'Health'
            ];
          }

          final Map<String, String> emojiMapping = {
            'food': '🍔',
            'pagkain': '🍔',
            'makanan': '🍔',
            'transport': '🚗',
            'pamasahe': '🚗',
            'ongkos': '🚗',
            'electricity': '⚡',
            'kuryente': '⚡',
            'listrik': '⚡',
            'water': '💧',
            'tubig': '💧',
            'air': '💧',
            'groceries': '🥦',
            'belanjaan': '🥦',
            'shopping': '🛍️',
            'belanja': '🛍️',
            'education': '🎓',
            'edukasyon': '🎓',
            'edukasi': '🎓',
            'health': '💊',
            'kalusugan': '💊',
            'kesehatan': '💊',
          };

          return FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              List<String> activePresets = List.from(defaultPresets);

              if (snapshot.hasData) {
                final prefs = snapshot.data!;
                List<String> savedCustom =
                    prefs.getStringList('user_custom_categories') ?? [];
                for (var cat in savedCustom) {
                  if (!activePresets
                      .any((e) => e.toLowerCase() == cat.toLowerCase())) {
                    activePresets.add(cat);
                  }
                }
              }

              return AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: Row(
                  children: [
                    const Icon(Icons.edit, color: Color(0xFFFFD700)),
                    const SizedBox(width: 8),
                    Text(_getTxt('edit_expense')),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 SINKRONAYS NA AUTOCOMPLETE SA EDIT DIALOG
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final String typed = textEditingValue.text.trim();

                          if (typed.isEmpty) {
                            return activePresets;
                          }

                          final filtered = activePresets.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(typed.toLowerCase());
                          }).toList();

                          if (filtered.length == 1 &&
                              filtered.first.toLowerCase() ==
                                  typed.toLowerCase()) {
                            return activePresets;
                          }

                          final String addCustomFlag =
                              '__ADD_CUSTOM_CATEGORY_FLAG__:$typed';
                          if (!activePresets.any((element) =>
                              element.toLowerCase() == typed.toLowerCase())) {
                            filtered.insert(0, addCustomFlag);
                          }

                          return filtered;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: const Color(0xFF1E1E1E),
                              elevation: 4.0,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.72,
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final String option =
                                        options.elementAt(index);
                                    final bool isCustomAddAction =
                                        option.startsWith(
                                            '__ADD_CUSTOM_CATEGORY_FLAG__:');

                                    if (isCustomAddAction) {
                                      final String rawTypedValue = option
                                          .split(
                                              '__ADD_CUSTOM_CATEGORY_FLAG__:')
                                          .last;
                                      final String displayBtnLabel =
                                          _currentLocale == 'tl'
                                              ? '➕ MAGDAGDAG NG BAGONG KATEGORYA'
                                              : (_currentLocale == 'id'
                                                  ? '➕ TAMBAH KATEGORI BARU'
                                                  : '➕ ADD NEW CATEGORY');

                                      return Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00E676)
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: const Color(0xFF00E676),
                                              width: 1),
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          title: Text(
                                            displayBtnLabel,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFF00E676),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '"$rawTypedValue"',
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 11),
                                          ),
                                          onTap: () {
                                            onSelected(rawTypedValue);
                                          },
                                        ),
                                      );
                                    }

                                    return ListTile(
                                      dense: true,
                                      leading: const Icon(
                                          Icons.label_important_outline,
                                          color: Color(0xFFFFD700),
                                          size: 16),
                                      title: Text(option,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13)),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        onSelected: (String selection) {
                          titleCtrl.text = selection;

                          final String normKey = selection.toLowerCase().trim();
                          if (emojiMapping.containsKey(normKey)) {
                            setModalState(() {
                              emojiCtrl.text = emojiMapping[normKey]!;
                            });
                          }

                          _searchEmojiForCategory(
                            val: selection,
                            emojiCtrl: emojiCtrl,
                            setModalState: setModalState,
                          );
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          if (textEditingController.text.isEmpty &&
                              titleCtrl.text.isNotEmpty) {
                            textEditingController.text = titleCtrl.text;
                          }
                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: _getTxt('category_label'),
                              suffixIcon: textEditingController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.white54, size: 18),
                                      onPressed: () {
                                        setModalState(() {
                                          textEditingController.clear();
                                          titleCtrl.clear();
                                        });
                                      },
                                    )
                                  : const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFFFFD700)),
                            ),
                            onChanged: (val) async {
                              titleCtrl.text = val;
                              setModalState(() {});
                              if (val.trim().isNotEmpty) {
                                _searchEmojiForCategory(
                                  val: val,
                                  emojiCtrl: emojiCtrl,
                                  setModalState: setModalState,
                                );
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CommaFormatter()
                        ],
                        decoration: InputDecoration(
                            prefixText: '$_currentCurrency ',
                            labelText: _getTxt('amount_label')),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentLocale == 'tl'
                            ? 'Baguhin ang Icon / Emoji:'
                            : 'Change Icon / Emoji:',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 8,
                        children: [
                          ...quickPresets.map((emoji) {
                            final bool isSelected = emojiCtrl.text == emoji;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  emojiCtrl.text = emoji;
                                });
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFD700)
                                          .withValues(alpha: 0.2)
                                      : const Color(0xFF252525),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFD700)
                                        : Colors.white10,
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                ),
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            );
                          }),
                          GestureDetector(
                            onTap: () {
                              final customEmojiCtrl = TextEditingController(
                                  text: !quickPresets.contains(emojiCtrl.text)
                                      ? emojiCtrl.text
                                      : "");
                              showDialog(
                                context: context,
                                builder: (subContext) => AlertDialog(
                                  backgroundColor: const Color(0xFF252525),
                                  title: Text(
                                    _currentLocale == 'tl'
                                        ? 'Mag-type ng Custom Emoji'
                                        : 'Type Custom Emoji',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFFFD700),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: TextField(
                                    controller: customEmojiCtrl,
                                    autofocus: true,
                                    maxLength: 1,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 26),
                                    decoration: const InputDecoration(
                                        counterText: "", hintText: "✨"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(subContext),
                                      child: Text(_getTxt('btn_cancel'),
                                          style: const TextStyle(
                                              color: Colors.white30)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (customEmojiCtrl.text
                                            .trim()
                                            .isNotEmpty) {
                                          setModalState(() {
                                            emojiCtrl.text =
                                                customEmojiCtrl.text.trim();
                                          });
                                        }
                                        Navigator.pop(subContext);
                                      },
                                      child: const Text('OK',
                                          style: TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !quickPresets.contains(emojiCtrl.text) &&
                                        emojiCtrl.text.isNotEmpty
                                    ? const Color(0xFFFFD700)
                                        .withValues(alpha: 0.2)
                                    : const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      !quickPresets.contains(emojiCtrl.text) &&
                                              emojiCtrl.text.isNotEmpty
                                          ? const Color(0xFFFFD700)
                                          : Colors.white30,
                                  width: 1.5,
                                ),
                              ),
                              child: !quickPresets.contains(emojiCtrl.text) &&
                                      emojiCtrl.text.isNotEmpty
                                  ? Text(emojiCtrl.text,
                                      style: const TextStyle(fontSize: 20))
                                  : const Icon(Icons.add,
                                      color: Color(0xFFFFD700), size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today,
                            color: Color(0xFFFFD700)),
                        title: Text(_getTxt('date_label'),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white54)),
                        subtitle: Text(
                            DateFormat('yyyy-MM-dd').format(napilingPetsa),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: napilingPetsa,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFFFD700),
                                  onPrimary: Colors.black,
                                  surface: Color(0xFF1E1E1E),
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null && picked != napilingPetsa) {
                            setModalState(() {
                              napilingPetsa = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_getTxt('btn_cancel'),
                        style: const TextStyle(color: Colors.white30)),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (titleCtrl.text.isNotEmpty &&
                          amountCtrl.text.isNotEmpty) {
                        String oldKeyName = item.title.toLowerCase().trim();
                        String newKeyName = titleCtrl.text.toLowerCase().trim();
                        double newAmt = double.tryParse(
                                amountCtrl.text.replaceAll(',', '')) ??
                            0;
                        double kasalukuyangTotalIwan = all
                            .where((e) => e.id != item.id)
                            .fold(0, (sum, e) => sum + e.amount);
                        double bagongTotalIwan = kasalukuyangTotalIwan + newAmt;
                        double natitiraPagkatapos = budget - bagongTotalIwan;
                        Color updatedColor = colorMap[newKeyName] ?? item.color;
                        String finalEmoji = emojiCtrl.text.trim().isEmpty
                            ? "💰"
                            : emojiCtrl.text.trim();
                        final p = await SharedPreferences.getInstance();
// 🔥 MABUTING PAG-SAVE: I-save rin ang kategorya kapag binago ito sa Edit Window
                        // PALITAN ANG LINE 6824-6832 NG EKSAKTONG CODE NA ITO:
                        if (!defaultPresets.any((e) =>
                            e.toLowerCase() == titleCtrl.text.toLowerCase())) {
                          // 🔥 NAITAMA: Ginamit ang List<String>.from para maging List<String> ang savedCustom
                          List<String> savedCustom = List<String>.from(
                              p.getStringList('user_custom_categories') ?? []);

                          if (!savedCustom.any((e) =>
                              e.toLowerCase() ==
                              titleCtrl.text.toLowerCase())) {
                            savedCustom.add(titleCtrl.text.trim());
                            await p.setStringList(
                                'user_custom_categories', savedCustom);
                          }
                        }

                        setState(() {
                          item.title = titleCtrl.text.trim();
                          item.amount = newAmt;
                          item.color = updatedColor;
                          item.date = napilingPetsa;
                          for (var expense in all) {
                            if (expense.title.toLowerCase().trim() ==
                                    oldKeyName ||
                                expense.title.toLowerCase().trim() ==
                                    newKeyName) {
                              expense.iconEmoji = finalEmoji;
                            }
                          }
                        });
                        try {
                          for (var w in wallets) {
                            String? walletExpenseData =
                                p.getString('expenses${w.id}');
                            if (walletExpenseData != null) {
                              List parsedList = jsonDecode(walletExpenseData);
                              bool chunkModified = false;
                              for (var rawExp in parsedList) {
                                String rawTitle = rawExp['title']
                                    .toString()
                                    .toLowerCase()
                                    .trim();
                                if (rawTitle == oldKeyName ||
                                    rawTitle == newKeyName) {
                                  rawExp['iconEmoji'] = finalEmoji;
                                  chunkModified = true;
                                }
                              }
                              if (chunkModified) {
                                await p.setString(
                                    'expenses${w.id}', jsonEncode(parsedList));
                              }
                            }
                          }
                        } catch (_) {}
                        await saveData();
                        if (mounted) {
                          String editSuccessMsg = _currentLocale == 'tl'
                              ? 'Matagumpay na na-update ang gastos!'
                              : (_currentLocale == 'id'
                                  ? 'Catatan pengeluaran berhasil diperbarui!'
                                  : 'Expense successfully updated!');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(editSuccessMsg,
                                  style: const TextStyle(color: Colors.black)),
                              backgroundColor: const Color(0xFFFFD700),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        Navigator.pop(context);
                        if (natitiraPagkatapos <= 0) {
                          Future.delayed(const Duration(milliseconds: 150), () {
                            _showBudgetExhaustedAlert();
                          });
                        } else if (bagongTotalIwan >= (budget * 0.9)) {
                          Future.delayed(const Duration(milliseconds: 150), () {
                            _showNearLimitBudgetDialog(
                                kasalukuyangTotalIwan, newAmt);
                          });
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(_getTxt('btn_update'),
                        style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold)),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showUpgradeOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFD700), size: 26),
                      const SizedBox(width: 8),
                      Text(
                        _getTxt('pro_plan_title'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getTxt('pro_plan_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 20),
                  _buildPlanTile(
                    title: 'Monthly Plan',
                    price: '₱30 / month',
                    badgeText: 'Base Plan',
                    badgeColor: Colors.white24,
                    onTap: () {
                      Navigator.pop(context);
                      _buyPlan('gastos_ko_monthly');
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPlanTile(
                    title: 'Semi-Annual Plan',
                    price: '₱149 / 6 months',
                    badgeText: 'Save 17%',
                    badgeColor: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _buyPlan('gastos_ko_semiannual');
                    },
                  ),
                  _buildPlanTile(
                    title: 'Annual Plan',
                    price: '₱249 / 1 year',
                    badgeText: 'Best Value - Save 30%',
                    badgeColor: const Color(0xFF00E676),
                    isFeatured: true,
                    onTap: () {
                      Navigator.pop(context);
                      _buyPlan('gastos_ko_annual');
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanTile({
    required String title,
    required String price,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
    bool isFeatured = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFeatured ? const Color(0xFFFFD700) : Colors.white10,
          width: isFeatured ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isFeatured ? const Color(0xFFFFD700) : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor, width: 0.8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                      color: badgeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            price,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: isFeatured ? const Color(0xFFFFD700) : Colors.white30,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSummaryCard(
      {required String title,
      required String value,
      required Color color,
      required IconData icon,
      bool isFullWidth = false,
      bool highlightCard = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      // 🔥 Mas pino ang padding kapag compact mode (10 kumpara sa default na 16)
      padding: EdgeInsets.all(_isCompactMode ? 10 : 16),
      decoration: BoxDecoration(
        color: _boxBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      // 🔥 Mas maliit na upper label size kapag compact mode
                      fontSize: highlightCard
                          ? (_isCompactMode ? 11 : 13)
                          : (_isCompactMode ? 9 : 11),
                      color: _appFontColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600)),
              // 🔥 Mas maliit na icon size kapag compact mode
              Icon(icon,
                  color: color,
                  size: highlightCard
                      ? (_isCompactMode ? 16 : 19)
                      : (_isCompactMode ? 13 : 16)),
            ],
          ),
          // 🔥 Binawasan ang patlang mula 8 patungong 4 kapag compact mode
          SizedBox(height: _isCompactMode ? 4 : 8),
          Text(value,
              textAlign: TextAlign.start,
              style: TextStyle(
                  // 🔥 Matalinong pagpili ng laki ng halaga ng pera para hindi mag-overflow
                  fontSize: highlightCard
                      ? (_isCompactMode ? 20 : 26)
                      : (isFullWidth
                          ? (_isCompactMode ? 18 : 22)
                          : (_isCompactMode ? 15 : 18)),
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildSummaryCardDateFilters() {
    String customBtnLabel = _selectedDateRange == null
        ? (_currentLocale == 'tl' ? "Pumili ng Range" : "Pick Range")
        : "${DateFormat('MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd').format(_selectedDateRange!.end)}";
    final bool canInteract = !(_isTrialExpired && !_isPremiumUser);
    return Padding(
      // 🔥 Mula 12, ginawang 4 ang bottom padding kapag compact mode
      padding: EdgeInsets.only(bottom: _isCompactMode ? 4.0 : 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            ChoiceChip(
              // 🔥 Ginawang mas compact ang padding sa loob ng chip
              visualDensity: _isCompactMode
                  ? VisualDensity.compact
                  : VisualDensity.standard,
              label: Text(_getTxt('filter_all'),
                  style: TextStyle(fontSize: _isCompactMode ? 11 : 13)),
              selected: _activeDateFilter == "all",
              selectedColor: const Color(0xFFFFD700),
              labelStyle: TextStyle(
                  color: _activeDateFilter == "all"
                      ? Colors.black
                      : Colors.white70),
              onSelected: canInteract
                  ? (val) {
                      if (val) {
                        setState(() {
                          _activeDateFilter = "all";
                          selectedIndex = null;
                        });
                      }
                    }
                  : null,
            ),
            const SizedBox(width: 6),
            ChoiceChip(
              visualDensity: _isCompactMode
                  ? VisualDensity.compact
                  : VisualDensity.standard,
              label: Text(_getTxt('filter_today'),
                  style: TextStyle(fontSize: _isCompactMode ? 11 : 13)),
              selected: _activeDateFilter == "today",
              selectedColor: const Color(0xFFFFD700),
              labelStyle: TextStyle(
                  color: _activeDateFilter == "today"
                      ? Colors.black
                      : Colors.white70),
              onSelected: canInteract
                  ? (val) {
                      if (val) {
                        setState(() {
                          _activeDateFilter = "today";
                          selectedIndex = null;
                        });
                      }
                    }
                  : null,
            ),
            const SizedBox(width: 6),
            InputChip(
              visualDensity: _isCompactMode
                  ? VisualDensity.compact
                  : VisualDensity.standard,
              avatar: Icon(Icons.calendar_month,
                  size: _isCompactMode ? 14 : 16,
                  color: _activeDateFilter == "custom"
                      ? Colors.black
                      : const Color(0xFFFFD700)),
              label: Text(customBtnLabel,
                  style: TextStyle(fontSize: _isCompactMode ? 11 : 13)),
              selected: _activeDateFilter == "custom",
              selectedColor: const Color(0xFFFFD700),
              labelStyle: TextStyle(
                  color: _activeDateFilter == "custom"
                      ? Colors.black
                      : Colors.white70),
              onPressed: canInteract
                  ? () async {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        initialDateRange: _selectedDateRange,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFFFFD700),
                              onPrimary: Colors.black,
                              surface: Color(0xFF1E1E1E),
                              onSurface: Colors.white,
                              primaryContainer: Color(0xFFFFD700),
                              onPrimaryContainer: Colors.black,
                            ),
                            scaffoldBackgroundColor: const Color(0xFF121212),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDateRange = picked;
                          _activeDateFilter = "custom";
                          selectedIndex = null;
                        });
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List dateFilteredExpenses = all.where((item) {
      if (_activeDateFilter == "today") {
        final ngayon = DateTime.now();
        return item.date.year == ngayon.year &&
            item.date.month == ngayon.month &&
            item.date.day == ngayon.day;
      } else if (_activeDateFilter == "custom" && _selectedDateRange != null) {
        final startBoundary = DateTime(
            _selectedDateRange!.start.year,
            _selectedDateRange!.start.month,
            _selectedDateRange!.start.day,
            0,
            0,
            0);
        final endBoundary = DateTime(
            _selectedDateRange!.end.year,
            _selectedDateRange!.end.month,
            _selectedDateRange!.end.day,
            23,
            59,
            59);
        return item.date
                .isAfter(startBoundary.subtract(const Duration(seconds: 1))) &&
            item.date.isBefore(endBoundary.add(const Duration(seconds: 1)));
      }
      return true;
    }).toList();

    double totalGastos = all.fold(0, (sum, item) => sum + item.amount);
    Map<String, List> grouped = {};

    for (var e in dateFilteredExpenses) {
      String key = e.title.toLowerCase().trim();
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(e);

      if (!colorMap.containsKey(key)) {
        colorMap[key] = dynamicColors[colorMap.length % dynamicColors.length];
      }
      e.color = colorMap[key]!;
    }

    List chartData = [];
    grouped.forEach((key, list) {
      double sum = list.fold(0, (prev, e) => prev + e.amount);
      Color assignedColor = colorMap[key] ?? dynamicColors.first;
      String assignedEmoji = list.isNotEmpty ? list.first.iconEmoji : "💰";

      chartData.add(GroupedExpense(
        title: list.first.title,
        total: sum,
        color: assignedColor,
        count: list.length,
        iconEmoji: assignedEmoji,
      ));
    });

    chartData.sort((a, b) => b.total.compareTo(a.total));

    // 🔥 AUTOMATION ENGINE: Kung walang entries, gumawa ng multilinggwal na placeholder data para magpakita ang slider at bars
    List visibleChartDataForLayout = List.from(chartData);
    if (visibleChartDataForLayout.isEmpty) {
      String placeholderLabel =
          _currentLocale == 'tl' ? "Walang Gastos" : "No Expenses";
      visibleChartDataForLayout.add(GroupedExpense(
        title: placeholderLabel,
        total: 0.0,
        color: Colors.white24,
        count: 0,
        iconEmoji: "📉",
      ));
    }

    double totalGastosParaSaChart =
        dateFilteredExpenses.fold(0.0, (sum, item) => sum + item.amount);

    double natirangBudget = budget - totalGastos;
    String activeWalletName = "Main Wallet";
    for (var w in wallets) {
      if (w.id == activeWalletId) {
        activeWalletName = w.name;
        break;
      }
    }

    List finalFilteredExpenses = dateFilteredExpenses.where((item) {
      return item.title.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    if (_activeSortFilter == "latest") {
      finalFilteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    } else if (_activeSortFilter == "oldest") {
      finalFilteredExpenses.sort((a, b) => a.date.compareTo(b.date));
    } else if (_activeSortFilter == "highest") {
      finalFilteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_activeSortFilter == "lowest") {
      finalFilteredExpenses.sort((a, b) => a.amount.compareTo(b.amount));
    }

    final bool trialExpiredWithNoPremium = _isTrialExpired && !_isPremiumUser;

    String tabHome = _currentLocale == 'en'
        ? 'Home'
        : (_currentLocale == 'id' ? 'Beranda' : 'Dashboard');
    String tabGoals = _currentLocale == 'en'
        ? 'Goals'
        : (_currentLocale == 'id' ? 'Target' : 'Mga Ipon');
    String tabDebts = _currentLocale == 'en'
        ? 'Debts'
        : (_currentLocale == 'id' ? 'Utang' : 'Mga Utang');
    String tabConvert = _currentLocale == 'en'
        ? 'Convert'
        : (_currentLocale == 'id' ? 'Konversi' : 'Palitan');

    return Scaffold(
      backgroundColor: _appBgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('GASTOS KO',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 5,
              runSpacing: 2,
              children: [
                Text(
                    _isPremiumUser
                        ? 'Pro Active'
                        : (trialExpiredWithNoPremium
                            ? 'Trial Expired'
                            : 'Free Trial Version'),
                    style: TextStyle(
                        color: trialExpiredWithNoPremium
                            ? Colors.redAccent
                            : Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0.3)),
                Icon(
                  Icons.fiber_manual_record,
                  size: 6,
                  color: trialExpiredWithNoPremium
                      ? Colors.redAccent
                      : const Color(0xFF00E676),
                ),
                Text(
                  _isPremiumUser
                      ? _purchasedPlanTitle
                      : (trialExpiredWithNoPremium
                          ? 'Locked'
                          : '$_trialDaysLeft days left'),
                  style: TextStyle(
                      color: trialExpiredWithNoPremium
                          ? Colors.redAccent
                          : const Color(0xFF00E676),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF121212),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      DrawerHeader(
                        decoration:
                            const BoxDecoration(color: Color(0xFF1E1E1E)),
                        child: Row(
                          children: [
                            Image.asset('assets/icon.png',
                                width: 60,
                                height: 60,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.calculate,
                                        color: Color(0xFFFFD700), size: 60)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('GASTOS KO',
                                      style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isPremiumUser
                                        ? "Pro Active ($_purchasedPlanTitle)"
                                        : (trialExpiredWithNoPremium
                                            ? 'Trial Expired'
                                            : "Free Trial ($_trialDaysLeft days left)"),
                                    style: TextStyle(
                                      color: trialExpiredWithNoPremium
                                          ? Colors.redAccent
                                          : Colors.white38,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.language,
                            color: Color(0xFFFFD700)),
                        title: Text(_getTxt('lang_lbl'),
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                        trailing: DropdownButton(
                          value: _currentLocale,
                          dropdownColor: const Color(0xFF1E1E1E),
                          underline: const SizedBox(),
                          onChanged: (String? newLocale) {
                            if (newLocale != null) {
                              setState(() {
                                _currentLocale = newLocale;
                                saveData();
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                                value: 'en',
                                child: Text('🇺🇸 English(USA)',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'tl',
                                child: Text('🇵🇭 Tagalog(PHL)',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'id',
                                child: Text('🇮🇩 Bahasa(IDN)',
                                    style: TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      if (!_isPremiumUser) ...[
                        ListTile(
                          leading: const Icon(Icons.star_rounded,
                              color: Color(0xFFFFD700)),
                          title: Text(
                            _getTxt('upgrade_title'),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFD700)),
                          ),
                          subtitle: Text(
                            _getTxt('upgrade_subtitle'),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white38),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showUpgradeOptionsBottomSheet();
                          },
                        ),
                      ],
                      ListTile(
                        leading: const Icon(Icons.privacy_tip,
                            color: Color(0xFF00E676)),
                        title: Text(
                          _currentLocale == 'tl'
                              ? 'Patakaran sa Pagkapribado'
                              : _currentLocale == 'id'
                                  ? 'Kebijakan Privasi'
                                  : 'Privacy Policy', // Default kapag 'en'
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _launchComplianceUrl(
                              'https://docs.google.com/document/d/e/2PACX-1vTjonFfWFs9UiUqNne5Ro0c2ab2UhR1mnwe0E1BBl68qrK5gdaqWc9STAAvTAapBSve_7AuS8-rNNpx/pub');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.description,
                            color: Color(0xFF29B6F6)),
                        title: Text(
                          _currentLocale == 'tl'
                              ? 'Mga Tuntunin sa Paggamit'
                              : _currentLocale == 'id'
                                  ? 'Syarat Penggunaan'
                                  : 'Terms of Use (EULA)', // Default kapag 'en'
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _launchComplianceUrl(
                              'https://docs.google.com/document/d/e/2PACX-1vS4ekakFeVHrKq98abpasJFDV9tdEQGFWf9USDoSOADmlY859l75tURqA5qPrcbFwEKfMPb-Bg-hLpL/pub');
                        },
                      ),
                      ExpansionTile(
                        leading: const Icon(Icons.mail_outline,
                            color: Color(0xFFFFD700)),
                        title: Text(
                          _currentLocale == 'tl'
                              ? 'Makipag-ugnayan sa Amin'
                              : _currentLocale == 'id'
                                  ? 'Hubungi Kami'
                                  : 'Contact Us', // Default kapag 'en'
                          style: const TextStyle(fontSize: 14),
                        ),
                        iconColor: const Color(0xFFFFD700),
                        collapsedIconColor: Colors.white54,
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.only(left: 32),
                            leading: const Icon(Icons.bug_report,
                                color: Colors.redAccent, size: 20),
                            title: Text(
                              _currentLocale == 'tl'
                                  ? 'Mag-ulat ng Bug o Problema'
                                  : _currentLocale == 'id'
                                      ? 'Laporkan Bug o Masalah'
                                      : 'Report a Bug or Problem', // Default kapag 'en'
                              style: const TextStyle(
                                  fontSize:
                                      13), // Naka-set sa 13 base sa orihinal mong code
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _sendSupportEmail('GASTOS KO - Bug Report');
                            },
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.only(left: 32),
                            leading: const Icon(Icons.lightbulb_outline,
                                color: Colors.amber, size: 20),
                            title: Text(
                              _currentLocale == 'tl'
                                  ? 'Magpadala ng Mungkahi'
                                  : _currentLocale == 'id'
                                      ? 'Kirim Saran'
                                      : 'Send Suggestion', // Default kapag 'en'
                              style: const TextStyle(
                                  fontSize:
                                      13), // Naka-set sa 13 base sa orihinal mong code
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _sendSupportEmail('GASTOS KO - App Suggestion');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFFFFD700)),
                title: Text(
                    _currentLocale == 'en'
                        ? 'Settings'
                        : (_currentLocale == 'id'
                            ? 'Pengaturan'
                            : 'Mga Setting'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(
                    _currentLocale == 'en'
                        ? 'App configurations & reset'
                        : 'Mga config ng app & reset',
                    style:
                        const TextStyle(fontSize: 10, color: Colors.white38)),
                onTap: () {
                  Navigator.pop(context);
                  final TextEditingController newPinCtrl =
                      TextEditingController();
                  String settingsError = "";
                  showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setDialogState) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: Text(
                            _currentLocale == 'en'
                                ? 'Settings'
                                : (_currentLocale == 'id'
                                    ? 'Pengaturan'
                                    : 'Mga Setting'),
                            style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: EdgeInsets.zero,
                                    leading: const SizedBox(
                                      width: 28,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Icon(Icons.palette_outlined,
                                            color: Color(0xFFFFD700)),
                                      ),
                                    ),
                                    title: Text(
                                      _currentLocale == 'tl'
                                          ? 'Baguhin ang Kulay ng Background'
                                          : (_currentLocale == 'id'
                                              ? 'Ubah Warna Latar Belakang'
                                              : 'Change Background Color'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    iconColor: const Color(0xFFFFD700),
                                    collapsedIconColor: Colors.white54,
                                    children: [
                                      const SizedBox(height: 8),
                                      _buildPresetRowItem(
                                          "Classic Dark 🕶️",
                                          const Color(0xFF121212),
                                          Colors.white,
                                          const Color(0xFF1E1E1E),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Golden Pro 💼",
                                          Colors.black,
                                          const Color(0xFFFFD700),
                                          const Color(0xFF1A1916),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Midnight Neon 👾",
                                          const Color(0xFF0A001F),
                                          const Color(0xFF00FFCC),
                                          const Color(0xFF1A0B36),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Rose Gold 👑",
                                          const Color(0xFF1A1216),
                                          const Color(0xFFFFB7CE),
                                          const Color(0xFF2E1F27),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Deep Ocean ⚓",
                                          const Color(0xFF0B132B),
                                          const Color(0xFF48CAE4),
                                          const Color(0xFF1C2541),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Matte Commando 🎖️",
                                          const Color(0xFF1B221B),
                                          const Color(0xFFD4AF37),
                                          const Color(0xFF2A342A),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Sakura Pink 🌸",
                                          const Color(0xFF1F1619),
                                          const Color(0xFFFFC0CB),
                                          const Color(0xFF332025),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Lavender Dreams 🔮",
                                          const Color(0xFF120E2E),
                                          const Color(0xFFE0B0FF),
                                          const Color(0xFF241B4B),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Crimson Stealth 🚗",
                                          const Color(0xFF140D0D),
                                          const Color(0xFFFF4D4D),
                                          const Color(0xFF241717),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Mint Fresh 🍃",
                                          const Color(0xFF0F171A),
                                          const Color(0xFFB9F6CA),
                                          const Color(0xFF1C282C),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Barbie Dream 💅",
                                          const Color(0xFF2B0A1A),
                                          const Color(0xFFFF69B4),
                                          const Color(0xFF4A1530),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Cyberpunk ⚡",
                                          const Color(0xFF1A0033),
                                          const Color(0xFFFFF000),
                                          const Color(0xFF330066),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Emerald Luxury 💎",
                                          const Color(0xFF06140E),
                                          const Color(0xFF50C878),
                                          const Color(0xFF0D281C),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Ice Princess ❄️",
                                          const Color(0xFF0F1C2E),
                                          const Color(0xFFE0F7FA),
                                          const Color(0xFF1F3A60),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Chocolate Mocha ☕",
                                          const Color(0xFF1A110B),
                                          const Color(0xFFD7CCC8),
                                          const Color(0xFF2D1E15),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Cotton Candy 🍧",
                                          const Color(0xFF141724),
                                          const Color(0xFFFBB6CE),
                                          const Color(0xFF23293F),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Sunset Vibe 🌅",
                                          const Color(0xFF1F0D0D),
                                          const Color(0xFFFF9E79),
                                          const Color(0xFF3D1919),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Orchid Glam 💄",
                                          const Color(0xFF180A22),
                                          const Color(0xFFDA70D6),
                                          const Color(0xFF2E1542),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Stealth Carbon 🛹",
                                          const Color(0xFF0F0F0F),
                                          const Color(0xFF90A4AE),
                                          const Color(0xFF212121),
                                          setDialogState),
                                      _buildPresetRowItem(
                                          "Vintage Autumn 🍂",
                                          const Color(0xFF1B140E),
                                          const Color(0xFFFFB300),
                                          const Color(0xFF2E2216),
                                          setDialogState),
                                    ],
                                  ),
                                ),
                                const Divider(color: Colors.white10),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: EdgeInsets.zero,
                                    leading: const SizedBox(
                                      width: 28,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Icon(Icons.lock_outline,
                                            color: Color(0xFFFFD700)),
                                      ),
                                    ),
                                    title: Text(
                                      _currentLocale == 'tl'
                                          ? 'Palitan ang PIN Code'
                                          : (_currentLocale == 'id'
                                              ? 'Ubah Kode PIN'
                                              : 'Change PIN Code'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    iconColor: const Color(0xFFFFD700),
                                    collapsedIconColor: Colors.white54,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 24.0,
                                            right: 8.0,
                                            top: 4.0,
                                            bottom: 12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            TextField(
                                              controller: newPinCtrl,
                                              keyboardType:
                                                  TextInputType.number,
                                              obscureText: true,
                                              maxLength: 4,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  letterSpacing: 8),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                counterText: "",
                                                hintText: "••••",
                                                hintStyle: const TextStyle(
                                                    color: Colors.white24,
                                                    letterSpacing: 8),
                                                labelText: _currentLocale ==
                                                        'tl'
                                                    ? 'Ipasok ang Bagong 4-Digit PIN'
                                                    : (_currentLocale == 'id'
                                                        ? 'Masukkan PIN 4-Digit Baru'
                                                        : 'Enter New 4-Digit PIN'),
                                                labelStyle: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white54,
                                                    letterSpacing: 0),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .white
                                                                .withValues(
                                                                    alpha:
                                                                        0.2))),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFFFD700))),
                                              ),
                                            ),
                                            if (settingsError.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(settingsError,
                                                  style: const TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                            const SizedBox(height: 16),
                                            // 🔥 NAITAMA NA MULTILINGGWAL SAVE PIN BUTTON CONTROL ENGINE
                                            ElevatedButton(
                                              onPressed: () async {
                                                String pinInput =
                                                    newPinCtrl.text.trim();
                                                if (pinInput.length < 4) {
                                                  setDialogState(() {
                                                    // Sinasala ang error text base sa tatlong wika ng app
                                                    if (_currentLocale ==
                                                        'tl') {
                                                      settingsError =
                                                          'Pakilagay ng apat na numero!';
                                                    } else if (_currentLocale ==
                                                        'id') {
                                                      settingsError =
                                                          'Masukkan 4 digit angka!';
                                                    } else {
                                                      settingsError =
                                                          'Please input 4 digits!';
                                                    }
                                                  });
                                                  return;
                                                }
                                                final messenger =
                                                    ScaffoldMessenger.of(
                                                        context);
                                                final navigator =
                                                    Navigator.of(context);

                                                String successMessage = "";
                                                // Sinasala ang success SnackBar message base sa tatlong wika
                                                if (_currentLocale == 'tl') {
                                                  successMessage =
                                                      'Matagumpay na naitakda ang bagong PIN!';
                                                } else if (_currentLocale ==
                                                    'id') {
                                                  successMessage =
                                                      'PIN berhasil diubah!';
                                                } else {
                                                  successMessage =
                                                      'PIN successfully changed!';
                                                }

                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await prefs.setString(
                                                    'user_pincode', pinInput);
                                                setDialogState(() {
                                                  settingsError = "";
                                                  newPinCtrl.clear();
                                                });
                                                if (!mounted) return;
                                                navigator.pop();
                                                messenger.showSnackBar(SnackBar(
                                                    content:
                                                        Text(successMessage),
                                                    backgroundColor:
                                                        Colors.green));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFFFD700),
                                                  foregroundColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8))),
                                              child: Text(
                                                  _currentLocale == 'tl'
                                                      ? 'I-SAVE'
                                                      : (_currentLocale == 'id'
                                                          ? 'SIMPAN'
                                                          : 'SAVE'),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const Divider(color: Colors.white10),
                                // 🔥 NAITAMA NA MULTILINGGWAL PRIVACY MODE SWITCH
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  secondary: const SizedBox(
                                    width: 28,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.visibility_off_outlined,
                                          color: Color(0xFFFFD700)),
                                    ),
                                  ),
                                  title: Text(
                                    _currentLocale == 'en'
                                        ? 'Hide All Numbers'
                                        : (_currentLocale == 'id'
                                            ? 'Sembunyikan Semua Angka'
                                            : 'Itago ang mga Numero'),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    _currentLocale == 'en'
                                        ? 'Mask balances and costs from the dashboard'
                                        : (_currentLocale == 'id'
                                            ? 'Samarkan saldo dan pengeluaran dari dasbor'
                                            : 'Itago ang mga halaga at badyet sa screen'),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white38),
                                  ),
                                  value: _isPrivacyHideMode,
                                  activeColor: const Color(0xFFFFD700),
                                  onChanged: (bool value) async {
                                    setState(() {
                                      _isPrivacyHideMode = value;
                                    });
                                    setDialogState(() {});
                                    final p =
                                        await SharedPreferences.getInstance();
                                    await p.setBool(
                                        'user_privacy_hide_mode', value);
                                  },
                                ),

                                // 🔥 NAITAMA NA MULTILINGGWAL COMPACT MODE SWITCH
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  secondary: const SizedBox(
                                    width: 28,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.view_headline_rounded,
                                          color: Color(0xFFFFD700)),
                                    ),
                                  ),
                                  title: Text(
                                    _currentLocale == 'en'
                                        ? 'Compact Mode'
                                        : (_currentLocale == 'id'
                                            ? 'Mode Ringkas'
                                            : 'Compact Mode'),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    _currentLocale == 'en'
                                        ? 'Make dashboard layout smaller'
                                        : (_currentLocale == 'id'
                                            ? 'Perkecil tampilan tata letak dasbor'
                                            : 'Paliitin ang dashboard layout'),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white38),
                                  ),
                                  value: _isCompactMode,
                                  activeColor: const Color(0xFFFFD700),
                                  onChanged: (bool value) async {
                                    String dialogTitle = "";
                                    String dialogContent = "";
                                    String btnConfirmLabel = "";

                                    // Dinamikong pagsasalin ng Pop-up Confirmation Dialog
                                    if (_currentLocale == 'en') {
                                      dialogTitle = value
                                          ? "Enable Compact Mode?"
                                          : "Disable Compact Mode?";
                                      dialogContent = value
                                          ? "The main screen layout will shrink for a tighter list view. Do you want to proceed?"
                                          : "The main screen layout will return to the normal, larger size. Do you want to proceed?";
                                      btnConfirmLabel = "PROCEED";
                                    } else if (_currentLocale == 'id') {
                                      dialogTitle = value
                                          ? "Aktifkan Mode Ringkas?"
                                          : "Nonaktifkan Mode Ringkas?";
                                      dialogContent = value
                                          ? "Tata letak layar utama akan diperkecil untuk tampilan daftar yang lebih padat. Lanjutkan?"
                                          : "Tata letak layar utama akan kembali ke ukuran normal yang lebih besar. Lanjutkan?";
                                      btnConfirmLabel = "LANJUTKAN";
                                    } else {
                                      // Default ay Tagalog ('tl')
                                      dialogTitle = value
                                          ? "I-on ang Compact Mode?"
                                          : "I-off ang Compact Mode?";
                                      dialogContent = value
                                          ? "Liliit ang view ng iyong main screen para sa mas masikip na listahan. Nais mo bang ituloy?"
                                          : "Babalik sa normal at mas malaking sukat ang layout ng iyong main screen. Nais mo bang ituloy?";
                                      btnConfirmLabel = "ITULOY";
                                    }

                                    bool? shouldApply = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        backgroundColor:
                                            const Color(0xFF1E1E1E),
                                        title: Text(dialogTitle,
                                            style: const TextStyle(
                                                color: Color(0xFFFFD700),
                                                fontWeight: FontWeight.bold)),
                                        content: Text(dialogContent,
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text(_getTxt('btn_cancel'),
                                                  style: const TextStyle(
                                                      color: Colors.white30))),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: Text(btnConfirmLabel,
                                                  style: const TextStyle(
                                                      color: Color(0xFFFFD700),
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ],
                                      ),
                                    );
                                    if (shouldApply == true) {
                                      setState(() {
                                        _isCompactMode = value;
                                      });
                                      setDialogState(() {});
                                    }
                                  },
                                ),
                                const Divider(color: Colors.white10),

                                // 🔥 NAITAMA NA MULTILINGGWAL DATA MANAGEMENT LISTTILE
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const SizedBox(
                                    width: 28,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.cloud_sync_outlined,
                                          color: Color(0xFFFFD700)),
                                    ),
                                  ),
                                  title: Text(
                                    _currentLocale == 'en'
                                        ? 'Manage Your Data'
                                        : (_currentLocale == 'id'
                                            ? 'Kelola Data Anda'
                                            : 'I-manage ang Iyong Data'),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFD700)),
                                  ),
                                  subtitle: Text(
                                      _currentLocale == 'en'
                                          ? 'Backup or restore full application data'
                                          : (_currentLocale == 'id'
                                              ? 'Cadangkan atau pulihkan seluruh data aplikasi'
                                              : 'I-backup o i-restore ang buong app data'),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white38)),
                                  onTap: () {
                                    _showBackupAndRestoreOptionsDialog();
                                  },
                                ),

                                const Divider(color: Colors.white10),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const SizedBox(
                                    width: 28,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.delete_forever,
                                          color: Colors.redAccent),
                                    ),
                                  ),
                                  title: Text(_getTxt('reset_data'),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(_getTxt('reset_subtitle'),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white38)),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        backgroundColor:
                                            const Color(0xFF1E1E1E),
                                        title: Text(
                                            _getTxt('reset_confirm_title')),
                                        content:
                                            Text(_getTxt('reset_confirm_desc')),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(_getTxt('btn_cancel'),
                                                  style: const TextStyle(
                                                      color: Colors.white30))),
                                          TextButton(
                                              onPressed: () {
                                                clearAllApplicationData();
                                                Navigator.pop(context);
                                              },
                                              child: Text(_getTxt('btn_reset'),
                                                  style: const TextStyle(
                                                      color: Colors.redAccent,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                                _currentLocale == 'en'
                                    ? 'CLOSE'
                                    : (_currentLocale == 'id'
                                        ? 'TUTUP'
                                        : 'ISARA'),
                                style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          // ----------------------------------------------------
          // TAB index 0: HOME DASHBOARD SCREEN
          // ----------------------------------------------------
          Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 NAITAMA: Pinagsama sa isang Row ang Wallet Icon, Label, Export, at Wallet Manager
                        Row(
                          children: [
                            const Icon(Icons.wallet,
                                color: Color(0xFFFFD700), size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activeWalletName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _appFontColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            // 📥 INILIPAT DITO: Export Popup Button
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.ios_share_rounded,
                                color: trialExpiredWithNoPremium
                                    ? Colors.white10
                                    : const Color(0xFFFFD700),
                                size: 24,
                              ),
                              tooltip: _currentLocale == 'tl'
                                  ? 'I-export ang Data'
                                  : 'Export Data',
                              color: const Color(0xFF1E1E1E),
                              onSelected: (String value) {
                                if (value == 'csv') {
                                  _exportWalletToCSV(finalFilteredExpenses);
                                } else if (value == 'pdf') {
                                  _exportWalletToPDF(finalFilteredExpenses);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem<String>(
                                  value: 'pdf',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.picture_as_pdf_rounded,
                                          color: Colors.redAccent, size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        _currentLocale == 'tl'
                                            ? 'I-export sa PDF'
                                            : 'Export to PDF',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'csv',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.table_chart_rounded,
                                          color: Color(0xFF00E676), size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        _currentLocale == 'tl'
                                            ? 'I-export sa CSV'
                                            : 'Export to CSV',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // 💼 INILIPAT DITO: Wallet Manager Card Sheet Controller
                            IconButton(
                              icon: Icon(Icons.account_balance_wallet,
                                  color: trialExpiredWithNoPremium
                                      ? Colors.white10
                                      : const Color(0xFFFFD700),
                                  size: 24),
                              tooltip: _getTxt('wallet_manager'),
                              onPressed: _showWalletManagerDialog,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCardDateFilters(),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: _getTxt('total_budget'),
                                value: peso(budget),
                                color: const Color(0xFFFFD700),
                                icon: Icons.account_balance_wallet,
                              ),
                            ),
                            SizedBox(width: _isCompactMode ? 8 : 12),
                            Expanded(
                              child: _buildSummaryCard(
                                title: _getTxt('total_expenses'),
                                value: peso(totalGastos),
                                color: totalGastos > budget
                                    ? Colors.redAccent
                                    : (totalGastos >= budget * 0.9
                                        ? Colors.orangeAccent
                                        : const Color(0xFF00E676)),
                                icon: Icons.trending_up,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: _isCompactMode ? 8 : 12),
                        _buildSummaryCard(
                          title: _getTxt('remaining_budget'),
                          value: peso(natirangBudget),
                          color: natirangBudget < 0
                              ? Colors.redAccent
                              : (totalGastos >= budget * 0.9
                                  ? Colors.orangeAccent
                                  : Colors.greenAccent),
                          icon: Icons.monetization_on,
                          isFullWidth: true,
                          highlightCard: true,
                        ),
                        const SizedBox(height: 24),
                        Text(_getTxt('chart_title'),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _appFontColor.withValues(alpha: 0.7))),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: CustomPaint(
                              painter: PiePainter(
                                data: chartData,
                                total: totalGastosParaSaChart,
                                selectedIndex: selectedIndex,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        runWalletCategoryLegends(visibleChartDataForLayout),
                        const SizedBox(height: 16),
                        _buildFinancialTrendsAndGoalsCard(
                            totalGastos, natirangBudget),
                        const SizedBox(height: 24),
                        _buildInteractiveBarChartReport(
                            visibleChartDataForLayout),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_getTxt('history_title'),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _appFontColor.withValues(alpha: 0.7))),
                            Text('${finalFilteredExpenses.length} items',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.start,
                          children: [
                            _buildSortChip(
                                filterValue: "latest",
                                icon: Icons.access_time_rounded,
                                label: _currentLocale == 'tl'
                                    ? 'Pinakabago'
                                    : (_currentLocale == 'id'
                                        ? 'Terbaru'
                                        : 'Latest')),
                            _buildSortChip(
                                filterValue: "oldest",
                                icon: Icons.history_rounded,
                                label: _currentLocale == 'tl'
                                    ? 'Pinakaluma'
                                    : (_currentLocale == 'id'
                                        ? 'Terlama'
                                        : 'Oldest')),
                            _buildSortChip(
                                filterValue: "highest",
                                icon: Icons.arrow_upward_rounded,
                                label: _currentLocale == 'tl'
                                    ? 'Pinakamataas'
                                    : (_currentLocale == 'id'
                                        ? 'Tertinggi'
                                        : 'Highest')),
                            _buildSortChip(
                                filterValue: "lowest",
                                icon: Icons.arrow_downward_rounded,
                                label: _currentLocale == 'tl'
                                    ? 'Pinakamababa'
                                    : (_currentLocale == 'id'
                                        ? 'Terendah'
                                        : 'Lowest')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (all.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextField(
                              controller: _searchController,
                              enabled: !trialExpiredWithNoPremium,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: trialExpiredWithNoPremium
                                    ? _getTxt('search_disabled_hint')
                                    : _getTxt('search_hint'),
                                hintStyle: const TextStyle(
                                    color: Colors.white38, fontSize: 13),
                                prefixIcon: const Icon(Icons.search,
                                    color: Color(0xFFFFD700), size: 20),
                                suffixIcon: searchQuery.isNotEmpty &&
                                        !trialExpiredWithNoPremium
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            size: 18, color: Colors.white54),
                                        onPressed: () {
                                          setState(() {
                                            searchQuery = "";
                                            _searchController.clear();
                                          });
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: _boxBgColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 16),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.white10)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFFFD700), width: 1)),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  searchQuery = val.trim();
                                });
                              },
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (finalFilteredExpenses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                                child: Text(
                                    searchQuery.isNotEmpty
                                        ? _getTxt('no_match')
                                        : _getTxt('no_items'),
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontStyle: FontStyle.italic))),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: finalFilteredExpenses.length,
                            itemBuilder: (context, index) {
                              final item = finalFilteredExpenses[index];
                              return Card(
                                color: _boxBgColor,
                                margin: EdgeInsets.symmetric(
                                    vertical: _isCompactMode ? 2 : 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: _isCompactMode
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4)
                                      : const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                  leading: CircleAvatar(
                                    radius: _isCompactMode ? 16 : 20,
                                    backgroundColor: item.color,
                                    child: Text(
                                      item.iconEmoji,
                                      style: TextStyle(
                                          fontSize: _isCompactMode ? 16 : 20,
                                          color: null),
                                    ),
                                  ),
                                  title: _isCompactMode
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(item.title,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: item.color,
                                                    fontSize: 13)),
                                            const SizedBox(height: 1),
                                            Text(
                                                DateFormat(
                                                        'MMM dd, yyyy - hh:mm a')
                                                    .format(item.date),
                                                style: const TextStyle(
                                                    color: Colors.white38,
                                                    fontSize: 10)),
                                          ],
                                        )
                                      : Text(item.title,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: item.color,
                                              fontSize: 14)),
                                  subtitle: _isCompactMode
                                      ? null
                                      : Text(
                                          DateFormat('MMM dd, yyyy - hh:mm a')
                                              .format(item.date),
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 12)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(peso(item.amount),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _appFontColor,
                                              fontSize:
                                                  _isCompactMode ? 13 : 14)),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: trialExpiredWithNoPremium
                                              ? Colors.white10
                                              : const Color(0xFFFFD700),
                                          size: 20,
                                        ),
                                        onPressed: trialExpiredWithNoPremium
                                            ? null
                                            : () =>
                                                _showEditExpenseDialog(item),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline,
                                            color: trialExpiredWithNoPremium
                                                ? Colors.white10
                                                : Colors.redAccent,
                                            size: 20),
                                        onPressed: trialExpiredWithNoPremium
                                            ? null
                                            : () {
                                                setState(() {
                                                  all.remove(item);
                                                  saveData();
                                                });
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                ),
              ),
              _buildTourOverlayOverlay(),
            ],
          ),
// ----------------------------------------------------
// TAB index 1: SAVINGS GOALS LIVE ACCESS INTERFACE
// ----------------------------------------------------
          SavingsGoalsPage(
            currentLocale: _currentLocale,
            savingsGoals: savingsGoals,
            pesoFormatter: (amount) => peso(amount),
            boxBgColor: _boxBgColor,
            fontColor: _appFontColor,
            onCreateNewGoal: () {
              _showCreateNewGoalDialog(
                onSaveSuccess: () {
                  setState(() {});
                },
              );
            },
            onEditGoal: (goal) {
              _showEditSingleGoalDialog(goal);
            },
            onDeleteGoal: (goal) {
              _showDeleteGoalConfirm(goal);
            },
          ),
// ----------------------------------------------------
// TAB index 2: DEBT TRACKER SCREEN PLACEHOLDER
// ----------------------------------------------------
          DebtsPage(
            debtsList: debts,
            currentLocale: _currentLocale,
            currentCurrency: _currentCurrency,
            pesoFormatter: (amount) => peso(amount),
            globalCurrencies: globalCurrencies,
            openCurrencySearchPicker: _openCurrencySearchPicker,
            boxBgColor: _boxBgColor,
            fontColor: _appFontColor,
            onDataChanged: () {
              _saveDebtsData();
              setState(() {});
            },
            showSuccessPopup: (
                {required String title,
                required String message,
                required String emoji}) {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                        ),
                        child: const Text('OKAY',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ── BOTT// ── BOTTOM NAVIGATION BAR STRUCTURE ──
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (int idx) {
          setState(() {
            _currentTabIndex = idx;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white30,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded), label: tabHome),
          BottomNavigationBarItem(
              icon: const Icon(Icons.track_changes_rounded), label: tabGoals),
          BottomNavigationBarItem(
              icon: const Icon(Icons.money_off_csred_rounded), label: tabDebts),
        ],
      ),
// ── FLOATING ACTION PLUS BUTTON CONTROL ──
      floatingActionButton: _currentTabIndex == 0
          ? SizedBox(
              width: 38,
              height: 38,
              child: FloatingActionButton(
                backgroundColor: _isTrialExpired && !_isPremiumUser
                    ? Colors.grey
                    : const Color(0xFFFFD700),
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.black, size: 24),
                onPressed: () {
                  if (_isTrialExpired && !_isPremiumUser) {
                    _showUpgradeOptionsBottomSheet();
                  } else {
                    _checkBudgetBeforeAdding();
                  }
                },
              ),
            )
          : null,
    ); // 👈 Isinasara nito ang Scaffold widget
  } // 👈 Isinasara nito ang Widget build(BuildContext context) method

  // ⚠️ DAPAT WALANG MAGSASARANG KULOT NA BRACKET ( } ) DITO!
  // Ang 'runWalletCategoryLegends' at '_buildPresetRowItem' ay DAPAT nasa loob pa rin ng class.

  Widget runWalletCategoryLegends(List chartData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount =
            _isCompactMode ? 3 : (constraints.maxWidth > 400 ? 3 : 2);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: chartData.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            mainAxisExtent: _isCompactMode ? 32 : 40,
          ),
          itemBuilder: (context, index) {
            final item = chartData[index];
            final bool isSelected = selectedIndex == index;

            // 🔥 GUMAGAWA NG UNIQUE KEY PARA SA LOKASYON NG CARD BOX
            final GlobalKey itemKey = GlobalKey();

            return GestureDetector(
              key: itemKey, // Ikakabit ang key para ma-track ang pwesto ng card
              onTap: () {
                setState(() {
                  selectedIndex = isSelected ? null : index;
                });

                if (selectedIndex == index) {
                  // Kunin ang eksaktong posisyon ng pinindot na card sa screen ng cellphone
                  final RenderBox? renderBox =
                      itemKey.currentContext?.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final position = renderBox.localToGlobal(Offset.zero);

                    late OverlayEntry overlayEntry;
                    overlayEntry = OverlayEntry(
                      builder: (subContext) => Positioned(
                        // Ipupuwesto ang pop-out malapit sa tapat ng card area
                        top: position.dy - 34,
                        left: position.dx + 4,
                        child: Material(
                          color: Colors.transparent,
                          child: IntrinsicWidth(
                            // 🔥 ETO ANG SULUSYON: Kasing-haba lang ng teksto ang sukat ng background bubble!
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth *
                                    0.8, // Limit para hindi lumampas sa screen kung sobrang haba
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25252D),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: item.color, width: 1.2),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 2))
                                ],
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min, // Tipirin ang espasyo
                                children: [
                                  Text(item.iconEmoji,
                                      style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${item.title}: ${peso(item.total)}",
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    Overlay.of(context).insert(overlayEntry);

                    // Awtomatikong maglalaho o mabubura ang maliit na bubble pagkatapos ng 2.5 segundo
                    Future.delayed(const Duration(milliseconds: 2500), () {
                      if (overlayEntry.mounted) {
                        overlayEntry.remove();
                      }
                    });
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    EdgeInsets.symmetric(horizontal: _isCompactMode ? 4 : 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withValues(alpha: 0.25)
                      : _boxBgColor,
                  borderRadius: BorderRadius.circular(_isCompactMode ? 6 : 12),
                  border: Border.all(
                    color: isSelected ? item.color : Colors.white10,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: _isCompactMode ? 2.5 : 5,
                      height: _isCompactMode ? 12 : 16,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: _isCompactMode ? 3 : 8),
                    Text(
                      item.iconEmoji,
                      style: TextStyle(
                        fontSize: _isCompactMode ? 11 : 14,
                        color: null,
                      ),
                    ),
                    SizedBox(width: _isCompactMode ? 3 : 6),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "${item.title}: ",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: _isCompactMode ? 8.5 : 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: item.color,
                              ),
                            ),
                          ),
                          Text(
                            peso(item.total),
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: _isCompactMode ? 8.5 : 11,
                                fontWeight: FontWeight.bold,
                                color: item.color),
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
      },
    );
  }

  Widget _buildPresetRowItem(String label, Color bg, Color font, Color box,
      StateSetter setDialogState) {
    final bool isCurrentSelected = _appBgColor.value == bg.value &&
        _appFontColor.value == font.value &&
        _boxBgColor.value == box.value;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: box.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isCurrentSelected ? font : Colors.white10, width: 1.8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        title: Text(label,
            style: TextStyle(
                color: font, fontWeight: FontWeight.bold, fontSize: 13)),
        trailing: isCurrentSelected
            ? Icon(Icons.radio_button_checked, color: font, size: 18)
            : const Icon(Icons.radio_button_off,
                color: Colors.white24, size: 18),
        onTap: () async {
          setState(() {
            _appBgColor = bg;
            _appFontColor = font;
            _boxBgColor = box;
          });
          setDialogState(() {});
          final p = await SharedPreferences.getInstance();
          await p.setInt('app_background_color_value', bg.toARGB32());
          await p.setInt('app_font_color_value', font.toARGB32());
          await p.setInt('app_box_color_value', box.toARGB32());
        },
      ),
    );
  }
} // 🔥 ANG KULOT NA BRACKET NA ITO ANG DAPAT NASA PINAKADULO NG HOMESCREENSTATE!

// ==========================================
// 📦 CORE DATA MODELS FOR DEBT TRACKER MODULE
// ==========================================

// ====================================================
// 🎯 GLOBAL SAVINGS GOALS MODULE CLASSES (Root-Level)
// ====================================================
class SavingsGoalsPage extends StatefulWidget {
  final String currentLocale;
  final List<SavingsGoal> savingsGoals;
  final Function(SavingsGoal) onEditGoal;
  final Function(SavingsGoal) onDeleteGoal;
  final VoidCallback onCreateNewGoal;
  final String Function(double) pesoFormatter;
  final Color boxBgColor;
  final Color fontColor;

  const SavingsGoalsPage({
    super.key,
    required this.currentLocale,
    required this.savingsGoals,
    required this.onEditGoal,
    required this.onDeleteGoal,
    required this.onCreateNewGoal,
    required this.pesoFormatter,
    required this.boxBgColor,
    required this.fontColor,
  });

  @override
  State<SavingsGoalsPage> createState() => _SavingsGoalsPageState();
}

class _SavingsGoalsPageState extends State<SavingsGoalsPage> {
  // 🔥 IDINAGDAG: Mga variable para sa sorting control engine at search query tracking
  String searchGoalQuery = "";
  String _currentGoalSortCriteria = 'latest'; // Default sorting value

  @override
  Widget build(BuildContext context) {
    String _translate(String en, String id, String fil) {
      if (widget.currentLocale == 'en') return en;
      if (widget.currentLocale == 'id') return id;
      return fil;
    }

    // 🔍 1. FILTRATION LAYER: Sinasala muna ang listahan base sa text search input box
    List<SavingsGoal> processedGoals = widget.savingsGoals.where((goal) {
      return goal.name.toLowerCase().contains(searchGoalQuery.toLowerCase());
    }).toList();

    // 📊 2. SORTING ENGINE SYSTEM: Isinasaayos ang pagkakasunod-sunod base sa napiling dropdown option
    if (_currentGoalSortCriteria == 'latest') {
      // Pinakabagong gawa (base sa id timestamp na millisecondsSinceEpoch)
      processedGoals.sort((a, b) => b.id.compareTo(a.id));
    } else if (_currentGoalSortCriteria == 'oldest') {
      // Pinakalumang gawa
      processedGoals.sort((a, b) => a.id.compareTo(b.id));
    } else if (_currentGoalSortCriteria == 'highest') {
      // Pinakamataas na target amount
      processedGoals.sort((a, b) => b.targetAmount.compareTo(a.targetAmount));
    } else if (_currentGoalSortCriteria == 'lowest') {
      // Pinakamababang target amount
      processedGoals.sort((a, b) => a.targetAmount.compareTo(b.targetAmount));
    }

    String txtSortLabel =
        _translate("Sort by:", "Urutkan:", "I-sort gamit ang:");

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          _translate("SAVINGS MILESTONES", "TARGET TABUNGAN", "MAG IPON"),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.fontColor,
              fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INTERACTIVE INPUT SEARCH BAR FIELD WIDGET
            TextField(
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: _translate('Search savings goals...',
                    'Cari target...', 'Maghanap ng layunin sa ipon...'),
                hintStyle: TextStyle(
                    color: widget.fontColor.withValues(alpha: 0.35),
                    fontSize: 13),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFFFFD700), size: 20),
                suffixIcon: searchGoalQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            size: 18,
                            color: widget.fontColor.withValues(alpha: 0.5)),
                        onPressed: () {
                          setState(() {
                            searchGoalQuery = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: widget.boxBgColor,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFFFD700), width: 1)),
              ),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: searchGoalQuery,
                  selection:
                      TextSelection.collapsed(offset: searchGoalQuery.length),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchGoalQuery = val.trim();
                });
              },
            ),

            // 🔥 IDINAGDAG: THE INTERACTIVE DROPDOWN SORTING CONTROL ROW (Eksaktong disenyo mula sa Utang Screen)
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.sort_rounded,
                    color: widget.fontColor.withValues(alpha: 0.7), size: 16),
                const SizedBox(width: 6),
                Text(txtSortLabel,
                    style: TextStyle(
                        color: widget.fontColor.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: widget.boxBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _currentGoalSortCriteria,
                      dropdownColor: widget.boxBgColor,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Color(0xFFFFD700), size: 18),
                      style: TextStyle(
                          color: widget.fontColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _currentGoalSortCriteria = newValue;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem(
                            value: 'latest',
                            child: Text(
                                _translate("Latest", "Terbaru", "Pinakabago"))),
                        DropdownMenuItem(
                            value: 'oldest',
                            child: Text(
                                _translate("Oldest", "Terlama", "Pinakaluma"))),
                        DropdownMenuItem(
                            value: 'highest',
                            child: Text(_translate(
                                "Highest", "Tertinggi", "Pinakamataas"))),
                        DropdownMenuItem(
                            value: 'lowest',
                            child: Text(_translate(
                                "Lowest", "Terendah", "Pinakamababa"))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // SINKRONAYS DETECTION SYSTEM LAYER
            if (processedGoals.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.track_changes,
                          size: 60, color: Colors.white12),
                      const SizedBox(height: 16),
                      Text(
                        searchGoalQuery.isNotEmpty
                            ? (_translate(
                                "No matching goals found.",
                                "Target tidak ditemukan.",
                                "Walang nahanap na tugmang layunin."))
                            : _translate(
                                "No active goals. Tap (+) to create one!",
                                "Belum ada target aktif. Ketuk (+) para menambahkan!",
                                "Walang aktibong layunin. I-click ang (+) para magdagdag!"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: widget.fontColor.withValues(alpha: 0.4),
                            fontSize: 14,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: processedGoals.length,
                  itemBuilder: (context, index) {
                    final goal = processedGoals[index];
                    int daysRemaining =
                        goal.deadline.difference(DateTime.now()).inDays;
                    if (daysRemaining < 0) daysRemaining = 0;

                    double progress = goal.targetAmount > 0
                        ? (goal.savedAmount / goal.targetAmount) * 100
                        : 0.0;
                    if (progress > 100) progress = 100;

                    int displayProgressPercentage = progress.floor();
                    if (goal.savedAmount >= goal.targetAmount) {
                      displayProgressPercentage = 100;
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        _navigateToDetailsPage(goal);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: widget.boxBgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.15),
                              width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(goal.name.toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFFFFD700))),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert,
                                      color: widget.fontColor
                                          .withValues(alpha: 0.5),
                                      size: 20),
                                  color: const Color(0xFF252525),
                                  onSelected: (String action) {
                                    if (action == 'deposit') {
                                      // 🔥 NAITAMA: Sa halip na tawagin ang popup dialog, direkta na nitong bubuksan ang Details Page/Add Funds page!
                                      _navigateToDetailsPage(goal);
                                    } else if (action == 'edit_name') {
                                      _showEditGoalNameDialog(goal);
                                    } else if (action == 'edit_amount') {
                                      _showEditGoalAmountDialog(goal);
                                    } else if (action == 'delete') {
                                      widget.onDeleteGoal(goal);
                                    }
                                  },
                                  itemBuilder: (ctx) {
                                    final bool isGoalCompleted =
                                        goal.savedAmount >= goal.targetAmount;
                                    return [
                                      PopupMenuItem<String>(
                                        value:
                                            isGoalCompleted ? null : 'deposit',
                                        enabled: !isGoalCompleted,
                                        child: Row(
                                          children: [
                                            Icon(Icons.add_circle_outline,
                                                color: isGoalCompleted
                                                    ? Colors.white24
                                                    : const Color(0xFF00E676),
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              _translate(
                                                  "Add Deposit",
                                                  "Tambah Setoran",
                                                  "Maghulog sa Ipon"),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: isGoalCompleted
                                                      ? Colors.white24
                                                      : Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 🔥 PINAGHIWALAY NA ITEM 1: EDIT NAME
                                      PopupMenuItem<String>(
                                        value: 'edit_name',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.edit_note,
                                                color: Color(0xFFFFD700),
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              _translate(
                                                  "Edit Name",
                                                  "Ubah Nama",
                                                  "I-edit ang Pangalan"),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 🔥 PINAGHIWALAY NA ITEM 2: EDIT AMOUNT
                                      PopupMenuItem<String>(
                                        value: 'edit_amount',
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.monetization_on_outlined,
                                                color: Color(0xFFFFD700),
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              _translate(
                                                  "Edit Amount",
                                                  "Ubah Jumlah",
                                                  "I-edit ang Halaga"),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete_outline,
                                                color: Colors.redAccent,
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              _translate(
                                                  "Delete", "Hapus", "Burahin"),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${_translate('Saved: ', 'Terkumpul: ', 'Naipon: ')}${goal.currencySymbol}${NumberFormat('#,##0', 'en_US').format(goal.savedAmount.toInt())}",
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00E676)),
                                ),
                                Text(
                                  "${_translate('Target: ', 'Target: ', 'Target: ')}${goal.currencySymbol}${NumberFormat('#,##0', 'en_US').format(goal.targetAmount.toInt())}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: widget.fontColor
                                          .withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Deadline: ${DateFormat('yyyy-MM-dd').format(goal.deadline)}",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: widget.fontColor
                                            .withValues(alpha: 0.38))),
                                Text(
                                    _translate(
                                        "$daysRemaining days left",
                                        "$daysRemaining hari lagi",
                                        "$daysRemaining araw na lang"),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.orangeAccent,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress / 100,
                                      backgroundColor: widget.fontColor
                                          .withValues(alpha: 0.1),
                                      valueColor: const AlwaysStoppedAnimation(
                                          Color(0xFFFFD700)),
                                      minHeight: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text("$displayProgressPercentage%",
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFD700))),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: widget.onCreateNewGoal,
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                _translate(
                    "CREATE NEW SAVINGS GOAL",
                    "BUAT TARGET TABUNGAN BARU",
                    "MAGDAGDAG NG LAYUNIN SA IPON"),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 TAMANG IMPLEMENTASYON (FIX): Ligtas na paglipat patungo sa Details Page
  void _navigateToDetailsPage(SavingsGoal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailsPage(
          goal: goal,
          currentLocale: widget.currentLocale,
          pesoFormatter: widget.pesoFormatter,
          fontColor: widget.fontColor,
          boxBgColor: widget.boxBgColor,
          showSuccessPopup: (
              {required String title,
              required String message,
              required String emoji}) {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12, height: 1.4)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: const Text('OKAY',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
          onDataChanged: () async {
            final p = await SharedPreferences.getInstance();
            await p.setString(
                'app_savings_goals',
                jsonEncode(
                    widget.savingsGoals.map((g) => g.toJson()).toList()));
            setState(() {});
          },
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  // 🔥 BAGONG FUNCTION (FIX): Automated modal builder para sa direct deposit sheet panel setup
  void _showDirectDepositDialog(SavingsGoal goal) {
    final TextEditingController amountCtrl = TextEditingController();
    String sym = goal.currencySymbol.isNotEmpty ? goal.currencySymbol : "₱";
    double kasalukuyangKulang = goal.targetAmount - goal.savedAmount;
    if (kasalukuyangKulang < 0) kasalukuyangKulang = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              _translate("Add Deposit", "Tambah Setoran", "Maghulog sa Ipon"),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            content: TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CommaFormatter()
              ],
              decoration: InputDecoration(
                prefixText: '$sym ',
                prefixStyle: const TextStyle(
                    color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                labelText: _translate(
                    "Deposit Amount", "Jumlah Setoran", "Halaga ng Ihuhulog"),
                labelStyle:
                    const TextStyle(color: Colors.white54, fontSize: 12),
                helperText:
                    '${_translate("Remaining needed:", "Sisa yang dibutuhkan:", "Natitirang kulang:")} $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}',
                helperStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_translate("Cancel", "Batal", "Kanselahin"),
                    style: const TextStyle(color: Colors.white38)),
              ),
              TextButton(
                onPressed: () async {
                  final String cleanText =
                      amountCtrl.text.replaceAll(',', '').trim();
                  final double? amt = double.tryParse(cleanText);
                  if (amt == null || amt <= 0) return;

                  if (goal.savedAmount >= goal.targetAmount) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_translate(
                            "Cannot add deposit because this goal is already 100% completed! 🛑",
                            "Tidak maaari menambah setoran karena target sudah tercapai 100%! 🛑",
                            "Bawal na maghulog dahil nakamit na ang 100% ng iyong target! 🛑")),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  if ((goal.savedAmount + amt) > goal.targetAmount) {
                    double natitirangKulang =
                        goal.targetAmount - goal.savedAmount;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_translate(
                            "Excess deposit amount! Remaining allowed is $sym${NumberFormat('#,##0', 'en_US').format(natitirangKulang.toInt())}",
                            "Jumlah setoran berlebih! Sisa yang diperbolehkan adalah $sym${NumberFormat('#,##0', 'en_US').format(natitirangKulang.toInt())}",
                            "Sobra ang iyong ihuhulog! Ang natitirang kulang na lang ay $sym${NumberFormat('#,##0', 'en_US').format(natitirangKulang.toInt())}")),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                    return;
                  }

                  double bagongNaipon = goal.savedAmount + amt;

                  setState(() {
                    goal.deposits
                        .add(GoalDeposit(amount: amt, date: DateTime.now()));
                    goal.savedAmount = bagongNaipon;
                  });

                  final p = await SharedPreferences.getInstance();
                  await p.setString(
                      'app_savings_goals',
                      jsonEncode(
                          widget.savingsGoals.map((g) => g.toJson()).toList()));

                  if (mounted) {
                    Navigator.pop(
                        context); // Isasara ang input sheet dialog box

                    // 🎉 KUMPIRMASYON PROMPT WINDOW (KATULAD SA EDIT NAME)
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                bagongNaipon >= goal.targetAmount
                                    ? "🎉🏆"
                                    : "💰✨",
                                style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text(
                              bagongNaipon >= goal.targetAmount
                                  ? _translate(
                                      "TARGET ACHIEVED! 🥳",
                                      "TARGET TERCAPAI! 🥳",
                                      "CONGRATULATIONS! 🥳")
                                  : _translate(
                                      "DEPOSIT ADDED!",
                                      "SETORAN DITAMBAHKAN!",
                                      "NAIHULOG NA MAAYOS!"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bagongNaipon >= goal.targetAmount
                                  ? _translate(
                                      "You have successfully saved the full amount for ${goal.name.toUpperCase()}!",
                                      "Anda telah berhasil menabung seluruh dana untuk ${goal.name.toUpperCase()}!",
                                      "Matagumpay mong naipon ang buong pondo para sa ${goal.name.toUpperCase()}!")
                                  : _translate(
                                      "Successfully added $sym${NumberFormat('#,##0', 'en_US').format(amt.toInt())} to your savings!",
                                      "Berhasil menambahkan $sym${NumberFormat('#,##0', 'en_US').format(amt.toInt())} ke tabungan Anda!",
                                      "Matagumpay na naidagdag ang $sym${NumberFormat('#,##0', 'en_US').format(amt.toInt())} sa iyong ipon!"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                              ),
                              child: Text(_translate("OKAY", "OK", "SIGE"),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
                child: Text(_translate("Deposit", "Setor", "Ihulog"),
                    style: const TextStyle(
                        color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }

  String _translate(String en, String id, String fil) {
    if (widget.currentLocale == 'en') return en;
    if (widget.currentLocale == 'id') return id;
    return fil;
  }

  // ── 🔥 FUNCTION 1: DIALOG PARA SA EDIT NAME NG GOAL ──
  void _showEditGoalNameDialog(SavingsGoal goal) {
    final nameCtrl = TextEditingController(text: goal.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: Text(
          _translate("Edit Name", "Ubah Nama", "I-edit ang Pangalan"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: nameCtrl,
          textCapitalization: TextCapitalization.words,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_translate("Cancel", "Batal", "Kanselahin"),
                style: const TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              setState(() {
                goal.name = nameCtrl.text.trim();
              });

              final p = await SharedPreferences.getInstance();
              await p.setString(
                  'app_savings_goals',
                  jsonEncode(
                      widget.savingsGoals.map((g) => g.toJson()).toList()));

              if (mounted) {
                Navigator.pop(context);
                // 🎉 Pormal na prompt na na-update ang pangalan
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("📝✨", style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          _translate("NAME UPDATED!", "NAMA DIPERBARUI!",
                              "NA-UPDATE ANG PANGALAN!"),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black),
                          child: Text(_translate("OKAY", "OK", "SIGE")),
                        )
                      ],
                    ),
                  ),
                );
              }
            },
            child: Text(_translate("Save", "Simpan", "I-save"),
                style: const TextStyle(
                    color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ── 🔥 FUNCTION 2: DIALOG PARA SA EDIT AMOUNT NG GOAL ──
  void _showEditGoalAmountDialog(SavingsGoal goal) {
    final targetCtrl = TextEditingController(
        text: NumberFormat('#,##0', 'en_US').format(goal.targetAmount.toInt()));
    String sym = goal.currencySymbol.isNotEmpty ? goal.currencySymbol : "₱";
    String internalErrorText = "";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          title: Text(
            _translate("Edit Target Amount", "Ubah Jumlah Target",
                "I-edit ang Target na Halaga"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CommaFormatter()
                ],
                decoration: InputDecoration(
                  prefixText: '$sym ',
                  labelText: _translate(
                      "Target Amount", "Jumlah Target", "Target na Halaga"),
                ),
              ),
              if (internalErrorText.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(internalErrorText,
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_translate("Cancel", "Batal", "Kanselahin"),
                  style: const TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () async {
                final String cleanText =
                    targetCtrl.text.replaceAll(',', '').trim();
                final double? parsedTarget = double.tryParse(cleanText);
                if (parsedTarget == null || parsedTarget <= 0) return;

                // 🛑 Live validation check laban sa kasalukuyang naipon
                if (parsedTarget < goal.savedAmount) {
                  setDialogState(() {
                    internalErrorText = _translate(
                        "Target cannot be lower than the already saved amount!",
                        "Batas target tidak boleh lebih rendah dari jumlah terkumpul!",
                        "Ang target ay hindi maaaring mas mababa sa naipon na pondo!");
                  });
                  return;
                }

                setState(() {
                  goal.targetAmount = parsedTarget;
                });
                final p = await SharedPreferences.getInstance();
                await p.setString(
                    'app_savings_goals',
                    jsonEncode(
                        widget.savingsGoals.map((g) => g.toJson()).toList()));

                if (mounted) {
                  Navigator.pop(context);
                  // 🎉 Pormal na prompt na na-update ang halaga ng target
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("💰✨", style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text(
                            _translate("AMOUNT UPDATED!", "JUMLAH DIPERBARUI!",
                                "NA-UPDATE ANG HALAGA!"),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black),
                            child: Text(_translate("OKAY", "OK", "SIGE")),
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
              child: Text(_translate("Save", "Simpan", "I-save"),
                  style: const TextStyle(
                      color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

class GoalDetailsPage extends StatefulWidget {
  final SavingsGoal goal;
  final String currentLocale;
  final String Function(double) pesoFormatter;
  final VoidCallback onDataChanged;
  final Function(
      {required String title,
      required String message,
      required String emoji}) showSuccessPopup;
  final Color boxBgColor;
  final Color fontColor;

  const GoalDetailsPage(
      {super.key,
      required this.goal,
      required this.currentLocale,
      required this.pesoFormatter,
      required this.onDataChanged,
      required this.showSuccessPopup,
      required this.boxBgColor,
      required this.fontColor});

  @override
  State<GoalDetailsPage> createState() => _GoalDetailsPageState();
}

class _GoalDetailsPageState extends State<GoalDetailsPage> {
  String _translate(String en, String id, String fil) {
    if (widget.currentLocale == 'en') return en;
    if (widget.currentLocale == 'id') return id;
    return fil;
  }

  // 🔥 BAGONG IMPLEMENTASYON: PDF Generating Engine para sa Savings Goal Certificate Report
  Future<void> _generateAndShareGoalPDF() async {
    final pdf = pw.Document();
    double remaining = widget.goal.targetAmount - widget.goal.savedAmount;
    if (remaining < 0) remaining = 0.0;

    double progress = widget.goal.targetAmount > 0
        ? (widget.goal.savedAmount / widget.goal.targetAmount) * 100
        : 0.0;
    if (progress > 100) progress = 100;
    int displayProgressPercentage = progress.floor();
    if (widget.goal.savedAmount >= widget.goal.targetAmount)
      displayProgressPercentage = 100;

    final String cleanTitle = widget.goal.name.toUpperCase();
    String sym = widget.goal.currencySymbol.isNotEmpty
        ? widget.goal.currencySymbol
        : "₱";

    // I-load ang Unicode supported fonts para sa ligtas na '₱' rendering
    final pw.Font unicodeRegular = await PdfGoogleFonts.robotoRegular();
    final pw.Font unicodeBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            // Inalis ang dobleng pw.Column line at pinanatili ang naitamang spelling alignment key
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("GASTOS KO - SAVINGS GOAL MILESTONE REPORT",
                    style: pw.TextStyle(
                        fontSize: 10,
                        font: unicodeRegular,
                        color: PdfColors.grey)),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 16),
                pw.Text(cleanTitle,
                    style: pw.TextStyle(
                        fontSize: 24,
                        font: unicodeBold,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    "${_translate('Target Progress:', 'Progres Target:', 'Progreso ng Layunin:')} $displayProgressPercentage%",
                    style: pw.TextStyle(
                        fontSize: 12,
                        font: unicodeRegular,
                        color: PdfColors.grey700)),
                pw.SizedBox(height: 24),

                // Summary Progress Card Area
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              _translate("Target Amount:", "Jumlah Target:",
                                  "Target na Halaga:"),
                              style: pw.TextStyle(font: unicodeRegular)),
                          pw.Text(
                              "$sym${NumberFormat('#,##0', 'en_US').format(widget.goal.targetAmount.toInt())}",
                              style: pw.TextStyle(
                                  font: unicodeBold,
                                  fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              _translate("Total Saved:", "Total Terkumpul:",
                                  "Naipon na Pondo:"),
                              style: pw.TextStyle(font: unicodeRegular)),
                          pw.Text(
                              "$sym${NumberFormat('#,##0', 'en_US').format(widget.goal.savedAmount.toInt())}",
                              style: pw.TextStyle(
                                  font: unicodeBold,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              _translate(
                                  "Remaining Balance Needed:",
                                  "Sisa yang Dibutuhkan:",
                                  "Natitirang Kulang sa Ipon:"),
                              style: pw.TextStyle(
                                  font: unicodeBold,
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "$sym${NumberFormat('#,##0', 'en_US').format(remaining.toInt())}",
                              style: pw.TextStyle(
                                  font: unicodeBold,
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                  color: remaining <= 0
                                      ? PdfColors.green
                                      : PdfColors.orange)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),

                // Deposit Log Section
                // 🔥 TAMA (FIX): Inalis ang emoji na 📜 para hindi mag-error ang font rendering ng PDF
                pw.Text(
                  _translate("DEPOSIT HISTORY", "RIWAYAT SETORAN",
                      "KASAYSAYAN NG MGA HULOG"),
                  style: pw.TextStyle(
                      font: unicodeBold,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold),
                ),

                pw.SizedBox(height: 12),
                if (widget.goal.deposits.isEmpty)
                  pw.Text(
                      _translate(
                          "No deposits made yet.",
                          "Belum ada transaksi setoran.",
                          "Walang nakatalang transaksyon ng hulog dito."),
                      style: pw.TextStyle(
                          font: unicodeRegular,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey500))
                else
                  pw.Table(
                    border: pw.TableBorder.all(
                        color: PdfColors.grey300, width: 0.5),
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('#',
                                  style: pw.TextStyle(
                                      font: unicodeBold,
                                      fontWeight: pw.FontWeight.bold))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  _translate('Date', 'Tanggal', 'Petsa'),
                                  style: pw.TextStyle(
                                      font: unicodeBold,
                                      fontWeight: pw.FontWeight.bold))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  _translate('Amount Deposited',
                                      'Jumlah Setoran', 'Halagang Inihulog'),
                                  style: pw.TextStyle(
                                      font: unicodeBold,
                                      fontWeight: pw.FontWeight.bold))),
                        ],
                      ),
                      ...List.generate(widget.goal.deposits.length, (index) {
                        final d = widget.goal.deposits[index];
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text("${index + 1}",
                                    style: pw.TextStyle(font: unicodeRegular))),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                    DateFormat('yyyy-MM-dd hh:mm a')
                                        .format(d.date),
                                    style: pw.TextStyle(font: unicodeRegular))),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                    "$sym${NumberFormat('#,##0', 'en_US').format(d.amount.toInt())}",
                                    style: pw.TextStyle(font: unicodeRegular))),
                          ],
                        );
                      }),
                    ],
                  ),
                pw.SizedBox(height: 40),
                pw.Center(
                    child: pw.Text(
                        _translate(
                            "Keep up the good work and achieve your goals!",
                            "Teruskan kerja bagus ini atapai target Anda!",
                            "Ipagpatuloy ang mabuting gawain para maabot ang iyong layunin!"),
                        style: pw.TextStyle(
                            font: unicodeRegular,
                            fontStyle: pw.FontStyle.italic,
                            fontSize: 11,
                            color: PdfColors.grey600))),
              ],
            ),
          );
        },
      ),
    );

    // Try-catch frame checker para sa phone validation guard
    try {
      await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'Savings_Statement_${widget.goal.name}.pdf');
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🛑❌", style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                    _translate(
                        "EXPORT FAILED!", "EKSPOR GAGAL!", "HINDI MAI-EXPORT!"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                    _translate(
                        "No compatible PDF sharing app found.",
                        "Tidak mukan aplikasi pembaca PDF.",
                        "Walang nahanap na PDF application sa device na ito."),
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_translate("OKAY", "OK", "SIGE"))),
              ],
            ),
          ),
        );
      }
    }
  }

  void _addFundsDialog() {
    final TextEditingController amountCtrl = TextEditingController();
    String sym = widget.goal.currencySymbol.isNotEmpty
        ? widget.goal.currencySymbol
        : "₱";
    double kasalukuyangKulang =
        widget.goal.targetAmount - widget.goal.savedAmount;
    if (kasalukuyangKulang < 0) kasalukuyangKulang = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // 🔥 IDINAGDAG: Local variable para sa live text verification layout display tracking control
          String internalDepositErrorText = "";

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              _translate("Add Deposit", "Tambah Setoran", "Maghulog sa Ipon"),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CommaFormatter()
                    ],
                    decoration: InputDecoration(
                      prefixText: '$sym ',
                      prefixStyle: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold),
                      labelText: _translate("Deposit Amount", "Jumlah Setoran",
                          "Halaga ng Ihuhulog"),
                      labelStyle:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_translate("Remaining needed:", "Sisa yang dibutuhkan:", "Natitirang kulang:")} $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}',
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),

                  // 🛑 LIVE VALIDATION DISPLAY AREA: Dito lalabas ang pulang error card sa harap mismo ng diálogo
                  if (internalDepositErrorText.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.5),
                            width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              internalDepositErrorText,
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_translate("Cancel", "Batal", "Kanselahin"),
                    style: const TextStyle(color: Colors.white38)),
              ),
              TextButton(
                onPressed: () async {
                  final String cleanText =
                      amountCtrl.text.replaceAll(',', '').trim();
                  final double? amt = double.tryParse(cleanText);
                  if (amt == null || amt <= 0) return;

                  // 🛑 VALIDATION 1: Kung kompleto na ang 100% target line
                  if (widget.goal.savedAmount >= widget.goal.targetAmount) {
                    setDialogState(() {
                      internalDepositErrorText = _translate(
                          "Cannot add deposit because this goal is already 100% completed! 🛑",
                          "Tidak maaari menambah setoran karena target sudah tercapai 100%! 🛑",
                          "Bawal na maghulog dahil nakamit na ang 100% ng iyong target! 🛑");
                    });
                    return;
                  }

                  // 🛑 VALIDATION 2: Kung sumobra ang ihuhulog sa natitirang kulang sa ipon
                  if ((widget.goal.savedAmount + amt) >
                      widget.goal.targetAmount) {
                    setDialogState(() {
                      internalDepositErrorText = _translate(
                          "Excess deposit amount! Remaining allowed is $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}",
                          "Jumlah setoran berlebih! Sisa yang diperbolehkan adalah $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}",
                          "Sobra ang iyong ihuhulog! Ang natitirang kulang na lang ay $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}");
                    });
                    return;
                  }

                  // Matagumpay na pagpoproseso at pag-update sa disk registry array data stream
                  double bagongNaipon = widget.goal.savedAmount + amt;

                  setState(() {
                    widget.goal.deposits
                        .add(GoalDeposit(amount: amt, date: DateTime.now()));
                    widget.goal.savedAmount = bagongNaipon;
                  });

                  widget
                      .onDataChanged(); // I-trigger ang shared preferences file storage data dispatcher save script
                  Navigator.pop(
                      context); // Isasara ang input dialogue box panel frame

                  // 🎉 KUMPIRMASYON PROMPT CARD WINDOW (KATULAD SA MAIN SCREEN AT UTANG PAGE)
                  if (mounted) {
                    bool lunasNa = bagongNaipon >= widget.goal.targetAmount;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(lunasNa ? "🎉🏆" : "💰✨",
                                style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text(
                              lunasNa
                                  ? _translate(
                                      "TARGET ACHIEVED! 🥳",
                                      "TARGET TERCAPAI! 🥳",
                                      "CONGRATULATIONS! 🥳")
                                  : _translate(
                                      "DEPOSIT ADDED!",
                                      "SETORAN DITAMBAHKAN!",
                                      "NAIHULOG NA MAAYOS!"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lunasNa
                                  ? _translate(
                                      "You have successfully saved the full amount for ${widget.goal.name.toUpperCase()}!",
                                      "Anda telah berhasil menabung seluruh dana untuk ${widget.goal.name.toUpperCase()}!",
                                      "Matagumpay mong naipon ang buong pondo para sa ${widget.goal.name.toUpperCase()}!")
                                  : _translate(
                                      "Successfully added $sym${NumberFormat('#,##0', 'en_US').format(amt.toInt())} to your savings!",
                                      "Berhasil menambahkan $sym${NumberFormat('#,##0', 'en_US').format(amt.toInt())} ke tabungan Anda!",
                                      "Matagumpay na naidagdag ang $sym${NumberFormat('#,##0', 'en_US').format(amt.toInt())} sa iyong ipon!"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                              ),
                              child: Text(_translate("OKAY", "OK", "SIGE"),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
                child: Text(_translate("Deposit", "Setor", "Ihulog"),
                    style: const TextStyle(
                        color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double remaining = widget.goal.targetAmount - widget.goal.savedAmount;
    if (remaining < 0) remaining = 0.0;
    double progress = widget.goal.targetAmount > 0
        ? (widget.goal.savedAmount / widget.goal.targetAmount) * 100
        : 0.0;
    if (progress > 100) progress = 100;
    int displayProgress = progress.floor();
    bool isComplete = widget.goal.savedAmount >= widget.goal.targetAmount;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(widget.goal.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
// 🔥 IDINAGDAG: PDF icon button actions sa AppBar ng Mag Ipon sub-details screen
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded,
                color: Color(0xFFFFD700), size: 22),
            tooltip: _translate(
                "Export Report", "Ekspor Laporan", "I-export ang Report"),
            onPressed:
                _generateAndShareGoalPDF, // 🚀 Tinatawag ang bagong PDF Document script generator
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// Outstanding Goal Dashboard Panel Header Display Card
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: widget.boxBgColor,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text(_translate("REM. KULANG", "SISA UTANG", "Rem:"),
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    isComplete
                        ? _translate(
                            "ACHIEVED! 🎉", "TERCAPAI! 🎉", "NABUO NA! 🎉")
                        : "${widget.goal.currencySymbol}${NumberFormat('#,##0', 'en_US').format(remaining.toInt())}",
                    style: TextStyle(
                        color: isComplete
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFFD700),
                        fontSize: 22,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.white10,
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFFFFD700)),
                        minHeight: 6),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text(_translate("Saved", "Terbayar", "Naipon"),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                            "${widget.goal.currencySymbol}${NumberFormat('#,##0', 'en_US').format(widget.goal.savedAmount.toInt())}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00E676)))
                      ]),
                      Column(children: [
                        Text(_translate("Progress", "Progres", "Progress"),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text("$displayProgress%",
                            style: const TextStyle(fontWeight: FontWeight.bold))
                      ]),
                      Column(children: [
                        Text(_translate("Target", "Target", "Target"),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                            "${widget.goal.currencySymbol}${NumberFormat('#,##0', 'en_US').format(widget.goal.targetAmount.toInt())}",
                            style: const TextStyle(fontWeight: FontWeight.bold))
                      ]),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
                "${_translate('DEPOSIT HISTORY', 'RIWAYAT SETORAN', 'KASAYSAYAN NG MGA HULOG')} 📜",
                style: TextStyle(
                    color: widget.fontColor.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
// Dynamic Loop List View for Goal Deposits Log
            Expanded(
              child: widget.goal.deposits.isEmpty
                  ? Center(
                      child: Text(
                          _translate(
                              "No deposits made yet.",
                              "Belum ada transaksi setoran.",
                              "Walang nakatalang transaksyon ng hulog dito."),
                          style: TextStyle(
                              color: widget.fontColor.withValues(alpha: 0.24),
                              fontStyle: FontStyle.italic)))
                  : ListView.builder(
                      itemCount: widget.goal.deposits.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, idx) {
                        final dep = widget.goal.deposits[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: widget.boxBgColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${_translate('Deposit', 'Setoran', 'Hulog')} #${idx + 1}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFFFFD700))),
                                  const SizedBox(height: 4),
                                  Text(
                                      DateFormat('yyyy-MM-dd - hh:mm a')
                                          .format(dep.date),
                                      style: const TextStyle(
                                          color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                              Text(
                                  "+ ${widget.goal.currencySymbol}${NumberFormat('#,##0', 'en_US').format(dep.amount.toInt())}",
                                  style: const TextStyle(
                                      color: Color(0xFF00E676),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              // 🔥 TAMA AT AKTIBO (FIX): Kung hindi pa 100% complete, papayagan nating magbukas ang input form dialog panel
              onPressed: isComplete
                  ? null
                  : () {
                      // 🚀 AUTOMATION INJECTION: Direkta nitong tinatawag ang naitama nating interactive deposit form box
                      _addFundsDialog();
                    },
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                _translate("ADD FUNDS TO GOAL", "TAMBAH SETORAN TARGET",
                    "MAGDAGDAG NG HULOG SA LAYUNIN"),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                // Kapag disabled (100% kompleto na), magiging madilim ang button
                disabledBackgroundColor: Colors.white12,
                disabledForegroundColor: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================
// 🎨 FLIGHT TRACKER CUSTOM PAINTER (Root-Level Class)
// ====================================================

class DebtPayment {
  double amount;
  DateTime date;

  DebtPayment({required this.amount, required this.date});

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory DebtPayment.fromJson(Map<String, dynamic> json) => DebtPayment(
        amount: (json['amount'] as num? ?? 0.0).toDouble(),
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
      );
}

// ==========================================
// 📜 TRANSACTIONS LOG LOGISTIC VIEW PANEL
// ==========================================

class DebtHistoryPage extends StatefulWidget {
  final DebtItemV2 debt;
  final String currentLocale;
  final String Function(double) pesoFormatter;
  final VoidCallback onPaymentAdded;
  final Color boxBgColor;
  final Color fontColor;

  const DebtHistoryPage(
      {super.key,
      required this.debt,
      required this.currentLocale,
      required this.pesoFormatter,
      required this.onPaymentAdded,
      required this.boxBgColor,
      required this.fontColor});

  @override
  State<DebtHistoryPage> createState() => _DebtHistoryPageState();
}

class _DebtHistoryPageState extends State<DebtHistoryPage> {
  String _translate(String en, String id, String fil) {
    if (widget.currentLocale == 'en') return en;
    if (widget.currentLocale == 'id') return id;
    return fil;
  }

  // 🔥 BAGONG IMPLEMENTASYON: PDF Generating Engine para sa Borrower Transaction Statement
  // 🔥 TAMANG IMPLEMENTASYON (FIX): Unicode Supported PDF Generator Engine
  Future<void> _generateAndShareDebtPDF() async {
    final pdf = pw.Document();
    final double remaining = widget.debt.totalAmount - widget.debt.paidAmount;
    final String cleanTitle = widget.debt.name.toUpperCase();

    // 🚀 UNICODE ENGINE FIX: I-load ang Roboto font mula sa Google Fonts na may buong suporta sa '₱' symbol
    final pw.Font unicodeFontRegular = await PdfGoogleFonts.robotoRegular();
    final pw.Font unicodeFontBold = await PdfGoogleFonts.robotoBold();

    String statusTxt = widget.debt.isOwedToMe ? "OWED TO YOU" : "YOU OWE";
    if (widget.currentLocale == 'tl')
      statusTxt = widget.debt.isOwedToMe ? "UTANG SAYO" : "UTANG MO";
    if (widget.currentLocale == 'id')
      statusTxt = widget.debt.isOwedToMe ? "PIUTANG" : "UTANG";
    if (remaining <= 0) statusTxt += " (LUNAS / SETTLED)";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 🔥 LAHAT NG TEXT STYLE DITO AY GINAMITAN NG ATING UNICODE ENGINES:
                pw.Text("GASTOS KO - STATEMENT OF ACCOUNT",
                    style: pw.TextStyle(
                        fontSize: 10,
                        font: unicodeFontRegular,
                        color: PdfColors.grey)),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 16),
                pw.Text(cleanTitle,
                    style: pw.TextStyle(
                        fontSize: 24,
                        font: unicodeFontBold,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    "${_translate('Status:', 'Status:', 'Katayuan:')} $statusTxt",
                    style: pw.TextStyle(
                        fontSize: 12,
                        font: unicodeFontRegular,
                        color: PdfColors.grey700)),
                pw.SizedBox(height: 24),

                // Summary Box Area
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              _translate("Total Debt:", "Total Utang:",
                                  "Kabuuang Utang:"),
                              style: pw.TextStyle(font: unicodeFontRegular)),
                          pw.Text(
                              "${widget.debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(widget.debt.totalAmount.toInt())}",
                              style: pw.TextStyle(
                                  font: unicodeFontBold,
                                  fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              _translate("Total Paid:", "Total Dibayar:",
                                  "Naibayad Na:"),
                              style: pw.TextStyle(font: unicodeFontRegular)),
                          pw.Text(
                              "${widget.debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(widget.debt.paidAmount.toInt())}",
                              style: pw.TextStyle(
                                  font: unicodeFontBold,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              _translate("Outstanding Balance:", "Sisa Utang:",
                                  "Natitirang Balanse:"),
                              style: pw.TextStyle(
                                  font: unicodeFontBold,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "${widget.debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(remaining.toInt())}",
                              style: pw.TextStyle(
                                  font: unicodeFontBold,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: remaining <= 0
                                      ? PdfColors.green
                                      : PdfColors.red)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),

                // Transactions Log Section
                // 🔥 TAMA (FIX): Inalis din ang emoji dito para malinis ang papel ng PDF report
                // 🔥 TAMA (FIX): Pinalitan ang unicodeBold patungong unicodeFontBold para magtugma sa deklarasyon
                pw.Text(
                  _translate("PAYMENT TRANSACTIONS LOG",
                      "LOG TRANSAKSI PEMBAYARAN", "TALAAN NG MGA BAYAD"),
                  style: pw.TextStyle(
                      font: unicodeFontBold,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold),
                ),

                pw.SizedBox(height: 12),
                if (widget.debt.payments.isEmpty)
                  pw.Text(
                      _translate(
                          "No payment transactions recorded yet.",
                          "Belum ada transaksi pembayaran.",
                          "Walang nakatalang transaksyon ng bayad dito."),
                      style: pw.TextStyle(
                          font: unicodeFontRegular,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey500))
                else
                  pw.Table(
                    border: pw.TableBorder.all(
                        color: PdfColors.grey300, width: 0.5),
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('#',
                                  style: pw.TextStyle(
                                      font: unicodeFontBold,
                                      fontWeight: pw.FontWeight.bold))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  _translate('Date', 'Tanggal', 'Petsa'),
                                  style: pw.TextStyle(
                                      font: unicodeFontBold,
                                      fontWeight: pw.FontWeight.bold))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  _translate('Amount Received', 'Jumlah',
                                      'Halagang Tinanggap'),
                                  style: pw.TextStyle(
                                      font: unicodeFontBold,
                                      fontWeight: pw.FontWeight.bold))),
                        ],
                      ),
                      ...List.generate(widget.debt.payments.length, (index) {
                        final p = widget.debt.payments[index];
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text("${index + 1}",
                                    style: pw.TextStyle(
                                        font: unicodeFontRegular))),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                    DateFormat('yyyy-MM-dd hh:mm a')
                                        .format(p.date),
                                    style: pw.TextStyle(
                                        font: unicodeFontRegular))),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                    "${widget.debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(p.amount.toInt())}",
                                    style: pw.TextStyle(
                                        font: unicodeFontRegular))),
                          ],
                        );
                      }),
                    ],
                  ),
                pw.SizedBox(height: 40),
                pw.Center(
                    child: pw.Text(
                        _translate(
                            "Thank you for your transaction!",
                            "Terima kasih atas transaksi Anda!",
                            "Salamat sa iyong transaksyon!"),
                        style: pw.TextStyle(
                            font: unicodeFontRegular,
                            fontStyle: pw.FontStyle.italic,
                            fontSize: 11,
                            color: PdfColors.grey600))),
              ],
            ),
          );
        },
      ),
    );
    try {
      // 🚀 OPERATIONAL SHIELD DISPATCHER: Sinusubukang i-open ang native share window sheet drawer console frame
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Statement_of_Account_${widget.debt.name}.pdf',
      );
    } catch (e) {
      // 🛑 LIVE BLOCKING EXCEPTION TRIGGER (FIX): Lalabas ang pormal na prompt window kung walang katugmang app ang device
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🛑❌", style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  _translate(
                      "EXPORT FAILED!", "EKSPOR GAGAL!", "HINDI MAI-EXPORT!"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _translate(
                      "No compatible PDF reader or sharing application found on this device. Please install one first.",
                      "Tidak mukan aplikasi pembaca PDF atau berbagi yang kompatibel. Silakan instal terlebih dahulu.",
                      "Walang nahanap na PDF reader o sharing application sa device na ito. Paki-install muna ito."),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                  ),
                  child: Text(
                    _translate("OKAY", "OK", "SIGE"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _addPaymentEntryDialog() {
    final TextEditingController amountCtrl = TextEditingController();
    String sym = widget.debt.currencySymbol.isNotEmpty
        ? widget.debt.currencySymbol
        : "₱";
    double kasalukuyangKulang =
        widget.debt.totalAmount - widget.debt.paidAmount;
    if (kasalukuyangKulang < 0) kasalukuyangKulang = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(_translate(
                "Add Payment", "Tambah Pembayaran", "Magtala ng Bayad")),
            content: TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CommaFormatter()
              ],
              decoration: InputDecoration(
                prefixText: '$sym ',
                prefixStyle: const TextStyle(
                    color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                labelText: _translate("Payment Amount", "Jumlah Pembayaran",
                    "Halaga ng Ibabayad"),
                helperText:
                    '${_translate("Remaining balance:", "Sisa utang:", "Natitirang kulang:")} $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}',
                helperStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_translate("Cancel", "Batal", "Kanselahin"),
                      style: const TextStyle(color: Colors.white38))),
              TextButton(
                onPressed: () async {
                  final String cleanText =
                      amountCtrl.text.replaceAll(',', '').trim();
                  final double? amt = double.tryParse(cleanText);
                  if (amt == null || amt <= 0) return;

                  if ((widget.debt.paidAmount + amt) >
                      widget.debt.totalAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(_translate(
                            "Excess payment amount!",
                            "Jumlah pembayaran berlebih!",
                            "Sobra ang iyong ibinayad!"))));
                    return;
                  }

                  setState(() {
                    widget.debt.payments
                        .add(DebtPayment(amount: amt, date: DateTime.now()));
                    widget.debt.paidAmount += amt;
                  });
                  widget.onPaymentAdded();
                  Navigator.pop(context);
                },
                child: Text(_translate("Pay", "Bayar", "Ibayad"),
                    style: const TextStyle(
                        color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double remaining = widget.debt.totalAmount - widget.debt.paidAmount;
    bool isFullyPaid = remaining <= 0;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(widget.debt.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
// 🔥 NAGDAGDAG NG MGA ACTIONS SA APP BAR PARA SA PDF EXPORT MANAGER CONTROL
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded,
                color: Color(0xFFFFD700), size: 22),
            tooltip: _translate(
                "Export Statement", "Ekspor Laporan", "I-export ang Report"),
            onPressed:
                _generateAndShareDebtPDF, // 🚀 Tinatawag ang PDF Engine setup panel
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// Outstanding Balance Dashboard Card Element
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: widget.boxBgColor,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text(
                      _translate("OUTSTANDING BALANCE", "SISA UTANG",
                          "NATITIRANG UTANG"),
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text(
                    isFullyPaid
                        ? _translate("SETTLED 🥳", "LUNAS 🥳", "LUNAS NA 🥳")
                        : "${widget.debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(remaining.toInt())}",
                    style: TextStyle(
                        color: isFullyPaid
                            ? const Color(0xFF00E676)
                            : Colors.greenAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text(
                            _translate(
                                "Total Debt", "Total Utang", "Kabuuang Utang"),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                            "${widget.debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(widget.debt.totalAmount.toInt())}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14))
                      ]),
                      Column(children: [
                        Text(
                            _translate(
                                "Total Paid", "Total Dibayar", "Naibayad Na"),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                            "${widget.debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(widget.debt.paidAmount.toInt())}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF00E676)))
                      ]),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
                "${_translate('PAYMENT TRANSACTIONS LOG', 'LOG TRANSAKSI PEMBAYARAN', 'TALAAN NG MGA BAYAD')} 📜",
                style: TextStyle(
                    color: widget.fontColor.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
// Payments List View dynamic container loop
            Expanded(
              child: widget.debt.payments.isEmpty
                  ? Center(
                      child: Text(
                          _translate(
                              "No payment transactions recorded yet.",
                              "Belum ada transaksi pembayaran.",
                              "Walang nakatalang transaksyon ng bayad dito."),
                          style: TextStyle(
                              color: widget.fontColor.withValues(alpha: 0.24),
                              fontStyle: FontStyle.italic)))
                  : ListView.builder(
                      itemCount: widget.debt.payments.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, idx) {
                        final payment = widget.debt.payments[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: widget.boxBgColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${_translate('Payment', 'Pembayaran', 'Hulog')} #${idx + 1}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFFFFD700))),
                                  const SizedBox(height: 4),
                                  Text(
                                      DateFormat('yyyy-MM-dd - hh:mm a')
                                          .format(payment.date),
                                      style: const TextStyle(
                                          color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                              Text(
                                  "+ ${widget.debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(payment.amount.toInt())}",
                                  style: const TextStyle(
                                      color: Color(0xFF00E676),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: isFullyPaid ? null : _addPaymentEntryDialog,
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                  _translate("ADD PAYMENT ENTRY", "TAMBAH CATATAN PEMBAYARAN",
                      "MAGDAGDAG NG HULOG"),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DebtsPage extends StatefulWidget {
  final List<DebtItemV2> debtsList;
  final String currentLocale;
  final String currentCurrency;
  final String Function(double) pesoFormatter;
  final VoidCallback onDataChanged;
  final Function(
      {required String title,
      required String message,
      required String emoji}) showSuccessPopup;
  final List<Map<String, String>> globalCurrencies;
  final Function(Function(Map<String, String>)) openCurrencySearchPicker;
  final Color boxBgColor;
  final Color fontColor;

  const DebtsPage({
    super.key,
    required this.debtsList,
    required this.currentLocale,
    required this.currentCurrency,
    required this.pesoFormatter,
    required this.onDataChanged,
    required this.showSuccessPopup,
    required this.globalCurrencies,
    required this.openCurrencySearchPicker,
    required this.boxBgColor,
    required this.fontColor,
  });

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  String _currentSortCriteria = 'latest';

  void _showEditDebtAmountDialog(DebtItemV2 debt) {
    final TextEditingController amountCtrl = TextEditingController(
      text: NumberFormat('#,##0', 'en_US').format(debt.totalAmount.toInt()),
    );
    String sym = debt.currencySymbol.isNotEmpty ? debt.currencySymbol : "₱";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.currentLocale == 'en'
              ? "Correct Beginning Debt Amount"
              : (widget.currentLocale == 'id'
                  ? "Koreksi Jumlah Utang Awal"
                  : "Itama ang Simulang Utang"),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CommaFormatter()
          ],
          decoration: InputDecoration(
            prefixText: '$sym ',
            prefixStyle: const TextStyle(
                color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
            labelText: widget.currentLocale == 'en'
                ? "Original / Beginning Amount"
                : (widget.currentLocale == 'id'
                    ? "Jumlah Utang Awal"
                    : "Simulang Halaga ng Utang"),
            labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
            helperText:
                '${widget.currentLocale == 'en' ? "Total payments made so far:" : (widget.currentLocale == 'id' ? "Total pembayaran sejauh ini:" : "Kabuuang naibayad na:")} $sym${NumberFormat('#,##0', 'en_US').format(debt.paidAmount.toInt())}',
            helperStyle: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                widget.currentLocale == 'en'
                    ? "Cancel"
                    : (widget.currentLocale == 'id' ? "Batal" : "Kanselahin"),
                style: const TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              final String cleanText =
                  amountCtrl.text.replaceAll(',', '').trim();
              final double? newBeginningTotal = double.tryParse(cleanText);
              if (newBeginningTotal == null || newBeginningTotal <= 0) return;

              if (newBeginningTotal < debt.paidAmount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.currentLocale == 'en'
                        ? "Amount cannot be lower than the already paid amount!"
                        : (widget.currentLocale == 'id'
                            ? "Jumlah tidak boleh lebih rendah dari yang sudah dibayar!"
                            : "Hindi pwedeng mas mababa sa naibayad na!")),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              setState(() {
                debt.totalAmount = newBeginningTotal;
              });
              widget.onDataChanged();
              Navigator.pop(context); // Isasara ang input dialog

              // 🎉 KUMPIRMASYON PROMPT WINDOW (KATULAD SA GOAL SCREEN)
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("💰✨", style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        widget.currentLocale == 'en'
                            ? "AMOUNT UPDATED!"
                            : (widget.currentLocale == 'id'
                                ? "JUMLAH DIPERBARUI!"
                                : "NA-UPDATE ANG HALAGA!"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.currentLocale == 'en'
                            ? "Successfully updated the beginning debt amount!"
                            : (widget.currentLocale == 'id'
                                ? "Berhasil memperbarui jumlah utang awal!"
                                : "Matagumpay na na-update ang simulang halaga ng utang!"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                        ),
                        child: Text(
                            widget.currentLocale == 'en'
                                ? "OKAY"
                                : (widget.currentLocale == 'id'
                                    ? "OK"
                                    : "SIGE"),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Text(
                widget.currentLocale == 'en'
                    ? "Save"
                    : (widget.currentLocale == 'id' ? "Simpan" : "I-save"),
                style: const TextStyle(
                    color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showAddDebtDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isOwedToMe = false;
    String selectedDebtCurrencySymbol = widget.currentCurrency;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) {
          final currentCurrencyDetails = widget.globalCurrencies.firstWhere(
              (c) => c["symbol"] == selectedDebtCurrencySymbol,
              orElse: () => {
                    "country": "Philippines 🇵🇭",
                    "code": "PHP",
                    "symbol": "₱"
                  });
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              widget.currentLocale == 'en'
                  ? "ADD NEW DEBT RECORD"
                  : (widget.currentLocale == 'id'
                      ? "CATAT UTANG BARU"
                      : "MAGTALA NG UTANG"),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDlgState(() => isOwedToMe = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isOwedToMe
                                  ? Colors.redAccent.withValues(alpha: 0.2)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: !isOwedToMe
                                      ? Colors.redAccent
                                      : Colors.transparent,
                                  width: 1.5),
                            ),
                            child: Text(
                                widget.currentLocale == 'en'
                                    ? "I Owe Them"
                                    : (widget.currentLocale == 'id'
                                        ? "Utang"
                                        : "Utang Ko"),
                                style: TextStyle(
                                    color: !isOwedToMe
                                        ? Colors.redAccent
                                        : Colors.white54,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDlgState(() => isOwedToMe = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isOwedToMe
                                  ? const Color(0xFF00E676)
                                      .withValues(alpha: 0.2)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isOwedToMe
                                      ? const Color(0xFF00E676)
                                      : Colors.transparent,
                                  width: 1.5),
                            ),
                            child: Text(
                                widget.currentLocale == 'en'
                                    ? "They Owe Me"
                                    : (widget.currentLocale == 'id'
                                        ? "Piutang"
                                        : "Utang Sa'kin"),
                                style: TextStyle(
                                    color: isOwedToMe
                                        ? const Color(0xFF00E676)
                                        : Colors.white54,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                        widget.currentLocale == 'en'
                            ? "Select Debt Currency"
                            : "Pumili ng Currency ng Utang",
                        style: const TextStyle(fontSize: 11)),
                    subtitle: Text(
                        "${currentCurrencyDetails["country"]} [${currentCurrencyDetails["symbol"]}]",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700))),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () {
                      widget.openCurrencySearchPicker((chosen) {
                        setDlgState(() {
                          selectedDebtCurrencySymbol = chosen["symbol"]!;
                        });
                      });
                    },
                  ),
                  TextField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: widget.currentLocale == 'en'
                          ? "Name"
                          : (widget.currentLocale == 'id'
                              ? "Nama"
                              : "Pangalan"),
                    ),
                  ),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CommaFormatter()
                    ],
                    decoration: InputDecoration(
                      prefixText: '$selectedDebtCurrencySymbol ',
                      labelText: widget.currentLocale == 'en'
                          ? "Amount"
                          : (widget.currentLocale == 'id'
                              ? "Jumlah"
                              : "Halaga"),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  widget.currentLocale == 'en'
                      ? "Cancel"
                      : (widget.currentLocale == 'id' ? "Batal" : "Kanselahin"),
                ),
              ),
              TextButton(
                onPressed: () {
                  final String name = nameCtrl.text.trim();
                  final double? total =
                      double.tryParse(amountCtrl.text.replaceAll(',', ''));
                  if (name.isEmpty || total == null || total <= 0) return;

                  setState(() {
                    widget.debtsList.add(DebtItemV2(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      totalAmount: total,
                      paidAmount: 0.0,
                      isOwedToMe: isOwedToMe,
                      date: DateTime.now(),
                      currencySymbol: selectedDebtCurrencySymbol,
                      payments: [],
                    ));
                  });
                  Navigator.pop(context);
                  widget.onDataChanged();
                },
                child: Text(
                  widget.currentLocale == 'en'
                      ? "Save"
                      : (widget.currentLocale == 'id' ? "Simpan" : "I-save"),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _showEditDebtNameDialog(DebtItemV2 debt) {
    final nameCtrl = TextEditingController(text: debt.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.currentLocale == 'en'
              ? "Edit Name"
              : (widget.currentLocale == 'id'
                  ? "Ubah Nama"
                  : "I-edit ang Pangalan"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: nameCtrl,
          textCapitalization: TextCapitalization.words,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                widget.currentLocale == 'en'
                    ? "Cancel"
                    : (widget.currentLocale == 'id' ? "Batal" : "Kanselahin"),
                style: const TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              setState(() {
                debt.name = nameCtrl.text.trim();
              });
              widget.onDataChanged();
              Navigator.pop(context); // Isasara ang input dialog

              // 🎉 KUMPIRMASYON PROMPT WINDOW (KATULAD SA GOAL SCREEN)
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("📝✨", style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        widget.currentLocale == 'en'
                            ? "NAME UPDATED!"
                            : (widget.currentLocale == 'id'
                                ? "NAMA DIPERBARUI!"
                                : "NA-UPDATE ANG PANGALAN!"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.currentLocale == 'en'
                            ? "Successfully updated the name of the debt record!"
                            : (widget.currentLocale == 'id'
                                ? "Berhasil memperbarui nama catatan utang!"
                                : "Matagumpay na na-update ang pangalan sa talaan ng utang!"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                        ),
                        child: Text(
                            widget.currentLocale == 'en'
                                ? "OKAY"
                                : (widget.currentLocale == 'id'
                                    ? "OK"
                                    : "SIGE"),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Text(
                widget.currentLocale == 'en'
                    ? "Save"
                    : (widget.currentLocale == 'id' ? "Simpan" : "I-save"),
                style: const TextStyle(
                    color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _confirmDeleteDebt(DebtItemV2 debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.currentLocale == 'en'
              ? "Delete Record?"
              : (widget.currentLocale == 'id'
                  ? "Hapus Catatan?"
                  : "Burahin ang Talaan?"),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          widget.currentLocale == 'en'
              ? "Are you sure you want to permanently remove \"${debt.name.toUpperCase()}\"?"
              : (widget.currentLocale == 'id'
                  ? "Apakah Anda yakin ingin menghapus \"${debt.name.toUpperCase()}\" secara permanen?"
                  : "Sigurado ka bang gusto mong burahin nang tuluyan si \"${debt.name.toUpperCase()}\"?"),
          style:
              const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                widget.currentLocale == 'en'
                    ? "Cancel"
                    : (widget.currentLocale == 'id' ? "Batal" : "Kanselahin"),
                style: const TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.debtsList.remove(debt);
              });
              Navigator.pop(context); // Isasara ang confirmation checker
              widget.onDataChanged();

              // 🎉 KUMPIRMASYON PROMPT WINDOW PAGKABURA (KATULAD SA GOAL SCREEN)
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🗑️✨", style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        widget.currentLocale == 'en'
                            ? "RECORD DELETED!"
                            : (widget.currentLocale == 'id'
                                ? "CATATAN DIHAPUS!"
                                : "NABURA ANG TALAAN!"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.currentLocale == 'en'
                            ? "The debt record has been permanently removed."
                            : (widget.currentLocale == 'id'
                                ? "Catatan utang telah berhasil dihapus secara permanen."
                                : "Ang talaan ng utang ay matagumpay na nabura nang tuluyan."),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                        ),
                        child: Text(
                            widget.currentLocale == 'en'
                                ? "OKAY"
                                : (widget.currentLocale == 'id'
                                    ? "OK"
                                    : "SIGE"),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Text(
                widget.currentLocale == 'en'
                    ? "Delete"
                    : (widget.currentLocale == 'id' ? "Hapus" : "Burahin"),
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  String searchDebtQuery = "";

  @override
  Widget build(BuildContext context) {
    final Map<String, double> summaryOweThem = {};
    final Map<String, double> summaryOweMe = {};

    for (var e in widget.debtsList) {
      double remaining = e.totalAmount - e.paidAmount;
      if (remaining <= 0) continue;
      String sym = e.currencySymbol;
      if (!summaryOweThem.containsKey(sym)) summaryOweThem[sym] = 0.0;
      if (!summaryOweMe.containsKey(sym)) summaryOweMe[sym] = 0.0;

      if (!e.isOwedToMe) {
        summaryOweThem[sym] = summaryOweThem[sym]! + remaining;
      } else {
        summaryOweMe[sym] = summaryOweMe[sym]! + remaining;
      }
    }

    // 🔍 PINALAWAK (FIX): Sinasala muna ang listahan base sa pangalan na hinahanap ng user
    List<DebtItemV2> processedDebts = widget.debtsList.where((item) {
      return item.name.toLowerCase().contains(searchDebtQuery.toLowerCase());
    }).toList();

    // 🔥 SORTING ENGINE SYSTEM (In-apply sa processedDebts na may search filter)
    if (_currentSortCriteria == 'latest') {
      processedDebts.sort((a, b) => b.date.compareTo(a.date));
    } else if (_currentSortCriteria == 'oldest') {
      processedDebts.sort((a, b) => a.date.compareTo(b.date));
    } else if (_currentSortCriteria == 'highest') {
      processedDebts.sort((a, b) => (b.totalAmount - b.paidAmount)
          .compareTo(a.totalAmount - a.paidAmount));
    } else if (_currentSortCriteria == 'lowest') {
      processedDebts.sort((a, b) => (a.totalAmount - a.paidAmount)
          .compareTo(b.totalAmount - b.paidAmount));
    }

    String txtSortLabel = widget.currentLocale == 'en'
        ? "Sort by:"
        : (widget.currentLocale == 'id' ? "Urutkan:" : "I-sort gamit ang:");

    String unpaidLabel = widget.currentLocale == 'en'
        ? "UNPAID"
        : (widget.currentLocale == 'id' ? "BELUM LUNAS" : "MAY UTANG");

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.currentLocale == 'en'
                  ? "DEBT MANAGEMENT"
                  : (widget.currentLocale == 'id'
                      ? "MANAJEMEN UTANG"
                      : "MGA UTANG"),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.fontColor,
                  fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: widget.boxBgColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentLocale == 'en'
                              ? "TOTAL YOU OWE 🛑"
                              : (widget.currentLocale == 'id'
                                  ? "TOTAL UTANG ANDA 🛑"
                                  : "UTANG MO 🛑"),
                          style: TextStyle(
                              color: widget.fontColor.withValues(alpha: 0.5),
                              fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        if (summaryOweThem.entries
                            .where((e) => e.value > 0)
                            .isEmpty)
                          const Text("0",
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold))
                        else
                          ...summaryOweThem.entries
                              .where((e) => e.value > 0)
                              .map((item) => Text(
                                  "${item.key}${NumberFormat('#,##0', 'en_US').format(item.value.toInt())}",
                                  style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: widget.boxBgColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentLocale == 'en'
                              ? "TOTAL OWED TO YOU 🟢"
                              : (widget.currentLocale == 'id'
                                  ? "TOTAL PIUTANG ANDA 🟢"
                                  : "UTANG SAYO 🟢"),
                          style: TextStyle(
                              color: widget.fontColor.withValues(alpha: 0.5),
                              fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        if (summaryOweMe.entries
                            .where((e) => e.value > 0)
                            .isEmpty)
                          const Text("0",
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold))
                        else
                          ...summaryOweMe.entries.where((e) => e.value > 0).map(
                              (item) => Text(
                                  "${item.key}${NumberFormat('#,##0', 'en_US').format(item.value.toInt())}",
                                  style: const TextStyle(
                                      color: Color(0xFF00E676),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.currentLocale == 'en'
                    ? 'Search person name...'
                    : (widget.currentLocale == 'id'
                        ? 'Cari nama orang...'
                        : 'Maghanap ng pangalan...'),
                hintStyle: TextStyle(
                    color: widget.fontColor.withValues(alpha: 0.35),
                    fontSize: 13),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFFFFD700), size: 20),
                suffixIcon: searchDebtQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            size: 18,
                            color: widget.fontColor.withValues(alpha: 0.5)),
                        onPressed: () {
                          setState(() {
                            searchDebtQuery = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: widget.boxBgColor,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white10)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFFFD700), width: 1)),
              ),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: searchDebtQuery,
                  selection:
                      TextSelection.collapsed(offset: searchDebtQuery.length),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchDebtQuery = val.trim();
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.sort_rounded,
                    color: widget.fontColor.withValues(alpha: 0.7), size: 16),
                const SizedBox(width: 6),
                Text(txtSortLabel,
                    style: TextStyle(
                        color: widget.fontColor.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: widget.boxBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: _currentSortCriteria,
                      dropdownColor: widget.boxBgColor,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Color(0xFFFFD700), size: 18),
                      style: TextStyle(
                          color: widget.fontColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _currentSortCriteria = newValue;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem(
                            value: 'latest',
                            child: Text(widget.currentLocale == 'en'
                                ? "Latest"
                                : (widget.currentLocale == 'id'
                                    ? "Terbaru"
                                    : "Pinakabago"))),
                        DropdownMenuItem(
                            value: 'oldest',
                            child: Text(widget.currentLocale == 'en'
                                ? "Oldest"
                                : (widget.currentLocale == 'id'
                                    ? "Terlama"
                                    : "Pinakaluma"))),
                        DropdownMenuItem(
                            value: 'highest',
                            child: Text(widget.currentLocale == 'en'
                                ? "Highest"
                                : (widget.currentLocale == 'id'
                                    ? "Tertinggi"
                                    : "Pinakamataas"))),
                        DropdownMenuItem(
                            value: 'lowest',
                            child: Text(widget.currentLocale == 'en'
                                ? "Lowest"
                                : (widget.currentLocale == 'id'
                                    ? "Terendah"
                                    : "Pinakamababa"))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: processedDebts
                      .isEmpty // 🔥 PALITAN: sortedDebts -> processedDebts
                  ? Center(
                      child: Text(
                        searchDebtQuery.isNotEmpty
                            ? (widget.currentLocale == 'en'
                                ? "No matching names found."
                                : (widget.currentLocale == 'id'
                                    ? "Nama tidak ditemukan."
                                    : "Walang nahanap na tugmang pangalan."))
                            : (widget.currentLocale == 'en'
                                ? "No debt records monitored."
                                : (widget.currentLocale == 'id'
                                    ? "Tidak ada catatan utang."
                                    : "Walang nakatalang utang dito.")),
                        style: TextStyle(
                            color: widget.fontColor.withValues(alpha: 0.24),
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: processedDebts
                          .length, // 🔥 PALITAN: sortedDebts -> processedDebts
                      itemBuilder: (context, index) {
                        final debt = processedDebts[
                            index]; // 🔥 PALITAN: sortedDebts -> processedDebts
                        double remaining = debt.totalAmount - debt.paidAmount;
                        bool isFullyPaid = remaining <= 0;
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            // Binubuksan ang detalyadong Transaction History page kapag tinap ang card
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DebtHistoryPage(
                                  debt: debt,
                                  currentLocale: widget.currentLocale,
                                  pesoFormatter: widget.pesoFormatter,
                                  // 🔥 IDINAGDAG ANG MGA KULAY DITO SA ONTAP:
                                  boxBgColor: widget.boxBgColor,
                                  fontColor: widget.fontColor,
                                  onPaymentAdded: () {
                                    widget.onDataChanged();
                                    setState(() {});
                                  },
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: widget.boxBgColor,
                                borderRadius: BorderRadius.circular(14)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: debt.isOwedToMe
                                                  ? const Color(0xFF00E676)
                                                      .withValues(alpha: 0.15)
                                                  : Colors.redAccent
                                                      .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(
                                              debt.isOwedToMe
                                                  ? (widget.currentLocale ==
                                                          'en'
                                                      ? "OWED TO YOU"
                                                      : (widget.currentLocale ==
                                                              'id'
                                                          ? "PIUTANG"
                                                          : "UTANG SAYO"))
                                                  : (widget.currentLocale ==
                                                          'en'
                                                      ? "YOU OWE"
                                                      : (widget.currentLocale ==
                                                              'id'
                                                          ? "UTANG"
                                                          : "UTANG MO")),
                                              style: TextStyle(
                                                  color: debt.isOwedToMe
                                                      ? const Color(0xFF00E676)
                                                      : Colors.redAccent,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(debt.name,
                                            style: TextStyle(
                                                color: widget.fontColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                        "Paid: ${debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(debt.paidAmount.toInt())} / ${debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(debt.totalAmount.toInt())}",
                                        style: TextStyle(
                                            color: widget.fontColor
                                                .withValues(alpha: 0.38),
                                            fontSize: 11)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            isFullyPaid
                                                ? "LUNAS"
                                                : "${debt.currencySymbol}${NumberFormat('#,##0', 'en_US').format(remaining.toInt())}",
                                            style: TextStyle(
                                                color: isFullyPaid
                                                    ? const Color(0xFF00E676)
                                                    : (debt.isOwedToMe
                                                        ? const Color(
                                                            0xFF00E676)
                                                        : Colors.redAccent),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        if (!isFullyPaid) ...[
                                          const SizedBox(height: 2),
                                          Text(unpaidLabel,
                                              style: TextStyle(
                                                  color: widget.fontColor
                                                      .withValues(alpha: 0.38),
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ],
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert,
                                          color: widget.fontColor
                                              .withValues(alpha: 0.3),
                                          size: 18),
                                      color: const Color(0xFF252525),
                                      // ── 🔥 BINAGO ANG ONSELECTED LOGIC CONTROLS ──
                                      onSelected: (String action) {
                                        if (action == 'add_payment') {
                                          // 🚀 DIREKTA SA ENTRY PAGE: Nilalaktawan ang simpleng popup dialog
                                          // At tinatawag ang buong details history navigation sub-page frame
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DebtHistoryPage(
                                                debt: debt,
                                                currentLocale:
                                                    widget.currentLocale,
                                                pesoFormatter:
                                                    widget.pesoFormatter,
                                                boxBgColor: widget.boxBgColor,
                                                fontColor: widget.fontColor,
                                                onPaymentAdded: () {
                                                  widget.onDataChanged();
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                          ).then((_) => setState(() {}));
                                        } else if (action == 'edit_name') {
                                          _showEditDebtNameDialog(debt);
                                        } else if (action == 'edit_amount') {
                                          _showEditDebtAmountDialog(debt);
                                        } else if (action == 'delete') {
                                          _confirmDeleteDebt(debt);
                                        }
                                      },
                                      itemBuilder: (ctx) {
                                        // manatili ang iyong orihinal na list items array code...

                                        bool isFullyPaid = (debt.totalAmount -
                                                debt.paidAmount) <=
                                            0;
                                        return [
                                          // 🔥 BAGONG POPUP ITEM: GRAYED OUT KAPAG LUNAS NA
                                          PopupMenuItem(
                                              value: isFullyPaid
                                                  ? null
                                                  : 'add_payment',
                                              enabled: !isFullyPaid,
                                              child: Row(children: [
                                                Icon(Icons.add_circle_outline,
                                                    color: isFullyPaid
                                                        ? Colors.white24
                                                        : const Color(
                                                            0xFF00E676),
                                                    size: 16),
                                                const SizedBox(width: 8),
                                                Text(
                                                    widget.currentLocale == 'en'
                                                        ? "Add Payment"
                                                        : (widget.currentLocale ==
                                                                'id'
                                                            ? "Tambah Pembayaran"
                                                            : "Magbayad / Maningil"),
                                                    style: TextStyle(
                                                        color: isFullyPaid
                                                            ? Colors.white24
                                                            : Colors.white,
                                                        fontSize: 13))
                                              ])),
                                          PopupMenuItem(
                                              value: 'edit_name',
                                              child: Row(children: [
                                                const Icon(Icons.edit,
                                                    color: Color(0xFFFFD700),
                                                    size: 16),
                                                const SizedBox(width: 8),
                                                Text(
                                                    widget.currentLocale == 'en'
                                                        ? "Edit Name"
                                                        : (widget.currentLocale ==
                                                                'id'
                                                            ? "Ubah Nama"
                                                            : "I-edit ang Pangalan"),
                                                    style: TextStyle(
                                                        color: widget.fontColor,
                                                        fontSize: 13))
                                              ])),
                                          PopupMenuItem(
                                              value: 'edit_amount',
                                              child: Row(children: [
                                                const Icon(
                                                    Icons
                                                        .monetization_on_outlined,
                                                    color: Color(0xFFFFD700),
                                                    size: 16),
                                                const SizedBox(width: 8),
                                                Text(
                                                    widget.currentLocale == 'en'
                                                        ? "Edit Amount"
                                                        : (widget.currentLocale ==
                                                                'id'
                                                            ? "Ubah Jumlah"
                                                            : "I-edit ang Halaga"),
                                                    style: TextStyle(
                                                        color: widget.fontColor,
                                                        fontSize: 13))
                                              ])),
                                          PopupMenuItem(
                                              value: 'delete',
                                              child: Row(children: [
                                                const Icon(Icons.delete_outline,
                                                    color: Colors.redAccent,
                                                    size: 16),
                                                const SizedBox(width: 8),
                                                Text(
                                                    widget.currentLocale == 'en'
                                                        ? "Delete"
                                                        : (widget.currentLocale ==
                                                                'id'
                                                            ? "Hapus"
                                                            : "Burahin"),
                                                    style: TextStyle(
                                                        color: widget.fontColor,
                                                        fontSize: 13))
                                              ])),
                                        ];
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddDebtDialog,
              icon: const Icon(Icons.add_card),
              label: Text(
                widget.currentLocale == 'en'
                    ? "TRACK NEW DEBT TRANSACTION"
                    : (widget.currentLocale == 'id'
                        ? "CATAT TRANSAKSI UTANG BARU"
                        : "MAGDAGDAG NG UTANG"),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            )
          ],
        ),
      ),
    );
  }

  void _showAddDebtPaymentDialog(DebtItemV2 debt) {
    final TextEditingController amountCtrl = TextEditingController();
    String sym = debt.currencySymbol.isNotEmpty ? debt.currencySymbol : "₱";
    double kasalukuyangKulang = debt.totalAmount - debt.paidAmount;
    if (kasalukuyangKulang < 0) kasalukuyangKulang = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // 🔥 IDINAGDAG: Local variable para sa error text layout block matrix control
          String internalPaymentErrorText = "";

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              widget.currentLocale == 'en'
                  ? "Add Payment"
                  : (widget.currentLocale == 'id'
                      ? "Tambah Pembayaran"
                      : "Magtala ng Bayad"),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CommaFormatter()
                    ],
                    decoration: InputDecoration(
                      prefixText: '$sym ',
                      prefixStyle: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold),
                      labelText: widget.currentLocale == 'en'
                          ? "Payment Amount"
                          : (widget.currentLocale == 'id'
                              ? "Jumlah Pembayaran"
                              : "Halaga ng Ibabayad"),
                      labelStyle:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Display line para sa natitirang utang / pondo
                  Text(
                    '${widget.currentLocale == 'en' ? "Remaining balance:" : (widget.currentLocale == 'id' ? "Sisa utang:" : "Natitirang kulang:")} $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}',
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),

                  // 🔥 BAGONG IMPLEMENTASYON: Dito lalabas ang pulang error box sa mismong HARAP ng dialog box
                  if (internalPaymentErrorText.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.5),
                            width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              internalPaymentErrorText,
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                    widget.currentLocale == 'en'
                        ? "Cancel"
                        : (widget.currentLocale == 'id'
                            ? "Batal"
                            : "Kanselahin"),
                    style: const TextStyle(color: Colors.white38)),
              ),
              TextButton(
                onPressed: () async {
                  final String cleanText =
                      amountCtrl.text.replaceAll(',', '').trim();
                  final double? amt = double.tryParse(cleanText);
                  if (amt == null || amt <= 0) return;

                  // 🛑 LIVE VALIDATION 1: Kung bayad na ang utang
                  if (debt.paidAmount >= debt.totalAmount) {
                    setDialogState(() {
                      internalPaymentErrorText = widget.currentLocale == 'en'
                          ? "This debt is already fully paid! 🛑"
                          : (widget.currentLocale == 'id'
                              ? "Utang ini sudah lunas! 🛑"
                              : "Ang utang na ito ay lunas na! 🛑");
                    });
                    return;
                  }

                  // 🛑 LIVE VALIDATION 2: Kung sumobra ang ibinabayad sa natitirang balanse (Gaya ng nasa image mo)
                  if ((debt.paidAmount + amt) > debt.totalAmount) {
                    setDialogState(() {
                      internalPaymentErrorText = widget.currentLocale == 'en'
                          ? "Excess payment amount! Remaining balance is $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}"
                          : (widget.currentLocale == 'id'
                              ? "Jumlah pembayaran berlebih! Sisa utang adalah $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}"
                              : "Sobra ang iyong ibinayad! Ang natitirang utang na lang ay $sym${NumberFormat('#,##0', 'en_US').format(kasalukuyangKulang.toInt())}");
                    });
                    return; // Pinipigilan ang pagpapatuloy ng save mechanism
                  }

                  // Pag-save kung pumasa sa data tracking rules validation matrix
                  double bagongPaidTotal = debt.paidAmount + amt;

                  setState(() {
                    debt.payments
                        .add(DebtPayment(amount: amt, date: DateTime.now()));
                    debt.paidAmount = bagongPaidTotal;
                  });

                  widget.onDataChanged();
                  Navigator.pop(context); // Isasara ang input page dialog view

                  if (mounted) {
                    bool lunasNa = bagongPaidTotal >= debt.totalAmount;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(lunasNa ? "🎉🏆" : "🟢✨",
                                style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text(
                              lunasNa
                                  ? (widget.currentLocale == 'en'
                                      ? "DEBT FULLY PAID! 🥳"
                                      : (widget.currentLocale == 'id'
                                          ? "UTANG LUNAS! 🥳"
                                          : "UTANG AY LUNAS NA! 🥳"))
                                  : (widget.currentLocale == 'en'
                                      ? "PAYMENT ADDED!"
                                      : (widget.currentLocale == 'id'
                                          ? "PEMBAYARAN DICATAT!"
                                          : "NAITALA ANG BAYAD!")),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lunasNa
                                  ? (widget.currentLocale == 'en'
                                      ? "Congratulations! You have settled the record for ${debt.name.toUpperCase()}."
                                      : (widget.currentLocale == 'id'
                                          ? "Selamat! Anda telah melunasi catatan untuk ${debt.name.toUpperCase()}."
                                          : "Salamat sa Diyos! Matagumpay mong nailunsad at nabayaran si ${debt.name.toUpperCase()}."))
                                  : (widget.currentLocale == 'en'
                                      ? "Successfully added a payment of $sym${NumberFormat('#,##0', 'en_US').format(amt.toInt())}."
                                      : (widget.currentLocale == 'id'
                                          ? "Berhasil mencatat pembayaran sebesar $sym${NumberFormat('#,##0', 'en_US').format(amt.toInt())}."
                                          : "Matagumpay na naidagdag ang bayad na $sym${NumberFormat('#,##0', 'en_US').format(amt.toInt())}.")),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                              ),
                              child: Text(
                                  widget.currentLocale == 'en'
                                      ? "OKAY"
                                      : (widget.currentLocale == 'id'
                                          ? "OK"
                                          : "SIGE"),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                    widget.currentLocale == 'en'
                        ? "Pay"
                        : (widget.currentLocale == 'id' ? "Bayar" : "Ibayad"),
                    style: const TextStyle(
                        color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }
}

class FlightTrackerPainter extends CustomPainter {
  final double progress;
  final String remainingText;

  FlightTrackerPainter({
    required this.progress,
    required this.remainingText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double startX = size.width * 0.1;
    final double endX = size.width * 0.9;
    final double y = size.height * 0.6;

    final Paint baselinePaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(startX, y), Offset(endX, y), baselinePaint);

    final double currentX = startX + ((endX - startX) * progress);

    if (progress > 0) {
      canvas.drawLine(Offset(startX, y), Offset(currentX, y), progressPaint);
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: remainingText,
        style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout();
    final double textX = (size.width / 2) - (textPainter.width / 2);
    final double textY = y - 32;

    textPainter.paint(canvas, Offset(textX, textY));

    final Paint dotPaint = Paint()..style = PaintingStyle.fill;

    dotPaint.color = Colors.white24;
    canvas.drawCircle(Offset(startX, y), 5, dotPaint);

    dotPaint.color = progress >= 1.0 ? const Color(0xFF00E676) : Colors.white24;
    canvas.drawCircle(Offset(endX, y), 5, dotPaint);

    if (progress > 0) {
      final Paint sliderPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(currentX, y), 6, sliderPaint);

      final Paint glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, y), 12, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FlightTrackerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.remainingText != remainingText;
  }
}

class DebtItemV2 {
  String id;
  String name;
  double totalAmount;
  double paidAmount;
  bool isOwedToMe;
  DateTime date;
  String currencySymbol;
  List<DebtPayment> payments;

  DebtItemV2({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.paidAmount,
    required this.isOwedToMe,
    required this.date,
    required this.currencySymbol,
    required this.payments,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'isOwedToMe': isOwedToMe,
        'date': date.toIso8601String(),
        'currencySymbol': currencySymbol,
        'payments': payments.map((p) => p.toJson()).toList(),
      };

  factory DebtItemV2.fromJson(Map<String, dynamic> json) => DebtItemV2(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        totalAmount: (json['totalAmount'] as num? ?? 0.0).toDouble(),
        paidAmount: (json['paidAmount'] as num? ?? 0.0).toDouble(),
        isOwedToMe: json['isOwedToMe'] ?? false,
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
        currencySymbol: json['currencySymbol'] ?? '₱',
        payments: json['payments'] != null
            ? (json['payments'] as List)
                .map((p) => DebtPayment.fromJson(p))
                .toList()
            : [],
      );
}
