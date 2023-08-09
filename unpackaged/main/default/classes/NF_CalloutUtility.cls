/**
 * @description       : Utility class to make callout to any external system.
 * @author            : chayan.batabyal@neuraflash.com
 * @last modified on  : 09-04-2021
 * @last modified by  : chayan.batabyal@neuraflash.com
 **/
public with sharing class NF_CalloutUtility{
    public class CalloutException extends Exception{
    }

    /**
     * @description Does the callout and returns the response
     * @author chayan.batabyal@neuraflash.com | 09-02-2021
     * @param endpoint
     * @param method
     * @param timeout
     * @param headers
     * @param body
     * @param statusCode
     * @param toCheckForNonEmptyResponseBody
     * @return HttpResponse
     **/
    public static HttpResponse doCallout(String endpoint, String method, Integer timeout, Map<String, Object> headers, String body, Integer statusCode, Boolean toCheckForNonEmptyResponseBody){
        HttpResponse response;

        if (String.isBlank(endpoint) || String.isBlank(method) || timeout == null || timeout <= 0 || timeout > 120000){
            Log.push('Endpoint: ' + endpoint + ', Method: ' + method + ', Timeout: ' + timeout);
            Logger.logDebug();
            Logger.logError('Error in configuations, please check metadata record');
            throw new CalloutException(SYSTEM.LABEL.Error_in_configuations_please_check_metadata_record);
        }

        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setTimeout(timeout);

            if (headers != null && !headers.keySet().isEmpty()){
                for (String eachHeader : headers.keySet()){
                    String headerValue = String.valueOf(headers.get(eachHeader));
                    if (String.isNotBlank(eachHeader) && String.isNotBlank(headerValue)){
                        req.setHeader(eachHeader, headerValue);
                    }
                }
            }

            if (String.isNotBlank(body)){
                req.setBody(body);
            }

            response = new Http().send(req);
        } catch (Exception e){
            Logger.logException(e);
        }

        if ((statusCode != null || toCheckForNonEmptyResponseBody) && (response == null || (statusCode != null && response.getStatusCode() != statusCode) || (toCheckForNonEmptyResponseBody && String.isBlank(response.getBody())))){
            Log.push('Status Code: ' + response.getStatusCode());
            Log.push('Body: ' + response.getBody());
            Logger.logDebug();
            Logger.logError('Response is not as expected');
            throw new CalloutException(SYSTEM.LABEL.Response_is_not_as_expected);
        }

        return response;
    }

}