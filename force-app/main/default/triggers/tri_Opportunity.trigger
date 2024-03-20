/**
 * @description       : 기회 개체 트리거
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-28-2024
 * @last modified by  : ms.kim
**/
trigger tri_Opportunity on Opportunity (before insert, before update, before delete, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            
            Set<Id> acc_ids = new Set<Id>();
            Set<Id> oppty_rectype_ids = new Set<Id>();
            for(Opportunity oppty : Trigger.new){
                acc_ids.add(oppty.AccountId);
                oppty_rectype_ids.add(oppty.RecordTypeId);
            }
            
            Map<Id, Account> opportunityToAccountIdMap = new Map<Id, Account>([SELECT Id
                                                                                    , Name 
                                                                                FROM Account 
                                                                                WHERE IsDeleted = false 
                                                                                AND Id IN: acc_ids]);

            Map<Id, String> recordtypeId_dname_map = new Map<Id,String>();
            for(RecordType rt : [SELECT Id, DeveloperName
                                FROM RecordType 
                                WHERE IsActive = true 
                                AND SobjectType = 'Opportunity']){
                recordtypeId_dname_map.put(rt.Id, rt.DeveloperName);
            }

            for(Opportunity oppty : Trigger.new){
                Account acc = opportunityToAccountIdMap.get(oppty.AccountId);
                String DvName = recordtypeId_dname_map.get(oppty.RecordTypeId);

                // 기회 레코드 유형 1.무료체험 => 무료체험등록일 = Date.today()
                //                               기회명 = 부모명 + 무료체험                                            
                //                 2.직가입 => 직가입등록일 = Date.today()
                //                             기회명 = 부모명 + 직가입
                if(DvName == 'FreeTrial'){
                    oppty.Name = acc.Name + ' 무료체험';
                    oppty.FreeTrialRegistDate__c = Date.today();
                }else{
                    oppty.Name = acc.Name + ' 직가입';
                    oppty.DirectJoinRegistDate__c = Date.today();
                }
            } 
        }
        
        if(Trigger.isUpdate){
            
            Set<Id> curuser_ids = new Set<Id>();
            for(Opportunity oppty : Trigger.new){
                Opportunity old_oppty = Trigger.oldmap.get(oppty.Id);
                if(old_oppty.OwnerId != oppty.OwnerId){
                    curuser_ids.add(UserInfo.getUserId());
                }
            }

            Map<Id, User> cur_usermap = new Map<Id, User>([SELECT Id
                                                            , UserRole.Name 
                                                            , UserRole.DeveloperName    
                                                        FROM User 
                                                        WHERE IsActive = true
                                                        AND Id IN: curuser_ids ]);
            
            CustomNotificationType notiType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'LeadReAssignNotification' limit 1];

            Map<Id, Account> acc_map = new Map<Id, Account>();

            for(Opportunity oppty : Trigger.new){
                Opportunity old_oppty = Trigger.oldmap.get(oppty.Id);
                if(!cur_usermap.isEmpty()){
                    User cur_user = cur_usermap.get(UserInfo.getUserId());
    
                    if(cur_user != null && cur_user.UserRole.Name == '본사' || cur_user.UserRole.DeveloperName.contains('Manager')){
                        if(oppty.OwnerId == oppty.LastAssign__c && oppty.Batch__c == false){
                            // 최종배분교사에게 회수 후 재분배 불가 Validate
                            oppty.addError(Label.CLS_ReAssign);
                        }else{
                            // 본사계정 -> 표준사용자 OwnerId 변경 시
                            // 1. 마지막 분배교사 Update
                            // 2. 재배정 == Y
                            // 3. 계정 소유자 Update
                            oppty.LastAssign__c = oppty.OwnerId;
                            oppty.ReAssign__c = 'Y';
                            oppty.Batch__c = false;

                            Account acc = acc_map.get(oppty.AccountId);
                            if(acc == null){
                                acc = new Account(Id = oppty.AccountId);
                            }

                            acc.OwnerId = oppty.OwnerId;
                            acc_map.put(oppty.AccountId, acc);

                            // 재할당 후 상담교사에게 알림
                            String formatDT = Utilities.transDateTimeFormat(Datetime.now());
                            Set<String> singleTargetUserId = new Set<String>{oppty.OwnerId};
                            String title = '재할당 건 알림입니다.';
                            String body = oppty.fm_AccountName__c+'님이 '+formatDT+ '에 재할당되었습니다.';
                            UTIL_Notification.unCalloutNotiSend(notiType.Id, cur_user.Id, oppty.Id, title, body, singleTargetUserId);
                        }
                    }else if(cur_user.UserRole.Name.contains('상담파트') && oppty.Batch__c == false){
                        // 상담교사는 Owner 변경 시 validate
                        oppty.addError(Label.CLS_ReAssign2);
                    }
                }

                // 자녀생일 변경 시 자녀 학년 기본값 업데이트
                if(old_oppty.ChildBirthday__c != oppty.ChildBirthday__c){
                    if(oppty.ChildBirthday__c != null){
                        Decimal Childyear = System.today().year() - oppty.ChildBirthday__c.year() +1;
                        oppty.ChildSchoolYear__c = Childyear > 16 ? '기타' : String.valueOf(Childyear);
                    }else{
                        oppty.ChildSchoolYear__c = null;
                    }
                }

                // 계약번호 삭제 시 차번 계약번호 삭제
                if(old_oppty.ContractNumber1__c != oppty.ContractNumber1__c && oppty.ContractNumber1__c == null ){
                    oppty.ContractNumber2__c = null;
                    oppty.ContractNumber3__c = null;
                    oppty.ContractNumber4__c = null;
                }else if(old_oppty.ContractNumber2__c != oppty.ContractNumber2__c && oppty.ContractNumber2__c == null){
                    oppty.ContractNumber3__c = null;
                    oppty.ContractNumber4__c = null;
                }else if(old_oppty.ContractNumber3__c != oppty.ContractNumber3__c && oppty.ContractNumber3__c == null){
                    oppty.ContractNumber4__c = null;
                }

                // 기회 단계 변경 시
                // 1. 고객 유형 업데이트
                // 2. 상태변경일자 업데이트
                if((old_oppty.StageName != oppty.StageName)){
                    Account acc = acc_map.get(oppty.AccountId);
                    if(acc == null){
                        acc = new Account(Id = oppty.AccountId);
                    }

                    if(oppty.StageName == '정회원확정'){
                        oppty.A1DateTime__c = Datetime.now();
                        acc.AccountType__c = 'A2';

                    }else if(oppty.StageName == '해지'){
                        oppty.A2DateTime__c = Datetime.now();
                    }else if(oppty.StageName == '가입취소'){
                        oppty.A3DateTime__c = Datetime.now();
                    }
                    acc_map.put(oppty.AccountId, acc);
                }

                // 2024-02-28 ~ 2024-02-29 신청일시 변경에 따른 텍스트 업데이트
                if(old_oppty.RequestDateTime__c != oppty.RequestDateTime__c && oppty.RequestDateTime__c != null){
                    oppty.RequestDateTime_AddWeekday__c = oppty.RequestDateTime__c != null ? Utilities.transDateTimeFormat(oppty.RequestDateTime__c) : '';
                }
            }

            if(!acc_map.isEmpty()) update acc_map.values();
        }

        if(Trigger.isDelete){
            User usr = [SELECT Id
                                , Profile.Name 
                        FROM User 
                        WHERE IsActive = true 
                        AND Id=:UserInfo.getUserId() 
                        LIMIT 1];
            if(usr.Profile.Name == 'System Administrator' || usr.Profile.Name == '시스템 관리자' ){     
                //시스템 관리자는 Delete 허용.
            }else{
                for(Opportunity oppty : Trigger.old){
                    oppty.addError('삭제 할 수 없습니다.');
                }
            }
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isUpdate){

            List<Account> acc_list = new List<Account>();
            List<FeedTracking__c> ft_List = new List<FeedTracking__c>();
            Set<Id> oppty_ids = new Set<Id>();
            Map<Id, Id> opptyid_leadid_map = new Map<Id, Id>();

            for(Opportunity oppty : Trigger.new){
                Opportunity old_oppty = Trigger.oldMap.get(oppty.Id);
                
                // 관리요청번호 이력생성
                if(old_oppty.NOKNumber__c != oppty.NOKNumber__c){
                    ft_List.add(
                        new FeedTracking__c(
                            NOKNumberChangeDateTime__c = Datetime.now()
                            , ChangePhoneNo__c = oppty.NOKNumber__c
                            , FieldAPIName__c = 'NOKNumber__c'
                            , Opportunity__c = oppty.Id
                    ));
                }

                // 특이사항 이력생성
                if(old_oppty.Note__c != oppty.Note__c){
                    ft_List.add(
                        new FeedTracking__c(
                            Value__c = oppty.Note__c
                            , FieldAPIName__c = 'Note__c'
                            , Opportunity__c = oppty.Id
                    ));
                }

                // 2024-02-28 ~ 2024-02-29 기회 변경 사항 리드 업데이트
                // 1. 신청일시
                // 2. 유입경로 (채널, 유입경로, 제품(서비스), 장치, 가입프로모션, 무체프로모션, 미디어코드)
                if( old_oppty.RequestDateTime__c != oppty.RequestDateTime__c && oppty.RequestDateTime__c != null
                    || old_oppty.Channel__c != oppty.Channel__c && oppty.Channel__c != null
                    || old_oppty.LeadSource__c != oppty.LeadSource__c && oppty.LeadSource__c != null
                    || old_oppty.ProductService__c != oppty.ProductService__c
                    || old_oppty.Device__c != oppty.Device__c
                    || old_oppty.Promotion_Join__c != oppty.Promotion_Join__c
                    || old_oppty.Promotion_Freetrial__c != oppty.Promotion_Freetrial__c
                    || old_oppty.MediaCode__c != oppty.MediaCode__c){
                    oppty_ids.add(oppty.Id);
                }
            }

            List<Lead> convertedLead = [SELECT Id
                                                , ConvertedOpportunityId
                                            FROM Lead 
                                            WHERE IsDeleted = false 
                                            AND ConvertedOpportunityId IN: oppty_ids];
                                            
            for(Lead ld : convertedLead){
                opptyid_leadid_map.put(ld.convertedOpportunityId, ld.Id);
            }       
            
            List<Lead> ld_List = new List<Lead>();

            for(Opportunity oppty : Trigger.new){
                Opportunity old_oppty = Trigger.oldMap.get(oppty.Id);
                Lead ld = new Lead(Id = opptyid_leadid_map.get(oppty.Id));
                if(opptyid_leadid_map.get(oppty.Id) != null){

                    if(old_oppty.RequestDateTime__c != oppty.RequestDateTime__c && oppty.RequestDateTime__c != null){
                        ld.RequestDateTime__c = oppty.RequestDateTime__c;
                        ld.RequestDateTime_AddWeekday__c = oppty.RequestDateTime_AddWeekday__c;
                    }
                    if(old_oppty.Channel__c != oppty.Channel__c && oppty.Channel__c != null){
                        ld.Channel__c = oppty.Channel__c;
                    }
                    if(old_oppty.LeadSource__c != oppty.LeadSource__c && oppty.LeadSource__c != null){
                        ld.LeadSource__c = oppty.LeadSource__c;
                    }
                    if(old_oppty.ProductService__c != oppty.ProductService__c && oppty.ProductService__c != null){
                        ld.ProductService__c = oppty.ProductService__c;
                    }
                    if(old_oppty.Device__c != oppty.Device__c){
                        ld.Device__c = oppty.Device__c;
                    }
                    if(old_oppty.Promotion_Join__c != oppty.Promotion_Join__c){
                        ld.Promotion_Join__c = oppty.Promotion_Join__c;
                    }
                    if(old_oppty.Promotion_Freetrial__c != oppty.Promotion_Freetrial__c){
                        ld.Promotion_Freetrial__c = oppty.Promotion_Freetrial__c;
                    }
                    if(old_oppty.MediaCode__c != oppty.MediaCode__c){
                        ld.MediaCode__c = oppty.MediaCode__c;
                    }
                    ld_List.add(ld);
                }
            }

            if(!acc_list.isEmpty()) update acc_list;
            if(!ft_List.isEmpty()) insert ft_List;
            if(!ld_List.isEmpty()) update ld_List;
        }
    }
}