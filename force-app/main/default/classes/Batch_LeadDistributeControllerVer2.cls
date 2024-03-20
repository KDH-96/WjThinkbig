/**
 * @description       : 
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-21-2024
 * @last modified by  : wj.chae
**/
public class Batch_LeadDistributeControllerVer2 implements Database.Batchable<sObject>, Database.Stateful {
    public List<Group__c> updGroupList = new List<Group__c>();
    public List<WeightTurn__c> upsWeightList = new List<WeightTurn__c>();
    public Map<Id, WeightTurn__c> upsWeightMap = new Map<Id, WeightTurn__c>();

    /**
     * 교사에게 분배되지 않은 신규 유입된 데이터 조회
     */
    public Database.QueryLocator start(Database.BatchableContext dbc) {
        // 신규DB 데이터 취득
        // 채널 판단 분배 키 항목: 채널, 유입경로, 제품(서비스)
        String strQuery = 
            'SELECT Id, Name, MobilePhone__c, Name__c, RequestDateTime__c, Channel__c, LeadSource__c, LeadSourceDetail__c, ProductService__c, ChildBirthday__c, ChildName__c, ' + 
            'AssignUser__c, AssignDate__c, RequestStatusDetail__c, PostalCode__c, Address1__c, Address2__c, ContractNumber__c, ' + 
            'ProductName__c, Amount__c, RegisterName__c, ChildAge__c, Requirement__c, FullPaymentFlg__c, MembershipNumber__c, ' + 
            'Device__c, Promotion_Freetrial__c, Promotion_Join__c, MediaCode__c, Group__c ' + 
            'FROM DB_Log__c ' + 
            'WHERE AssignUser__c = null AND AssignDate__c = null AND RequestStatusDetail__c = \'New\' AND IsDeleted = false ' + 
            'ORDER BY CreatedDate';

        return Database.getQueryLocator(strQuery);
    }

    
    /**
     * 유입경로 별로 설정된 교사 그룹의 상담교사에게 분배
     */
    public void execute(Database.BatchableContext dbc, List<DB_Log__c> importList) {

        system.debug('>>> DB유입된 개수: ' + importList.size());

        List<String> chList = new List<String>();
        List<String> lsList = new List<String>();
        List<String> psList = new List<String>();
        List<String> pfList = new List<String>();
        List<String> pjList = new List<String>();
        List<String> deviceList = new List<String>();
        List<String> mcList = new List<String>();

        // 레코드Id 조회를 위한 코드 별 리스트화
        for (DB_Log__c data : importList) {
            // 채널
            if (String.isNotEmpty(data.Channel__c) && !chList.contains(data.Channel__c)) {
                chList.add(data.Channel__c.trim());
            }
            // 유입경로
            if (String.isNotEmpty(data.LeadSource__c) && !lsList.contains(data.LeadSource__c)) {
                lsList.add(data.LeadSource__c.trim());
            }
            // 제품(서비스)
            if (String.isNotEmpty(data.ProductService__c) && !psList.contains(data.ProductService__c)) {
                psList.add(data.ProductService__c.trim());
            }
            // 디바이스
            if (String.isNotEmpty(data.Device__c) && !deviceList.contains(data.Device__c)) {
                deviceList.add(data.Device__c.trim());
            }
            // 무체프로모션
            if (String.isNotEmpty(data.Promotion_Freetrial__c) && !pfList.contains(data.Promotion_Freetrial__c)) {
                pfList.add(data.Promotion_Freetrial__c.trim());
            }
            // 가입프로모션
            if (String.isNotEmpty(data.Promotion_Join__c) && !pjList.contains(data.Promotion_Join__c)) {
                pjList.add(data.Promotion_Join__c.trim());
            }
            // 미디어코드
            if (String.isNotEmpty(data.MediaCode__c) && !mcList.contains(data.MediaCode__c)) {
                mcList.add(data.MediaCode__c.trim());
            }
        }


        /** 채널 */
        List<Channel__c>  chCodeList = new List<Channel__c>([
            SELECT Id, Name, Code__c
            FROM Channel__c
            WHERE Code__c IN :chList AND IsDeleted = false
        ]);
        Map<String,Id> chMap = new Map<String,Id>();
        for (Channel__c ch : chCodeList) {
            chMap.put(ch.Code__c, ch.Id);
        }

        /** 유입경로 */
        List<LeadSource__c>  lsCodeList = new List<LeadSource__c>([
            SELECT Id, Name, Code__c
            FROM LeadSource__c
            WHERE Code__c IN :lsList AND IsDeleted = false
        ]);
        Map<String,Id> lsMap = new Map<String,Id>();
        for (LeadSource__c ls : lsCodeList) {
            lsMap.put(ls.Code__c, ls.Id);
        }

        /** 제품(서비스) */
        List<ProductService__c>  psCodeList = new List<ProductService__c>([
            SELECT Id, Name, Code__c
            FROM ProductService__c
            WHERE Code__c IN :psList AND IsDeleted = false
        ]);
        Map<String,Id> psMap = new Map<String,Id>();
        for (ProductService__c ps : psCodeList) {
            psMap.put(ps.Code__c, ps.Id);
        }

        /** 디바이스 */
        List<Device__c> deviceCodeList = new List<Device__c>([
            SELECT Id, Name, Code__c
            FROM Device__c
            WHERE Code__c IN :deviceList AND IsDeleted = false
        ]);
        Map<String,Id> deviceMap = new Map<String,Id>();
        for (Device__c d : deviceCodeList) {
            deviceMap.put(d.Code__c, d.Id);
        }

        /** 무체프로모션 */
        List<Promotion_Freetrial__c> pfCodeList = new List<Promotion_Freetrial__c>([
            SELECT Id, Name, Code__c
            FROM Promotion_Freetrial__c
            WHERE Code__c IN :pfList AND IsDeleted = false
        ]);
        Map<String,Id> pfMap = new Map<String,Id>();
        for (Promotion_Freetrial__c pf : pfCodeList) {
            pfMap.put(pf.Code__c, pf.Id);
        }

        /** 가입프로모션 */
        List<Promotion_Join__c> pjCodeList = new List<Promotion_Join__c>([
            SELECT Id, Name, Code__c
            FROM Promotion_Join__c
            WHERE Code__c IN :pjList AND IsDeleted = false
        ]);
        Map<String,Id> pjMap = new Map<String,Id>();
        for (Promotion_Join__c pj : pjCodeList) {
            pjMap.put(pj.Code__c, pj.Id);
        }

        /** 미디어코드 */
        List<MediaCode__c> mideaCodeList = new List<MediaCode__c>([
            SELECT Id, Name, Code__c
            FROM MediaCode__c
            WHERE Code__c IN :mcList AND IsDeleted = false
        ]);
        Map<String,Id> mcMap = new Map<String,Id>();
        for (MediaCode__c mc : mideaCodeList) {
            mcMap.put(mc.Code__c, mc.Id);
        }


        /** 교사그룹 조회 */
        String strQuoteLeadSource = '(\'' + String.join(lsList, '\',\'') + '\')';
        String qrGroup = 
            'SELECT Id, Name, LeadSource__c, LastAssign__c, Assigning__c, Criteria__c ' + 
            'FROM Group__c ' + 
            'WHERE LeadSource__c INCLUDES ' + strQuoteLeadSource + ' AND IsDeleted = false';
        List<Group__c> groupList = DataBase.query(qrGroup);
        /**
         * 조회한 교사그룹 데이터 Map화
         * Key: 교사그룹 레코드Id
         * Value: 교사그룹
         */
        Map<Id, Group__c> groupMap = new Map<Id, Group__c>();
        for (Group__c gr : groupList) {
            groupMap.put(gr.Id, gr);
        }


        /** 교사그룹 상세항목(교사 목록) 조회 */
        String qrGroupDetail = 
            'SELECT Id, Name, SortOrder__c, WeightedValue__c, MinDistriNo__c, Group__r.LeadSource__c, Group__r.Id, Group__c, User__c ' + 
            'FROM GroupDetail__c ' + 
            'WHERE Group__r.LeadSource__c INCLUDES ' + strQuoteLeadSource + ' ' + 'AND IsDeleted = false ' + 
            'ORDER BY SortOrder__c';
        List<GroupDetail__c> grDetailList = DataBase.query(qrGroupDetail);
        /**
         * 조회한 교사그룹 상세항목 데이터 Map화
         * Key: 교사그룹 상세항목 레코드Id
         * Value: 교사그룹 상세항목
         */
        Map<Id, GroupDetail__c> grDetailMap = new Map<Id, GroupDetail__c>();
        for (GroupDetail__c grd : grDetailList) {
            grDetailMap.put(grd.Id, grd);
        }


        /** 
         * 유입경로 별 교사그룹Id 
         * Key: 유입경로코드
         * Value: 교사그룹 레코드Id
        */
        Map<String, Id> groupCodeMap = new Map<String, Id>();
        for (Id key : groupMap.keySet()) {
            Group__c gr = groupMap.get(key);
            
            String[] lsCodes = gr.LeadSource__c.split(';');
            for (String code : lsCodes) {
                groupCodeMap.put(code, key);
            }
        }


        /**
         * 할당교사 및 유입경로 별 할당된 리드 수 카운트를 위한 DB유입경로 조회
         */
        Map<Id, DB_Log__c> assignedLeads = new Map<Id, DB_Log__c>([
            SELECT Id, AssignUser__c, LeadSource__c, Group__c  
            FROM DB_Log__c 
            WHERE Group__c IN :groupMap.keySet() AND AssignUser__c <> null AND Group__c <> null  AND IsDeleted = false
        ]);

        Map<Id, Map<Id, String>> assignedLogMap = new Map<Id, Map<Id, String>>();
        for (Id key : groupMap.keySet()) {
            // 유입경로 및 상담교사 별 map (할당된 개수 알아내기 위함) 
            Map<Id, String> assignedUserMap = new Map<Id, String>();
            for (DB_Log__c log : assignedLeads.values()) {
                if (log.Group__c == key) {
                    assignedUserMap.put(log.Id, log.AssignUser__c);
                }
            }

            // Key: 교사그룹.레코드Id
            // Value: assignedUserMap
            assignedLogMap.put(key, assignedUserMap);
        }


        /**
         * 가중치 순번 데이터 조회
         * Key: 교사그룹 레코드Id + 사용자 레코드Id
         * Value: 가중치 순번
         */
        Map<Id, WeightTurn__c> weightTurnMap = new Map<Id, WeightTurn__c>([
            SELECT 
                Id, User__c, EvenFlg__c, Group__c
            FROM WeightTurn__c 
            WHERE Group__c IN :groupMap.keySet() AND IsDeleted = false
            ORDER BY CreatedDate DESC
        ]);
        Map<String, WeightTurn__c> turnByChannelMap = new Map<String, WeightTurn__c>();
        for (WeightTurn__c turn : weightTurnMap.values()) {
            turnByChannelMap.put(String.valueOf(turn.Group__c) + String.valueOf(turn.User__c), turn);
        }

        
        /**
         * 교사그룹 별 교사목록 조회
         * Key: 그룹Id
         * Value: 교사목록
         */
        Map<Id, List<GroupDetail__c>> consulMap = new Map<Id, List<GroupDetail__c>>();
        for (Id key : groupMap.keySet()) {
            // Group__c gr = groupMap.get(key);

            List<GroupDetail__c> consulList = new List<GroupDetail__c>();
            for (GroupDetail__c det : grDetailMap.values()) {
                if (key == det.Group__r.Id) {
                    consulList.add(det);
                }
            }
            consulMap.put(key, consulList);
        }


        /**
         * 상담교사 별 남은 최소분배수 추출하여 map 에 담기
         * Key: 교사그룹 레코드Id + 사용자 레코드Id
         * Value: 할당된 DB 수
         */
        Map<String, Integer> remainMinDistMap = new Map<String, Integer>();
        for (Id key : groupMap.keySet()) {
            List<GroupDetail__c> consultants = consulMap.get(key);
            Map<Id, String> assignedListByLeadSrc = assignedLogMap.get(key);
            
            if (consultants?.size() > 0) {
                for (GroupDetail__c consulInfo : consultants) {

                    // 최소 분배수
                    Integer minDist = consulInfo.MinDistriNo__c == null ? 0 : Integer.valueOf(consulInfo.MinDistriNo__c);

                    // 상담교사에게 할당된 db
                    List<Id> assignedList = new List<Id>();
                    for (Id usrId : assignedListByLeadSrc.values()) {
                        if (consulInfo.User__c == usrId) {
                            assignedList.add(usrId);
                        }
                    }

                    Integer cntAssigned = assignedList?.size();
                    // 상담교사 별 최소분배수를 채우지 못한 경우, 남은 개수 Map 화
                    if (minDist > cntAssigned) {
                        remainMinDistMap.put(String.valueOf(key)+String.valueOf(consulInfo.User__c), minDist-cntAssigned);
                    }
                }
            }
        }


        List<Lead> insLeadList = new List<Lead>();
        List<DB_Log__c> updDbLogList = new List<DB_Log__c>();
        Map<String, Integer> assignCountMap = new Map<String, Integer>();

        /** DB유입된 데이터를 상담교사들에게 분배 시작  */
        for (DB_Log__c data : importList) {

            String groupId = groupCodeMap.get(data.LeadSource__c);
            if (String.isEmpty(groupId)) continue;

            // 교사그룹 정보 취득
            Group__c grInfo;
            if (groupMap.containsKey(groupId)) {
                grInfo = groupMap.get(groupId);
            }
            if (grInfo == null) continue;

            // 분배를 시작할 교사 추출
            Integer startNo = 1;
            List<GroupDetail__c> consultants = new List<GroupDetail__c>(consulMap.get(groupId));
            for(GroupDetail__c gd : consultants) {
                
                if (updGroupList.contains(grInfo) && 
                    String.valueOf(gd.SortOrder__c) == updGroupList.get(updGroupList.indexOf(grInfo)).LastAssign__c) {
                    
                    startNo = (consultants.indexOf(gd)) + 1;
                    break;

                }else {
                    if(String.isNotEmpty(grInfo.LastAssign__c) && 
                        String.valueOf(gd.SortOrder__c) == grInfo.LastAssign__c) {

                        startNo = (consultants.indexOf(gd)) + 1;
                        break;
                    }
                }
            }

            
            if(String.isNotEmpty(grInfo.LastAssign__c) && !grInfo.Assigning__c) {
                startNo++;

                // 마지막 순번의 할당교사의 경우 첫 순번에서 다시 시작
                if(startNo > consultants?.size()) {
                    startNo = 1;
                }
            }

            //  최소분배수를 다 채웠을 경우, 가중치를 기준으로 분배
            String criteria = grInfo.Criteria__c;
            if (remainMinDistMap?.size() <= 0) {
                criteria = Label.CLS_Weight;
            }

            // 자녀 학년
            String schoolYear;
            if (String.isNotEmpty(data.ChildAge__c)) {
                schoolYear = data.ChildAge__c;
                if (Integer.valueOf(schoolYear) > 16) {
                    schoolYear = Label.CLS_Etc;
                }
            }


            Integer turnNo = 1;
            Datetime dtNow = DateTime.now();
            Map<String, Integer> distCountMap = new Map<String, Integer>();

            // 최소분배수
            if (Label.CLS_MinDistNum.equals(criteria)) {
                
                for (Integer j = 0; j < consultants.size(); j++) {
                    
                    System.debug('>>> 최소분배수 IN');
                    GroupDetail__c consulInfo = consultants[startNo-1];
                    
                    // 상담교사 별 최수분배수
                    Integer minDistCount = consulInfo.MinDistriNo__c == null ? 0 : Integer.valueOf(consulInfo.MinDistriNo__c);
    
                    // 남은 분배수 
                    Map<Id, String> assignedListByLeadSrc = assignedLogMap.get(groupId);
                    List<Id> assignedListByUser = new List<Id>();
                    for (Id usrId : assignedListByLeadSrc.values()) {
                        if (consulInfo.User__c == usrId) {
                            assignedListByUser.add(usrId);
                        }
                    }
                    system.debug('>>> assignedListByUser: ' + assignedListByUser);
                    
                    // 유저 별 할당할 개수
                    Integer cntAssign = 0;
                    
                    if (assignCountMap.containsKey(String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c))) {
                        cntAssign = assignCountMap.get(String.valueOf(grInfo.Id)+String.valueOf(consulInfo.User__c));
                    }
                    else {
                        system.debug('>>> assignCountMap not exist!! ');
                        cntAssign = assignedListByUser == null ? 0 : assignedListByUser.size();
                        assignCountMap.put(String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c), cntAssign);
                    }
                    system.debug('>>> assignCountMap: ' + assignCountMap);
                    
                    Integer cnt = 0;
                    // 남은 개수
                    Integer distCount = 0;
                    if (cntAssign < minDistCount) {
                        distCount = minDistCount - cntAssign;
                    }
                    system.debug('>>> 남은 할당: ' + distCount);

                    // 남은 최소분배수를 최소분배수에 따른 분배
                    if (distCount > 0) {
                        
                        // Lead
                        insLeadList.add(new Lead(
                            MobilePhone = data.MobilePhone__c,
                            LastName = data.Name__c,
                            RequestDateTime__c = Datetime.valueOf(data.RequestDateTime__c),
                            LeadSource__c = lsMap?.containsKey(data.LeadSource__c) ? lsMap.get(data.LeadSource__c) : null,
                            LeadSourceDetail__c = data.LeadSourceDetail__c,
                            ContractNumber__c = data.ContractNumber__c,
                            ProductName__c = data.ProductName__c,
                            Amount__c = data.Amount__c,
                            FullPaymentFlg__c = data.FullPaymentFlg__c,
                            RegisterName__c = data.RegisterName__c,
                            MembershipNumber__c = data.MembershipNumber__c,
                            ChildName__c = data.ChildName__c,
                            ChildSchoolYear__c = schoolYear,
                            ChildBirthday__c = String.isEmpty(data.ChildBirthday__c) ? null : Date.valueOf(data.ChildBirthday__c),
                            Street = data.Address1__c + ' ' + data.Address2__c,
                            PostalCode = data.PostalCode__c,
                            Requirement__c = data.Requirement__c,
                            Device__c = String.isNotEmpty(data.Device__c) ? deviceMap.get(data.Device__c) : null,
                            Channel__c = chMap?.containsKey(data.Channel__c) ? chMap.get(data.Channel__c) : null,
                            ProductService__c = psMap?.containsKey(data.ProductService__c) ? psMap.get(data.ProductService__c) : null,
                            Promotion_Freetrial__c = String.isNotEmpty(data.Promotion_Freetrial__c) ? pfMap.get(data.Promotion_Freetrial__c) : null,
                            Promotion_Join__c = String.isNotEmpty(data.Promotion_Join__c) ? pjMap.get(data.Promotion_Join__c) : null,
                            MediaCode__c = mcMap?.containsKey(data.MediaCode__c) ? mcMap.get(data.MediaCode__c) : null,
                            RequestStatusDetail__c = data.RequestStatusDetail__c,
                            LastAssign__c = consulInfo.User__c,
                            AssignDateTime__c = dtNow,
                            OwnerId = consulInfo.User__c
                        ));
    
                        // DB 유입 업데이트
                        updDbLogList.add(new DB_Log__c(
                            Id = data.Id,
                            Group__c = grInfo.Id,
                            AssignUser__c = consulInfo.User__c,
                            AssignDate__c = dtNow,
                            LastAssignUser__c = consulInfo.User__c,
                            LastAssignDate__c = dtNow
                        ));
    
                        // 분배 개수 카운트
                        cnt++;
                        
                        // 분배 기준 판단하기 위해 마지막 분배가 끝나면 map 데이터 삭제
                        if (remainMinDistMap.containsKey(String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c))) {
                            
                            if (distCount == 1) {
                                remainMinDistMap.remove(
                                    String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c)
                                );
                            }else {
                                remainMinDistMap.put(
                                    String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c), 
                                    remainMinDistMap.get(String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c))-1
                                );
                            }
                        }
    
                        if (assignCountMap.containsKey(String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c))) {
                            assignCountMap.put(
                                String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c), 
                                assignCountMap.get(String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c))+1
                            );
                        }
                        
                        system.debug('>>> assignCountMap22: ' + assignCountMap);
                    }
    
                    /** 교사그룹 데이터 업데이트(분배기준, 마지막 할당 교사, 추가할당) */
                    if(cnt > 0) {
                        Group__c updGroupInfo = grInfo;
    
                        updGroupInfo.Criteria__c = criteria;
                        updGroupInfo.LastAssign__c = String.valueOf(consulInfo.SortOrder__c);
                        updGroupInfo.Assigning__c = false;
    
                        if (updGroupList.contains(grInfo)) {
                            updGroupList.set(updGroupList.indexOf(grInfo), updGroupInfo);
                        }
                        else {
                            updGroupList.add(updGroupInfo);
                        }
    
                        break;
                    }

                    system.debug('>>> 상담교사 수: ' + consultants.size());
                    if(startNo == consultants.size()) {
                        startNo = 1;
                    }
                    else{
                        startNo++;
                    }
                }
                
            }
            else if (Label.CLS_Weight.equals(criteria)) {

                System.debug('>>> 가중치 IN');

                for (Integer j = 0; j < consultants.size(); j++) {
                    GroupDetail__c consulInfo = consultants[startNo - 1];

                    Decimal weight =  decimal.valueOf(consulInfo.WeightedValue__c);
                    WeightTurn__c turnInfo = turnByChannelMap.get(String.valueOf(grInfo.Id) + String.valueOf(consulInfo.User__c));
                    system.debug('>>> 가중치순번관리 정보: ' + turnInfo);

                    if (turnInfo != null) {
                        turnNo = turnInfo.EvenFlg__c ? 2 : 1;
                        turnNo++;
                    }
                    system.debug('>>> turnNo: ' + turnNo);
                    
                    // 분배 개수(홀수 번째 분배의 경우는 버림, 짝수 번째 분배의 경우 올림)
                    Integer distCount = 
                        Math.mod(turnNo, 2) == 0 ? 
                        Integer.valueOf(weight.round(System.RoundingMode.UP)) : 
                        Integer.valueOf(weight.round(System.RoundingMode.FLOOR));
                    
                    system.debug('>>> 분배 개수: ' + distCount);
                    system.debug('>>> 가중치: ' + weight);
                    
                    Integer cnt = 0;
                    if (distCount > 0) {
                        // Lead
                        insLeadList.add(new Lead(
                            MobilePhone = data.MobilePhone__c,
                            LastName = data.Name__c,
                            RequestDateTime__c = Datetime.valueOf(data.RequestDateTime__c),
                            LeadSource__c = lsMap?.containsKey(data.LeadSource__c) ? lsMap.get(data.LeadSource__c) : null,
                            LeadSourceDetail__c = data.LeadSourceDetail__c,
                            ContractNumber__c = data.ContractNumber__c,
                            ProductName__c = data.ProductName__c,
                            Amount__c = data.Amount__c,
                            FullPaymentFlg__c = data.FullPaymentFlg__c,
                            RegisterName__c = data.RegisterName__c,
                            MembershipNumber__c = data.MembershipNumber__c,
                            ChildName__c = data.ChildName__c,
                            ChildSchoolYear__c = schoolYear,
                            ChildBirthday__c = String.isEmpty(data.ChildBirthday__c) ? null : Date.valueOf(data.ChildBirthday__c),
                            Street = data.Address1__c + ' ' +data.Address2__c,
                            PostalCode = data.PostalCode__c,
                            Requirement__c = data.Requirement__c,
                            Device__c = String.isNotEmpty(data.Device__c) ? deviceMap.get(data.Device__c) : null,
                            Channel__c = chMap?.containsKey(data.Channel__c) ? chMap.get(data.Channel__c) : null,
                            ProductService__c = psMap?.containsKey(data.ProductService__c) ? psMap.get(data.ProductService__c) : null,
                            Promotion_Freetrial__c = String.isNotEmpty(data.Promotion_Freetrial__c) ? pfMap.get(data.Promotion_Freetrial__c) : null,
                            Promotion_Join__c = String.isNotEmpty(data.Promotion_Join__c) ? pjMap.get(data.Promotion_Join__c) : null,
                            MediaCode__c = mcMap?.containsKey(data.MediaCode__c) ? mcMap.get(data.MediaCode__c) : null,
                            RequestStatusDetail__c = data.RequestStatusDetail__c,
                            LastAssign__c = consulInfo.User__c,
                            AssignDateTime__c = dtNow,
                            OwnerId = consulInfo.User__c
                        ));

                        updDbLogList.add(new DB_Log__c(
                            Id = data.Id,
                            Group__c = grInfo.Id,
                            AssignUser__c = consulInfo.User__c,
                            AssignDate__c = dtNow,
                            LastAssignUser__c = consulInfo.User__c,
                            LastAssignDate__c = dtNow
                        ));
                        
                        cnt++;
                    }
                    
                    if (cnt > 0) {

                        // 교사그룹 정보 최신화
                        Group__c updGroupInfo = grInfo;
                        updGroupInfo.Criteria__c = criteria;
                        updGroupInfo.LastAssign__c = String.valueOf(consulInfo.SortOrder__c);
                        updGroupInfo.Assigning__c = grInfo.Assigning__c ? false : distCount - cnt > 0 ? true : false;

                        // 리스트에 동일한 교사 그룹이 존재할 경우, 정보 갱신
                        if (updGroupList.contains(grInfo)) {
                            updGroupList.set(updGroupList.indexOf(grInfo), updGroupInfo);
                        }
                        else {
                            updGroupList.add(updGroupInfo);
                        }

                        // 가중치 순번 정보 최신화
                        WeightTurn__c upsTurnInfo = turnInfo;
                        if (turnInfo != null && !upsWeightMap.containsKey(turnInfo.Id)) {
                            upsWeightMap.put(turnInfo.Id, turnInfo);
                        }else {
                            upsWeightList.add(new WeightTurn__c(
                                Id = turnInfo == null ? null : turnInfo.Id,
                                User__c = consulInfo.User__c,
                                Group__c = grInfo.Id,
                                EvenFlg__c = Math.mod(turnNo, 2) == 0 ? true : false
                            ));
                        }
                        
                        break;
                    }

                    // 다음에 분배할 상담교사 순번
                    startNo = (startNo == consultants.size()) ? 1 : startNo++;
                }

            } else {
                return;
            }       
        }

        Savepoint sp = Database.setSavepoint();

        try {
            // 알림처리 Dohun
            User admin = [SELECT Id FROM User WHERE Profile.name = '시스템 관리자' limit 1];
            CustomNotificationType notiType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'LeadNotification' limit 1];
            String title,body,formatDT;

            // 예비고객 레코드 생성
            system.debug('>>> 생성할 리드 수: ' + insLeadList.size());
            if(insLeadList?.size() > 0){                
                insert insLeadList;

                // 재진입 리드 UPDATE 이후 알림 처리
                for(Lead l : insLeadList){
                    formatDT = Utilities.transDateTimeFormat(l.RequestDateTime__c);
                    //targetUserIds.add(l.OwnerId);
                    Set<String> singleTargetUserId = new Set<String>{l.OwnerId};
                    title = '신규 예비고객 배정';
                    body = l.LastName+'님이 '+formatDT+ '에 신규로 배정되었습니다.';
                    UTIL_Notification.unCalloutNotiSend(notiType.Id, admin.Id, l.Id, title, body, singleTargetUserId);
                    
                }
            }

            // DB유입 update
            // db유입 > 할당교사, 할당시간, 그룹 정보 업데이트 
            system.debug('>>> DB유입 업데이트 레코드 수: ' + updDbLogList?.size());
            if(updDbLogList?.size() > 0){
                update updDbLogList;
            }
        } catch (Exception e) {
            Database.rollback(sp);
        }

    }


    /**
     * 분배 관련된 데이터 업데이트
     */
    public void finish(Database.BatchableContext dbc) {
        system.debug('>>> finish()');
        
        
        // 교사그룹 > 분배기준 업데이트(마지막 분배 교사 LastAssign__c, 추가할당 Assigning__c )
        if (updGroupList?.size() > 0) {
            update updGroupList;
            system.debug('>>> 교사그룹 update 수: ' + updGroupList.size());
        }
        
        // 가중치 순번 upsert
        if (upsWeightMap?.size() > 0 || upsWeightList?.size() > 0) {
            List<WeightTurn__c> upsList = new List<WeightTurn__c>();
            upsList.addAll(upsWeightMap.values());
            
            for (WeightTurn__c val : upsWeightList) {
                if (!upsWeightMap.containsKey(val.Id)) {
                    upsList.add(val);
                }
            }

            upsert upsList;
            system.debug('>>> 가중치순번관리 upsert 수: ' + upsList.size());
        }
    }
}