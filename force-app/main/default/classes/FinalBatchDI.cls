global class FinalBatchDI implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT ID, oppTarget__c FROM DeliveryInfo__c WHERE oppTarget__c = true';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<DeliveryInfo__c> targets){
        List<DeliveryInfo__c> updateDIs = new List<DeliveryInfo__c>();
        for(DeliveryInfo__c di : targets){
            di.oppTarget__c = false;
            updateDIs.add(di);
        }
        update updateDIs;        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}