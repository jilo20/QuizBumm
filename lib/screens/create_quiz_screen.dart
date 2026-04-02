import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final List<Map<String, dynamic>> _questions = [];
  bool _isSaving = false;

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': '',
        'options': ['', '', '', ''],
        'pairs': List.generate(4, (_) => {'left': '', 'right': ''}),
        'correctIndex': 0,
        'mode': 'swipe',
      });
    });
  }

  Future<void> _saveQuiz() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one question.')),
        );
        return;
      }
      
      setState(() => _isSaving = true);

      try {
        final Map<String, dynamic> payload = {
          'title': _titleController.text.trim(),
          'description': _descController.text.trim(),
          'questions': _questions,
        };

        const String apiUrl = 'http://127.0.0.1:8000/api.php';
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quiz successfully saved!')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error saving quiz.')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const darkSlate = Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Quiz',
          style: TextStyle(color: darkSlate, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkSlate),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isSaving ? null : _saveQuiz,
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text('SAVE', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Basic Info
            const Text(
              'Quiz Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkSlate),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Quiz Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            // Questions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkSlate),
                ),
                ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    foregroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_questions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.quiz_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No questions added yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_questions.length, (index) {
                return _buildQuestionCard(index);
              }),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    const primaryColor = Color(0xFF2563EB);
    final isConnect = _questions[index]['mode'] == 'connect';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _questions.removeAt(index);
                  });
                },
              ),
            ],
          ),
          TextFormField(
            initialValue: _questions[index]['question'],
            decoration: const InputDecoration(
              labelText: 'Question / Instruction',
              hintText: 'e.g. Match the capitals',
              isDense: true,
            ),
            onChanged: (val) => _questions[index]['question'] = val,
            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _questions[index]['mode'] ?? 'swipe',
            decoration: const InputDecoration(
              labelText: 'Answering Mode',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'swipe', child: Text('Swipe Mode (Radar)')),
              DropdownMenuItem(value: 'press', child: Text('Press Mode (Grid)')),
              DropdownMenuItem(value: 'connect', child: Text('Connect Mode (Matching)')),
            ],
            onChanged: (val) {
              setState(() {
                _questions[index]['mode'] = val ?? 'swipe';
                if (val == 'connect' && (_questions[index]['pairs'] as List).isEmpty) {
                   _questions[index]['pairs'] = List.generate(4, (_) => {'left': '', 'right': ''});
                }
              });
            },
          ),
          const SizedBox(height: 20),
          if (isConnect) ...[
            const Text('Column A (Left) vs Column B (Right)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ...List.generate(4, (pIdx) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _questions[index]['pairs'][pIdx]['left'],
                        decoration: InputDecoration(
                          hintText: 'Left ${pIdx + 1}',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) => _questions[index]['pairs'][pIdx]['left'] = val,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.link, size: 16, color: Colors.grey),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: _questions[index]['pairs'][pIdx]['right'],
                        decoration: InputDecoration(
                          hintText: 'Right ${pIdx + 1}',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) => _questions[index]['pairs'][pIdx]['right'] = val,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            const Text('Select the correct answer by picking a radio button:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            ...List.generate(4, (optIndex) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _questions[index]['correctIndex'] == optIndex ? primaryColor : Colors.grey.shade300,
                    width: _questions[index]['correctIndex'] == optIndex ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    radioTheme: RadioThemeData(
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return primaryColor;
                        }
                        return Colors.grey;
                      }),
                    ),
                  ),
                  child: RadioListTile<int>(
                    value: optIndex,
                    groupValue: _questions[index]['correctIndex'],
                    onChanged: (val) {
                      setState(() {
                        _questions[index]['correctIndex'] = val;
                      });
                    },
                    title: TextFormField(
                      initialValue: _questions[index]['options'][optIndex],
                      decoration: const InputDecoration(
                        labelText: 'Option',
                        isDense: true,
                      ),
                      onChanged: (val) => _questions[index]['options'][optIndex] = val,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    contentPadding: EdgeInsets.zero,
                    activeColor: primaryColor,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
