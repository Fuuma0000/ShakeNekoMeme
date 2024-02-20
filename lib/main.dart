import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shake Neko Meme',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Shake Neko Meme'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VideoPlayerController? _xAxisController;
  VideoPlayerController? _yAxisController;
  bool complete = false;
  static const double shakeThreshold = 2.0; // この値は調整してください

  @override
  initState() {
    super.initState();
    _initVideoPlayers();
    userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        setState(() {
          // 例: X軸の加速度が一定の閾値を超えたらX軸用の動画を再生
          if (event.x.abs() > shakeThreshold) {
            // もしyが再生中じゃないなら再生
            if (!_yAxisController!.value.isPlaying) {
              setState(() {
                _startPlaying(_xAxisController!);
              });
            }
          }
          // 例: Y軸の加速度が一定の閾値を超えたらY軸用の動画を再生
          else if (event.y.abs() > shakeThreshold) {
            if (!_xAxisController!.value.isPlaying) {
              setState(() {
                _startPlaying(_yAxisController!);
              });
            }
          } else {
            // それ以外の場合は動画を停止
            if (_xAxisController != null && _xAxisController!.value.isPlaying) {
              _xAxisController!.pause();
            }
            if (_yAxisController != null && _yAxisController!.value.isPlaying) {
              _yAxisController!.pause();
            }
          }
        });
      },
    );
  }

  Future<void> _initVideoPlayers() async {
    _xAxisController = VideoPlayerController.asset('assets/tipitipi.mp4');
    await _xAxisController!.initialize();

    _yAxisController = VideoPlayerController.asset('assets/happyhappy.mp4');
    await _yAxisController!.initialize();

    setState(() {
      complete = true;
    });
  }

  void _startPlaying(VideoPlayerController controller) {
    if (!controller.value.isPlaying) {
      controller.seekTo(Duration.zero).then((_) => controller.play());
    }
  }

  @override
  Widget build(BuildContext context) {
    return !complete
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              backgroundColor: const Color.fromARGB(255, 58, 245, 25),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("ローディング中"),
                ],
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 58, 245, 25),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              backgroundColor: const Color.fromARGB(255, 58, 245, 25),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_xAxisController != null &&
                      _xAxisController!.value.isPlaying)
                    AspectRatio(
                      aspectRatio: _xAxisController!.value.aspectRatio,
                      child: VideoPlayer(_xAxisController!),
                    )
                  else if (_yAxisController != null &&
                      _yAxisController!.value.isPlaying)
                    AspectRatio(
                      aspectRatio: _yAxisController!.value.aspectRatio,
                      child: VideoPlayer(_yAxisController!),
                    )
                  else
                    //  中央にスマホを縦か横に振るように促すテキスト
                    Text(
                      "スマホを縦か横に\n振ってみよう！",
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 58, 245, 25),
          );
  }
}
