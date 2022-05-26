// Persistent logger keeping track of what is going on.

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Option "mo:base/Option";

import TextLoggerModule "TextLogger";
import Logger "mo:ic-logger/Logger";

actor{
  
  type TextLogger = TextLoggerModule.TextLogger;
  let MAX_LINES : Nat = 50;

  var canisterAmount : Nat = 0;
  var canisterList = Buffer.Buffer<TextLogger>(0);

  // Add a set of messages to the log.
  public shared (msg) func append(msgs: [Text]) : async () {

    let logger = switch(canisterAmount){
      case (0) {
        let tl = await TextLoggerModule.TextLogger(0);
        canisterList.add(tl);
        canisterAmount := 1;
        canisterList.get(0)
      };
      case _ canisterList.get(canisterAmount - 1);
    };

    var messages : [Text] = msgs;
    messages := await logger.append(messages);

    while (messages.size() > 0) {
      let logger = await TextLoggerModule.TextLogger(canisterAmount * MAX_LINES);
      canisterList.add(logger);
      canisterAmount += 1;
      messages := await logger.append(messages);
    }
  };

  // Return the messages between from and to indice (inclusive).
  public shared (msg) func view(from: Nat, to: Nat) : async Logger.View<Text> {

    assert(canisterList.size() > 0);
    assert(canisterAmount > 0);
    assert(from <= to);

    var textArray : [Text] = [];
    var startIndex = from / MAX_LINES;
    let endIndex = to / MAX_LINES;
    
    while (startIndex <= endIndex and startIndex < canisterList.size()){
      let viewPart = await canisterList.get(startIndex).view(from, to);
      startIndex += 1;
      textArray := Array.append<Text>(textArray, viewPart.messages);
    };
      
    {
      start_index = from; 
      messages = textArray;
    }
  };
}
