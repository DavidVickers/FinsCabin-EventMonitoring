global class CabinTransactionalSec2 implements TxnSecurity.EventCondition {
    public boolean evaluate(SObject event) {
        System.debug(event);
        switch on event{
            when ApiEvent apiEvent {
                return contactsEval((string)apiEvent.Records, apiEvent.QueriedEntities ,'ae');
            }
            when ReportEvent reportEvent {
                return contactsEval((string)reportEvent.Records, reportEvent.QueriedEntities, 're');
            }
            when ListViewEvent listViewEvent {
                return contactsEval((string)listViewEvent.Records, listViewEvent.QueriedEntities, 'lve' );
            }
            when null {
                return false;   
            }
            when else{
                return false;
            }
        }
    }
    
    private boolean evaluate(String queriedEntities, Decimal rowsProcessed){
        if(queriedEntities.contains('Lead') && rowsProcessed > 2000){
            return true;
        }
        return false;
    }
    
    Private boolean contactsEval(string records, string queriedEntities,string eventType){
        System.debug(queriedEntities);
        if(queriedEntities.contains('Contact')){
            Set<string> setContacts = new set<string>();
            Map<String, Object> recordsObj = (Map<String, Object>)JSON.deserializeUntyped(records);
            System.debug(recordsObj);
            switch on eventType{
                when 'ae' {
                }
                when 're' {
                    setContacts  = reportEventprocessor((List<Object>)recordsObj.get('rows'));
                }
                when 'lve' {
                    setContacts  = ListEventprocessor((List <Object>)recordsObj.get('records'));
                }
                when else{
                    return false;
                }
            }
            List<contact> vipContacts =[SELECT id from contact where ID in :setContacts AND VIP__c = true];
            If(vipContacts.size()>0){
                return true;
            }
        }
        return false;
    }
    
    private Static Set<string> reportEventprocessor(List<object> rows){  
        Set<string> setContacts = new set<string>();
        For(Object o :rows){
            Map<string,object> data = (Map<string,object>)o;
            List<object> listdata = (List<object>)data.get('datacells'); 
            string contactId;   
            For(object oo : listdata){
                String s = (string)oo;
                If(s.left(3) == '003'){contactId = s;}  
            } 
            if (contactId <> Null){    
                setContacts.add(contactId); 
            }  
        }
        return setContacts;
    }
    
    private Static Set<string> ListEventprocessor(list<Object> records){  
        Set<string> setContacts = new set<string>();
        System.debug(records);
        For(Object o :records){
            Map<string,object> data = (Map<string,object>)o;
            string contactId = (string)data.get('Id'); 
            setContacts.add(contactId);
        }
        return setContacts;
    }
    
    
    
}