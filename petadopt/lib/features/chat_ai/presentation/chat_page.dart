import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../data/gemini_client.dart';

final geminiClientProvider = Provider<GeminiClient>((ref) => GeminiClient());

final chatMessagesProvider = StateNotifierProvider<ChatMessagesController, List<ChatMsg>>((ref) {
  return ChatMessagesController(ref.read(geminiClientProvider));
});

class ChatMsg {
  final String role; // user / model
  final String text;
  ChatMsg(this.role, this.text);
}

class ChatMessagesController extends StateNotifier<List<ChatMsg>> {
  final GeminiClient client;
  ChatMessagesController(this.client) : super([]);

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    final history = state.map((m) => {'role': m.role, 'text': m.text}).toList();
    state = [...state, ChatMsg('user', text)];

    final reply = await client.generate(history: history, message: text);
    state = [...state, ChatMsg('model', reply)];
  }

  void clear() => state = [];
}

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ctrl = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return AppScaffold(
      title: '😺 Asistente PetAdopt 🐶',
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => ref.read(chatMessagesProvider.notifier).clear(),
        )
      ],
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final m = messages[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(m.text),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Escribe tu pregunta (cuidados, alimentación, etc.)',
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: sending ? null : _send,
                icon: sending ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = ctrl.text;
    ctrl.clear();
    setState(() => sending = true);
    try {
      await ref.read(chatMessagesProvider.notifier).send(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => sending = false);
    }
  }
}
