/**
 * @description       : 이력관리 개체 트리거
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-01-2024
 * @last modified by  : ms.kim
**/
trigger tri_FeedTracking on FeedTracking__c (before insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            
            Set<Id> oppty_ids = new Set<Id>();
            for(FeedTracking__c od : Trigger.new){
                // FieldAPIName__c 값 없는 경우 == 회원상담정보 Insert  
                od.FieldAPIName__c = od.FieldAPIName__c != null? od.FieldAPIName__c : Label.CLS_FieldAPIName_1;
                
                // FROM 기회 / 리드 구분
                if(od.Opportunity__c != null && (od.FieldAPIName__c == Label.CLS_FieldAPIName_1 || od.FieldAPIName__c == Label.CLS_FieldAPIName_2 || od.FieldAPIName__c == Label.CLS_FieldAPIName_3)){
                    oppty_ids.add(od.Opportunity__c);
                }else {
                    od.Accounttype__c = 'A1';
                }
            }

            Map<Id,Id> Oppty_lead_map = new Map<Id,Id>();
            Map<Id,String> Oppty_stagenm_map = new Map<Id,String>();
            if(!oppty_ids.isEmpty()){
                List<Lead> convertedLead = [SELECT Id
                                                , ConvertedOpportunityId 
                                            FROM Lead 
                                            WHERE IsDeleted = false 
                                            AND ConvertedOpportunityId IN: oppty_ids];

                for(Lead le : convertedLead){
                    Oppty_lead_map.put(le.ConvertedOpportunityId, le.Id);
                }
                
                List<Opportunity> convertedOpportunity = [SELECT Id
                                                                , StageName 
                                                          FROM Opportunity 
                                                          WHERE IsDeleted = false 
                                                          AND Id IN: oppty_ids];
                                                          
                for(Opportunity oppty : convertedOpportunity){
                    Oppty_stagenm_map.put(oppty.Id, oppty.StageName);
                }
            }
            
            List<Opportunity> updateOppty_List = new List<Opportunity>();
            if(!Oppty_lead_map.isEmpty()){
                for(FeedTracking__c od : Trigger.new){
                    // 회원구분 
                    // 기회 단계 1. 정회원확정 => 정회원
                    //           2. null => 예비
                    //           3. else => 준회원
                    String acctype;
                    String opptyStagenm = Oppty_stagenm_map.get(od.Opportunity__c);
                    if(opptyStagenm == '정회원확정'){
                        acctype = 'A3';
                    }else if(opptyStagenm == null){
                        acctype = 'A1';
                    }else{
                        acctype = 'A2';
                    }

                    od.Accounttype__c = acctype;
                    od.Lead__c = Oppty_lead_map.get(od.Opportunity__c);

                    if( od.FieldAPIName__c == Label.CLS_FieldAPIName_1){
                        // 기회 회원상담정보 Update
                        updateOppty_List.add(
                            new Opportunity(
                                Id = od.Opportunity__c
                                , ConsultationInfo__c = od.Value__c
                        ));
                    }
                }
            }

            List<Lead> updateLead_List = new List<Lead>();
            for(FeedTracking__c od : Trigger.new){

                // 리드 회원상담정보 업데이트
                if( od.FieldAPIName__c == Label.CLS_FieldAPIName_1){
                    updateLead_List.add(
                        new Lead(
                            Id = od.Lead__c
                            , ConsultationInfo__c = od.Value__c
                    ));
                }
            }

            if(!updateLead_List.isEmpty()) update updateLead_List;
            if(!updateOppty_List.isEmpty()) update updateOppty_List;
        }
    }
}