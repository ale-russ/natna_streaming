class Message {
  String message;
  String token;
  User user;

  Message({required this.message, required this.token, required this.user});

  Message copyWith({String? message, String? token, User? user}) => Message(
    message: message ?? this.message,
    token: token ?? this.token,
    user: user ?? this.user,
  );

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json["message"],
      token: json["token"],
      user: User.fromJson(json["user"]),
    );
  }
}

class User {
  String id;
  String fullName;
  String email;
  List<dynamic>? whitelist;
  List<dynamic>? blacklist;
  List<dynamic>? parentalKeywords;
  DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.whitelist,
    this.blacklist,
    this.parentalKeywords,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"] ?? json["id"],
      fullName: json["fullName"],
      email: json["email"],
      whitelist: json["whitelist"] != null
          ? List<String>.from(json["whitelist"])
          : [],
      blacklist: json["blacklist"] != null
          ? List<String>.from(json["blacklist"])
          : [],
      parentalKeywords: json["parentalKeywords"] != null
          ? List<String>.from(json["parentalKeywords"])
          : [],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    List<dynamic>? whitelist,
    List<dynamic>? blacklist,
    List<dynamic>? parentalKeywords,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    whitelist: whitelist ?? this.whitelist,
    blacklist: blacklist ?? this.blacklist,
    parentalKeywords: parentalKeywords ?? this.parentalKeywords,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      // "password":password
      "whitelist": whitelist,
      "blacklist": blacklist,
      "parentalKeywords": parentalKeywords,
      "createdAt": createdAt,
    };
  }
}
