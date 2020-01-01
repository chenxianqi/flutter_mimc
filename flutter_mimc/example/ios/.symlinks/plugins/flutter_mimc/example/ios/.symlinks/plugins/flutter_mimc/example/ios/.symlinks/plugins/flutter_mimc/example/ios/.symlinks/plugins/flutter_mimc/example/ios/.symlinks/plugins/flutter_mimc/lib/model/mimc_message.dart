class MIMCMessage {
  String toAccount;
  String bizType;
  num timestamp;
  String fromAccount;
  int topicId;
  String payload;

  MIMCMessage(
      {this.toAccount,
      this.bizType,
      this.timestamp,
      this.fromAccount,
      this.topicId,
      this.payload});

  MIMCMessage.fromJson(Map<dynamic, dynamic> json) {
    this.toAccount = json['toAccount'];
    this.bizType = json['bizType'];
    this.fromAccount = json['fromAccount'];
    this.topicId = json['topicId'];
    this.timestamp = json['timestamp'];
    this.payload = json['payload'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['toAccount'] = this.toAccount;
    data['bizType'] = this.bizType;
    data['fromAccount'] = this.fromAccount;
    data['topicId'] = this.topicId;
    data['timestamp'] = this.timestamp;
    data['payload'] = this.payload;
    return data;
  }
}
