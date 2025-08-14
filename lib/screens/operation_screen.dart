import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

enum MathOperation { addition, subtraction, multiplication, division }

class OperationScreen extends StatefulWidget {
  final MathOperation operation;

  const OperationScreen({super.key, required this.operation});

  @override
  State<OperationScreen> createState() => _OperationScreenState();
}

class _OperationScreenState extends State<OperationScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  int score = 0;
  int questionCount = 0;
  int num1 = 0;
  int num2 = 0;
  int correctAnswer = 0;
  List<int> options = [];
  int? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _generateQuestion();
    _scaleController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    final random = Random();
    
    switch (widget.operation) {
      case MathOperation.addition:
        num1 = random.nextInt(50) + 1;
        num2 = random.nextInt(50) + 1;
        correctAnswer = num1 + num2;
        break;
      case MathOperation.subtraction:
        num1 = random.nextInt(50) + 20;
        num2 = random.nextInt(num1);
        correctAnswer = num1 - num2;
        break;
      case MathOperation.multiplication:
        num1 = random.nextInt(12) + 1;
        num2 = random.nextInt(12) + 1;
        correctAnswer = num1 * num2;
        break;
      case MathOperation.division:
        num2 = random.nextInt(12) + 1;
        correctAnswer = random.nextInt(12) + 1;
        num1 = num2 * correctAnswer;
        break;
    }

    _generateOptions();
    selectedAnswer = null;
    showResult = false;
    _scaleController.reset();
    _scaleController.forward();
  }

  void _generateOptions() {
    final random = Random();
    options = [correctAnswer];
    
    while (options.length < 4) {
      int wrongAnswer;
      switch (widget.operation) {
        case MathOperation.addition:
          wrongAnswer = correctAnswer + random.nextInt(20) - 10;
          break;
        case MathOperation.subtraction:
          wrongAnswer = correctAnswer + random.nextInt(20) - 10;
          break;
        case MathOperation.multiplication:
          wrongAnswer = correctAnswer + random.nextInt(40) - 20;
          break;
        case MathOperation.division:
          wrongAnswer = correctAnswer + random.nextInt(10) - 5;
          break;
      }
      
      if (wrongAnswer > 0 && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    
    options.shuffle();
  }

  void _checkAnswer(int answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = answer == correctAnswer;
      showResult = true;
      
      if (isCorrect) {
        score++;
        _confettiController.play();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        questionCount++;
        if (questionCount < 10) {
          _generateQuestion();
        } else {
          _showFinalScore();
        }
      });
    });
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Great Job! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Final Score: $score/10',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _getScoreMessage(),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Home', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String _getScoreMessage() {
    if (score >= 9) return 'Outstanding! 🌟';
    if (score >= 7) return 'Great work! 👏';
    if (score >= 5) return 'Good job! 👍';
    return 'Keep practicing! 💪';
  }

  void _resetGame() {
    setState(() {
      score = 0;
      questionCount = 0;
      _generateQuestion();
    });
  }

  String _getOperationSymbol() {
    switch (widget.operation) {
      case MathOperation.addition:
        return '+';
      case MathOperation.subtraction:
        return '-';
      case MathOperation.multiplication:
        return '×';
      case MathOperation.division:
        return '÷';
    }
  }

  String _getOperationName() {
    return widget.operation.name.substring(0, 1).toUpperCase() + 
           widget.operation.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF74b9ff), Color(0xFF0984e3)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildQuestionCard(),
                  const SizedBox(height: 30),
                  _buildOptionsGrid(),
                  const Spacer(),
                  if (showResult) _buildResultFeedback(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          ),
          Column(
            children: [
              Text(
                _getOperationName(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Question ${questionCount + 1}/10',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Score: $score',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'What is',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$num1',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                Text(
                  _getOperationSymbol(),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(width: 20),
                Text(
                  '$num2',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ScaleTransition(
              scale: _pulseAnimation,
              child: const Text(
                '?',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 2,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = selectedAnswer == option;
          final isCorrectOption = option == correctAnswer;
          
          Color backgroundColor = Colors.white;
          Color textColor = Colors.black;
          
          if (showResult && isSelected) {
            backgroundColor = isCorrect ? Colors.green : Colors.red;
            textColor = Colors.white;
          } else if (showResult && isCorrectOption && !isCorrect) {
            backgroundColor = Colors.green;
            textColor = Colors.white;
          }

          return GestureDetector(
            onTap: showResult ? null : () => _checkAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$option',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultFeedback() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              isCorrect ? 'Correct! Well done! 🎉' : 'Oops! Try again next time! 💪',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
