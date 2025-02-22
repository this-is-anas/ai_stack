import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromptGeneratorPage extends StatefulWidget {
  const PromptGeneratorPage({super.key});

  @override
  State<PromptGeneratorPage> createState() => _PromptGeneratorPageState();
}

class _PromptGeneratorPageState extends State<PromptGeneratorPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isGenerating = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _generatePrompt() async {
    if (_inputController.text.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final prompt = await _geminiService.generateTailoredPrompt(
        _inputController.text,
      );

      if (prompt != null && mounted) {
        _showResultDialog(prompt);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showResultDialog(String prompt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generated Prompt'),
        content: SingleChildScrollView(child: Text(prompt)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () => _savePrompt(prompt),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _savePrompt(String prompt) async {
    try {
      // Implement your save logic here (Firestore, Local DB, etc.)
      // Example using SharedPreferences:
      final prefs = await SharedPreferences.getInstance();
      final savedPrompts = prefs.getStringList('saved_prompts') ?? [];
      savedPrompts.add(prompt);
      await prefs.setStringList('saved_prompts', savedPrompts);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prompt saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save prompt')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Generator',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withOpacity(0.1),
                colors.secondary.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildInputSection(theme),
                        const SizedBox(height: 32),
                        _buildActionButton(theme),
                        const SizedBox(height: 24),
                        _buildExamplesSection(),
                      ],
                    ),
                  ),
                ),
                // Add space for keyboard/nav bar
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isGenerating ? null : _generatePrompt,
        child: _isGenerating
            ? const CircularProgressIndicator()
            : const Icon(Icons.auto_awesome),
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Describe Your Idea',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                )),
            const SizedBox(height: 12),
            TextField(
              controller: _inputController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText:
                    'e.g. "A futuristic city where AI controls weather..."',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.primary.withOpacity(0.05),
                prefixIcon: const Icon(Icons.lightbulb_outline),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_inputController.text.length}/500',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generatePrompt,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGenerating
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Generate Magic',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ],
              ),
      ),
    );
  }

  Widget _buildExamplesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Example Prompts',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey[600],
            )),
        const SizedBox(height: 12),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _ExampleChip(text: 'AI-powered healthcare system for rural areas'),
            _ExampleChip(text: 'Robot chef that adapts to dietary needs'),
            _ExampleChip(text: 'VR education platform for space exploration'),
            _ExampleChip(text: 'Sustainable city powered by renewable AI'),
          ],
        ),
      ],
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String text;
  const _ExampleChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            )),
      ),
    );
  }
}
