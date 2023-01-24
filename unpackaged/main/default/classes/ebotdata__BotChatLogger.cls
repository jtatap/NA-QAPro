/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class BotChatLogger {
    global BotChatLogger() {

    }
    @InvocableMethod(label='Einstein Bot - Log Chat')
    global static void logChat(List<ebotdata.BotChatLogger.ChatLoggerRequest> chatLogRequests) {

    }
global class ChatLoggerRequest {
    @InvocableVariable( required=false)
    global Decimal currentConfidenceForUtterance;
    @InvocableVariable( required=false)
    global String currentDialogId;
    @InvocableVariable( required=false)
    global String currentDialogName;
    @InvocableVariable( required=false)
    global Decimal currentThresholdHigh;
    @InvocableVariable( required=false)
    global String currentUtterance;
    @InvocableVariable( required=false)
    global String liveAgentSessionId;
    global ChatLoggerRequest() {

    }
}
}
