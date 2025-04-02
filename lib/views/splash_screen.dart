import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:bloc_crud_example/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _controller.forward().then((_) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(40, 255, 255, 255),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return ClipPath(
                clipper: CircleRevealClipper(_animation.value),
                child: Container(
                  color: const Color.fromARGB(248, 10, 10, 10),
                ),
              );
            },
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'lib/assets/lottie/fire_splash_lottie.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20), 

                Text(
                  'Recur ',
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w300, 
                    color: Colors.orangeAccent,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'M',
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold, 
                          color: Colors.orange,
                        ),
                      ),
                      TextSpan(
                        text: 'a',
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w300, 
                          fontStyle: FontStyle.italic, 
                          color: Colors.orangeAccent,
                        ),
                      ),
                      TextSpan(
                        text: 'dness',
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold, 
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Circle Animation Clipper
class CircleRevealClipper extends CustomClipper<Path> {
  final double radiusFactor;

  CircleRevealClipper(this.radiusFactor);

  @override
  Path getClip(Size size) {
    double radius = radiusFactor * size.height;
    Path path = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius));

    return path;
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.radiusFactor != radiusFactor;
  }
}
