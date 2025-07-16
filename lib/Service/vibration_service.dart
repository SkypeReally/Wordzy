// import 'package:vibration/vibration.dart';

// class VibrationService {
//   static Future<void> vibrate({int duration = 50}) async {
//     if (await Vibration.hasVibrator() == true) {
//       final hasCustomVibration = await Vibration.hasAmplitudeControl() == true;

//       if (hasCustomVibration) {
//         await Vibration.vibrate(duration: duration, amplitude: 128);
//       } else {
//         await Vibration.vibrate(duration: duration);
//       }
//     }
//   }

//   static Future<void> vibrateSuccess() async {
//     await vibrate(duration: 30);
//   }

//   static Future<void> vibrateError() async {
//     await vibrate(duration: 100);
//   }

//   static Future<void> vibratePattern() async {
//     if (await Vibration.hasVibrator() == true) {
//       await Vibration.vibrate(pattern: [0, 40, 80, 40], amplitude: 128);
//     }
//   }
// }
