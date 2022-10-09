import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

const _splashRadius = 20.0;

class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({super.key});

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  final _springDescription = const SpringDescription(
    mass: 1,
    stiffness: 500,
    damping: 15,
  );

  SpringSimulation? _springSimulation;
  int _counter = 0;
  Alignment _dragAlignment = Alignment.center;
  Ticker? _ticker;
  bool _isPressed = false;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  void _decrement() {
    setState(() {
      _counter--;
    });
  }

  void _startAnimation() {
    _ticker ??= Ticker(_onTick);
    _springSimulation = SpringSimulation(
      _springDescription,
      _dragAlignment.x,
      0,
      0,
    );
    _ticker?.start();
  }

  void _stopAnimation() {
    _ticker?.stop();
  }

  void _onTick(Duration duration) {
    if (_springSimulation != null) {
      final time = duration.inMilliseconds / 1000.0;
      final value = _springSimulation!.x(time);
      setState(() {
        _dragAlignment = Alignment(value, 0);
      });
      if (_springSimulation!.isDone(time)) {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 220.0;
    const maxHeigth = 70.0;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
            height: maxHeigth,
            child: Stack(
              children: [
                Align(
                  alignment: _dragAlignment,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: maxWidth - 50,
                    ),
                    child: _buildActionButtons(constraints),
                  ),
                ),
                Align(
                  alignment: _dragAlignment,
                  child: _buildCenterButton(constraints),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints) {
    return Material(
      color: const Color(0xFF2d2d2d),
      borderRadius: BorderRadius.circular(35),
      child: Opacity(
        opacity: _isPressed ? 0.5 : 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: _decrement,
                splashRadius: _splashRadius,
                icon: const Icon(
                  Icons.remove,
                  color: Colors.grey,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _increment,
                splashRadius: _splashRadius,
                icon: const Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(BoxConstraints constraints) {
    return GestureDetector(
      onPanDown: (_) {
        _stopAnimation();
      },
      onPanUpdate: (details) {
        setState(() {
          _isPressed = true;
          _dragAlignment += Alignment(
            details.delta.dx / (constraints.maxWidth / 2),
            0,
          );
          if (_dragAlignment.x > 1) {
            _dragAlignment = const Alignment(1.0, 0.0);
          } else if (_dragAlignment.x < -1) {
            _dragAlignment = const Alignment(-1.0, 0.0);
          }
        });
      },
      onPanEnd: (_) {
        _isPressed = false;
        if (_dragAlignment.x > 0) {
          _increment();
        } else {
          _decrement();
        }
        _startAnimation();
      },
      child: FloatingActionButton(
        onPressed: _increment,
        backgroundColor: const Color(0xFF444444),
        child: FittedBox(
          child: Text(
            _counter.toString(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
