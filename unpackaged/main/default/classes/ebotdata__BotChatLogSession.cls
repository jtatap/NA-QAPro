/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class BotChatLogSession {
    global BotChatLogSession() {

    }
    @InvocableMethod(label='Einstein Bot - Create Chat Session Log')
    global static void logChat(List<ebotdata.BotChatLogSession.ChatLoggerRequest> chatLogRequests) {

    }
global class ChatLoggerRequest {
    @InvocableVariable( required=false)
    global String botName;
    @InvocableVariable( required=false)
    global String liveAgentSessionId;
    global ChatLoggerRequest() {

    }
}
}
