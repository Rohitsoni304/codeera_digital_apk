import 'dart:async';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------
/// 1. ONLY App ID is needed (token auth disabled in console)
/// ---------------------------------------------------------------
const String kAgoraAppId = '5173727a6a9f43b490469432056158fa';

class AgoraChatScreen2 extends StatefulWidget {
  const AgoraChatScreen2({Key? key}) : super(key: key);
  @override
  State<AgoraChatScreen2> createState() => _AgoraChatScreen2State();
}

class _AgoraChatScreen2State extends State<AgoraChatScreen2> {
  // Controllers
  late final TextEditingController _userIdCtr;
  late final TextEditingController _channelCtr;
  late final TextEditingController _msgCtr;

  // RTM objects
  AgoraRtmClient? _rtmClient;
  AgoraRtmChannel? _rtmChannel;

  // UI state
  final List<_ChatMessage> _messages = [];
  bool _isLoggedIn = false;
  bool _isJoined = false;
  RtmConnectionState _connState = RtmConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _userIdCtr = TextEditingController(text: 'rishu123');
    _channelCtr = TextEditingController(text: 'global');
    _msgCtr = TextEditingController();

    _initRtmClient();
  }

  // ---------------------------------------------------------------
  // 2. Initialise client + callbacks
  // ---------------------------------------------------------------
  Future<void> _initRtmClient() async {
    _rtmClient = await AgoraRtmClient.createInstance(kAgoraAppId);

    // Peer messages
    _rtmClient?.onMessageReceived = (RtmMessage msg, String peerId) {
      _pushMsg(_ChatMessage(
        author: peerId,
        text: msg.text ?? '',
        isLocal: false,
      ));
    };

    // Connection state
    _rtmClient!.onConnectionStateChanged2 =
        (RtmConnectionState state, RtmConnectionChangeReason reason) {
      setState(() => _connState = state);
      if (state == RtmConnectionState.aborted ||
          state == RtmConnectionState.disconnected) {
        setState(() {
          _isLoggedIn = false;
          _isJoined = false;
        });
      }
    };
  }

  // ---------------------------------------------------------------
  // 3. Login with **empty token** (token auth disabled)
  // ---------------------------------------------------------------
  Future<void> _login() async {
    if (_rtmClient == null) return;

    final userId = 'rishu123';
    if (userId.isEmpty) {
      _toast('User ID cannot be empty', isError: true);
      return;
    }

    try {
      // Empty token → works only when token auth is OFF
      await _rtmClient!.login('007eJxTYDAXbjRyXJLxxqLk4pYVC5bzzIwtZfoQIN49bdnzpW+7J+9UYDA1NDc2NzJPNEu0TDMxTjKxNDAxszQxNjIwNTM0tUhL9NMQyWwIZGTYuEyNlZGBlYERCEF8FQbDxEQjc0MDA92kNItUXUPDNAPdxOTENF3TlCTL5GTz5KRES1MAFO0mug==', userId);
      setState(() => _isLoggedIn = true);
      _toast('Logged in as $userId');
    } on AgoraRtmClientException catch (e) {
      _toast('Login failed [${e.code}] ${e}', isError: true);
    } catch (e) {
      _toast('Login failed: $e', isError: true);
    }
  }

  // ---------------------------------------------------------------
  // 4. Logout
  // ---------------------------------------------------------------
  Future<void> _logout() async {
    try {
      await _leaveChannel();
      await _rtmClient?.logout();
      setState(() => _isLoggedIn = false);
      _toast('Logged out');
    } catch (e) {
      _toast('Logout failed: $e', isError: true);
    }
  }

  // ---------------------------------------------------------------
  // 5. Join / Leave channel
  // ---------------------------------------------------------------
  Future<void> _joinChannel() async {
    if (!_isLoggedIn) {
      _toast('Please login first', isError: true);
      return;
    }
    final channelId = _channelCtr.text.trim();
    if (channelId.isEmpty) return;

    try {
      _rtmChannel = await _rtmClient?.createChannel(channelId);

      _rtmChannel?.onMessageReceived =
          (RtmMessage msg, RtmChannelMember member) {
        _pushMsg(_ChatMessage(
          author: member.userId,
          text: msg.text ?? '',
          isLocal: false,
        ));
      };
      _rtmChannel?.onMemberJoined = (member) => _pushSys('${member.userId} joined');
      _rtmChannel?.onMemberLeft = (member) => _pushSys('${member.userId} left');

      await _rtmChannel?.join();
      setState(() => _isJoined = true);
      _pushSys('Joined channel: $channelId');
    } catch (e) {
      _toast('Join failed: $e', isError: true);
    }
  }

  Future<void> _leaveChannel() async {
    try {
      await _rtmChannel?.leave();
      await _rtmChannel?.release();
    } catch (_) {}
    setState(() => _isJoined = false);
  }

  // ---------------------------------------------------------------
  // 6. Send message
  // ---------------------------------------------------------------
  Future<void> _sendChannelMessage() async {
    final text = _msgCtr.text.trim();
    if (text.isEmpty || !_isJoined) return;

    try {
      await _rtmChannel?.sendMessage(RtmMessage.fromText(text));
      _pushMsg(_ChatMessage(
        author: _userIdCtr.text.trim(),
        text: text,
        isLocal: true,
      ));
      _msgCtr.clear();
    } catch (e) {
      _toast('Send failed: $e', isError: true);
    }
  }

  // ---------------------------------------------------------------
  // 7. UI helpers
  // ---------------------------------------------------------------
  void _pushMsg(_ChatMessage m) => setState(() => _messages.add(m));

  void _pushSys(String s) => setState(() => _messages.add(
    _ChatMessage(author: 'system', text: s, isSystem: true),
  ));

  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.black87,
      ),
    );
  }

  @override
  void dispose() {
    _leaveChannel();
    _rtmClient?.logout();
    _rtmClient?.release();
    _userIdCtr.dispose();
    _channelCtr.dispose();
    _msgCtr.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // 8. UI (unchanged)
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final canLogin = !_isLoggedIn;
    final canJoin = _isLoggedIn && !_isJoined;
    final canSend = _isJoined;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora RTM Chat'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                _connState.name.toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _box(
                        child: TextField(
                          controller: _userIdCtr,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isLoggedIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _box(
                        child: TextField(
                          controller: _channelCtr,
                          decoration: const InputDecoration(
                            labelText: 'Channel ID',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isJoined,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canLogin ? _login : _logout,
                        icon: Icon(canLogin ? Icons.login : Icons.logout),
                        label: Text(canLogin ? 'Login' : 'Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          canLogin ? Colors.green : Colors.redAccent,
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canJoin
                            ? _joinChannel
                            : (_isJoined ? _leaveChannel : null),
                        icon: Icon(
                            canJoin ? Icons.meeting_room : Icons.exit_to_app),
                        label: Text(canJoin
                            ? 'Join Channel'
                            : (_isJoined ? 'Leave Channel' : '')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          canJoin ? Colors.blueAccent : Colors.orange,
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Message list
          Expanded(
            child: Container(
              color: const Color(0xFFF7F9FC),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  if (m.isSystem) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Center(
                        child: Text(
                          m.text,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Align(
                    alignment:
                    m.isLocal ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: m.isLocal ? Colors.blueAccent : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: m.isLocal
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.author,
                            style: TextStyle(
                              fontSize: 11,
                              color:
                              m.isLocal ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: m.isLocal ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Input
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtr,
                      enabled: canSend,
                      decoration: InputDecoration(
                        hintText: canSend
                            ? 'Type a message…'
                            : 'Join a channel to chat',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendChannelMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: canSend ? _sendChannelMessage : null,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );
}

// -----------------------------------------------------------------
class _ChatMessage {
  final String author;
  final String text;
  final bool isLocal;
  final bool isSystem;

  _ChatMessage({
    required this.author,
    required this.text,
    this.isLocal = false,
    this.isSystem = false,
  });
}