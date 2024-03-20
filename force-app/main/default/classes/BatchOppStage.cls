global class BatchOppStage implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([SELECT ID, StageName, ReEntryDateTime__c FROM Opportunity]);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> targets){
        List<DeliveryInfo__c> diList = [SELECT ID, OpportunityId__c, DeliveryStatus__c, Category__c FROM DeliveryInfo__c WHERE oppTarget__c = true];
        Map<String, DeliveryInfo__c> temp = new Map<String, DeliveryInfo__c>();
        for(DeliveryInfo__c di : diList){
            temp.put(di.OpportunityId__c, di);
        }
        
        Map<Id, Opportunity> targetOpps = new Map<Id, Opportunity>(targets);
        List<Opportunity> updateOpps = new List<Opportunity>();
        
        for(DeliveryInfo__c di : diList){
            String diStatus = di.DeliveryStatus__c;
            String diCategory = di.Category__c;
            Opportunity opp = targetOpps.get(di.OpportunityId__c);
            if(opp.ReEntryDateTime__c == null){
                if((diStatus == '배송준비') && (diCategory == '패드 발송')){
                    opp.StageName = '배송 준비';
                }else if((diStatus == '배송중') && (diCategory == '패드 발송')){
                    opp.StageName = '배송중';
                }else if((diStatus == '배송완료') && (diCategory == '패드 발송')){
                    opp.StageName = '체험진행중';
                }else if((diStatus == '기기회수중') && (diCategory == '패드 회수')){
                    opp.StageName = '체험진행중';
                }else if((diStatus == '기기회수완료' && diCategory == '패드 회수')){
                    opp.StageName = '체험종료';
                }
            }

            updateOpps.add(opp);
        }
        update updateOpps;
    }
    
    global void finish(Database.BatchableContext BC){
        BatchDINotification nextBatch = new BatchDINotification();
        database.executeBatch(nextBatch,1000);
    }

}