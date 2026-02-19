import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class VoiceCallPage extends StatefulWidget {
  final String callId;
  final String chatId;
  final bool isCaller;

  const VoiceCallPage({
    super.key,
    required this.callId,
    required this.chatId,
    required this.isCaller,
  });

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  StreamSubscription? _callSubscription;
  StreamSubscription? _candidateSubscription;

  bool _isMuted = false;
  bool _remoteDescriptionSet = false;

 @override
void initState() {
  super.initState();

  if (widget.isCaller) {
    _startCallerFlow();
  } else {
    _startReceiverFlow(); // 🔥 directly start
  }
}


  @override
  void dispose() {
    _callSubscription?.cancel();
    _candidateSubscription?.cancel();
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  // =========================
  // CALLER FLOW
  // =========================

  Future<void> _startCallerFlow() async {
    await _initPeer();

    final currentUser = FirebaseAuth.instance.currentUser!.uid;

    final chatSnapshot =
        await _firestore.collection('chats').doc(widget.chatId).get();

    final chatData = chatSnapshot.data();
    if (chatData == null) return;

    final mentorId = chatData['mentorId'];
    final studentId = chatData['studentId'];

    final receiverId =
        currentUser == mentorId ? studentId : mentorId;

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await _firestore.collection('calls').doc(widget.callId).set({
      'callerId': currentUser,
      'receiverId': receiverId,
      'chatId': widget.chatId,
      'offer': offer.toMap(),
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _listenForAnswer();
  }

  void _listenForAnswer() {
    _callSubscription = _firestore
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen((snapshot) async {
      final data = snapshot.data();
      if (data == null) return;

      if (data['answer'] != null && !_remoteDescriptionSet) {
        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        await _peerConnection!.setRemoteDescription(answer);
        _remoteDescriptionSet = true;
      }
    });
  }

  // =========================
  // RECEIVER FLOW
  // =========================

  

  Future<void> _startReceiverFlow() async {
    await _initPeer();

    final snapshot =
        await _firestore.collection('calls').doc(widget.callId).get();

    final data = snapshot.data();
    if (data == null || data['offer'] == null) return;

    final offer = RTCSessionDescription(
      data['offer']['sdp'],
      data['offer']['type'],
    );

    await _peerConnection!.setRemoteDescription(offer);

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await _firestore.collection('calls').doc(widget.callId).update({
      'answer': answer.toMap(),
    });
  }

  // =========================
  // PEER SETUP
  // =========================

  Future<void> _initPeer() async {
    final configuration = {
  'iceServers': [
    {
      'urls': 'stun:stun.relay.metered.ca:80',
    },
    {
      'urls': [
        'turn:standard.relay.metered.ca:80',
        'turn:standard.relay.metered.ca:80?transport=tcp',
        'turn:standard.relay.metered.ca:443',
        'turns:standard.relay.metered.ca:443?transport=tcp'
      ],
      'username': 'c409270b1ad3c4bb5638efc9',
      'credential': 'ZKyTqpU7initKWLi',
    },
  ]
};



    _peerConnection = await createPeerConnection(configuration);

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false
    });

    for (var track in _localStream!.getTracks()) {
      _peerConnection!.addTrack(track, _localStream!);
    }

    _handleIce();
  }

  void _handleIce() {
    final sendCollection =
        widget.isCaller ? 'callerCandidates' : 'calleeCandidates';

    final listenCollection =
        widget.isCaller ? 'calleeCandidates' : 'callerCandidates';

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _firestore
            .collection('calls')
            .doc(widget.callId)
            .collection(sendCollection)
            .add(candidate.toMap());
      }
    };

    _candidateSubscription = _firestore
        .collection('calls')
        .doc(widget.callId)
        .collection(listenCollection)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data == null) continue;

        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        );

        _peerConnection!.addCandidate(candidate);
      }
    });
  }

  // =========================
  // UI
  // =========================

  void _toggleMute() {
    if (_localStream != null &&
        _localStream!.getAudioTracks().isNotEmpty) {
      final audioTrack = _localStream!.getAudioTracks().first;

      setState(() {
        _isMuted = !_isMuted;
        audioTrack.enabled = !_isMuted;
      });
    }
  }

  Future<void> _endCall() async {
    _localStream?.getTracks().forEach((track) => track.stop());
    await _peerConnection?.close();

    await _firestore.collection('calls').doc(widget.callId).update({
      'status': 'ended'
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Voice Call",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person,
                color: Colors.grey, size: 100),
            const SizedBox(height: 20),
            Text(
              widget.isCaller ? "Calling..." : "Connected",
              style: const TextStyle(
                  color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isMuted
                          ? Icons.mic_off
                          : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _toggleMute,
                  ),
                ),
                const SizedBox(width: 40),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: _endCall,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
