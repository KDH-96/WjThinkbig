/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 01-25-2024
 * @last modified by  : ms.kim
**/
trigger tri_DeliveryInfo on DeliveryInfo__c (before insert, after insert) {
	/**
     * 배송현황 레코드 생성 시, 기회Id, 배송요청일 추출 
     */
    if (Trigger.isBefore && Trigger.isInsert) {

        Set<String> numbers = new Set<String>();
        for (DeliveryInfo__c di : Trigger.new) {
            if (String.isNotEmpty(di.PhoneNumber__c)) {
                numbers.add(di.PhoneNumber__c);
            }
        }
        
        Map<Id, Opportunity> rsltOppMap = new Map<Id, Opportunity>([
            SELECT Id, ParentPhone__c, DeliveryRequestDate__c, ReturnRequestDate__c, fm_ParentName__c
            FROM Opportunity
            WHERE ParentPhone__c IN :numbers 
        ]);

        // Map<Opportunity.ParentPhone__c, Opportunity.Id>
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        for(Opportunity opp : rsltOppMap.values()) {
            oppMap.put(opp.ParentPhone__c, opp);
        }

        system.debug('oppMap: '+ oppMap);
        system.debug('TriNew: '+ Trigger.new);
        
        for (DeliveryInfo__c di : Trigger.new) {
            Opportunity oppty = oppMap.get(di.PhoneNumber__c);
            //system.debug('Name Compare');
            //system.debug(oppty.fm_ParentName__c);
            //system.debug(di.ParentName__c);
            if(di.ParentName__c == oppty.fm_ParentName__c){
                di.OpportunityId__c = oppty.Id;
                if(di.Category__c == '패드 발송'){
                    di.DeliveryRequestDate__c = oppty.DeliveryRequestDate__c;
                } else if(di.Category__c == '패드 회수'){
                    di.ReturnRequestDate__c = oppty.ReturnRequestDate__c;
                }
            }
        }
    }
    // 배송현황 생성 후 배송현황 id를 관련 기회에 심어주기 - 배송요청일이 더 뒤인걸로.
    // - 기기회수 시, 배송현황을 새로 만들어주는 것이 아니라 기존 배송현황의 송장번호를 바꾼다고 하면
    // - isUpdate로 바꿔서, 송장번호 바뀔때 배송현황 id 심어주는 걸로 로직 바꿔야 함.
    if(Trigger.isAfter && Trigger.isInsert){
        List<String> targetOpps = new List<String>();
        for(DeliveryInfo__c di : Trigger.New){
            if((di.Category__c == '패드 발송') || (di.Category__c == '패드 회수')){
                targetOpps.add(di.OpportunityId__c);
            }
        }
        
        Map<Id, Opportunity> opps = new Map<Id, Opportunity>([
            SELECT Id, DeliveryInfoId__c, DeliveryNumber__c, StageName
            FROM Opportunity
            WHERE Id IN: targetOpps
        ]);
        
        List<String> targetDis = new List<String>();
        for(Id opp : opps.keySet()){
            if(opps.get(opp).DeliveryInfoId__c != null){
                targetDis.add(opps.get(opp).DeliveryInfoId__c);
            }
        }
        
        List<Opportunity> updateOpps = new List<Opportunity>();
        Map<Id, DeliveryInfo__c> disMap = new Map<Id, DeliveryInfo__c>([
            SELECT Id, CreatedDate
            FROM DeliveryInfo__c
            WHERE Id IN: targetDis and (Category__c = '패드 발송' or Category__c = '패드 회수')
        ]);
        
        for(DeliveryInfo__c di : Trigger.New){
            if((di.Category__c == '패드 발송') || (di.Category__c == '패드 회수')){
                Opportunity opp = opps.get(di.OpportunityId__c);
                if(di.Category__c == '패드 발송' && opp.StageName == '무료체험 전환'){
                    opp.StageName = '배송 준비';
                }
                if(String.isBlank(opp.DeliveryInfoId__c)){
                    opp.DeliveryInfoId__c = di.Id;
                    opp.DeliveryNumber__c = di.DeliveryNumber__c;
                    opps.put(di.OpportunityId__c, opp);
                    updateOpps.add(opp);
                } else {
                    if(disMap.size() > 0){
                        if(disMap.get(opp.DeliveryInfoId__c) == null){
                        }else{
                            if(disMap.get(opp.DeliveryInfoId__c) != null){
                                if(di.CreatedDate.getTime() - disMap.get(opp.DeliveryInfoId__c).CreatedDate.getTime() > 0){
                                    opp.DeliveryInfoId__c = di.Id;
                                    opp.DeliveryNumber__c = di.DeliveryNumber__c;
                                    opps.put(di.OpportunityId__c, opp);
                                    updateOpps.add(opp);
                                }else{
                                }
                            }
                        }
                    }else{
                        opp.DeliveryInfoId__c = di.Id;
                        opp.DeliveryNumber__c = di.DeliveryNumber__c;
                        opps.put(di.OpportunityId__c, opp);
                        updateOpps.add(opp);
                    }
                }
            }
        }
        system.debug(updateOpps);
        if(updateOpps.size() > 0) update updateOpps;
    }
}