class MIMCMessage {
  num sequence;
  String toAccount;
  String bizType;
  num timestamp;
  String fromAccount;
  int topicId;
  String payload;
  bool isStore;
  MIMCMessage(
      {this.toAccount,
      this.bizType,
      this.sequence,
      this.timestamp,
      this.fromAccount,
      this.topicId,
      this.isStore = true,
      this.payload});

  MIMCMessage.fromJson(Map<dynamic, dynamic> json) {
    this.sequence = json['sequence'];
    this.toAccount = json['toAccount'];
    this.bizType = json['bizType'];
    this.fromAccount = json['fromAccount'];
    this.topicId = json['topicId'];
    this.timestamp = json['timestamp'];
    this.isStore = json['isStore'];
    this.payload = json['payload'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sequence'] = this.sequence;
    data['toAccount'] = this.toAccount;
    data['bizType'] = this.bizType;
    data['fromAccount'] = this.fromAccount;
    data['topicId'] = this.topicId;
    data['timestamp'] = this.timestamp;
    data['isStore'] = this.isStore;
    data['payload'] = this.payload;
    return data;
  }
}
