import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserProfileImg extends StatelessWidget {
  const UserProfileImg({this.imageUrl, super.key});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl?.trim() ?? '';
    final uri = trimmed.isNotEmpty ? Uri.tryParse(trimmed) : null;
    final isValidNetworkImage =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.isNotEmpty);
    return SizedBox(
      width: 55.w,
      height: 55.w,
      child: ClipOval(
        child: isValidNetworkImage
            ? Image.network(
                trimmed,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset('assets/img/user.png', fit: BoxFit.cover),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CupertinoActivityIndicator());
                },
              )
            : Image.asset('assets/img/user.png', fit: BoxFit.cover),
      ),
    );
  }
}
