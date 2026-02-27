import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPage extends StatefulWidget {
  final String callId;
  final String chatId;
  final bool isCaller;

  const VideoCallPage({
    super.key,
    required this.callId,
    required this.chatId,
    required this.isCaller,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  StreamSubscription? _callSubscription;
  StreamSubscription? _candidateSubscription;

  @override
  void initState() {
    super.initState();
    _initRenderers();

    _initPeer();

    if (widget.isCaller) {
      _startCaller();
    } else {
      _waitForAccepted();
    }
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    _callSubscription?.cancel();
    _candidateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initPeer() async {
    // 🔥 1️⃣ Request camera + mic permission FIRST
  var cameraStatus = await Permission.camera.request();
  var micStatus = await Permission.microphone.request();

  if (!cameraStatus.isGranted || !micStatus.isGranted) {
    print("Camera or Mic permission denied");
    return;
  }
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

    _peerConnection = await createPeerConnection(
  {
    'iceServers': configuration['iceServers'],
    'sdpSemantics': 'unified-plan', // 🔥 ADD THIS
  },
  {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  },
);

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
      'facingMode': 'user',
      'width': 640,
    'height': 480,
    'frameRate': 24, // optional but recommended
    },
    });

    _localRenderer.srcObject = _localStream;

    for (var track in _localStream!.getTracks()) {
      _peerConnection!.addTrack(track, _localStream!);
    }
    _localStream!.getVideoTracks().first.enabled = true;

    _peerConnection!.onTrack = (RTCTrackEvent event) {
  print("Track received: ${event.track.kind}");

  if (event.streams.isNotEmpty) {
    setState(() {
      _remoteRenderer.srcObject = event.streams[0];
    });
  }
};

    _handleIce();
  }

  Future<void> _startCaller() async {
    await _initPeer();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await _firestore.collection('calls').doc(widget.callId).update({
      'offer': offer.toMap(),
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

      if (data['answer'] != null) {
        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        await _peerConnection!.setRemoteDescription(answer);
      }
    });
  }

  void _waitForAccepted() {
    _callSubscription = _firestore
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen((snapshot) async {
      final data = snapshot.data();
      if (data == null) return;

      if (data['status'] == 'accepted') {
        

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
    });
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

  Future<void> _endCall() async {
    await _firestore.collection('calls').doc(widget.callId).update({
      'status': 'ended'
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          RTCVideoView(_remoteRenderer),

          Positioned(
            right: 20,
            top: 50,
            child: SizedBox(
              width: 120,
              height: 160,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: _endCall,
                child: const Icon(Icons.call_end),
              ),
            ),
          ),
        ],
      ),
    );
  }
}