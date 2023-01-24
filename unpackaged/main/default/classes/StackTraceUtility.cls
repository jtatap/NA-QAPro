/*
* @Author: Apoorv (NeuraFlash)
* @CreatedDate: May'21, 2020
* @Description: Utility class to extract class & method name from the exception stack trace. 
*/

public with sharing class StackTraceUtility {

    private static final String ORG_NAMESPACE = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
    private static final Pattern STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$');
    
    public static void populateClassAndMethodName(Log_Event__e logEvent, String stackTraceString){
        List<String> stacktrace = stackTraceString.split('\n');

		for(String line : stacktrace) {
			Matcher matcher = STACK_LINE.matcher(line);
			if(matcher.find() && !line.startsWith('Class.System.')){
				Boolean hasNamespace = String.isNotBlank(matcher.group(3));
				if(hasNamespace) {
					logEvent.Class_Name__c = (matcher.group(1).equals(ORG_NAMESPACE)) ? matcher.group(2) : matcher.group(1) + '.' + matcher.group(2);
					logEvent.Method_Name__c = getMethodName(matcher.group(3));
				} else {
					logEvent.Class_Name__c = matcher.group(1);
					logEvent.Method_Name__c = getMethodName(matcher.group(2));
				}
				return;
			}
		}
    }

    private static String getMethodName(String method) {
		String methodName = (method == null) ? 'anonymous' : method;
		return (methodName.contains('init')) ? 'constructor' : methodName;
    }
}