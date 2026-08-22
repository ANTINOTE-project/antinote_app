import 'package:material_ui/material_ui.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  final double? progress;

  const LoadingWidget({super.key, this.size = 30, this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,

        child: CircularProgressIndicator(
          strokeWidth: size / 7,
          strokeCap: .round,
          value: progress,
        ),
      ),
    );
  }
}
