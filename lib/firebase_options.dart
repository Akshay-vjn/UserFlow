import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCIabih1e4MyxqACpEgfE5BTtM4D7BcMVg',
    appId: '1:975651004709:android:519bae3c726cdf00c23acc',
    messagingSenderId: '975651004709',
    projectId: 'userflow-e9091',
    storageBucket: 'userflow-e9091.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBFlfpH6lFGlosTXCQbzSi7TN1B-bSaNgE',
    appId: '1:975651004709:ios:10d68c72c235aadec23acc',
    messagingSenderId: '975651004709',
    projectId: 'userflow-e9091',
    storageBucket: 'userflow-e9091.firebasestorage.app',
    androidClientId: '975651004709-f90le2uksc4onp8nstmn92um7sq23dpq.apps.googleusercontent.com',
    iosClientId: '975651004709-u0aje0vfcfi7fc2n5jdeihtp0crrspv7.apps.googleusercontent.com',
    iosBundleId: 'com.example.userflow',
  );

}