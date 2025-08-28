class DateFormatter {
  static String formatLastLogin(DateTime lastLoginAt) {
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày${difference.inDays > 1 ? 's' : ''} trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ${difference.inHours > 1 ? 's' : ''} trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút${difference.inMinutes > 1 ? 's' : ''} trước';
    } else {
      return 'Vừa xong';
    }
  }
}
