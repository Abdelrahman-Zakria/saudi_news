class Job {
  final String id;
  final String title;
  final String company;
  final String city;
  final String type;
  final String field;
  final String experience;
  final String salary;
  final DateTime createdAt;
  final String twitterDate;
  final String logo;
  final bool urgent;
  final List<String> mediaUrls;
  final String? videoUrl;
  final int likeCount;
  final int retweetCount;
  final int replyCount;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.city,
    required this.type,
    required this.field,
    required this.experience,
    required this.salary,
    required this.createdAt,
    required this.twitterDate,
    required this.logo,
    this.urgent = false,
    this.mediaUrls = const [],
    this.videoUrl,
    this.likeCount = 0,
    this.retweetCount = 0,
    this.replyCount = 0,
  });
}
