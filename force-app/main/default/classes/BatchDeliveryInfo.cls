global class BatchDeliveryInfo implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT ID, DeliveryStatus__c, DeliveryDateTime__c, DeliveryLocation__c, DeliveryNumber__c, OpportunityId__c, oppTarget__c, Name, ';
        query += 'DeliveryCompleteDate__c, DelivBatchNotiTarget__c, OpportunityName__c, ReturnRequestDate__c, ReturnCompleteDate__c, Category__c ';
        query += 'FROM DeliveryInfo__c WHERE DeliveryStatus__c != \'배송완료\' and DeliveryStatus__c != \'기기회수완료\' and OpportunityId__c != null and (Category__c = \'패드 발송\' or Category__c = \'패드 회수\')';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<DeliveryInfo__c> targets){
        List<DeliveryInfo__c> updateDIs = new List<DeliveryInfo__c>();
        List<String> oppIds = new List<String>();
        
        for(DeliveryInfo__c di : targets){
            oppIds.add(di.OpportunityId__c);
        }
        system.debug(oppIds);

        Map<ID, Opportunity> opps = new Map<ID, Opportunity>([SELECT ID, StageName, OwnerId, Name, ReEntryDateTime__c FROM Opportunity WHERE ID IN: oppIds]);

        for(DeliveryInfo__c di : targets){
            Opportunity opp = opps.get(di.OpportunityId__c);
            //system.debug('opp????????????????');
            //system.debug(opp);
            //system.debug(opp.ReEntryDateTime__c);
            updateDIs.add(loadDeliveryInfos.loadDelivInfos(di, opp));
        }
        try{
            update updateDIs;
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        BatchOppStage nextBatch = new BatchOppStage();
        database.executeBatch(nextBatch,1000);
    }
    
}