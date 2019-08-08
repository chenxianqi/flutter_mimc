class MimcChatMessage {
  String toAccount;
  String bizType;
  String fromAccount;
  int topicId;
  num timestamp;
  MimcMessageBena message;

  MimcChatMessage({this.toAccount, this.bizType, this.fromAccount, this.topicId, this.timestamp, this.message});

  MimcChatMessage.fromJson(Map<dynamic, dynamic> json) {
    this.toAccount = json['toAccount'];
    this.bizType = json['bizType'];
    this.fromAccount = json['fromAccount'];
    this.topicId = json['topicId'];
    this.timestamp = json['timestamp'];
    this.message = json['message'] != null ? MimcMessageBena.fromJson(json['message']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<dynamic, dynamic>();
    data['toAccount'] = this.toAccount;
    data['bizType'] = this.bizType;
    data['fromAccount'] = this.fromAccount;
    data['topicId'] = this.topicId;
    data['timestamp'] = this.timestamp;
    if (this.message != null) {
      data['message'] = this.message.toJson();
    }
    return data;
  }

}

class MimcMessageBena {
  String payload;
  String msgId;
  String timestamp;
  int version;

  MimcMessageBena({this.payload, this.msgId, this.timestamp, this.version});

  MimcMessageBena.fromJson(Map<dynamic, dynamic> json) {
    this.payload = json['payload'];
    this.msgId = json['msgId'];
    this.timestamp = json['timestamp'];
    this.version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<dynamic, dynamic>();
    data['payload'] = this.payload;
    data['msgId'] = this.msgId;
    data['timestamp'] = this.timestamp;
    data['version'] = this.version;
    return data;
  }
}
