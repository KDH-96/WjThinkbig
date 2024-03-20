/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
public class Batch_ReEnterLeadUpdateController implements Database.Batchable<sObject>, Database.Stateful {
    public List<Lead> updateLeadList = new List<Lead>();
    /**
     * 기회 미변환 재진입 예비고객 업데이트
     * 예비고객 재진입 시 이력 내역 추가
     * 재진입된 예비고객의 담당자에게 알림 처리
     */
    public Database.QueryLocator start(Database.BatchableContext dbc) {
        
        String strQuery = 'SELECT Id, OwnerId, Name, CreatedDate, MobilePhone__c, Name__c, RequestDateTime__c, LeadSource__c, LeadSourceDetail__c, ChildBirthday__c, ChildName__c, ChildAge__c, ReEntryDateTime__c,';
        strQuery+= ' AssignUser__c, AssignDate__c, LastAssignUser__c, LastAssignDate__c, fm_Codes__c, ContractNumber__c, ProductName__c, FullPaymentFlg__c, Amount__c, RegisterName__c, MembershipNumber__c, ';
        strQuery+= ' Address1__c, Address2__c, PostalCode__c, Requirement__c, MediaCode__c, ReEntryCheck__c, Device__c, Channel__c, ProductService__c, Promotion_Freetrial__c, Promotion_Join__c, RequestStatusDetail__c';
        strQuery+= ' FROM DB_Log__c WHERE RequestStatusDetail__c != \'New\' AND ReEntryCheck__c = False';

        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext dbc, List<DB_Log__c> updateDBList) {
    
    Savepoint sp = Database.setSavepoint();    
    try{
        Set<String> dbSet = new Set<String>();
        Set<String> dbIdSet = new Set<String>();
        Map<String,DB_Log__c> dbMap = new Map<String,DB_Log__c>();
        Set<String> targetUserIds = new Set<String>();
        List<FeedTracking__c> feedInsertList = new List<FeedTracking__c>();
        List<DB_Log__c> DBUpdateList = new List<DB_Log__c>();
        
        Map<String,Channel__c> channelMap = new Map<String,Channel__c>();
        Map<String,ProductService__c> ProductServiceMap = new Map<String,ProductService__c>();
        Map<String,Device__c> DeviceMap = new Map<String,Device__c>();
        Map<String,Promotion_Freetrial__c> PromotionFreelMap = new Map<String,Promotion_Freetrial__c>();
        Map<String,Promotion_Join__c> PromtionJoinMap = new Map<String,Promotion_Join__c>();
        Map<String,LeadSource__c> LeadSourceMap = new Map<String,LeadSource__c>();
        Map<String,MediaCode__c> MediaCodeMap = new Map<String,MediaCode__c>();

        for(DB_Log__c d : updateDBList){
            dbSet.add(d.MobilePhone__c);
            dbSet.add(d.MobilePhone__c.replaceAll('[^0-9]', ''));

            dbIdSet.add(d.LeadSource__c);
            dbIdSet.add(d.Channel__c);
            dbIdSet.add(d.ProductService__c);
            dbIdSet.add(d.Device__c);
            dbIdSet.add(d.Promotion_Freetrial__c);
            dbIdSet.add(d.Promotion_Join__c);
            dbIdSet.add(d.MediaCode__c);

            dbMap.put(d.MobilePhone__c,d);
            dbMap.put(d.MobilePhone__c.replaceAll('[^0-9]', ''),d);
        }
        
        /**
         * DB로 인입된 코드 해당 Object 레코드 데이터 조회
         * 유입경로
         * 채널
         * 제품(서비스)
         * 장치
         * 무체프로모션
         * 가입프로모션
         * 미디어코드
         */
        List<LeadSource__c> leadSourceList = new List<LeadSource__c>([SELECT Id, Name, Code__c FROM LeadSource__c WHERE Code__c= :dbIdSet]);
        List<Channel__c> ChannelList = new List<Channel__c>([SELECT Id, Code__c FROM Channel__c WHERE Code__c= :dbIdSet]);
        List<ProductService__c> ProductServiceList = new List<ProductService__c>([SELECT Id, Code__c FROM ProductService__c WHERE Code__c= :dbIdSet]);
        List<Device__c> DeviceList = new List<Device__c>([SELECT Id, Code__c FROM Device__c WHERE Code__c= :dbIdSet]);
        List<Promotion_Freetrial__c> PromotionFreeList = new List<Promotion_Freetrial__c>([SELECT Id, Name, Code__c FROM Promotion_Freetrial__c WHERE Code__c= :dbIdSet]);
        List<Promotion_Join__c> PromotionJoinList = new List<Promotion_Join__c>([SELECT Id, Code__c FROM Promotion_Join__c WHERE Code__c= :dbIdSet]);
        List<MediaCode__c> MediaCodeList = new List<MediaCode__c>([SELECT Id, Code__c FROM MediaCode__c WHERE Code__c= :dbIdSet]);


        for(LeadSource__c ls : leadSourceList){
            LeadSourceMap.put(ls.Code__c,ls);
        }
        for(Channel__c  ch: ChannelList){
            channelMap.put(ch.Code__c,ch);
        }
        for(ProductService__c ps: ProductServiceList){
            ProductServiceMap.put(ps.Code__c,ps);
        }
        for(Device__c  dv: DeviceList){
            DeviceMap.put(dv.Code__c,dv);
        }
        for(Promotion_Freetrial__c  pf: PromotionFreeList){
            PromotionFreelMap.put(pf.Code__c,pf);
        }
        for(Promotion_Join__c  pj: PromotionJoinList){
            PromtionJoinMap.put(pj.Code__c,pj);
        }
        for(MediaCode__c mc: MediaCodeList){
            MediaCodeMap.put(mc.Code__c,mc);
        }
        List<Lead> existLeadList = new List<Lead>([SELECT Id
                                                        ,MobilePhone
                                                        ,LastName
                                                        ,PostalCode
                                                        ,Street
                                                        ,RequestDateTime__c
                                                        ,LeadSource__c
                                                        ,LeadSource__r.Code__c
                                                        ,ChildName__c
                                                        ,ChildBirthday__c
                                                        ,ChildSchoolYear__c
                                                        ,Channel__c
                                                        ,ProductService__c
                                                        ,Device__c
                                                        ,Promotion_Freetrial__c
                                                        ,Promotion_Join__c
                                                        ,Requirement__c
                                                        ,ContractNumber__c
                                                        ,ProductName__c
                                                        ,Amount__c
                                                        ,FullPaymentFlg__c
                                                        ,RegisterName__c
                                                        ,MembershipNumber__c
                                                        ,LeadSourceDetail__c
                                                        ,batch__c
                                                        ,CreatedDate
                                                        ,ConvertedOpportunityId
                                                        ,ConvertedAccountId
                                                        ,ConvertedOpportunity.OwnerId
                                                        ,ConvertedOpportunity.Name
                                                        ,isConverted
                                                        ,ReEntryDateTime__c
                                                        ,RequestStatusDetail__c
                                                        ,ConvertedOpportunity.RecordType.Name
                                                        ,OwnerId
                                                        ,LastAssign__c
                                                        FROM Lead WHERE MobilePhone IN :dbSet ORDER BY CreatedDate DESC]);

        User admin = [SELECT Id FROM User WHERE Profile.name = '시스템 관리자' limit 1];
        CustomNotificationType notiType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'LeadNotification' limit 1];
        String title,body;

        Set<String> oppId = new Set<String>();
        // 2차 반영예정
        Set<String> accId = new Set<String>();
        Set<String> leadId = new Set<String>();
        
        for(Lead l : existLeadList){
            if(l.ConvertedOpportunityId!=null) oppId.add(l.ConvertedOpportunityId);
            // 2차 반영예정
            if(l.ConvertedAccountId!=null) accId.add(l.ConvertedAccountId);
            if(l.Id!=null) leadId.add(l.Id);
        }
        List<Opportunity> convertedOppList = new List<Opportunity>([SELECT Id
                                                                        ,RecordType.DeveloperName
                                                                        ,Name
                                                                        ,LeadSource__c
                                                                        ,ChildName__c
                                                                        ,ChildBirthday__c  
                                                                        ,ChildSchoolYear__c 
                                                                        ,ParentAddress__PostalCode__s  
                                                                        ,ParentAddress__Street__s  
                                                                        ,Channel__c  
                                                                        ,ProductService__c  
                                                                        ,Device__c  
                                                                        ,Promotion_Freetrial__c  
                                                                        ,Promotion_Join__c  
                                                                        ,MediaCode__c  
                                                                        ,Requirement__c  
                                                                        ,ContractNumber__c  
                                                                        ,ProductName__c  
                                                                        ,Amount__c  
                                                                        ,FullPaymentFlg__c  
                                                                        ,RegisterName__c  
                                                                        ,MembershipNumber__c  
                                                                        ,LeadSourceDetail__c  
                                                                        ,OwnerId
                                                                        ,batch__c
                                                                        FROM Opportunity WHERE Id IN : oppId]);

        // 2차 반영예정
        List<Account> convertedAccList = new List<Account>([SELECT Id
                                                                ,LastName
                                                                FROM Account WHERE Id IN : accId]);
                                                                       
        if(!existLeadList.isEmpty() && existLeadList.size()>0){

            // 재진입 시 예비고객 UPDATE
            for(Lead l : existLeadList){
                Lead updateLead = new Lead(Id = l.Id);

                // 조회 이외 필드들

                // 2차 반영예정 //
                updateLead.LastName = dbMap.get(l.MobilePhone).Name__c != null ? dbMap.get(l.MobilePhone).Name__c : null;
                updateLead.ChildName__c = dbMap.get(l.MobilePhone).ChildName__c != null ? dbMap.get(l.MobilePhone).ChildName__c : null;
                updateLead.ChildBirthday__c = dbMap.get(l.MobilePhone).ChildBirthday__c != null ? Date.valueOf(dbMap.get(l.MobilePhone).ChildBirthday__c) : null;
                updateLead.PostalCode = dbMap.get(l.MobilePhone).PostalCode__c != null ? dbMap.get(l.MobilePhone).PostalCode__c : l.PostalCode;
                updateLead.Street = dbMap.get(l.MobilePhone).Address1__c != null && dbMap.get(l.MobilePhone).Address2__c != null ? dbMap.get(l.MobilePhone).Address1__c + ' ' + dbMap.get(l.MobilePhone).Address2__c : l.Street;
                
                updateLead.Requirement__c = dbMap.get(l.MobilePhone).Requirement__c != null ? dbMap.get(l.MobilePhone).Requirement__c : null;
                updateLead.ContractNumber__c = dbMap.get(l.MobilePhone).ContractNumber__c != null ? dbMap.get(l.MobilePhone).ContractNumber__c : null;
                updateLead.ProductName__c = dbMap.get(l.MobilePhone).ProductName__c != null ? dbMap.get(l.MobilePhone).ProductName__c : null;
                updateLead.Amount__c = dbMap.get(l.MobilePhone).Amount__c != null ? dbMap.get(l.MobilePhone).Amount__c : null;
                updateLead.FullPaymentFlg__c = dbMap.get(l.MobilePhone).FullPaymentFlg__c != null ? dbMap.get(l.MobilePhone).FullPaymentFlg__c : null;
                updateLead.RegisterName__c = dbMap.get(l.MobilePhone).RegisterName__c != null ? dbMap.get(l.MobilePhone).RegisterName__c : null;
                updateLead.MembershipNumber__c = dbMap.get(l.MobilePhone).MembershipNumber__c != null ? dbMap.get(l.MobilePhone).MembershipNumber__c : null;
                updateLead.LeadSourceDetail__c = dbMap.get(l.MobilePhone).LeadSourceDetail__c != null ? dbMap.get(l.MobilePhone).LeadSourceDetail__c : null;
                
                // 조회 필드들
                updateLead.LeadSource__c = LeadSourceMap.get(dbMap.get(l.MobilePhone).LeadSource__c) != null ? LeadSourceMap.get(dbMap.get(l.MobilePhone).LeadSource__c).Id : null;
                updateLead.Channel__c = channelMap.get(dbMap.get(l.MobilePhone).Channel__c) != null ? channelMap.get(dbMap.get(l.MobilePhone).Channel__c).Id : null;
                updateLead.ProductService__c = ProductServiceMap.get(dbMap.get(l.MobilePhone).ProductService__c) != null ? ProductServiceMap.get(dbMap.get(l.MobilePhone).ProductService__c).Id : null;
                updateLead.Device__c = DeviceMap.get(dbMap.get(l.MobilePhone).Device__c) != null ? DeviceMap.get(dbMap.get(l.MobilePhone).Device__c).Id : null;
                updateLead.Promotion_Freetrial__c = PromotionFreelMap.get(dbMap.get(l.MobilePhone).Promotion_Freetrial__c) != null ? PromotionFreelMap.get(dbMap.get(l.MobilePhone).Promotion_Freetrial__c).Id : null;
                updateLead.Promotion_Join__c = PromtionJoinMap.get(dbMap.get(l.MobilePhone).Promotion_Join__c) != null ? PromtionJoinMap.get(dbMap.get(l.MobilePhone).Promotion_Join__c).Id : null;
                updateLead.MediaCode__c = MediaCodeMap.get(dbMap.get(l.MobilePhone).MediaCode__c) != null ? MediaCodeMap.get(dbMap.get(l.MobilePhone).MediaCode__c).Id : null;
                
                updateLead.RequestStatusDetail__c = dbMap.get(l.MobilePhone).RequestStatusDetail__c;
                updateLead.ReEntryDateTime__c = dbMap.get(l.MobilePhone).ReEntryDateTime__c;
                updateLead.OwnerId = l.LastAssign__c;
                updateLead.batch__c = true;

                updateLeadList.add(updateLead);
            }

            System.debug('updateLeadList size  >>>> ' + updateLeadList.size());
            if(updateLeadList.size()>0 && !updateLeadList.isEmpty()){
                System.debug('updateLeadList   >>>> ' + JSON.serializePretty(updateLeadList));
                UPDATE updateLeadList;

                for(Lead l : existLeadList){
                    title = '예비고객 업데이트';
                    // DateTime yyyy년MM월dd일 a h:mm format 처리
                    body = l.ConvertedOpportunityId != null ? l.LastName + '님이 '+Utilities.transDateTimeFormat(dbMap.get(l.MobilePhone).ReEntryDateTime__c)+'에 무료체험 재인입 되었습니다' : l.LastName + '님이 '+Utilities.transDateTimeFormat(dbMap.get(l.MobilePhone).ReEntryDateTime__c)+'에 재인입 되었습니다';
                    Set<String> singleTargetUserId = new Set<String>{l.OwnerId};
                    UTIL_Notification.unCalloutNotiSend(notiType.Id, admin.Id, l.ConvertedOpportunityId != null? l.ConvertedOpportunityId : l.Id, title, body, singleTargetUserId);
                }

                // Lead UPDATE 이후 해당 DB, 리드로 할당 되었는지 구분 표시(재진입 되지 않게끔) 
                for(DB_Log__c upDBList : updateDBList){
                    DB_Log__c db = new DB_Log__c(Id = upDBList.Id);
                    db.ReEntryCheck__c = True;
                    DBUpdateList.add(db);
                }

                if(!DBUpdateList.isEmpty()&& DBUpdateList.size() >0) UPDATE DBUpdateList; 
                //if(feedInsertList.size()>0 && !feedInsertList.isEmpty()) INSERT feedInsertList;
            }

            List<Lead> updatedLeadList = new List<Lead>([SELECT Id
                                                            ,MobilePhone
                                                            ,LastName
                                                            ,RequestDateTime__c
                                                            ,LeadSource__c
                                                            ,ChildName__c
                                                            ,ChildBirthday__c
                                                            ,ChildSchoolYear__c
                                                            ,PostalCode
                                                            ,Street
                                                            ,Channel__c
                                                            ,ProductService__c
                                                            ,Device__c
                                                            ,Promotion_Freetrial__c
                                                            ,Promotion_Join__c
                                                            ,MediaCode__c
                                                            ,Requirement__c
                                                            ,ContractNumber__c
                                                            ,ProductName__c
                                                            ,Amount__c
                                                            ,FullPaymentFlg__c
                                                            ,RegisterName__c
                                                            ,MembershipNumber__c
                                                            ,LeadSourceDetail__c
                                                            ,CreatedDate
                                                            ,ConvertedOpportunityId
                                                            ,ConvertedAccountId
                                                            ,isConverted
                                                            ,ReEntryDateTime__c
                                                            ,RequestStatusDetail__c
                                                            ,ConvertedOpportunity.RecordType.Name
                                                            ,OwnerId
                                                            ,LastAssign__c
                                                            ,batch__c
                                                            FROM Lead WHERE ConvertedOpportunityId IN :oppId]);

            
            List<Lead> updatedLeadListForMobile = new List<Lead>([SELECT Id, LastName, MobilePhone FROM Lead WHERE Id IN :leadId]);

            Map<String,Lead> updateLeadMap = new Map<String,Lead>();
            Map<String,Lead> updateLeadMapForMobile = new Map<String,Lead>();

            for(Lead l : updatedLeadList){
                if(l.ConvertedOpportunityId != null) updateLeadMap.put(l.ConvertedOpportunityId,l);
                if(l.ConvertedAccountId != null) updateLeadMap.put(l.ConvertedAccountId,l);
                System.debug('ConvertedAccountId>>> '+ l.ConvertedAccountId);
            }

            for(Lead l : updatedLeadListForMobile){
                updateLeadMapForMobile.put(l.MobilePhone, l);
                updateLeadMapForMobile.put(l.MobilePhone.replaceAll('[^0-9]', ''), l);
            } 
            
            System.debug('updatedLeadListForMobile>>> '+ updatedLeadListForMobile);
            System.debug('updateLeadMapForMobile>>> '+ updateLeadMapForMobile);
            System.debug('updateLeadMap>>> '+ updateLeadMap);

            List<Opportunity> updateOppList = new List<Opportunity>();

            // 2차 반영예정
            List<Account> updateAccList = new List<Account>();
            if(!convertedAccList.isEmpty() && convertedAccList.size()>0){
                for(Account a : convertedAccList){
                    Account updateAcc = new Account(Id = a.Id);
                    updateAcc.LastName = updateLeadMap.get(a.Id).LastName;
                    updateAccList.add(updateAcc);
                }
            }
            if(updateAccList.size()>0 && !updateAccList.isEmpty()) UPDATE updateAccList;

            // 재진입 예비고객 변환된 기회가 있을 시 UPDATE
            if(!convertedOppList.isEmpty() && convertedOppList.size()>0){
                for(Opportunity o : convertedOppList){

                    Opportunity updateOpp = new Opportunity(Id = o.Id);
                    //2차 반영예정
                    updateOpp.Name = o.RecordType.DeveloperName == 'FreeTrial' ? updateLeadMap.get(o.Id).LastName + ' 무료체험' : updateLeadMap.get(o.Id).LastName + ' 직가입';
                    updateOpp.LeadSource__c = updateLeadMap.get(o.Id).LeadSource__c;
                    updateOpp.ChildName__c = updateLeadMap.get(o.Id).ChildName__c;
                    updateOpp.ChildBirthday__c = updateLeadMap.get(o.Id).ChildBirthday__c;
                    //updateOpp.ChildSchoolYear__c = updateLeadMap.get(o.Id).ChildSchoolYear__c;
                    updateOpp.ParentAddress__PostalCode__s = updateLeadMap.get(o.Id).PostalCode;
                    updateOpp.ParentAddress__Street__s = updateLeadMap.get(o.Id).Street;
                    updateOpp.Channel__c = updateLeadMap.get(o.Id).Channel__c;
                    updateOpp.ProductService__c = updateLeadMap.get(o.Id).ProductService__c;
                    updateOpp.Device__c =updateLeadMap.get(o.Id).Device__c;
                    updateOpp.Promotion_Freetrial__c = updateLeadMap.get(o.Id).Promotion_Freetrial__c;
                    updateOpp.Promotion_Join__c = updateLeadMap.get(o.Id).Promotion_Join__c;
                    updateOpp.MediaCode__c = updateLeadMap.get(o.Id).MediaCode__c;
                    updateOpp.Requirement__c = updateLeadMap.get(o.Id).Requirement__c;
                    updateOpp.ContractNumber__c = updateLeadMap.get(o.Id).ContractNumber__c;
                    updateOpp.ProductName__c = updateLeadMap.get(o.Id).ProductName__c;
                    updateOpp.Amount__c = updateLeadMap.get(o.Id).Amount__c;
                    updateOpp.FullPaymentFlg__c = updateLeadMap.get(o.Id).FullPaymentFlg__c;
                    updateOpp.RegisterName__c = updateLeadMap.get(o.Id).RegisterName__c;
                    updateOpp.MembershipNumber__c = updateLeadMap.get(o.Id).MembershipNumber__c;
                    updateOpp.LeadSourceDetail__c = updateLeadMap.get(o.Id).LeadSourceDetail__c;
                    updateOpp.OwnerId = updateLeadMap.get(o.Id).LastAssign__c;
                    updateOpp.batch__c = updateLeadMap.get(o.Id).batch__c;
                    
                    updateOppList.add(updateOpp);
                }
            }
            if(updateOppList.size()>0 && !updateOppList.isEmpty()) UPDATE updateOppList;


                        /**
             * 재진입 시 이력관리 INSERT
             * 기회로 변환된 리드 => [구분 : 무체재인입]
             * 기회로 변환되지 않은 리드 => [구분 : 재인입]
             */
            
            System.debug('LeadSourceMap >> '+LeadSourceMap);
            for(Lead l : existLeadList){
                
                FeedTracking__c feed = new FeedTracking__c();
                feed.FieldAPIName__c = l.ConvertedOpportunityId != null ? '무체재인입' : '재인입';
                feed.Lead__c = l.Id;
                feed.Opportunity__c = l.ConvertedOpportunityId != null ? l.ConvertedOpportunityId : null;
                feed.ReEntryDateTime__c = dbMap.get(l.MobilePhone).ReEntryDateTime__c;
                feed.OwnerId = l.ConvertedOpportunityId != null ? l.ConvertedOpportunity.OwnerId : l.OwnerId;
                feed.ReAssign__c = l.ConvertedOpportunityId != null ? '무체재인입' : '재인입';
                feed.LeadSource__c = LeadSourceMap.get(dbMap.get(l.MobilePhone).LeadSource__c).Name;
                // 2차 반영예정
                feed.Value__c = !l.LastName.equals(updateLeadMapForMobile.get(l.MobilePhone).LastName) ? l.LastName + '님의 성명이 ' + updateLeadMapForMobile.get(l.MobilePhone).LastName +'으로 변경되었습니다.': '';
                feedInsertList.add(feed);
            }
            System.debug('feedInsertList >>> '+ feedInsertList);
            if(feedInsertList.size()>0 && !feedInsertList.isEmpty()) INSERT feedInsertList;

        }
        
    } catch (Exception e) {
        Database.rollback(sp);
        System.debug(e.getMessage() + '/' + e.getStackTraceString());
    }
}

    public void finish(Database.BatchableContext dbc) {
    

    }
}