@isTest
public class InGeneric_MockTest implements HttpCalloutMock {
	public String body ;
    public Integer statusCode;
    
    public InGeneric_MockTest(String body, Integer statusCode){
        this.body = body;
		this.statusCode = statusCode;

    }
    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatusCode(statusCode);
        return response; 
    }
}