public class MultiRequestMock implements HttpCalloutMock {
    // Map<EndPointAndMethod, HttpCalloutMock> requests;
    // List<mockDictionary> rq;

    // public MultiRequestMock() {
    //     this.requests = new Map<EndPointAndMethod, HttpCalloutMock>();
    //     this.rq = new List<mockDictionary>();
    // }

    // public MultiRequestMock(Map<EndPointAndMethod, HttpCalloutMock> requests, List<mockDictionary> rq) {
    //     this.requests = requests;
    //     this.rq = rq;
    // }

    // public HTTPResponse respond(HTTPRequest req) {
    //     EndPointAndMethod incomingReq = new EndPointAndMethod(req.getEndpoint(), req.getMethod());
    //     HttpCalloutMock mock = requests.get(incomingReq);
    //     for (mockDictionary md : rq) {
    //         if (md.endPoint == req.getEndpoint()  &&  md.method == req.getMethod()) {
    //             return md.mock;
    //         }
    //     }
    //     CalloutException e = new CalloutException();
    //     e.setMessage('HTTP callout not supported for test methods');
    //     throw e;


    //     // System.debug(requests);
    //     // System.debug(incomingReq);
    //     // System.debug(req);
    //     // if (mock != null) {
    //     //     return mock.respond(req);
    //     // } else {
    //     //     CalloutException e = new CalloutException();
    //     //     e.setMessage('HTTP callout not supported for test methods');
    //     //     throw e;
    //     // }
    // }

    // public void addRequestMock(String url, String method, HttpCalloutMock mockToRespondWith) {
    //     requests.put(new EndPointAndMethod(url, method), mockToRespondWith);
    // }

    // public class EndPointAndMethod {
    //     String endPoint, method;

    //     public EndPointAndMethod(String endPoint, String method){
    //         this.endPoint = endPoint;
    //         this.method = method;
    //     }
    // }



    // public class mockDictionary {
    //     String endPoint, method;
    //     HttpCalloutMock mock;

    //     public mockDisctionary (Sting endPoint, String method, HttpCalloutMock mock) {
    //         this.endPoint = endPoint;
    //         this.method = method;
    //         this.mock = mock;
    //     }
    // }


    List<MockDictionary> mocks;

    public MultiRequestMock() {
        this.mocks = new List<MockDictionary>();
    }

    public MultiRequestMock(List<MockDictionary> inputMocks) {
        this.mocks = inputMocks;
    }

    public HTTPResponse respond(HTTPRequest req) {
        for (MockDictionary md : mocks) {
            if (md.endPoint == req.getEndpoint()  &&  md.method == req.getMethod()) {
                return md.mock.respond(req);
            }
        }
        CalloutException e = new CalloutException();
        e.setMessage('HTTP callout not supported for test methods');
        throw e;
    }

    public void addRequestMock(String url, String method, HttpCalloutMock mockToRespondWith) {
        mocks.add(new mockDictionary(url, method, mockToRespondWith));
    }



    public class MockDictionary {
        String endPoint, method;
        HttpCalloutMock mock;

        public MockDictionary (String endPoint, String method, HttpCalloutMock mock) {
            this.endPoint = endPoint;
            this.method = method;
            this.mock = mock;
        }
    }
}