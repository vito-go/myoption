import 'package:cryptography/cryptography.dart';

Future<Signature> ed25519Sign(Map<String, dynamic> m) async {
  final ed25519 = Ed25519();
  final message = m['message'];
  final keyPair = m['keyPair'];
  return ed25519.sign(message, keyPair: keyPair);
}

void debugX25519() async {
  final algorithm = X25519();

// We need the private key pair of Alice.
  final SimpleKeyPair aliceKeyPair = await algorithm.newKeyPair();
  var alicePubKey = await aliceKeyPair.extractPublicKey();
  var alicePriKey = await aliceKeyPair.extractPrivateKeyBytes();
  print(
      "alicePubKey.bytes: ${alicePubKey.bytes.length}-> ${alicePubKey.bytes}");
  print("alicePriKey.bytes: ${alicePriKey.length}-> ${alicePriKey}");

// We need only public key of Bob.
  final bobKeyPair = await algorithm.newKeyPair();
  final bobPublicKey = await bobKeyPair.extractPublicKey();

  var bobPubKey = await bobKeyPair.extractPublicKey();
  var bobPrikey = await bobKeyPair.extractPrivateKeyBytes();
  print("bobPubKey.bytes: ${bobPubKey.bytes.length}-> ${bobPubKey.bytes}");
  print("bobPrikey.bytes: ${bobPrikey.length}-> ${bobPrikey}");

  // We can now calculate a 32-byte shared secret key.
  final sharedSecretKey = await algorithm.sharedSecretKey(
    keyPair: aliceKeyPair,
    remotePublicKey: bobPublicKey,
  );
  var sharedSecretKeyBytes = await sharedSecretKey.extractBytes();
  print(
      "sharedSecretKeyBytes: ${sharedSecretKeyBytes.length}-> ${sharedSecretKeyBytes}");

// We can now calculate a 32-byte shared secret key.
  final sharedSecretKeyBob = await algorithm.sharedSecretKey(
    keyPair: bobKeyPair,
    remotePublicKey: alicePubKey,
  );
  var sharedSecretKeyBobBytes = await sharedSecretKeyBob.extractBytes();
  print(
      "sharedSecretKeyBobBytes: ${sharedSecretKeyBobBytes.length}-> ${sharedSecretKeyBobBytes}");
}
