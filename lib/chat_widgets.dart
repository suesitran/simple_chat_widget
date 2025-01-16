import 'dart:math';

import 'package:flutter/material.dart';

/// data classes
class Message {
  final String id;
  final DateTime time;
  final String senderUid;
  final String message;

  Message({required this.time, required this.senderUid, required this.message})
      : id = '';

  Message.fromMap(this.id, Map<String, dynamic> map)
      : time = DateTime.fromMillisecondsSinceEpoch(map['time']),
        senderUid = map['from'],
        message = map['message'];

  Map<String, dynamic> toMap() =>
      {'time': time.millisecondsSinceEpoch, 'from': senderUid, 'message': message};
}

class UserDetail {
  final String uid;
  final String displayName;
  final String? avatar;

  UserDetail({required this.uid, required this.displayName, this.avatar});

  UserDetail.fromMap(Map<String, dynamic> map)
      : uid = map['uid'],
        displayName = map['displayName'],
        avatar = map['avatar'];

  Map<String, dynamic> toMap() =>
      {'uid': uid, 'displayName': displayName, 'avatar': avatar};
}

/// Chat bubble to display sent messages
class ChatBubble extends StatelessWidget {
  final String text;
  final String senderUid;
  final bool isMine;

  const ChatBubble(
      {required this.text,
        required this.senderUid,
        required this.isMine,
        super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      UserAvatarView(avatar: senderUid == 'model' ? 'model' : null),
      const SizedBox(
        width: 4,
      ),
      Flexible(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color:
              isMine ? const Color(0xFF7A8194) : const Color(0xFF373E4E)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            text,
            style: TextStyle(color: isMine ? null : Colors.white),
          ),
        ),
      ),
      const SizedBox(
        width: 50,
      )
    ];

    if (isMine) {
      children = children.reversed.toList();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
        isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// TextField with Send button to send message
class MessageBoxView extends StatefulWidget {
  final ValueChanged<Message> onSend;
  final String uid;
  const MessageBoxView({required this.onSend, required this.uid, super.key});

  @override
  State<MessageBoxView> createState() => _MessageBoxViewState();
}

class _MessageBoxViewState extends State<MessageBoxView> {
  final TextEditingController _editingController = TextEditingController();

  @override
  Widget build(BuildContext context) => TextField(
    controller: _editingController,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
        hintText: 'Message',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        fillColor: const Color(0xFF3D4354),
        prefixIcon: const CircleAvatar(
          radius: 15,
          backgroundColor: Color(0xFF9398A7),
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 15,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,
        ),
        suffixIcon: InkWell(
          child: const CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFF9398A7),
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 15,
            ),
          ),
          onTap: () => _sendMessage(_editingController.text),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 50)),
    onSubmitted: _sendMessage,
  );

  InputBorder get inputBorder =>
      FilledInputBorder(borderRadius: BorderRadius.circular(25.0));

  void _sendMessage(String text) {
    widget.onSend(Message(
        time: DateTime.now().toUtc(), senderUid: widget.uid, message: text));
    _editingController.text = '';
  }
}

class FilledInputBorder extends InputBorder {
  final BorderSide side;
  final TextDirection? textDirection;
  final BorderRadius borderRadius;

  final Paint _paint = Paint()
    ..color = const Color(0xFF3D4354)
    ..style = PaintingStyle.fill;

  FilledInputBorder(
      {this.side = BorderSide.none,
        this.textDirection,
        this.borderRadius = BorderRadius.zero});

  @override
  InputBorder copyWith(
      {BorderSide? borderSide, TextDirection? textDirection}) =>
      FilledInputBorder(
          side: borderSide ?? side,
          textDirection: textDirection ?? this.textDirection);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(max(side.strokeInset, 0));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(borderRadius
          .resolve(textDirection)
          .toRRect(rect)
          .deflate(borderSide.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  bool get isOutline => false;

  @override
  void paint(Canvas canvas, Rect rect,
      {double? gapStart,
        double gapExtent = 0.0,
        double gapPercentage = 0.0,
        TextDirection? textDirection}) {
    canvas.drawRRect(borderRadius.resolve(textDirection).toRRect(rect), _paint);
  }

  @override
  ShapeBorder scale(double t) {
    return OutlineInputBorder(
      borderSide: borderSide.scale(t),
      borderRadius: borderRadius * t,
    );
  }
}

/// Circle avatar which conveniently load user photo from url
class UserAvatarView extends StatelessWidget {
  final String? avatar;
  final double size;

  const UserAvatarView({required this.avatar, this.size = 30, super.key});

  @override
  Widget build(BuildContext context) {
    if (avatar == null) {
      return Icon(Icons.person, size: size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: avatar == 'model'
          ? Icon(Icons.manage_accounts_outlined)
          : Image.network(
        avatar!,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.person, size: size),
      ),
    );
  }
}
