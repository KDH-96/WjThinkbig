/**
 * @description       : 과업 개체 트리거
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : wj.chae
**/
trigger tri_Task on Task (before insert, after insert) {
    if (Trigger.isBefore) {
        if(Trigger.isInsert){
            List<Event> evntList = new List<Event>();
            List<Lead> le_list = new List<Lead>();
            List<Opportunity> oppUpdList = new List<Opportunity>();
            
            for(Task t : Trigger.new) {

                // 다음 상담예약 값으로 이벤트 생성
                if(t.NextCounselresv__c != null) {
                    evntList.add(
                        new Event(
                            WhoId = t.WhoId,
                            WhatId = t.WhatId,
                            Subject = '다음 상담 예약',
                            StartDateTime = t.NextCounselresv__c,
                            EndDateTime = t.NextCounselresv__c.addHours(1),
                            EventSubtype = 'Event',
                            OwnerId = t.OwnerId,
                            IsReminderSet = true,
                            ReminderDateTime = t.NextCounselresv__c.addMinutes(-15)
                    ));
                }

                // 과업 제목 = 예비회원 : 상담내용 Lv1 + 상담내용 Lv2 + 상담내용 Lv3
                //          = 무료체험회원 : 상담내용 Lv1 + 상담내용 Lv2
                String strSubject;
                if(t.WhoId != null){
                    if(t.LeadCounselCategory1__c != null) strSubject = t.LeadCounselCategory1__c;
                    if(t.LeadCounselCategory2__c != null) strSubject = strSubject +'-'+ t.LeadCounselCategory2__c;
                    if(t.LeadCounselCategory3__c != null) strSubject = strSubject +'-'+ t.LeadCounselCategory3__c;

                    le_list.add(
                        new Lead(
                        Id = t.WhoId
                        , Status = '상담진행중'
                        , Rating = t.CounselContent__c
                        , LastCounselSubject__c = strSubject
                        , LastCounselDateTime__c = Datetime.now()
                        , LastCounselDescription__c = t.Description
                        , NextCounselResv__c = t.NextCounselresv__c
                    ));

                }else if(t.WhatId != null){
                    if(t.OpportunityCounselCategory1__c != null) strSubject = t.OpportunityCounselCategory1__c;
                    if(t.OpportunityCounselCategory2__c != null) strSubject = strSubject +'-'+ t.OpportunityCounselCategory2__c;

                    // Opportunity (최종상담내용, 최종상담일시, 최종상담내용, 다음 상담차수, 소유자) 업데이트
                    oppUpdList.add(new Opportunity(
                        Id = t.WhatId
                        ,Rating__c = t.CounselContent__c
                        ,LastCounselSubject__c = strSubject
                        ,LastCounselDateTime__c = Datetime.now()
                        ,LastCounselDescription__c = t.Description
                        ,NextCounselResv__c = t.NextCounselresv__c
                    ));

                }else{
                    strSubject = '';
                }
                
                // 과업 제목 양식에 맞춰 입력
                String template = Label.CLS_Subject;
                List<Object> param = 
                    new List<Object> {strSubject, Utilities.transDateTimeFormat(DateTime.now()), UserInfo.getName()};
                        t.Subject = String.format(template, param);
            }
            
            if(!le_list.isEmpty()) update le_list;
            if(!oppUpdList.isEmpty()) update oppUpdList;
            if (evntList?.size() > 0) {
                insert evntList;
            }
        }
    }

    if (Trigger.isAfter) {
        if(Trigger.isInsert){
            Set<Id> leadIds = new Set<Id>();
            Set<Id> oppIds = new Set<Id>();

            
            // 상담교사가 6번 상담 시도하였으나 부재일 경우 파트장에게 회수하기 위해
            // 리드 및 기회 소유자를 파트장으로 변경
            for(Task t : Trigger.new) {
                if(t.WhoId != null){
                    
                    // 상담구분2의 값이 '6차 부재 이상'일 경우, 파트장에게 회수
                    Boolean is6Missed = '6차 부재 이상'.equals(t.LeadCounselCategory2__c) ? true : false;
                    if (is6Missed) {
                        leadIds.add(t.whoId);
                    }

                }else if(t.WhatId != null){

                    // 상담구분2의 값이 '6차 부재 이상'일 경우, 파트장에게 회수
                    Boolean is6Missed = '6차 부재 이상'.equals(t.OpportunityCounselCategory2__c) ? true : false;
                    if (is6Missed) {
                        oppIds.add(t.WhatId);
                    }
                }
            }
            
            // 소유자 변경 배치 스케줄 예약(5분 후 시작)
            Datetime dtNow = Datetime.now().addMinutes(5);
            String hour = String.valueOf(dtNow.hour()); 
            String min = String.valueOf(dtNow.minute()); 
            String ss = String.valueOf(dtNow.second()); 
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?'; 
            
            // Lead 소유자 업데이트 배치
            if (!leadIds.isEmpty()) {
                Scheduler_BatchChangeOwnerLead bat = new Scheduler_BatchChangeOwnerLead(leadIds, '6차 부재 이상');
                System.schedule('BatchChangeOwnerLead' + String.valueOf(Datetime.now()), nextFireTime, bat);
            }
            
            // Opportunity 소유자 업데이트 배치
            if (!oppIds.isEmpty()) {
                Scheduler_BatchChangeOwnerOppty bat = new Scheduler_BatchChangeOwnerOppty(oppIds, '6차 부재 이상');
                System.schedule('Scheduler_BatchChangeOwnerOppty' + String.valueOf(Datetime.now()), nextFireTime, bat);
            }
        }
    }
}