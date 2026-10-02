class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final String mobile;
  final String image;
  final String coverImage;
  final String accessToken;
  final String refreshToken;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.age = 0,
    this.mobile = '',
    required this.image,
    this.coverImage = '',
    required this.accessToken,
    required this.refreshToken,
  });

  // Per-person profile assets keyed by lowercase full name.
  static const Map<String, Map<String, String>> _profileOverrides = {
    'renan turno': {
      'image': 'assets/images/pfp1.jpg',
      'coverImage': 'assets/images/hirin.jpg',
    },
    'nansu amiri': {
      'image': 'assets/images/hewin.jpg',
      'coverImage': 'assets/images/newj.jpg',
    },
  };

  factory User.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final overrides =
        _profileOverrides['$firstName $lastName'.trim().toLowerCase()] ??
        const {};

    return User(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: firstName,
      lastName: lastName,
      gender: json['gender'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      mobile: json['mobile'] as String? ?? json['phone'] as String? ?? '',
      image: overrides['image'] ?? json['image'] as String? ?? '',
      coverImage:
          overrides['coverImage'] ?? json['coverImage'] as String? ?? '',
      accessToken:
          json['accessToken'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'age': age,
      'mobile': mobile,
      'image': image,
      'coverImage': coverImage,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final letters = [firstName, lastName]
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim()[0].toUpperCase())
        .join();
    if (letters.isNotEmpty) return letters;
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  /// Photos shown on the profile's Photos tab. New accounts start empty.
  List<String> get photos => _profilePhotos[fullName.toLowerCase()] ?? const [];

  static const Map<String, List<String>> _profilePhotos = {
    'renan turno': [
      'assets/images/manok.jpg',
      'assets/images/weh.jpg',
      'assets/images/ikaw.jpg',
      'assets/images/hearin.jpg',
      'assets/images/haerinz.jpg',
      'assets/images/baby.jpg',
      'assets/images/sigelang.jpg',
      'assets/images/snakedragon.jpg',
      'assets/images/speed.jpg',
    ],
    'nansu amiri': [
      'assets/images/1.jpg',
      'assets/images/2.jpg',
      'assets/images/3.jpg',
      'assets/images/4.jpg',
      'assets/images/5.jpg',
      'assets/images/6.jpg',
      'assets/images/7.jpg',
      'assets/images/8.jpg',
      'assets/images/9.jpg',
    ],
  };
}
