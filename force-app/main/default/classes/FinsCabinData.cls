public class FinsCabinData {
    
    Public static void CreateData(){
        
    List<account> lAcc = [SELECT id FROM Account WHERE name = 'Butler249 Inc'];
        If(lAcc.size() <> 0 ) {
            System.debug('DATA CREATION ALREADY RUN .......... ABORTING JOB');
            return;
        }   
        
    StaticResource sr = [SELECT Id, Body,Name FROM StaticResource WHERE Name = 'FinsCabinEventMonitoringData' LIMIT 1];
	String body = sr.Body.toString();    
        // Instantiate a new Http object
    Http h = new Http();

    // Instantiate a new HTTP request
    // Specify request properties such as the endpoint, the POST method, etc. 
    HttpRequest req = new HttpRequest();
    string myUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v56.0/composite/tree/account';    
    req.setEndpoint(myUrl);
    req.setMethod('POST');
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());     
    req.setHeader('Content-Type', 'application/json');
    req.setBody(body);

    // Send the request, and return a response
    HttpResponse res = h.send(req);
    System.debug(res.getBody());
    System.debug(res.getStatusCode());  
  }    
}