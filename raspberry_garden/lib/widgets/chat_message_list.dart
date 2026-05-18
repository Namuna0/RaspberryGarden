import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/discord_message.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.isMyMessage,
  });

  final List<DiscordMessage> messages;
  final ScrollController scrollController;
  final bool Function(DiscordMessage message) isMyMessage;

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _normalizeDiscordText(String text) {
    return text
        .replaceAll(':game_die:', '🎲')
        .replaceAll(':smile:', '😄')
        .replaceAll(':heart:', '❤️');
  }

  Widget _buildAvatar(DiscordMessage msg) {
    final iconUrl = msg.iconUrl;

    if (iconUrl != null && iconUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.black26,
        backgroundImage: NetworkImage(iconUrl),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white24,
      child: Text(
        msg.user.isNotEmpty ? msg.user.characters.first : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBubble(DiscordMessage msg, bool mine) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: mine
            ? Colors.pink.withOpacity(0.70)
            : Colors.black.withOpacity(0.60),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '${msg.user}  ${_formatTime(msg.time.toLocal())}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _normalizeDiscordText(msg.content),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final mine = isMyMessage(msg);

        final avatar = _buildAvatar(msg);
        final bubble = _buildBubble(msg, mine);

        return GestureDetector(
          onLongPress: () async {
            await Clipboard.setData(
              ClipboardData(text: _normalizeDiscordText(msg.content)),
            );

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('コピーしました'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment:
                  mine ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: mine
                  ? [
                      Flexible(child: bubble),
                      const SizedBox(width: 8),
                      avatar,
                    ]
                  : [
                      avatar,
                      const SizedBox(width: 8),
                      Flexible(child: bubble),
                    ],
            ),
          ),
        );
      },
    );
  }
}