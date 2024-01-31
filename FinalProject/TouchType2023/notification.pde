//enum NotificationType { Door, PersonMoveHome, PersonMoveWork, Meeting, PersonStatus, ObjectMove, ApplianceStateChange, PackageDelivery, Message }
enum NotificationType{
  Craniovertebral_angle,
  Sagittal_head_tilt,
  Sagittal_shoulderC7_angle,
  Coronal_head_tilt,
  Coronal_shoulder_angle,
  Thoracic_kyphosis_angle,
  hand_angle
}
class Notification {
   
  int timestamp;
  NotificationType type; // door, person_move, object_move, appliance_state_change, package_delivery, message
  String note;
  String MusleInvolved;
  int angle;
  String Key;
  String Input;
  String flag;
  String Finger;
  
  
  public Notification(JSONObject json) {
    this.timestamp = json.getInt("timestamp");
    //time in milliseconds for playback from sketch start
    
    String typeString = json.getString("type");
    
    try {
      this.type = NotificationType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(typeString + " is not a valid value for enum NotificationType.");
    }
    
    
    if (json.isNull("note")) {
      this.note = "";
    }
    else {
      this.note = json.getString("note");
    }
    
    if (json.isNull("angle")) {
      this.angle = -1;
    }
    else {
      this.angle = json.getInt("angle");      
    }
    
    if (json.isNull("Key")) {
      this.Key = "";
    }
    else {
      this.Key = json.getString("Key");      
    }
    
    if (json.isNull("flag")) {
      this.flag = "";
    }
    else {
      this.flag = json.getString("flag");      
    }
    
    if (json.isNull("Input")) {
      this.Input = "";
    }
    else {
      this.Input = json.getString("Input");      
    }
    
    if (json.isNull("finger")) {
      this.Finger = "";
    }
    else {
      this.Finger = json.getString("finger");      
    }
    
     if (json.isNull("MusleInvolved")) {
      this.MusleInvolved = "";
    }
    else {
      this.MusleInvolved = json.getString("MusleInvolved");      
    }
    
    
    //1-3 levels (1 is highest, 3 is lowest)    
  }
  
  public int getTimestamp() { return timestamp; }
  public NotificationType getType() { return type; }
  public String getNote() { return note; }
  public int getAngle() { return angle; }
  public String getKey() { return Key; }
  public String getFlag() { return flag; }
  public String getInput() { return Input; }
  public String getFinger() { return Finger; }
  public String getMusleInvolved() { return MusleInvolved; }
  
  
  public String toString() {
      String output = getType().toString() + ": ";
      output += "(MusleInvolved: " + getMusleInvolved() + ") ";
      output += "(angle: " + getAngle() + ") ";
      output += "(Key: " + getKey() + ") ";
      output += "(Input: " + getInput() + ") ";
      output += "(flag: " + getFlag() + ") ";
      output += "(Finger: " + getFinger() + ") ";
      output += "(note: " + getNote() + ") ";
      return output;
    }
}
