import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Bool "mo:base/Bool";

actor class Dairy() {

  // TYPES

  // public type Subject = {
  //   #Mathematics;
  //   #Portuguese;
  //   #English;
  //   #Sport;
  //   #Humanities;
  //   #Technology;
  //   #Science;
  //   #Art;
  // };

  // public type Days = {
  //   #Monday;
  //   #Tuesday;
  //   #Wednesday;
  //   #Thursday;
  //   #Friday;
  // };

  public type Teacher = {
    teacherName : Text;
    principal : Principal;
    classroom : Classroom;
  };

  public type Classroom = {
    className : Text;
    creator : Principal;
    classId : Nat;
  };

  public type Profile = {
    childName : Text;
    childSecret : Text;
  };

  public type Child = {
    child : Profile;
    creator : Principal;
    classId : Nat;
  };

  public type Homework = {
    title : Text;
    description : Text;
    subject : Text;
    day : Nat;
  };

  public type Entry = {
    homework : Homework;
    creator : Principal;
    // classId : Nat;
  };

  public type ChildHomework = {
    child : Child;
    homework : Homework;
    completed : Bool;
  };

  // VARIABLES

  stable var classId : Nat = 0;
  var classrooms = Buffer.Buffer<Classroom>(1);
  stable var classroomsStableUpgrades : [(Text, Classroom)] = [];

  // stable var entryId : Nat = 0;
  stable var diaryStableUpgrades : [(Text, Entry)] = [];
  var diary = HashMap.HashMap<Text, Entry>(1, Text.equal, Text.hash);

  stable var childId : Nat = 0;
  stable var childrenStableUpgrades : [(Text, Child)] = [];
  var children = HashMap.HashMap<Text, Child>(1, Text.equal, Text.hash);

  system func preupgrade() {
    childrenStableUpgrades := Iter.toArray(children.entries());
    diaryStableUpgrades := Iter.toArray(diary.entries());
    // classroomsStableUpgrades := Buffer.toArray(classrooms);
  };

  system func postupgrade() {
    for ((homework, creator) in diaryStableUpgrades.vals()) {
      diary.put(homework, creator);
    };
    diaryStableUpgrades := [];

    for ((child) in childrenStableUpgrades.vals()) {
      children.put(child);
    };
    childrenStableUpgrades := [];

  };

  // FUNCTIONS

  // Add Class

  public shared ({ caller }) func addClass(c : Text) : async Nat {
    let newclass : Classroom = {
      className = c;
      classId = classId;
      creator = caller;
    };

    classrooms.add(newclass);
    classId += 1;
    return classId -1;
  };

  // Get Classes
  public query func getAllClasses() : async [Classroom] {
    return Buffer.toArray(classrooms);
  };

  // Add Homework

  public shared ({ caller }) func setHomework(h : Homework) : async Nat {
    let entry : Entry = {
      homework = h;
      creator = caller;
      // classId = 0; // use actual classId
    };
    let entryId = h.day;
    // let entryId = switch (h.day) {
    //   case (#Monday)(1);
    //   case (#Tuesday)(2);
    //   case (#Wednesday)(3);
    //   case (#Thursday)(4);
    //   case (#Friday)(5);
    // };
    // diary.put(Nat.toText(entryId), entry);
    // return entryId;

    diary.put(Nat.toText(entryId), entry);
    return entryId;
  };

  // Add child

  public shared ({ caller }) func addChild(p : Profile) : async Nat {

    // get the classId for the caller

    let child : Child = {
      child = p;
      creator = caller;
      classId = 0; // use actual classId
    };
    children.put(Nat.toText(childId), child);
    childId += 1;
    return childId - 1;
  };

  public query func getAllChildren() : async [Child] {
    let childList = Buffer.Buffer<Child>(0);
    for (child in children.vals()) {
      childList.add(child);
    };
    return Buffer.toArray(childList);
  };

  //Get all entries

  // this needs updating to only show entries for the creators classId
  public query func getAllEntries() : async [Entry] {
    let entries = Buffer.Buffer<Entry>(0);
    for (entry in diary.vals()) {
      entries.add(entry);
    };
    return Buffer.toArray(entries);
  };

  //Get a diary entry
  public shared query func getEntry(entryId : Nat) : async Result.Result<Entry, Text> {
    switch (diary.get(Nat.toText(entryId))) {
      case null #err("Invalid ID");
      case (?result) #ok(result);
    };
  };

  //Update entry
  public shared ({ caller }) func updateEntry(entryId : Nat, h : Homework) : async Result.Result<(), Text> {

    // get the classId for the caller

    var entry : Entry = switch (diary.get(Nat.toText(entryId))) {
      case null return #err("Invalid ID");
      case (?result) result;
    };
    if (entry.creator == caller) {

      let updatedEntry : Entry = {
        homework = h;
        creator = entry.creator;
        classId = 0; // use actual classId
      };
      diary.put(Nat.toText(entryId), updatedEntry);
      return #ok();
    } else {
      return #err("User is not the owner of the homework entry");
    };
  };

  //Delete entry
  public shared ({ caller }) func deleteEntry(entryId : Nat) : async Result.Result<(), Text> {
    // NEED TO CHECK entry.creator == caller - SEE ABOVE
    switch (diary.remove(Nat.toText(entryId))) {
      case null #err("Invalid ID");
      case (?result) #ok();
    };
  };

  // public func upVote(messageId : Nat) : async Result.Result<(), Text> {
  //   var message : Message = switch (wall.get(Nat.toText(messageId))) {
  //     case null return #err("Invalid message ID");
  //     case (?result) result;
  //   };

  //   let updatedMessage : Message = {
  //     content = message.content;
  //     vote = message.vote +1;
  //     creator = message.creator;
  //   };
  //   wall.put(Nat.toText(messageId), updatedMessage);
  //   return #ok();

  // };

  // public func downVote(messageId : Nat) : async Result.Result<(), Text> {
  //   var message : Message = switch (wall.get(Nat.toText(messageId))) {
  //     case null return #err("Invalid message ID");
  //     case (?result) result;
  //   };

  //   let updatedMessage : Message = {
  //     content = message.content;
  //     vote = message.vote -1;
  //     creator = message.creator;
  //   };
  //   wall.put(Nat.toText(messageId), updatedMessage);
  //   return #ok();
  // };

  // public query func getAllMessages() : async [Message] {
  //   let messages = Buffer.Buffer<Message>(0);
  //   for (message in wall.vals()) {
  //     messages.add(message);
  //   };
  //   return Buffer.toArray(messages);
  // };

  // private func sortVotes(m1 : Message, m2 : Message) : Order.Order {
  //   switch (Int.compare(m1.vote, m2.vote)) {
  //     case (#greater) return #less;
  //     case (#less) return #greater;
  //     case (_) return #equal;
  //   };
  // };

  // public shared query func getAllMessagesRanked() : async [Message] {
  //   var messagesBuffer = Buffer.Buffer<Message>(0);
  //   for (messages in wall.vals()) {
  //     messagesBuffer.add(messages);
  //   };
  //   messagesBuffer.sort(sortVotes);
  //   return Buffer.toArray(messagesBuffer);
  // };
};
