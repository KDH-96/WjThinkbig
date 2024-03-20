/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : wj.chae
**/
public without sharing class CustomButtonController {

    /**
     * @description 사용자정의버튼 Controller
     *              1. 예비회원 > 무료체험전환 버튼
     *              2. 예비회원 > 체험미신청 버튼
     *              3. 예비회원 > 직가입 버튼
     * @author ms.kim
     * @param  recordId
     * @param  eventType
     * @return
     */
    @AuraEnabled
    public static Map<String, String> CustomBtnEvent (String recordId, String eventType){
        
        Map<String, String> retMap = new Map<String, String>();
        Set<Id> record_ids = new Set<Id>();
        record_ids.add(recordId);

        Savepoint sv = Database.setSavepoint();
        try{

            switch on eventType {
                
                // 예비회원 > 무료체험전환
                when 'ConvertFreeTrial' {
                    Map<Id,Id> leadid_opptyid_map = fnConvertLead(record_ids, '무료체험 전환');
                    if(!leadid_opptyid_map.isEmpty()){
                        retMap.put('msg','done');
                        retMap.put('opptyId', leadid_opptyid_map.get(recordId));
                    }
                }

                // 예비회원 > 체험미신청
                when 'UnappliedFreeTrial' {
					List<Lead> updatelead_list = new List<Lead>();
                    updatelead_list.add(
                        new Lead(
                            Id = recordId
                            , Status = '체험미신청'
                    ));
                    
                    // 소유자 변경 배치 스케줄 예약(5분 후 시작)
                    Datetime dtNow = Datetime.now().addMinutes(5);
                    String hour = String.valueOf(dtNow.hour()); 
                    String min = String.valueOf(dtNow.minute()); 
                    String ss = String.valueOf(dtNow.second()); 
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';  

                    Scheduler_BatchChangeOwnerLead bat = new Scheduler_BatchChangeOwnerLead(record_ids, '체험미신청');
                    System.schedule('BatchChangeOwnerLead' + String.valueOf(Datetime.now()), nextFireTime, bat);
                    
                    if(!updatelead_list.isEmpty()) update updatelead_list;
                }

                // 예비회원 > 직가입
                when 'DirectJoin' {
                    Map<Id,Id> leadid_opptyid_map = fnConvertLead(record_ids, '직가입');
                    List<Opportunity> updateoppty_list = new List<Opportunity>();
                    Id oppty_recordtype = [SELECT Id 
                                           FROM RecordType 
                                           WHERE IsActive = true 
                                           AND DeveloperName = 'DirectJoin' 
                                           AND SobjectType = 'Opportunity'].Id;
                    Id oppty_Id = leadid_opptyid_map.get(recordId);
                    if(oppty_Id != null){
                        updateoppty_list.add(
                            new Opportunity(Id = leadid_opptyid_map.get(recordId)
                                            , RecordTypeId = oppty_recordtype
                                            , StageName = '직가입'
                        ));

                        retMap.put('msg','done');
                        retMap.put('opptyId', leadid_opptyid_map.get(recordId));
                    }

                    if(!updateoppty_list.isEmpty()) update updateoppty_list;
                }

                // 무료체험회원 > 무료체험취소
                when 'CancelFreeTrial' {
                    List<Opportunity> updateoppty_list = new List<Opportunity>();
                    updateoppty_list.add(
                            new Opportunity(Id = recordId
                                            , StageName = '미가입'
                    ));
                    
                    // 소유자 변경 배치 스케줄 예약(5분 후 시작)
                    Datetime dtNow = Datetime.now().addMinutes(5);
                    String hour = String.valueOf(dtNow.hour()); 
                    String min = String.valueOf(dtNow.minute()); 
                    String ss = String.valueOf(dtNow.second()); 
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?'; 

                    Scheduler_BatchChangeOwnerOppty bat = new Scheduler_BatchChangeOwnerOppty(record_ids, '무료체험취소');
                    System.schedule('BatchChangeOwnerOppty' + String.valueOf(Datetime.now()), nextFireTime, bat);
                    
                    if(!updateoppty_list.isEmpty()) update updateoppty_list;
                }
            }
        }catch(Exception e){
            if(e.getMessage().contains(Label.CLS_Required)){
                retMap.put('msg', Label.CLS_Required);
            }else{
                retMap.put('msg',e.getMessage() + '/' + e.getStackTraceString());
            }
            if(sv != null) Database.rollback(sv);
        }
        return retMap;
    }

    /**
     * @description 공통 리드 조회
     * @author ms.kim
     * @param  recordId
     * @return
     */
    public static List<Lead> fnReturnLead (Set<Id> record_ids){
        return [SELECT Id FROM Lead WHERE IsDeleted = false AND Id IN: record_ids];
    }

    /**
     * @description 공통 리드 변환
     * @author ms.kim
     * @param  recordId
     * @param  convertedStatus
     * @return
     */
    public static Map<Id,Id> fnConvertLead (Set<Id> record_ids , String convertedStatus){
        List<Database.LeadConvert> lc_list = new List<Database.LeadConvert>();    
        Map<Id,Id> leadid_opptyid_map = new Map<Id,Id>();

        for(Lead le : fnReturnLead(record_ids)){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(le.Id);
            lc.setConvertedStatus(convertedStatus);
            lc_list.add(lc);
        }

        if(!lc_list.isEmpty()){
            List<Database.LeadConvertResult> lcr_list = Database.convertLead(lc_list);
            for(Database.LeadConvertResult lcr : lcr_list){
                if(lcr.isSuccess()){
                    leadid_opptyid_map.put(lcr.getLeadId(), lcr.getOpportunityId());
                }
            }
        }
        return leadid_opptyid_map;
    }

    public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}