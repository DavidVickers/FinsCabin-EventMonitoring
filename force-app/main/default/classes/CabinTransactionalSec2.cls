// Fins Cabin 8 - Shield Event Monitoring you don’t know what you are missing.
    // https://salesforce.vidyard.com/watch/TGfe2FhCThsbUJS68haeG9?&_gl=1*2tys8a*_ga*Mzc4ODE4NDkuMTY3MTExMzAwOQ..*_ga_H6M98GGB18*MTY3MTM5NTc2MC41LjEuMTY3MTM5NTc2MS4wLjAuMA..&_ga=2.48409248.700554486.1671394439-37881849.1671113009
    // See Also https://trailhead.salesforce.com/trailblazer-community/groups/0F94S000000GwXk
    // SAMPLE JSON  file provided at end of code
    
// THIS CODE IS JUST AN EXAMPLE TO SHOW THE POWER OF TRANSACTIONAL SECURITY AND THE VERSITILITY IT BRINGS WHEN YOU USE APEX TO DEFINE DATA THAT WILL TRIGGER A 
// TRANSACTIONAL SECURITY POLICY. THIS IS NOT AN IMPLEMENTATION GUIDE. IT IS FOR EDUCATIONAL AND ILUSTRATIVE PURPOSES ONLY.
// 
// THE NUMBER OF POLICIES NEEDED THE COMPLEXITY OF DATA PATTERNS THAT WILL TRIGGER POLICIES ETC HOW MANY APEX POLICES YOU INTEND TO HAVE
// ALL NEED TO BE CONSIDERED AS YOU PLAN TO IMPLEMENT OR SCALE YOUR CURRENT IMPLEMENTATION OF TRANSACTION SECURITY. PLEASE ENSURE YOU HAVE 
// DESIGNED AND TESTED YOUR CODE ACCORDINGLY.
// 
// *******The Comet D listner used in the demo can be found here*****
// https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/code_sample_java_client_intro.htm

global class CabinTransactionalSec2 implements TxnSecurity.EventCondition {
    
    public boolean evaluate(SObject event) {
        // Use switch statment  to look for what event type we have and apply the approapriate methods to it 
        switch on event{
            when ApiEvent apiEvent {
                return contactsEval((string)apiEvent.Records, apiEvent.QueriedEntities ,'ae');
            }
            when ListViewEvent listViewEvent {
                return contactsEval((string)listViewEvent.Records, listViewEvent.QueriedEntities, 'lve' );
            }
            when ReportEvent reportEvent {
                // The only complete and working example in this code is for the report event
                // When a reports event is recived then the following code passes the report event records to the ContactsEval Method
                // it also passes the queried entities  and a string "re" (for report event because this code example uses a second swith statment)
                System.debug(reportEvent.records);
                return contactsEval((string)reportEvent.Records, reportEvent.QueriedEntities, 're');
            }
            
            // when null {
            //    return false;   
            //}
            when else{
                return false;
            }
        }
    }
        
    Private boolean contactsEval(string records, string queriedEntities,string eventType){
        System.debug(queriedEntities);
        // we check the queried entitiy to see if it contains Contact (note use corect capitalization) only run the code is the quireid entities contains Contacts
        // this just avoid running coded needlessly  
        if(queriedEntities.contains('Contact')){
            Set<string> setContacts = new set<string>();
            //deserialize the Json in to a string and object map
            Map<String, Object> recordsObj = (Map<String, Object>)JSON.deserializeUntyped(records);
            System.debug(recordsObj);
            switch on eventType{
                when 'ae' {
                }
                when 'lve' {
                    
                }
                //When it is a "Report Event" ie the strin passes was "re" then we will call the setContacts method  and pass it the rows object
                //NOTE different event types contain differnet objects when deserialized hence this second switch statment.
                when 're' {
                    setContacts  = reportEventprocessor((List<Object>)recordsObj.get('rows'));
                }
                when else{
                    return false;
                }
            }
            // We will get a set of contacts back from our example. To know if three are any VIP contacts in the report we just need to do a query
            // If the list of contact returned by this query is greater than 0 then we neet to triger the policy by returning true
            List<contact> vipContacts =[SELECT id from contact where ID in :setContacts AND VIP__c = true];
            If(vipContacts.size()>0){
                return true;
            }
        }
        return false;
    }
    
    private Static Set<string> reportEventprocessor(List<object> rows){  
        Set<string> setContacts = new set<string>();
        // iterate over the rows of data  (use o as the variable to represent the row object)
        For(Object o :rows){
            // break down the row object one more level to get at the "datacells"
            Map<string,object> data = (Map<string,object>)o;
            // here we get the datacells
            List<object> listdata = (List<object>)data.get('datacells'); 
            string contactId;  
            // now we can iterate over them
            // (use oo as the variable to represent the datacell content)
            For(object oo : listdata){
                String s = (string)oo;
                // All contact IDs start with '003'  thus when this pattern is matched we know the entry we are looking at is a contactid
                // and hence we add it to our set of contacts
                If(s.left(3) == '003'){contactId = s;}  
            } 
            if (contactId <> Null){    
                setContacts.add(contactId); 
            }  
        }
        System.debug('SET OF CONTACTS '  + setContacts);
        return setContacts;
    }
    
  /* 
   * EXAMPLE EVENT FILE
   {
  "schema": "mn_C9tvH0ofZbpxU2XthsQ",
  "payload": {
    "EventDate": "2022-12-16T11:45:22.000Z",
    "Description": null,
    "EvaluationTime": 113,
    "NumberOfColumns": 6,
    "Operation": "ReportRunFromLightning",
    "DashboardId": null,
    "LoginHistoryId": "0Ya4w0000BYNjvvCQD",
    "Name": "my Contacts & Accounts Report",
    "IsScheduled": false,
    "ColumnHeaders": "[OWNER_FULL_NAME, SALUTATION, ADDRESS2_COUNTRY, PHONE1, LAST_NAME, FIRST_NAME]",
    "Format": "Summary",
    "CreatedById": "0054w00000BxW1nAAF",
    "OwnerId": "00l4w000001KsHX",
    "SessionKey": "aXQxxxPRlXDSWkKn",
    "PolicyOutcome": "NoAction",
    "Records": "{\"totalSize\":4,\"rows\":[{\"datacells\":[\"0014w00003d4Ec1AAE\",\"0034w00004BeNxRAAV\",\"0054w00000BxW2EAAV\"]},{\"datacells\":[\"0014w00003d4Ec1AAE\",\"0034w00004BeNxMAAV\",\"0054w00000BxW2EAAV\"]},{\"datacells\":[\"0014w00003d4Ec1AAE\",\"0034w00004BeNZNAA3\",\"0054w00000BxW2EAAV\"]},{\"datacells\":[\"0014w00003d4Ec1AAE\",\"0034w00004BeNZIAA3\",\"0054w00000BxW2EAAV\"]}]}",
    "EventIdentifier": "7486ee21-917b-40a1-b5f4-eb5fa38f26a9",
    "DisplayedFieldEntities": "Account,User,Contact",
    "RelatedEventIdentifier": null,
    "ExecutionIdentifier": "bac4f9bd-20d8-4f97-8516-15a9b6f3d093",
    "RowsProcessed": 4,
    "RowsReturned": null,
    "ReportId": "00O4w000008AJHY",
    "Sequence": 1,
    "DashboardName": null,
    "EventSource": "Lightning",
    "SourceIp": "Salesforce.com IP",
    "Scope": "organization",
    "Username": "david.xxxxxxx@finscabindemos.com",
    "UserId": "0054w00000B1hlXAAR",
    "CreatedDate": "2022-12-16T11:45:32.601Z",
    "ExportFileFormat": null,
    "LoginKey": "xxx2rdXxxxmQjZJ6",
    "PolicyId": null,
    "GroupedColumnHeaders": "[ACCOUNT.NAME]",
    "QueriedEntities": "Contact",
    "SessionLevel": "STANDARD"
  },
  "event": {
    "replayId": 30442682
  }
}
*/
  
    
    
    
    
}