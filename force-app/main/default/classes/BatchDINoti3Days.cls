global class BatchDINoti3Days implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT ID, DeliveryStatus__c, DeliveryNumber__c, NotiTarget__c, Name, DeliveryCompleteDate__c, DelivBatchNotiTarget__c, OpportunityName__c, DeliveryLocation__c FROM DeliveryInfo__c WHERE DeliveryCompleteDate__c = N_DAYS_AGO:3';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<DeliveryInfo__c> targets){
        
        List<DeliveryInfo__c> updateDIs = new List<DeliveryInfo__c>();
        User admin = [SELECT Id FROM User WHERE Profile.name = '시스템 관리자' limit 1];
        CustomNotificationType notiType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'DeliveryNotification' limit 1];
        String title,body;
        
        for(DeliveryInfo__c di : targets){
            Set<String> targetUserIds = new Set<String>();
            targetUserIds.add(di.NotiTarget__c);
            
            if(di.DeliveryStatus__c == '배송완료'){
                title = '배송 완료 3일 경과';
                body = '기회(' + di.OpportunityName__c + ')의 물품이 배송 완료 3일 경과 되었습니다.\n- 배송현황 : ' + di.Name + '\n* 클릭 시 배송현황 정보 확인';

            }else if(di.DeliveryStatus__c == '기기회수완료'){
                title = '기기회수 완료 3일 경과';
                body = '기회(' + di.OpportunityName__c + ')의 물품이 회수 완료 3일 경과 되었습니다.\n- 배송현황 : ' + di.Name + '\n* 클릭 시 배송현황 정보 확인';

            }
            UTIL_Notification.unCalloutNotiSend(notiType.Id, admin.Id, di.Id, title, body, targetUserIds);
            //di.DeliveryLocation__c += '알림 성공?';
            updateDIs.add(di);
        }
        update updateDIs;

    }
    
    global void finish(Database.BatchableContext BC){
        BatchDINoti5Days nextBatch = new BatchDINoti5Days();
        database.executeBatch(nextBatch,1000);
        
    }

}