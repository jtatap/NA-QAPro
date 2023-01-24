/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'22, 2020
* @TestClass: LoggerTest
*/ 
public with sharing class Log {

    public static List<String> logEntries;

    public static void push(String logScope){
        if(logEntries == null){
            logEntries = new List<String>();
        }
        logEntries.add(logScope);
    }

    public static void pop(){
        if(logEntries != null && logEntries.size()>0){
            logEntries.remove(logEntries.size()-1);   
        }
    }
}