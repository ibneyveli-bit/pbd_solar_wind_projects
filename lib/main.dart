import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'project_data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PBD/NLCIL Renewable Energy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: WelcomeScreen(),
    );
  }
}

// Welcome Screen with Full Background
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _windmillController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Windmill rotation
    _windmillController = AnimationController(duration: Duration(seconds: 4), vsync: this)..repeat();

    // Fade in animation
    _fadeController = AnimationController(duration: Duration(seconds: 2), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    // Pulse animation for button
    _pulseController = AnimationController(duration: Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _windmillController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/renewable_energy_background.png'),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              debugPrint('Failed to load background image: $exception');
            },
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // Deep blue sky (fallback)
              Color(0xFF1976D2), // Medium blue
              Color(0xFF42A5F5), // Light blue
              Color(0xFF81C784), // Light green (ground)
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background Infrastructure Elements (without windmills)
            _buildBackgroundInfrastructure(),

            // Main Content Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 1),

                    // Windmills above the text box
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: AnimatedBuilder(
                        animation: _windmillController,
                        builder: (context, child) {
                          return _buildWindmillRow();
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    // Company Logo/Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.energy_savings_leaf, size: 60, color: Colors.green.shade700),
                            SizedBox(height: 10),
                            Text(
                              'PBD/NLCIL',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'RENEWABLE ENERGY PROJECTS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.green, Colors.blue]),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Sun and Solar Panel Diagram
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: AnimatedBuilder(
                        animation: _windmillController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(280, 200),
                            painter: SolarPanelSunPainter(animationValue: _windmillController.value),
                          );
                        },
                      ),
                    ),

                    Spacer(flex: 2),

                    // Get Started Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => RoleSelectionScreen(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(opacity: animation, child: child);
                                      },
                                      transitionDuration: Duration(milliseconds: 800),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  elevation: 15,
                                  shadowColor: Colors.orange.withValues(alpha: 0.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_arrow, size: 28),
                                    SizedBox(width: 10),
                                    Text(
                                      'GET STARTED',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindmillRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: CustomPaint(
            size: Size(40, 50),
            painter: WindmillPainter(
              animationValue: _windmillController.value,
              offset: index * pi / 6,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBackgroundInfrastructure() {
    return Stack(
      children: [
        // Background infrastructure removed - main diagram shows all elements
      ],
    );
  }

}

// Windmill Painter for individual windmills
class WindmillPainter extends CustomPainter {
  final double animationValue;
  final double offset;

  WindmillPainter({required this.animationValue, this.offset = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final towerPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final bladePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final bladeStrokePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final centerX = size.width / 2;

    // Draw windmill tower (post)
    canvas.drawLine(
      Offset(centerX, size.height * 0.2),
      Offset(centerX, size.height),
      towerPaint,
    );

    // Draw rotating blades at top of post
    final bladeCenter = Offset(centerX, size.height * 0.2);
    final rotationAngle = animationValue * 2 * pi + offset;

    // Draw 3 blades
    for (int j = 0; j < 3; j++) {
      final angle = rotationAngle + (j * 2 * pi / 3);

      final bladeLength = 15.0;

      // Calculate blade tip position
      final bladeTipX = bladeCenter.dx + bladeLength * cos(angle);
      final bladeTipY = bladeCenter.dy + bladeLength * sin(angle);

      // Draw blade as a path (tapered shape)
      final bladePath = Path();

      // Perpendicular angle for blade width
      final perpAngle = angle + pi / 2;

      // Blade base (wider)
      final baseOffset = 2.0;
      bladePath.moveTo(
        bladeCenter.dx + baseOffset * cos(perpAngle),
        bladeCenter.dy + baseOffset * sin(perpAngle),
      );
      bladePath.lineTo(
        bladeCenter.dx - baseOffset * cos(perpAngle),
        bladeCenter.dy - baseOffset * sin(perpAngle),
      );

      // Blade tip (narrower)
      final tipOffset = 0.5;
      bladePath.lineTo(
        bladeTipX - tipOffset * cos(perpAngle),
        bladeTipY - tipOffset * sin(perpAngle),
      );
      bladePath.lineTo(
        bladeTipX + tipOffset * cos(perpAngle),
        bladeTipY + tipOffset * sin(perpAngle),
      );
      bladePath.close();

      // Fill and stroke the blade
      canvas.drawPath(bladePath, bladePaint);
      canvas.drawPath(bladePath, bladeStrokePaint);
    }

    // Draw hub (center circle)
    canvas.drawCircle(bladeCenter, 2.5, Paint()..color = Colors.grey.shade800..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant WindmillPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class SolarPanelSunPainter extends CustomPainter {
  final double animationValue;

  SolarPanelSunPainter({this.animationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final sunPaint = Paint()
      ..color = Colors.orange.shade400
      ..style = PaintingStyle.fill;

    final rayPaint = Paint()
      ..color = Colors.orange.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final panelPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    final framePaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw sun centered in the middle
    final sunCenter = Offset(size.width * 0.5, size.height * 0.35);

    // Draw solar panels below the sun
    final panelWidth = size.width * 0.32;
    final panelHeight = size.height * 0.28;
    final startY = size.height * 0.65;
    canvas.drawCircle(sunCenter, 20, sunPaint);

    // Draw sun rays (animated - pulsing effect - rays come and go)
    final rayLength = 35 + (sin(animationValue * 2 * pi) * 15); // Pulse between 20-50
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * 3.14159 / 180;
      final start = Offset(sunCenter.dx + 25 * cos(angle), sunCenter.dy + 25 * sin(angle));
      final end = Offset(sunCenter.dx + (25 + rayLength) * cos(angle), sunCenter.dy + (25 + rayLength) * sin(angle));
      canvas.drawLine(start, end, rayPaint..strokeWidth = 3);
    }

    for (int i = 0; i < 2; i++) {
      // Position panels symmetrically: left panel and right panel centered around the middle
      final gapBetweenPanels = 20.0; // Small gap between panels
      final totalWidth = (panelWidth * 2) + gapBetweenPanels;
      final leftmostX = (size.width - totalWidth) / 2;
      final startX = leftmostX + (i * (panelWidth + gapBetweenPanels));

      // Draw panel
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(startX, startY, panelWidth, panelHeight), Radius.circular(3));
      canvas.drawRRect(rect, panelPaint);
      canvas.drawRRect(rect, framePaint..strokeWidth = 2.5);

      // Draw panel grid lines (horizontal) - white for realistic look
      for (int j = 1; j < 8; j++) {
        canvas.drawLine(
          Offset(startX, startY + (panelHeight / 8) * j),
          Offset(startX + panelWidth, startY + (panelHeight / 8) * j),
          gridPaint,
        );
      }

      // Draw panel grid lines (vertical) - white for realistic look
      for (int k = 1; k < 6; k++) {
        canvas.drawLine(
          Offset(startX + (panelWidth / 6) * k, startY),
          Offset(startX + (panelWidth / 6) * k, startY + panelHeight),
          gridPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SolarPanelSunPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Role Selection Screen
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: Duration(seconds: 1), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF81C784)],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  ),
                ),
              ),

              Spacer(flex: 2),

              // Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.admin_panel_settings, size: 50, color: Colors.blue.shade700),
                      SizedBox(height: 15),
                      Text(
                        'SELECT YOUR ROLE',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Choose your access level', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 60),

              // Role buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Administrator Button
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 8,
                          shadowColor: Colors.red.withValues(alpha: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.admin_panel_settings, size: 28),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ADMINISTRATOR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('View and Edit Access', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Viewer Button
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ViewerMainScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 8,
                          shadowColor: Colors.green.withValues(alpha: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('VIEWER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('View Only Access', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Login Screen
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Default admin credentials - in production, these should be stored securely
  final String _adminUsername = 'admin';
  final String _adminPassword = 'admin123';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: Duration(seconds: 1), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading delay
      await Future.delayed(Duration(milliseconds: 1500));

      if (_usernameController.text == _adminUsername && _passwordController.text == _adminPassword) {
        // Successful login
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminMainScreen()));
      } else {
        // Failed login
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid username or password'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF81C784)],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // Title Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.admin_panel_settings, size: 50, color: Colors.red.shade700),
                        SizedBox(height: 15),
                        Text(
                          'ADMINISTRATOR LOGIN',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enter your credentials to access admin panel',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // Login Form
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter admin username',
                              prefixIcon: Icon(Icons.person, color: Colors.red.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                              ),
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter username';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter admin password',
                              prefixIcon: Icon(Icons.lock, color: Colors.red.shade700),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                              ),
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 30),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 8,
                                shadowColor: Colors.red.withValues(alpha: 0.3),
                              ),
                              child: _isLoading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        ),
                                        SizedBox(width: 10),
                                        Text('Logging in...', style: TextStyle(fontSize: 16)),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login, size: 20),
                                        SizedBox(width: 8),
                                        Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Demo Credentials Info
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        SizedBox(height: 8),
                        Text(
                          'Demo Credentials',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Username: admin\nPassword: admin123',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Administrator Main Screen (with edit capabilities)
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  _AdminMainScreenState createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _cardAnimations;

  final List<ProjectCategory> categories = [
    ProjectCategory(
      name: 'BESS',
      icon: Icons.battery_charging_full,
      color: Colors.green,
      description: 'Battery Energy Storage Systems',
    ),
    ProjectCategory(
      name: 'Gujarat',
      icon: Icons.location_on,
      color: Colors.orange,
      description: 'Gujarat State Projects',
    ),
    ProjectCategory(
      name: 'Rajasthan',
      icon: Icons.location_on,
      color: Colors.red,
      description: 'Rajasthan State Projects',
    ),
    ProjectCategory(
      name: 'Mine II',
      icon: Icons.construction,
      color: Colors.brown,
      description: 'Mining Area Projects',
    ),
    ProjectCategory(
      name: 'Rooftop',
      icon: Icons.roofing,
      color: Colors.blue,
      description: 'Rooftop Solar Installations',
    ),
    ProjectCategory(name: 'PSP', icon: Icons.water_drop, color: Colors.cyan, description: 'Pumped Storage Projects'),
    ProjectCategory(
      name: 'Floating Solar',
      icon: Icons.water,
      color: Colors.lightBlue,
      description: 'Floating Solar Projects',
    ),
    ProjectCategory(
      name: 'EV Charging',
      icon: Icons.electric_car,
      color: Colors.purple,
      description: 'Electric Vehicle Charging',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(duration: Duration(milliseconds: 1200), vsync: this);

    _cardAnimations = List.generate(categories.length, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(index * 0.1, (index * 0.1) + 0.3, curve: Curves.easeOutBack),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF1B5E20)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Spacer(),
                        Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      'ADMINISTRATOR',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Full Access - View & Edit',
                      style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // Project Categories Grid
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _cardAnimations[index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _cardAnimations[index].value,
                            child: _buildAdminCategoryCard(categories[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCategoryCard(ProjectCategory category) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          if (category.name == 'BESS') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminBESSProjectsScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${category.name} projects - Coming Soon!'), backgroundColor: category.color),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: category.name == 'BESS'
                  ? [Colors.green.withValues(alpha: 0.9), Colors.green.withValues(alpha: 0.7)]
                  : [category.color.withValues(alpha: 0.8), category.color.withValues(alpha: 0.6)],
            ),
          ),
          child: Stack(
            children: [
              // Background image for BESS only
              if (category.name == 'BESS')
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage('assets/images/battery_storage.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                    ),
                  ),
                ),
              // Admin badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
              // Card content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (category.name != 'BESS') Icon(category.icon, size: 50, color: Colors.white),
                  SizedBox(height: category.name == 'BESS' ? 30 : 15),
                  Text(
                    category.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      category.description,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
}

// Viewer Main Screen (view only)
class ViewerMainScreen extends StatefulWidget {
  const ViewerMainScreen({super.key});

  @override
  _ViewerMainScreenState createState() => _ViewerMainScreenState();
}

class _ViewerMainScreenState extends State<ViewerMainScreen> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _cardAnimations;

  final List<ProjectCategory> categories = [
    ProjectCategory(
      name: 'BESS',
      icon: Icons.battery_charging_full,
      color: Colors.green,
      description: 'Battery Energy Storage Systems',
    ),
    ProjectCategory(
      name: 'Gujarat',
      icon: Icons.location_on,
      color: Colors.orange,
      description: 'Gujarat State Projects',
    ),
    ProjectCategory(
      name: 'Rajasthan',
      icon: Icons.location_on,
      color: Colors.red,
      description: 'Rajasthan State Projects',
    ),
    ProjectCategory(
      name: 'Mine II',
      icon: Icons.construction,
      color: Colors.brown,
      description: 'Mining Area Projects',
    ),
    ProjectCategory(
      name: 'Rooftop',
      icon: Icons.roofing,
      color: Colors.blue,
      description: 'Rooftop Solar Installations',
    ),
    ProjectCategory(name: 'PSP', icon: Icons.water_drop, color: Colors.cyan, description: 'Pumped Storage Projects'),
    ProjectCategory(
      name: 'Floating Solar',
      icon: Icons.water,
      color: Colors.lightBlue,
      description: 'Floating Solar Projects',
    ),
    ProjectCategory(
      name: 'EV Charging',
      icon: Icons.electric_car,
      color: Colors.purple,
      description: 'Electric Vehicle Charging',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(duration: Duration(milliseconds: 1200), vsync: this);

    _cardAnimations = List.generate(categories.length, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(index * 0.1, (index * 0.1) + 0.3, curve: Curves.easeOutBack),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF388E3C), Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Spacer(),
                        Text(
                          'VIEWER',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              ),

              // Project Categories Grid
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _cardAnimations[index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _cardAnimations[index].value,
                            child: _buildViewerCategoryCard(categories[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewerCategoryCard(ProjectCategory category) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          if (category.name == 'BESS') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewerBESSProjectsScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${category.name} projects - Coming Soon!'), backgroundColor: category.color),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: category.name == 'BESS'
                  ? [Colors.green.withValues(alpha: 0.9), Colors.green.withValues(alpha: 0.7)]
                  : [category.color.withValues(alpha: 0.8), category.color.withValues(alpha: 0.6)],
            ),
          ),
          child: Stack(
            children: [
              // Background image for BESS only
              if (category.name == 'BESS')
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage('assets/images/battery_storage.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                    ),
                  ),
                ),
              // Card content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (category.name != 'BESS') Icon(category.icon, size: 50, color: Colors.white),
                  SizedBox(height: category.name == 'BESS' ? 30 : 15),
                  Text(
                    category.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      category.description,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
}

// Main Screen with Project Categories
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _cardAnimations;

  final List<ProjectCategory> categories = [
    ProjectCategory(
      name: 'BESS',
      icon: Icons.battery_charging_full,
      color: Colors.green,
      description: 'Battery Energy Storage Systems',
    ),
    ProjectCategory(
      name: 'Gujarat',
      icon: Icons.location_on,
      color: Colors.orange,
      description: 'Gujarat State Projects',
    ),
    ProjectCategory(
      name: 'Rajasthan',
      icon: Icons.location_on,
      color: Colors.red,
      description: 'Rajasthan State Projects',
    ),
    ProjectCategory(
      name: 'Mine II',
      icon: Icons.construction,
      color: Colors.brown,
      description: 'Mining Area Projects',
    ),
    ProjectCategory(
      name: 'Rooftop',
      icon: Icons.roofing,
      color: Colors.blue,
      description: 'Rooftop Solar Installations',
    ),
    ProjectCategory(name: 'PSP', icon: Icons.water_drop, color: Colors.cyan, description: 'Pumped Storage Projects'),
    ProjectCategory(
      name: 'Floating Solar',
      icon: Icons.water,
      color: Colors.lightBlue,
      description: 'Floating Solar Projects',
    ),
    ProjectCategory(
      name: 'EV Charging',
      icon: Icons.electric_car,
      color: Colors.purple,
      description: 'Electric Vehicle Charging',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(duration: Duration(milliseconds: 1200), vsync: this);

    _cardAnimations = List.generate(categories.length, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(index * 0.1, (index * 0.1) + 0.3, curve: Curves.easeOutBack),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF1B5E20)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Spacer(),
                        Icon(Icons.energy_savings_leaf, color: Colors.white, size: 28),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      'PBD/NLCIL',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Project Categories',
                      style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // Project Categories Grid
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _cardAnimations[index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _cardAnimations[index].value,
                            child: _buildCategoryCard(categories[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ProjectCategory category) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          if (category.name == 'BESS') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BESSProjectsScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${category.name} projects - Coming Soon!'), backgroundColor: category.color),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [category.color.withValues(alpha: 0.8), category.color.withValues(alpha: 0.6)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, size: 50, color: Colors.white),
              SizedBox(height: 15),
              Text(
                category.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  category.description,
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// BESS Project Screen - Tamil Nadu 250 MW/500 MWh - Fixed navigation
class BESSProjectsScreen extends StatefulWidget {
  const BESSProjectsScreen({super.key});

  @override
  _BESSProjectsScreenState createState() => _BESSProjectsScreenState();
}

class _BESSProjectsScreenState extends State<BESSProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tamil Nadu 250 MW/500 MWh BESS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.blue.shade50, Colors.grey.shade50],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.battery_charging_full, size: 60, color: Colors.green.shade700),
                  SizedBox(height: 15),
                  Text(
                    'Tamil Nadu BESS Project',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '250 MW / 500 MWh',
                    style: TextStyle(fontSize: 20, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Text('Battery Energy Storage System', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),

            // Project Information Cards
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInfoCard(
                      'Project Overview',
                      Icons.info_outline,
                      Colors.lightBlue,
                      'Add your project overview details here',
                    ),
                    _buildInfoCard(
                      'Technical Specifications',
                      Icons.engineering,
                      Colors.orange.shade300,
                      'Add technical specifications here',
                    ),
                    _buildInfoCard(
                      'Erection and Commissioning',
                      Icons.construction,
                      Colors.teal.shade300,
                      'Add erection and commissioning details',
                    ),
                    _buildInfoCard(
                      'O&M',
                      Icons.settings,
                      Colors.purple.shade300,
                      'Add operation and maintenance information',
                    ),
                    SizedBox(height: 30),

                    // Action Buttons
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => MainScreen()),
                              (route) => false,
                            );
                          },
                          icon: Icon(Icons.home, size: 24),
                          label: Text('HOME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, Color color, String placeholder) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          // Navigation debug removed for production

          // Show snackbar for immediate feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title button pressed!'), duration: Duration(seconds: 2), backgroundColor: color),
          );

          // Navigate to specific screen based on title
          // Navigation debug removed for production
          try {
            if (title == 'Project Overview') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectOverviewScreen()),
              ).then((_) => print('=== NAVIGATION TO PROJECT OVERVIEW COMPLETED ==='));
            } else if (title == 'Technical Specifications') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TechnicalSpecificationsScreen()),
              ).then((_) => print('=== NAVIGATION TO TECHNICAL SPECS COMPLETED ==='));
            } else if (title == 'Erection and Commissioning') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocationInfrastructureScreen()),
              ).then((_) => print('=== NAVIGATION TO ERECTION & COMMISSIONING COMPLETED ==='));
            } else if (title == 'O&M') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvestmentTimelineScreen()),
              ).then((_) => print('=== NAVIGATION TO O&M COMPLETED ==='));
            }
          } catch (e) {
            print('=== NAVIGATION ERROR: $e ===');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigation error: $e'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.9),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 6,
          shadowColor: color.withValues(alpha: 0.3),
          minimumSize: Size(double.infinity, 60), // Ensure minimum touch area
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap to view details',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

// Admin BESS Projects Screen (with edit capabilities)
class AdminBESSProjectsScreen extends StatefulWidget {
  const AdminBESSProjectsScreen({super.key});

  @override
  _AdminBESSProjectsScreenState createState() => _AdminBESSProjectsScreenState();
}

class _AdminBESSProjectsScreenState extends State<AdminBESSProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin - Tamil Nadu 250 MW/500 MWh BESS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 5,
        actions: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit, size: 20),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.green.shade50, Colors.blue.shade50],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.admin_panel_settings, size: 30, color: Colors.red.shade700),
                      SizedBox(width: 10),
                      Icon(Icons.battery_charging_full, size: 60, color: Colors.green.shade700),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Administrator Mode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Battery Energy Storage System - Full Edit Access',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Project Information Cards
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildAdminInfoCard(
                      'Project Overview',
                      Icons.info_outline,
                      Colors.lightBlue,
                      'Edit project overview details',
                    ),
                    _buildAdminInfoCard(
                      'Technical Specifications',
                      Icons.engineering,
                      Colors.orange.shade300,
                      'Edit technical specifications',
                    ),
                    _buildAdminInfoCard(
                      'Erection and Commissioning',
                      Icons.construction,
                      Colors.teal.shade300,
                      'Edit erection and commissioning details',
                    ),
                    _buildAdminInfoCard(
                      'O&M',
                      Icons.settings,
                      Colors.purple.shade300,
                      'Edit operation and maintenance information',
                    ),
                    _buildAdminInfoCard(
                      'Documents',
                      Icons.description,
                      Colors.orange.shade600,
                      'Manage project documents and files',
                    ),
                    SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => AdminMainScreen()),
                                (route) => false,
                              );
                            },
                            icon: Icon(Icons.home, size: 24),
                            label: Text('ADMIN HOME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Admin: Save functionality - Coming Soon!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: Icon(Icons.save, size: 24),
                            label: Text('SAVE CHANGES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminInfoCard(String title, IconData icon, Color color, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          print('=== ADMIN BUTTON PRESSED: $title ===');

          // Show snackbar for immediate feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Admin: $title access granted!'),
              duration: Duration(seconds: 2),
              backgroundColor: color,
            ),
          );

          // Navigate to specific screen based on title
          print('=== ADMIN NAVIGATION: Attempting to navigate to: $title ===');
          try {
            Widget? destination;
            if (title == 'Project Overview') {
              print('Creating AdminProjectOverviewScreen');
              destination = AdminProjectOverviewScreen();
            } else if (title == 'Technical Specifications') {
              destination = AdminTechnicalSpecificationsScreen();
            } else if (title == 'Erection and Commissioning') {
              destination = AdminLocationInfrastructureScreen();
            } else if (title == 'O&M') {
              destination = AdminInvestmentTimelineScreen();
            } else if (title == 'Documents') {
              destination = DocumentsScreen(isAdmin: true);
            }

            if (destination != null) {
              print('Navigating to destination: ${destination.runtimeType}');
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => destination!,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.fastOutSlowIn;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                  transitionDuration: Duration(milliseconds: 300),
                ),
              );
            }
          } catch (e) {
            print('=== ADMIN NAVIGATION ERROR: $e ===');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.9),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 6,
          shadowColor: color.withValues(alpha: 0.3),
          minimumSize: Size(double.infinity, 60),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 2),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
              child: Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Viewer BESS Projects Screen (view only)
class ViewerBESSProjectsScreen extends StatefulWidget {
  const ViewerBESSProjectsScreen({super.key});

  @override
  _ViewerBESSProjectsScreenState createState() => _ViewerBESSProjectsScreenState();
}

class _ViewerBESSProjectsScreenState extends State<ViewerBESSProjectsScreen> {
  Widget _createViewerProjectOverviewScreen() {
    return ViewerProjectOverviewScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tamil Nadu 250 MW/500 MWh BESS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 5,
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.blue.shade50, Colors.grey.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildViewerInfoCard(
                'Project Overview',
                Icons.info_outline,
                Colors.lightBlue,
                'View project overview details',
              ),
              _buildViewerInfoCard(
                'Technical Specifications',
                Icons.engineering,
                Colors.orange.shade300,
                'View technical specifications',
              ),
              _buildViewerInfoCard(
                'Erection and Commissioning',
                Icons.construction,
                Colors.teal.shade300,
                'View erection and commissioning details',
              ),
              _buildViewerInfoCard(
                'O&M',
                Icons.settings,
                Colors.purple.shade300,
                'View operation and maintenance information',
              ),
              // Documents Button
              _buildViewerInfoCard(
                'Documents',
                Icons.description,
                Colors.orange.shade600,
                'View project documents and files',
              ),
              SizedBox(height: 20),

              // Action Buttons
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => ViewerMainScreen()),
                        (route) => false,
                      );
                    },
                    icon: Icon(Icons.home, size: 24),
                    label: Text('HOME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewerInfoCard(String title, IconData icon, Color color, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          print('=== VIEWER BUTTON PRESSED: $title ===');

          // Show snackbar for immediate feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewer: $title access granted!'),
              duration: Duration(seconds: 2),
              backgroundColor: color,
            ),
          );

          // Navigate to specific screen based on title
          try {
            Widget? destination;
            if (title == 'Project Overview') {
              destination = _createViewerProjectOverviewScreen();
            } else if (title == 'Technical Specifications') {
              destination = ViewerTechnicalSpecificationsScreen();
            } else if (title == 'Erection and Commissioning') {
              destination = ViewerLocationInfrastructureScreen();
            } else if (title == 'O&M') {
              destination = ViewerInvestmentTimelineScreen();
            } else if (title == 'Documents') {
              destination = DocumentsScreen(isAdmin: false);
            }

            if (destination != null) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => destination!,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.fastOutSlowIn;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                  transitionDuration: Duration(milliseconds: 300),
                ),
              );
            }
          } catch (e) {
            print('=== VIEWER NAVIGATION ERROR: $e ===');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.9),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 6,
          shadowColor: color.withValues(alpha: 0.3),
          minimumSize: Size(double.infinity, 60),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 2),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Parameter Model
class Parameter {
  static int _counter = 0;
  final String id;
  String description;
  String data;

  Parameter({this.description = '', this.data = ''})
    : id = 'param_${DateTime.now().millisecondsSinceEpoch}_${++_counter}';

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Parameter && other.id == id;
  }
}

// Project Overview Screen
class ProjectOverviewScreen extends StatefulWidget {
  const ProjectOverviewScreen({super.key});

  @override
  _ProjectOverviewScreenState createState() => _ProjectOverviewScreenState();
}

class _ProjectOverviewScreenState extends State<ProjectOverviewScreen> {
  List<Parameter> parameters = [Parameter(), Parameter(), Parameter()];

  void _addParameter() {
    setState(() {
      parameters.add(Parameter());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tamilnadu 250 MW/500 MWh BESS Project Overview',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.home),
            tooltip: 'Home',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.lightBlue.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.lightBlue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DataTable(
                      columnSpacing: 8.0,
                      dividerThickness: 1.0,
                      border: TableBorder(verticalInside: BorderSide(color: Colors.lightBlue.shade200, width: 1)),
                      headingRowColor: WidgetStateColor.resolveWith((states) => Colors.lightBlue.shade100),
                      columns: [
                        DataColumn(
                          label: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              'Description',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              'Data',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      rows: parameters.asMap().entries.map((entry) {
                        int index = entry.key;
                        Parameter parameter = entry.value;
                        return DataRow(
                          key: ValueKey(parameter.id),
                          cells: [
                            DataCell(
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                constraints: BoxConstraints(
                                  maxHeight: 120, // Prevent overflow to next row
                                ),
                                child: TextFormField(
                                  key: ValueKey('desc_${parameter.id}'),
                                  initialValue: parameter.description,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.lightBlue.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.lightBlue, width: 2),
                                    ),
                                    hintText: 'Enter description',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    isDense: true,
                                  ),
                                  style: TextStyle(fontSize: 14),
                                  onChanged: (value) {
                                    parameter.description = value;
                                  },
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                constraints: BoxConstraints(
                                  maxHeight: 120, // Prevent overflow to next row
                                ),
                                child: TextFormField(
                                  key: ValueKey('data_${parameter.id}'),
                                  initialValue: parameter.data,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.lightBlue.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.lightBlue, width: 2),
                                    ),
                                    hintText: 'Enter data',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    isDense: true,
                                  ),
                                  style: TextStyle(fontSize: 14),
                                  onChanged: (value) {
                                    parameter.data = value;
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addParameter,
        backgroundColor: Colors.lightBlue,
        tooltip: 'Add Parameter',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Technical Specifications Screen
class TechnicalSpecificationsScreen extends StatelessWidget {
  const TechnicalSpecificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Technical Specifications'),
        backgroundColor: Colors.orange.shade300,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.home),
            tooltip: 'Home',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.engineering, size: 60, color: Colors.orange.shade300),
              SizedBox(height: 10),
              Text(
                'Technical Specifications',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'Battery Technology Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade400),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  'Add your technical specifications here including battery technology type, capacity details, efficiency ratings, discharge duration, grid connection specifications, and other technical parameters.',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Location & Infrastructure Screen (now Erection and Commissioning)
class LocationInfrastructureScreen extends StatelessWidget {
  const LocationInfrastructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Erection and Commissioning'),
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.home),
            tooltip: 'Home',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.construction, size: 60, color: Colors.teal.shade300),
              SizedBox(height: 10),
              Text(
                'Erection and Commissioning',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'Construction & Commissioning Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade400),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(
                  'Add erection and commissioning details including construction phases, installation procedures, testing protocols, commissioning schedules, and project milestone information for the Tamil Nadu BESS project.',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Investment & Timeline Screen (now O&M)
class InvestmentTimelineScreen extends StatelessWidget {
  const InvestmentTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('O&M'),
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.home),
            tooltip: 'Home',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.settings, size: 60, color: Colors.purple.shade300),
              SizedBox(height: 10),
              Text(
                'Operation & Maintenance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'O&M Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade400),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Text(
                  'Add operation and maintenance details including maintenance schedules, operational procedures, performance monitoring, preventive maintenance plans, and long-term operation strategies for the Tamil Nadu BESS project.',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Project Overview Screen (with edit capabilities)
class AdminProjectOverviewScreen extends StatefulWidget {
  const AdminProjectOverviewScreen({super.key});

  @override
  _AdminProjectOverviewScreenState createState() => _AdminProjectOverviewScreenState();
}

class _AdminProjectOverviewScreenState extends State<AdminProjectOverviewScreen> {
  String selectedLocation = 'Project Overview';
  final ProjectDataManager _dataManager = ProjectDataManager();
  bool _isLoading = false; // Start with false to show content immediately
  bool _isEditMode = false; // Track edit mode state

  // Cache for TextEditingControllers to prevent rebuilds
  final Map<String, TextEditingController> _controllers = {};

  final Map<String, Map<String, String>> locationData = {
    'Project Overview': {
      'capacity': '250 MW / 500 MWh',
      'description': 'Tamil Nadu BESS Project - Complete Overview',
      'status': 'Under Development',
      'location': 'Tamil Nadu, India',
    },
    'Anuppankulam': {
      'capacity': '83.33 MW / 166.66 MWh',
      'description': 'Anuppankulam BESS Project - Phase 1',
      'status': 'Under Development',
      'location': 'Anuppankulam, Tamil Nadu',
    },
    'Ettayapuram': {
      'capacity': '83.33 MW / 166.66 MWh',
      'description': 'Ettayapuram BESS Project - Phase 2',
      'status': 'Planning Stage',
      'location': 'Ettayapuram, Tamil Nadu',
    },
    'Kayathar': {
      'capacity': '83.34 MW / 166.68 MWh',
      'description': 'Kayathar BESS Project - Phase 3',
      'status': 'Feasibility Study',
      'location': 'Kayathar, Tamil Nadu',
    },
  };

  // Fallback table data that works immediately
  final Map<String, List<Map<String, String>>> fallbackTableData = {
    'Project Overview': [
      {'description': 'Project Name', 'data': 'Tamil Nadu BESS Project'},
      {'description': 'Total Capacity', 'data': '250 MW / 500 MWh'},
      {'description': 'Project Type', 'data': 'Battery Energy Storage System'},
      {'description': 'Location', 'data': 'Tamil Nadu, India'},
      {'description': 'Status', 'data': 'Under Development'},
    ],
    'Anuppankulam': [
      {'description': 'Site Name', 'data': 'Anuppankulam BESS'},
      {'description': 'Capacity', 'data': '83.33 MW / 166.66 MWh'},
      {'description': 'Phase', 'data': 'Phase 1'},
      {'description': 'Location', 'data': 'Anuppankulam, Tamil Nadu'},
      {'description': 'Status', 'data': 'Under Development'},
    ],
    'Ettayapuram': [
      {'description': 'Site Name', 'data': 'Ettayapuram BESS'},
      {'description': 'Capacity', 'data': '83.33 MW / 166.66 MWh'},
      {'description': 'Phase', 'data': 'Phase 2'},
      {'description': 'Location', 'data': 'Ettayapuram, Tamil Nadu'},
      {'description': 'Status', 'data': 'Planning Stage'},
    ],
    'Kayathar': [
      {'description': 'Site Name', 'data': 'Kayathar BESS'},
      {'description': 'Capacity', 'data': '83.34 MW / 166.68 MWh'},
      {'description': 'Phase', 'data': 'Phase 3'},
      {'description': 'Location', 'data': 'Kayathar, Tamil Nadu'},
      {'description': 'Status', 'data': 'Feasibility Study'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _dataManager.addListener(_refreshData);
  }

  @override
  void dispose() {
    _dataManager.removeListener(_refreshData);
    super.dispose();
  }

  void _refreshData() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this screen
    if (!_isLoading) {
      setState(() {});
    }
  }

  // Get table data with fallback
  List<Map<String, String>> getCurrentTableData() {
    print('=== ADMIN SCREEN getCurrentTableData() DEBUG ===');
    print('Selected location: $selectedLocation');

    // Try to get data from data manager first
    List<Map<String, String>>? managerData = _dataManager.getLocationData(selectedLocation);
    print('Manager data: $managerData');
    print('Manager data length: ${managerData?.length ?? 0}');

    // If data manager has data, use it; otherwise use fallback
    if (managerData != null && managerData.isNotEmpty) {
      print('Using manager data');
      return managerData;
    }

    // Return fallback data
    var fallbackData = fallbackTableData[selectedLocation] ?? [];
    print('Using fallback data: $fallbackData');
    print('Fallback data length: ${fallbackData.length}');
    print('=== END DEBUG ===');
    return fallbackData;
  }

  void _addRow() {
    _dataManager.addRow(selectedLocation, description: 'New Parameter', data: 'Enter value');
  }

  void _removeRow(int index) {
    _dataManager.removeRow(selectedLocation, index);
  }

  void _updateCell(int rowIndex, String column, String value) {
    _dataManager.updateCell(selectedLocation, rowIndex, column, value);
  }

  void _saveData() {
    bool success = _dataManager.saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Admin: Changes saved successfully!' : 'Error saving changes'),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('=== ADMIN SCREEN BUILD() CALLED ===');
    print('_isLoading: $_isLoading');
    print('selectedLocation: $selectedLocation');

    // Show loading screen while data manager initializes
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.lightBlue),
              SizedBox(height: 20),
              Text('Initializing admin panel...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin - Tamil Nadu 250 MW/500 MWh BESS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Ensure we go back to the correct screen
            Navigator.pop(context);
          },
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit, size: 20),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.red.shade700))
            : Column(
                children: [
                  // Location Selection Header
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.red.shade100, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.red.shade700, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Admin - ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedLocation,
                              isExpanded: true,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                              items: _getLocationData().keys.map((String location) {
                                return DropdownMenuItem<String>(value: location, child: Text(location));
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedLocation = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Editable Data Table
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(children: [SizedBox(height: 16), _buildEditableDataTable(), SizedBox(height: 20)]),
                    ),
                  ),
                  // Edit Mode Toggle Button
                  Container(
                    margin: EdgeInsets.all(16),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditMode = !_isEditMode;
                              });
                              if (!_isEditMode) {
                                // Save changes when exiting edit mode
                                _dataManager.saveData();
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Changes saved successfully!')));
                              }
                            },
                            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
                            label: Text(_isEditMode ? 'Save Changes' : 'Edit Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEditMode ? Colors.green.shade600 : Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        if (!_isEditMode) ...[
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _addNewDataRow,
                              icon: Icon(Icons.add),
                              label: Text('Add New'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Helper method to get all location data
  Map<String, List<Map<String, String>>> _getLocationData() {
    // Always try to get data manager data first if available
    var managerData = _dataManager.tableData;
    if (managerData.isNotEmpty) {
      return managerData;
    }

    // Fallback to hardcoded data to ensure immediate visibility
    return fallbackTableData;
  }

  // Helper method to get current location data
  List<Map<String, String>> _getCurrentLocationData() {
    final data = _getLocationData()[selectedLocation];
    return data ?? [];
  }

  // Build editable data table for admin mode
  Widget _buildEditableDataTable() {
    final currentData = _getCurrentLocationData();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(2.5)},
          children: [
            // Table Header
            TableRow(
              decoration: BoxDecoration(color: Colors.red.shade700),
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Parameter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Value',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            // Table Rows
            ...currentData.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final description = item['description'] ?? '';
              final data = item['data'] ?? '';
              final isEven = index % 2 == 0;

              return TableRow(
                decoration: BoxDecoration(color: isEven ? Colors.grey.shade50 : Colors.white),
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(_getIconForDescription(description), color: Colors.red.shade700, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: _isEditMode
                              ? TextField(
                                  controller: TextEditingController(text: description),
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    _dataManager.updateCell(selectedLocation, index, 'description', value);
                                  },
                                )
                              : Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: _isEditMode
                        ? TextField(
                            controller: TextEditingController(text: data),
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              _dataManager.updateCell(selectedLocation, index, 'data', value);
                            },
                          )
                        : Text(
                            data,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Get appropriate icon for description
  IconData _getIconForDescription(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('name') || desc.contains('project')) return Icons.business;
    if (desc.contains('capacity') || desc.contains('power')) return Icons.battery_charging_full;
    if (desc.contains('type')) return Icons.category;
    if (desc.contains('location')) return Icons.location_on;
    if (desc.contains('status')) return Icons.info;
    if (desc.contains('phase')) return Icons.timeline;
    return Icons.data_usage;
  }

  // Delete data item with confirmation
  void _deleteDataItem(int index) {
    if (_getCurrentLocationData().length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot delete the last item'), backgroundColor: Colors.orange));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _dataManager.removeRow(selectedLocation, index);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item deleted successfully!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add new data row
  void _addNewDataRow() {
    showDialog(
      context: context,
      builder: (context) {
        String newDescription = '';
        String newData = '';

        return AlertDialog(
          title: Text('Add New Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                onChanged: (value) => newDescription = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Data', border: OutlineInputBorder()),
                onChanged: (value) => newData = value,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (newDescription.isNotEmpty && newData.isNotEmpty) {
                  _dataManager.addRow(selectedLocation, description: newDescription, data: newData);
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data added successfully!')));
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Edit data item
  void _editDataItem(int index, String currentDescription, String currentData) {
    showDialog(
      context: context,
      builder: (context) {
        String newDescription = currentDescription;
        String newData = currentData;

        return AlertDialog(
          title: Text('Edit Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                controller: TextEditingController(text: currentDescription),
                onChanged: (value) => newDescription = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Data', border: OutlineInputBorder()),
                controller: TextEditingController(text: currentData),
                onChanged: (value) => newData = value,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                _dataManager.removeRow(selectedLocation, index);
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data deleted!')));
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                _dataManager.updateCell(selectedLocation, index, 'description', newDescription);
                _dataManager.updateCell(selectedLocation, index, 'data', newData);
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data updated successfully!')));
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// Viewer Project Overview Screen (view only)
class ViewerProjectOverviewScreen extends StatefulWidget {
  const ViewerProjectOverviewScreen({super.key});

  @override
  _ViewerProjectOverviewScreenState createState() => _ViewerProjectOverviewScreenState();
}

class _ViewerProjectOverviewScreenState extends State<ViewerProjectOverviewScreen> {
  String selectedLocation = 'Project Overview';
  final ProjectDataManager _dataManager = ProjectDataManager();

  // Fallback table data that works immediately
  final Map<String, List<Map<String, String>>> fallbackTableData = {
    'Project Overview': [
      {'description': 'Project Name', 'data': 'Tamil Nadu BESS Project'},
      {'description': 'Total Capacity', 'data': '250 MW / 500 MWh'},
      {'description': 'Project Type', 'data': 'Battery Energy Storage System'},
      {'description': 'Location', 'data': 'Tamil Nadu, India'},
      {'description': 'Status', 'data': 'Under Development'},
    ],
    'Anuppankulam': [
      {'description': 'Site Name', 'data': 'Anuppankulam BESS'},
      {'description': 'Capacity', 'data': '83.33 MW / 166.66 MWh'},
      {'description': 'Phase', 'data': 'Phase 1'},
      {'description': 'Location', 'data': 'Anuppankulam, Tamil Nadu'},
      {'description': 'Status', 'data': 'Under Development'},
    ],
    'Ettayapuram': [
      {'description': 'Site Name', 'data': 'Ettayapuram BESS'},
      {'description': 'Capacity', 'data': '83.33 MW / 166.66 MWh'},
      {'description': 'Phase', 'data': 'Phase 2'},
      {'description': 'Location', 'data': 'Ettayapuram, Tamil Nadu'},
      {'description': 'Status', 'data': 'Planning Stage'},
    ],
    'Kayathar': [
      {'description': 'Site Name', 'data': 'Kayathar BESS'},
      {'description': 'Capacity', 'data': '83.34 MW / 166.68 MWh'},
      {'description': 'Phase', 'data': 'Phase 3'},
      {'description': 'Location', 'data': 'Kayathar, Tamil Nadu'},
      {'description': 'Status', 'data': 'Feasibility Study'},
    ],
  };

  final Map<String, Map<String, String>> locationData = {
    'Project Overview': {
      'capacity': '250 MW / 500 MWh',
      'description': 'Tamil Nadu BESS Project - Complete Overview',
      'status': 'Under Development',
      'location': 'Tamil Nadu, India',
    },
    'Anuppankulam': {
      'capacity': '83.33 MW / 166.66 MWh',
      'description': 'Anuppankulam BESS Project - Phase 1',
      'status': 'Under Development',
      'location': 'Anuppankulam, Tamil Nadu',
    },
    'Ettayapuram': {
      'capacity': '83.33 MW / 166.66 MWh',
      'description': 'Ettayapuram BESS Project - Phase 2',
      'status': 'Planning Stage',
      'location': 'Ettayapuram, Tamil Nadu',
    },
    'Kayathar': {
      'capacity': '83.34 MW / 166.68 MWh',
      'description': 'Kayathar BESS Project - Phase 3',
      'status': 'Feasibility Study',
      'location': 'Kayathar, Tamil Nadu',
    },
  };

  @override
  void initState() {
    super.initState();
    _dataManager.addListener(_refreshData);
    // Force initial data load for ViewerProjectOverviewScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _dataManager.removeListener(_refreshData);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this screen
    setState(() {});
  }

  void _refreshData() {
    if (mounted) {
      setState(() {});
    }
  }

  // Helper method to get all location data
  Map<String, List<Map<String, String>>> _getLocationData() {
    // Try to get data from ProjectDataManager first for real-time updates
    if (_dataManager.isInitialized && _dataManager.tableData.isNotEmpty) {
      return _dataManager.tableData;
    }
    // Fallback to default data if ProjectDataManager is not ready
    return fallbackTableData;
  }

  // Helper method to get current location data
  List<Map<String, String>> _getCurrentLocationData() {
    final data = _getLocationData()[selectedLocation];
    return data ?? [];
  }

  // Build efficient table view for data
  Widget _buildDataTable() {
    final currentData = _getCurrentLocationData();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
          children: [
            // Table Header
            TableRow(
              decoration: BoxDecoration(color: Colors.green.shade600),
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Parameter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Value',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            // Table Rows
            ...currentData.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final description = item['description'] ?? '';
              final data = item['data'] ?? '';
              final isEven = index % 2 == 0;

              return TableRow(
                decoration: BoxDecoration(color: isEven ? Colors.grey.shade50 : Colors.white),
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(_getIconForDescription(description), color: Colors.green.shade700, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            description,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(data, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Get icon for description (same as admin)
  IconData _getIconForDescription(String description) {
    final lowerDesc = description.toLowerCase();
    if (lowerDesc.contains('name') || lowerDesc.contains('project')) return Icons.business;
    if (lowerDesc.contains('capacity') || lowerDesc.contains('mw') || lowerDesc.contains('mwh'))
      return Icons.battery_charging_full;
    if (lowerDesc.contains('type')) return Icons.category;
    if (lowerDesc.contains('location') || lowerDesc.contains('site')) return Icons.location_on;
    if (lowerDesc.contains('status') || lowerDesc.contains('phase')) return Icons.info;
    return Icons.data_object;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tamil Nadu 250 MW/500 MWh BESS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.visibility, size: 20),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Location Selection Header
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLocation,
                        isExpanded: true,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                        items: _getLocationData().keys.map((String location) {
                          return DropdownMenuItem<String>(value: location, child: Text(location));
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedLocation = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Efficient Table View
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [SizedBox(height: 16), _buildDataTable(), SizedBox(height: 20)]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Admin Technical Specifications Screen
class AdminTechnicalSpecificationsScreen extends StatelessWidget {
  const AdminTechnicalSpecificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Technical Specifications'),
        backgroundColor: Colors.orange.shade300,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit, size: 20),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.red.shade700, size: 24),
                  SizedBox(width: 10),
                  Icon(Icons.engineering, size: 60, color: Colors.orange.shade300),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Administrator Mode - Technical Specifications',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'Edit Battery Technology Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade400),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: TextField(
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText:
                        'Enter technical specifications here including battery technology type, capacity details, efficiency ratings, discharge duration, grid connection specifications, and other technical parameters.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Admin: Technical specifications saved!'), backgroundColor: Colors.green),
                    );
                  },
                  icon: Icon(Icons.save),
                  label: Text('SAVE SPECIFICATIONS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Viewer Technical Specifications Screen
class ViewerTechnicalSpecificationsScreen extends StatelessWidget {
  const ViewerTechnicalSpecificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Technical Specifications'),
        backgroundColor: Colors.orange.shade300,
        foregroundColor: Colors.white,
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.engineering, size: 60, color: Colors.orange.shade300),
              SizedBox(height: 10),
              Text(
                'Viewer Mode - Technical Specifications',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'Battery Technology Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade400),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  'Battery Technology: Lithium-ion phosphate (LiFePO4)\nCapacity: 250 MW / 500 MWh\nEfficiency: 95% round-trip efficiency\nDischarge Duration: 2 hours at full capacity\nGrid Connection: 400kV transmission line\nOperating Temperature: -20°C to +60°C\nLifespan: 20+ years\nResponse Time: <100ms\nSafety Features: Advanced fire suppression system\nCompliance: IEC 62619, IEEE 1547',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Location Infrastructure Screen
class AdminLocationInfrastructureScreen extends StatelessWidget {
  const AdminLocationInfrastructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Erection and Commissioning'),
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit, size: 20),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.red.shade700, size: 24),
                  SizedBox(width: 10),
                  Icon(Icons.construction, size: 60, color: Colors.teal.shade300),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Administrator Mode - Erection and Commissioning',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'Edit Construction & Commissioning Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade400),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: TextField(
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText:
                        'Enter erection and commissioning details including construction phases, installation procedures, testing protocols, commissioning schedules, and project milestone information for the Tamil Nadu BESS project.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.teal.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Admin: Commissioning details saved!'), backgroundColor: Colors.green),
                    );
                  },
                  icon: Icon(Icons.save),
                  label: Text('SAVE COMMISSIONING DETAILS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Viewer Location Infrastructure Screen
class ViewerLocationInfrastructureScreen extends StatelessWidget {
  const ViewerLocationInfrastructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Erection and Commissioning'),
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.white,
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.construction, size: 60, color: Colors.teal.shade300),
              SizedBox(height: 10),
              Text(
                'Viewer Mode - Erection and Commissioning',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'Construction & Commissioning Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade400),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(
                  'Project Phases:\n\nPhase 1: Site Preparation (Q1 2024)\n- Land acquisition and clearance\n- Environmental impact assessment\n- Grid connection studies\n\nPhase 2: Civil Construction (Q2-Q3 2024)\n- Foundation work for battery containers\n- Power house construction\n- Substation installation\n\nPhase 3: Electrical Installation (Q4 2024)\n- Battery system installation\n- Power conversion system setup\n- Grid interconnection\n\nPhase 4: Testing & Commissioning (Q1 2025)\n- Factory acceptance tests\n- Site acceptance tests\n- Performance validation\n- Commercial operation',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Investment Timeline Screen
class AdminInvestmentTimelineScreen extends StatelessWidget {
  const AdminInvestmentTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - O&M'),
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit, size: 20),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.red.shade700, size: 24),
                  SizedBox(width: 10),
                  Icon(Icons.settings, size: 60, color: Colors.purple.shade300),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Administrator Mode - Operation & Maintenance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'Edit O&M Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade400),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: TextField(
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText:
                        'Enter operation and maintenance details including maintenance schedules, operational procedures, performance monitoring, preventive maintenance plans, and long-term operation strategies for the Tamil Nadu BESS project.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.purple.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Admin: O&M details saved!'), backgroundColor: Colors.green));
                  },
                  icon: Icon(Icons.save),
                  label: Text('SAVE O&M DETAILS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Viewer Investment Timeline Screen
class ViewerInvestmentTimelineScreen extends StatelessWidget {
  const ViewerInvestmentTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('O&M'),
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white])),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.settings, size: 60, color: Colors.purple.shade300),
              SizedBox(height: 10),
              Text(
                'Viewer Mode - Operation & Maintenance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'O&M Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade400),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Text(
                  'Operation & Maintenance Plan:\n\nDaily Operations:\n- System monitoring 24/7\n- Performance data analysis\n- Real-time fault detection\n\nPreventive Maintenance:\n- Monthly battery health checks\n- Quarterly cooling system service\n- Annual electrical inspections\n\nPredictive Maintenance:\n- Battery degradation monitoring\n- Thermal imaging inspections\n- Vibration analysis\n\nEmergency Response:\n- Fire suppression system monitoring\n- Emergency shutdown procedures\n- Backup power systems\n\nPerformance Optimization:\n- Efficiency tracking\n- Load dispatch optimization\n- Grid support services\n\nLifecycle Management:\n- Battery replacement planning\n- Component upgrade scheduling\n- End-of-life recycling',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Documents Screen
class DocumentsScreen extends StatefulWidget {
  final bool isAdmin;
  const DocumentsScreen({super.key, this.isAdmin = false});

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<Map<String, String>> _documents = [];
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.isAdmin;
    _loadSampleDocuments();
  }

  void _loadSampleDocuments() {
    // Start with empty document list
    // Users can add real documents using the Add Document button in admin mode
  }

  void _viewDocument(String title, String description, String url, String type) {
    print('=== VIEW DOCUMENT CALLED: $title ===');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text(description, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'Type: $type',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('URL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  SelectableText(url, style: TextStyle(color: Colors.blue, fontSize: 12)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _downloadDocument(String title, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading: $title'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
    );
    // In a real app, implement actual download functionality here
  }

  void _addDocument() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String description = '';
        String url = '';
        return AlertDialog(
          title: Text('Add New Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Document Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Document URL'),
                onChanged: (value) => url = value,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && url.isNotEmpty) {
                  setState(() {
                    _documents.add({'title': title, 'description': description, 'url': url, 'type': 'PDF'});
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveDocuments() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Documents saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tamil Nadu 250 MW/500 MWh BESS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _documents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade400),
                          SizedBox(height: 16),
                          Text(
                            'No Documents Yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _isAdmin
                                ? 'Use the Add Document button below to add your first document'
                                : 'No documents have been added yet',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _documents.length,
                      itemBuilder: (context, index) {
                        final document = _documents[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          child: ListTile(
                            leading: Icon(Icons.description, color: Colors.orange.shade600, size: 32),
                            title: Text(
                              document['title'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(document['description'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text(
                                      document['type'] ?? '',
                                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.download, color: Colors.green.shade600),
                              onPressed: () => _downloadDocument(document['title'] ?? '', document['url'] ?? ''),
                              tooltip: 'Download Document',
                            ),
                            onTap: () => _viewDocument(
                              document['title'] ?? '',
                              document['description'] ?? '',
                              document['url'] ?? '',
                              document['type'] ?? '',
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_isAdmin)
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addDocument,
                        icon: Icon(Icons.add),
                        label: Text('Add Document'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveDocuments,
                        icon: Icon(Icons.save),
                        label: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Project Category Model
class ProjectCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  ProjectCategory({required this.name, required this.icon, required this.color, required this.description});
}
