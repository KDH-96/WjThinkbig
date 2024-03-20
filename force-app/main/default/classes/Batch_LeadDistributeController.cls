/**
 * @description       : 
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-16-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
public class Batch_LeadDistributeController implements Database.Batchable<sObject>, Database.Stateful {

    // public Id lastAssignUser;
    // public Boolean assigningFlg = false;
    public List<Channel_Mgmt__c> updChannelList = new List<Channel_Mgmt__c>();
    public List<WeightTurn__c> upsWeightList = new List<WeightTurn__c>();
    public Map<Id, WeightTurn__c> upsWeightMap = new Map<Id, WeightTurn__c>();
/*     
    private String strQuery;
    
    public Batch_LeadDistributeController (String soql){
        strQuery = soql;
    } 
 */
    public Database.QueryLocator start(Database.BatchableContext dbc) {
        // 신규DB 데이터 취득
        // 채널 판단 분배 키 항목: 채널, 유입경로, 제품(서비스)
        String strQuery = 
            'SELECT Id, Name, MobilePhone__c, Name__c, RequestDateTime__c, Channel__c, LeadSource__c, LeadSourceDetail__c, ProductService__c, ChildBirthday__c, ChildName__c, AssignUser__c, AssignDate__c, fm_Codes__c, RequestStatusDetail__c, PostalCode__c, Address1__c, Address2__c, ' + 
            'ContractNumber__c, ProductName__c, Amount__c, RegisterName__c, ChildAge__c, Requirement__c, FullPaymentFlg__c, MembershipNumber__c, Device__c, Promotion_Freetrial__c, Promotion_Join__c, MediaCode__c ' + 
            'FROM DB_Log__c ' + 
            'WHERE AssignUser__c = null AND AssignDate__c = null AND RequestStatusDetail__c = \'New\' ' + 
            //'ORDER BY LastModifiedDate DESC LIMIT 3';
            'ORDER BY fm_Codes__c';

        return Database.getQueryLocator(strQuery);

    }
    
    public void execute(Database.BatchableContext dbc, List<DB_Log__c> importList) {
        system.debug('>>> importList:' + importList.size());
        
//         List<String> chList = new List<String>();
//         List<String> lsList = new List<String>();
//         List<String> psList = new List<String>();
//         List<String> pfList = new List<String>();
//         List<String> pjList = new List<String>();
//         List<String> deviceList = new List<String>();
//         List<String> mcList = new List<String>();
//         List<String> codesList = new List<String>();
//         Set<String> targetUserIds = new Set<String>();

//         for (DB_Log__c data : importList) {
//             // 채널
//             if (String.isNotEmpty(data.Channel__c) && !chList.contains(data.Channel__c)) {
//                 chList.add(data.Channel__c.trim());
//             }
//             // 유입경로
//             if (String.isNotEmpty(data.LeadSource__c) && !lsList.contains(data.LeadSource__c)) {
//                 lsList.add(data.LeadSource__c.trim());
//             }
//             // 제품(서비스)
//             if (String.isNotEmpty(data.ProductService__c) && !psList.contains(data.ProductService__c)) {
//                 psList.add(data.ProductService__c.trim());
//             }
//             // 디바이스
//             if (String.isNotEmpty(data.Device__c) && !deviceList.contains(data.Device__c)) {
//                 deviceList.add(data.Device__c.trim());
//             }
//             // 무체프로모션
//             if (String.isNotEmpty(data.Promotion_Freetrial__c) && !pfList.contains(data.Promotion_Freetrial__c)) {
//                 pfList.add(data.Promotion_Freetrial__c.trim());
//             }
//             // 가입프로모션
//             if (String.isNotEmpty(data.Promotion_Join__c) && !pjList.contains(data.Promotion_Join__c)) {
//                 pjList.add(data.Promotion_Join__c.trim());
//             }
//             // 미디어코드
//             if (String.isNotEmpty(data.MediaCode__c) && !mcList.contains(data.MediaCode__c)) {
//                 mcList.add(data.MediaCode__c.trim());
//             }
//             if (String.isNotEmpty(data.fm_Codes__c) && !codesList.contains(data.fm_Codes__c)) {
//                 codesList.add(data.fm_Codes__c);
//             }
//         }
        
//         system.debug('>>> lsList: ' + lsList);
//         system.debug('>>> psList: ' + psList);
//         system.debug('>>> codesList: ' + codesList);

//         //디바이스
//         List<Device__c> deviceCodeList = new List<Device__c>([
//             SELECT Id, Name, Code__c
//             FROM Device__c
//             WHERE Code__c IN :deviceList
//         ]);
//         Map<String,Id> deviceMap = new Map<String,Id>();
//         for (Device__c d : deviceCodeList) {
//             deviceMap.put(d.Code__c, d.Id);
//         }
//         system.debug('>>> deviceMap: ' + deviceMap);

//         //무체프로모션
//         List<Promotion_Freetrial__c> pfCodeList = new List<Promotion_Freetrial__c>([
//             SELECT Id, Name, Code__c
//             FROM Promotion_Freetrial__c
//             WHERE Code__c IN :pfList
//         ]);
//         Map<String,Id> pfMap = new Map<String,Id>();
//         for (Promotion_Freetrial__c pf : pfCodeList) {
//             pfMap.put(pf.Code__c, pf.Id);
//         }
//         system.debug('>>> pfMap: ' + pfMap);

//         //가입프로모션
//         List<Promotion_Join__c> pjCodeList = new List<Promotion_Join__c>([
//             SELECT Id, Name, Code__c
//             FROM Promotion_Join__c
//             WHERE Code__c IN :pjList
//         ]);
//         Map<String,Id> pjMap = new Map<String,Id>();
//         for (Promotion_Join__c pj : pjCodeList) {
//             pjMap.put(pj.Code__c, pj.Id);
//         }
//         system.debug('>>> pjMap: ' + pjMap);

//         //미디어코드
//         List<MediaCode__c> mideaCodeList = new List<MediaCode__c>([
//             SELECT Id, Name, Code__c
//             FROM MediaCode__c
//             WHERE Code__c IN :mcList
//         ]);
//         Map<String,Id> mideaCodeMap = new Map<String,Id>();
//         for (MediaCode__c mc : mideaCodeList) {
//             mideaCodeMap.put(mc.Code__c, mc.Id);
//         }

        
//         // 할당교사 및 이벤트 별 할당된 리드 수 카운트
//         Map<Id, DB_Log__c> assignedLeads = new Map<Id, DB_Log__c>([
//             SELECT Id, AssignUser__c, fm_Codes__c  
//             FROM DB_Log__c 
//             WHERE fm_Codes__c IN :codesList AND AssignUser__c <> null
//         ]);
        
        
//         Map<String, Map<Id, Id>> assignedByEventMap = new Map<String, Map<Id, Id>>();
//         Map<String, List<DB_Log__c>> toUploadMap = new Map<String, List<DB_Log__c>>();
        

//         for (String codes : codesList) {

//             // 이벤트 및 상담교사 별 map (할당된 개수 알아내기 위함) 
//             // Map<LogRecordId, 할당교사Id>
//             Map<Id, Id> assignedInfoMap = new Map<Id, Id>();
//             for (DB_Log__c log : assignedLeads.values()) {
//                 if (log.fm_Codes__c == codes) {
//                     assignedInfoMap.put(log.Id , log.AssignUser__c);
//                 }
//             }
            
//             // Map<코드조합, Map<LogRecordId, 할당교사Id>>
//             assignedByEventMap.put(codes, assignedInfoMap);

//             // 코드별 분류
//             List<DB_Log__c> toUploadList = new List<DB_Log__c>();
//             for (DB_Log__c data : importList) {
                
//                 if (data.fm_Codes__c != null && data.fm_Codes__c == codes) {
//                     toUploadList.add(data);
//                 }
//             }
//             toUploadMap.put(codes, toUploadList);
//         }
        
//         // 채널관리 데이터 취득
//         Map<Id, Channel_Mgmt__c> channelMap = new Map<Id, Channel_Mgmt__c>([
//             SELECT 
//                 Id, Group__c, Group__r.Id, Criteria__c, LastAssign__c, Assigning__c, fm_Codes__c, 
//                 Channel__r.Id, Channel__r.Code__c,
//                 LeadSource__r.Id, LeadSource__r.Code__c, 
//                 ProductService__r.Id, ProductService__r.Code__c,
//                 Device__r.Id, Device__r.Code__c,
//                 Promotion_Freetrial__r.Id, Promotion_Freetrial__r.Code__c,
//                 Promotion_Join__r.Id, Promotion_Join__r.Code__c
//             FROM Channel_Mgmt__c 
//             WHERE fm_Codes__c IN :codesList
//         ]);
        
//         // 가중치 순번 데이터 취득
//         Map<Id, WeightTurn__c> qrWeightTurnMap = new Map<Id, WeightTurn__c>([
//             SELECT 
//                 Id, User__c, EvenFlg__c, fm_Codes__c,
//                 Channel__r.Id, Channel__r.Code__c,
//                 LeadSource__r.Id, LeadSource__r.Code__c, 
//                 ProductService__r.Id, ProductService__r.Code__c
//             FROM WeightTurn__c 
//             WHERE Channel__r.Code__c IN :chList AND LeadSource__r.Code__c IN :lsList AND ProductService__r.Code__c IN :psList 
//             ORDER BY fm_Codes__c, CreatedDate DESC
//         ]);
        
//         Map<String, WeightTurn__c> turnByChannelMap = new Map<String, WeightTurn__c>();
//         for (WeightTurn__c turn : qrWeightTurnMap.values()) {
//             turnByChannelMap.put(turn.fm_Codes__c + turn.User__c, turn);
//         }
        
//         system.debug('>>> channelMap: ' + channelMap);
        
//         // 채널&유입경로&제품(서비스) 코드가 동일한 채널이 존재할 경우, 수정일자가 최근인 채널의 ID 추출
//         Set<Id> groupIds = new Set<Id>();
//         List<String> tgtGroupList = new List<String>();
//         for (Channel_Mgmt__c channel : channelMap.values()) {
//             if (!tgtGroupList?.contains(channel.fm_Codes__c)) {
//                 groupIds.add(channel.Group__c);
//             }
//         }
//         system.debug('>>> channelMap.values(): ' + channelMap.values());
//         Map<String, String> groupMap = new Map<String, String>();
//         for (Channel_Mgmt__c ch : channelMap.values()) {
//             groupMap.put(ch.Channel__r.Code__c+ch.LeadSource__r.Code__c+ch.ProductService__r.Code__c, ch.Group__c);
//         }
//         system.debug('>>> groupMap: ' + groupMap);

//         // 교사그룹 상세항목 데이터 취득
//         List<GroupDetail__c> groupDetailList = new List<GroupDetail__c>([
//             SELECT Id, Name, SortOrder__c, WeightedValue__c, Group__c, User__c, MinDistriNo__c
//             FROM GroupDetail__c 
//             WHERE Group__c IN :groupMap.values()
//             ORDER BY SortOrder__c
//         ]);
//         System.debug('groupDetailList >> '+groupDetailList);
//         System.debug('groupId >> ' + groupIds);
//         // 교사그룹별 교사목록 취득
//         Map<Id, List<GroupDetail__c>> consulMap = new Map<Id, List<GroupDetail__c>>();
//         for (Id groupId : groupIds) {
//             List<GroupDetail__c> consulList = new List<GroupDetail__c>();
//             for (GroupDetail__c detail : groupDetailList) {
//                 if (groupId == detail.Group__c) {
//                     consulList.add(detail);
//                 }
//             }
//             consulMap.put(groupId, consulList);
//         }
        
//         system.debug('>>> consulMap: ' + consulMap);
        
//         // 유저별 남은 최소분배수 추출하여 map 에 담기
//         Map<String, Integer> remainMinDistMap = new Map<String, Integer>();
//         for (String codes : codesList) {
//             List<GroupDetail__c> consultants = consulMap.get(groupMap.get(codes));
//             Map<Id, Id> assignedListByEvent = assignedByEventMap.get(codes);
//             System.debug('>>> consultants:' + consultants);
//             if (consultants?.size() > 0) {
//                 for (GroupDetail__c consulInfo : consultants) {

//                     // 최소 분배수
//                     Integer minDist = consulInfo.MinDistriNo__c == null ? 0 : Integer.valueOf(consulInfo.MinDistriNo__c);

//                     System.debug('>>> minDist:' + minDist);
//                     // 상담교사에게 할당된 db
//                     List<Id> assignedList = new List<Id>();
//                     for (Id usrId : assignedListByEvent.values()) {
//                         if (consulInfo.User__c == usrId) {
//                             assignedList.add(usrId);
//                         }
//                     }
//                     Integer cntAssigned = assignedList?.size();
                    
//                     System.debug('>>> cntAssigned:' + cntAssigned);
    
//                     if (minDist > cntAssigned) {
//                         remainMinDistMap.put(codes + consulInfo.User__c, minDist-cntAssigned);
//                     }
//                 }
//             }

//             System.debug('>>> remainMinDistMap:' +remainMinDistMap);
//         }


        
//         List<Lead> insLeadList = new List<Lead>();
//         List<DB_Log__c> updDbLogList = new List<DB_Log__c>();
//         Map<String, Integer> assignCountMap = new Map<String, Integer>();

//         /* 분배 시작 */ 
//         for (DB_Log__c data : importList) {
//             system.debug('=========================== ');
            
//             String groupId = groupMap.get(data.fm_Codes__c);
//             if (String.isEmpty(groupId)) {
//                 continue;
//             }
            
//             // 채널관리 정보 취득
//             Channel_Mgmt__c channelInfo;
//             for (Channel_Mgmt__c channel : channelMap.values()) {
//                 system.debug('>>> channel.Group__c: ' + channel.Group__c);
//                 system.debug('>>> groupId: ' + groupId);
                
//                 if (groupId == channel.Group__c) {
//                     channelInfo = channel;
//                 }
//             }

//             system.debug('>>> channelInfo: ' + channelInfo);
//             if (channelInfo == null) {
//                 continue;
//             }

//             /* 분배를 시작할 교사 추출 */
//             Integer startNo = 1;
//             List<GroupDetail__c> consultants = new List<GroupDetail__c>(consulMap.get(groupId));
//             for(GroupDetail__c gd : consultants) {
                
//                 if (updChannelList.contains(channelInfo) && 
//                     String.valueOf(gd.SortOrder__c) == updChannelList.get(updChannelList.indexOf(channelInfo)).LastAssign__c) {
                    
//                     startNo = (consultants.indexOf(gd)) + 1;
//                     break;

//                 }else {
//                     if(String.isNotEmpty(channelInfo.LastAssign__c) && 
//                         String.valueOf(gd.SortOrder__c) == channelInfo.LastAssign__c) {

//                         startNo = (consultants.indexOf(gd)) + 1;
//                         break;
//                     }
//                 }
//             }

//             system.debug('>>> channelInfo.Assigning__c: ' + channelInfo.Assigning__c);
//             if(String.isNotEmpty(channelInfo.LastAssign__c) && !channelInfo.Assigning__c) {
//                 startNo++;
//                 if(startNo > consultants.size()) {
//                     startNo = 1;
//                 }
//             }

//             system.debug('>>> ---------------- ');
//             system.debug('>>> startNo: ' + startNo);

            
//             Integer turnNo = 1;
//             // Map<String, Integer> assignCountMap = new Map<String, Integer>();
//             Map<String, Integer> distCountMap = new Map<String, Integer>();
            
//             Datetime dtNow = DateTime.now();


//             /* 최소분배수를 다 채웠을 경우, 가중치를 기준으로 분배 */
//             String criteria = channelInfo.Criteria__c;
//             if (remainMinDistMap?.size() <= 0) {
//                 criteria = '가중치';
//             }
//             System.debug('>>> criteria' + criteria);

//             // 자녀 학년
//             String schoolYear;
//             if (String.isNotEmpty(data.ChildAge__c)) {
//                 schoolYear = data.ChildAge__c;
//                 if (Integer.valueOf(schoolYear) > 16) {
//                     schoolYear = '기타';
//                 }
//             }


//             if (criteria == '최소분배수') {

//                 for (Integer j = 0; j < consultants.size(); j++) {
                    
//                     System.debug('>>> 최소분배수 IN');
//                     System.debug('>>> startNo' + startNo);
//                     GroupDetail__c consulInfo = consultants[startNo-1];
//                     system.debug('>>> consulInfo: ' + consulInfo);
    
                    
//                     // 최수분배수
//                     Integer minDistCount = consulInfo.MinDistriNo__c == null ? 0 : Integer.valueOf(consulInfo.MinDistriNo__c);
    
//                     // 남은 분배수 
//                     Map<Id, Id> assignedListByEvent = assignedByEventMap.get(data.fm_Codes__c);
//                     List<Id> assignedListByUser = new List<Id>();
//                     for (Id usrId : assignedListByEvent.values()) {
//                         if (consulInfo.User__c == usrId) {
//                             assignedListByUser.add(usrId);
//                         }
//                     }
                    
//                     system.debug('>>> assignedListByUser: ' + assignedListByUser);
                    
//                     Integer cntAssign = 0;
                    
//                     if (assignCountMap.containsKey(data.fm_Codes__c + consulInfo.User__c)) {
//                         system.debug('>>> assignCountMap exist!! ');
//                         cntAssign = assignCountMap.get(data.fm_Codes__c+consulInfo.User__c);
//                     }
//                     else {
//                         system.debug('>>> assignCountMap not exist!! ');
//                         cntAssign = assignedListByUser == null ? 0 : assignedListByUser.size();
//                         system.debug('>>> cntAssign: ' + cntAssign);
//                         assignCountMap.put(data.fm_Codes__c + consulInfo.User__c, cntAssign);
//                     }
//                     system.debug('>>> assignCountMap: ' + assignCountMap);
                    
//                     Integer cnt = 0;
//                     Integer distCount = 0;
//                     system.debug('>>> minDistCount: ' + minDistCount);
//                     if (cntAssign < minDistCount) {
//                         distCount = minDistCount - cntAssign;
//                     }
//                     system.debug('>>> distCount: ' + distCount);
                    
//                     // 최소 분배수로 분배
//                     if (distCount > 0) {
                        
//                         // Lead
//                         insLeadList.add(new Lead(
//                             MobilePhone = data.MobilePhone__c,
//                             LastName = data.Name__c,
//                             RequestDateTime__c = Datetime.valueOf(data.RequestDateTime__c),
//                             LeadSource__c = channelInfo.LeadSource__r.Id,
//                             LeadSourceDetail__c = data.LeadSourceDetail__c,
//                             ContractNumber__c = data.ContractNumber__c,
//                             ProductName__c = data.ProductName__c,
//                             Amount__c = data.Amount__c,
//                             FullPaymentFlg__c = data.FullPaymentFlg__c,
//                             RegisterName__c = data.RegisterName__c,
//                             MembershipNumber__c = data.MembershipNumber__c,
//                             ChildName__c = data.ChildName__c,
//                             ChildSchoolYear__c = schoolYear,
//                             ChildBirthday__c = String.isEmpty(data.ChildBirthday__c) ? null : Date.valueOf(data.ChildBirthday__c),
//                             Street = data.Address1__c + ' ' + data.Address2__c,
//                             PostalCode = data.PostalCode__c,
//                             Requirement__c = data.Requirement__c,
//                             Device__c = String.isNotEmpty(data.Device__c) ? deviceMap.get(data.Device__c) : null,
//                             Channel__c = channelInfo.Channel__r.Id,
//                             ProductService__c = channelInfo.ProductService__r.Id,
//                             Promotion_Freetrial__c = String.isNotEmpty(data.Promotion_Freetrial__c) ? pfMap.get(data.Promotion_Freetrial__c) : null,
//                             Promotion_Join__c = String.isNotEmpty(data.Promotion_Join__c) ? pjMap.get(data.Promotion_Join__c) : null,
//                             MediaCode__c = mideaCodeMap?.containsKey(data.MediaCode__c) ? mideaCodeMap.get(data.MediaCode__c) : null,
//                             RequestStatusDetail__c = data.RequestStatusDetail__c,
//                             LastAssign__c = consulInfo.User__c,
//                             AssignDateTime__c = dtNow,
//                             OwnerId = consulInfo.User__c
//                         ));
    
//                         // DB 유입
//                         updDbLogList.add(new DB_Log__c(
//                             Id = data.Id,
//                             AssignUser__c = consulInfo.User__c,
//                             AssignDate__c = dtNow,
//                             LastAssignUser__c = consulInfo.User__c,
//                             LastAssignDate__c = dtNow
//                         ));
    
//                         // 분배 개수 카운트
//                         cnt++;
                        
//                         /* 분배 기준 판단하기 위해 마지막 분배가 끝나면 map 데이터 삭제 */
//                         if (remainMinDistMap.containsKey(data.fm_Codes__c + consulInfo.User__c)) {
                            
//                             if (distCount == 1) {
//                                 remainMinDistMap.remove(data.fm_Codes__c + consulInfo.User__c);
//                             }else {
//                                 remainMinDistMap.put(data.fm_Codes__c + consulInfo.User__c, remainMinDistMap.get(data.fm_Codes__c + consulInfo.User__c)-1);
//                             }
//                         }
//                         system.debug('>>> remainMinDistMap22: ' + remainMinDistMap);
                        
    
//                         if (assignCountMap.containsKey(data.fm_Codes__c + consulInfo.User__c)) {
//                             assignCountMap.put(data.fm_Codes__c + consulInfo.User__c, assignCountMap.get(data.fm_Codes__c + consulInfo.User__c)+1);
//                         }
                        
//                         system.debug('>>> assignCountMap22: ' + assignCountMap);
//                     }
    
//                     if(cnt > 0) {
//                         Channel_Mgmt__c updChannelInfo = channelInfo;
    
//                         updChannelInfo.Criteria__c = criteria;
//                         updChannelInfo.LastAssign__c = String.valueOf(consulInfo.SortOrder__c);
//                         updChannelInfo.Assigning__c = false;
    
//                         if (updChannelList.contains(channelInfo)) {
//                             updChannelList.set(updChannelList.indexOf(channelInfo), updChannelInfo);
//                         }
//                         else {
//                             updChannelList.add(updChannelInfo);
//                         }
    
//                         break;
//                     }

//                     system.debug('>>> consultants.size(): ' + consultants.size());
//                     if(startNo == consultants.size()) {
//                         startNo = 1;
//                         system.debug('======== turnNo: ' + turnNo + '===========');
//                     }
//                     else{
//                         startNo++;
//                     }
//                 }
                
//             }
//             else if (criteria == '가중치') {

//                 System.debug('>>> 가중치 IN');

//                 for (Integer j = 0; j < consultants.size(); j++) {
//                     system.debug('>>> startNo - 1: ' + (startNo - 1));
//                     system.debug('>>> consultants.size(): ' + consultants.size());
                    
//                     GroupDetail__c consulInfo = consultants[startNo - 1];

//                     Decimal weight =  decimal.valueOf(consulInfo.WeightedValue__c);
//                     WeightTurn__c turnInfo = turnByChannelMap.get(data.fm_Codes__c + consulInfo.User__c);
//                     system.debug('>>> turnInfo: ' + turnInfo);

//                     if (turnInfo != null) {
//                         turnNo = turnInfo.EvenFlg__c ? 2 : 1;
//                         turnNo++;
//                     }
                    
//                     system.debug('>>> turnNo: ' + turnNo);
//                     Integer distCount = 
//                         Math.mod(turnNo, 2) == 0 ? 
//                         Integer.valueOf(weight.round(System.RoundingMode.UP)) : 
//                         Integer.valueOf(weight.round(System.RoundingMode.FLOOR));
                    
//                     system.debug('>>> distCount: ' + distCount);
//                     system.debug('>>> consulInfo: ' + consulInfo);
//                     system.debug('>>> weight: ' + weight);
                    
//                     Integer cnt = 0;
//                     if (distCount > 0) {
//                         // Lead
//                         insLeadList.add(new Lead(
//                             MobilePhone = data.MobilePhone__c,
//                             LastName = data.Name__c,
//                             RequestDateTime__c = Datetime.valueOf(data.RequestDateTime__c),
//                             LeadSource__c = channelInfo.LeadSource__r.Id,
//                             LeadSourceDetail__c = data.LeadSourceDetail__c,
//                             ContractNumber__c = data.ContractNumber__c,
//                             ProductName__c = data.ProductName__c,
//                             Amount__c = data.Amount__c,
//                             FullPaymentFlg__c = data.FullPaymentFlg__c,
//                             RegisterName__c = data.RegisterName__c,
//                             MembershipNumber__c = data.MembershipNumber__c,
//                             ChildName__c = data.ChildName__c,
//                             ChildSchoolYear__c = schoolYear,
//                             ChildBirthday__c = String.isEmpty(data.ChildBirthday__c) ? null : Date.valueOf(data.ChildBirthday__c),
//                             Street = data.Address1__c + ' ' +data.Address2__c,
//                             PostalCode = data.PostalCode__c,
//                             Requirement__c = data.Requirement__c,
//                             Device__c = String.isNotEmpty(data.Device__c) ? deviceMap.get(data.Device__c) : null,
//                             Channel__c = channelInfo.Channel__r.Id,
//                             ProductService__c = channelInfo.ProductService__r.Id,
//                             Promotion_Freetrial__c = String.isNotEmpty(data.Promotion_Freetrial__c) ? pfMap.get(data.Promotion_Freetrial__c) : null,
//                             Promotion_Join__c = String.isNotEmpty(data.Promotion_Join__c) ? pjMap.get(data.Promotion_Join__c) : null,
//                             MediaCode__c = mideaCodeMap?.containsKey(data.MediaCode__c) ? mideaCodeMap.get(data.MediaCode__c) : null,
//                             RequestStatusDetail__c = data.RequestStatusDetail__c,
//                             LastAssign__c = consulInfo.User__c,
//                             AssignDateTime__c = dtNow,
//                             OwnerId = consulInfo.User__c
//                         ));

//                         updDbLogList.add(new DB_Log__c(
//                             Id = data.Id,
//                             AssignUser__c = consulInfo.User__c,
//                             AssignDate__c = dtNow,
//                             LastAssignUser__c = consulInfo.User__c,
//                             LastAssignDate__c = dtNow
//                         ));
                        
//                         cnt++;
//                     }
                    

                    
//                     if (cnt > 0) {

//                         // 채널관리 업데이트
//                         Channel_Mgmt__c updChannelInfo = channelInfo;

//                         updChannelInfo.Criteria__c = criteria;
//                         updChannelInfo.LastAssign__c = String.valueOf(consulInfo.SortOrder__c);
//                         if(channelInfo.Assigning__c) {
//                             updChannelInfo.Assigning__c = false;
//                         }
//                         else {
//                             updChannelInfo.Assigning__c = distCount - cnt > 0 ? true : false;
//                         }

//                         if (updChannelList.contains(channelInfo)) {
//                             updChannelList.set(updChannelList.indexOf(channelInfo), updChannelInfo);
//                         }
//                         else {
//                             updChannelList.add(updChannelInfo);
//                         }

                        
//                         // 가중치 순번 update
//                         WeightTurn__c upsTurnInfo = turnInfo;
//                         if (turnInfo != null && !upsWeightMap.containsKey(turnInfo.Id)) {
//                             upsWeightMap.put(turnInfo.Id, turnInfo);

//                         }else {
//                             upsWeightList.add(new WeightTurn__c(
//                                 Id = turnInfo == null ? null : turnInfo.Id,
//                                 User__c = consulInfo.User__c,
//                                 Channel__c = channelInfo.Channel__r.Id,
//                                 LeadSource__c = channelInfo.LeadSource__r.Id,
//                                 ProductService__c = channelInfo.ProductService__r.Id,
//                                 // Channel_Mgmt__c = channelInfo.Id,
//                                 EvenFlg__c = Math.mod(turnNo, 2) == 0 ? true : false
//                             ));

//                         }
                        
//                         break;
//                     }
                    
//                     system.debug('>>> consultants.size(): ' + consultants.size());
//                     system.debug('>>> startNo: ' + startNo);
//                     if(startNo == consultants.size()) {
//                         startNo = 1;

//                         system.debug('======== turnNo: ' + turnNo + '===========');
//                     }
//                     else{
//                         startNo++;
//                     }
//                     system.debug('>>> startNo: ' + startNo);
//                 }

//             } else {
//                 return;
//             }            
//         }

        
//         Savepoint sp = Database.setSavepoint();

//         try {
//             // 알림처리 Dohun
//             User admin = [SELECT Id FROM User WHERE Profile.name = '시스템 관리자' limit 1];
//             CustomNotificationType notiType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'LeadNotification' limit 1];
//             String title,body,formatDT;

// /* 
//             /////// feed tracking(신규인입 히스토리) 등록 2024-02-14 시작//////
//             Set<String> dbLeadSourceSet = new Set<String>();
//             Map<String,LeadSource__c> LeadSourceMap = new Map<String,LeadSource__c>();
//             List<FeedTracking__c> feedInsertList = new List<FeedTracking__c>();
            
//             for (DB_Log__c data : importList) {
//                 if(data.LeadSource__c!=null) dbLeadSourceSet.add(data.LeadSource__c);
//             }
//             List<LeadSource__c> LeadSourceList = new List<LeadSource__c>([SELECT Id, Name, Code__c FROM LeadSource__c WHERE Code__c IN :dbLeadSourceSet]);

//             for(LeadSource__c ls : LeadSourceList){
//                 LeadSourceMap.put(ls.Id,ls);
//             }
            
//             /////// feed tracking(신규인입 히스토리) 등록 2024-02-14 끝//////
//  */
//             // lead insert
//             system.debug('>>> insLeadList: ' + insLeadList.size());
//             if(insLeadList?.size() > 0){                
//                 insert insLeadList;

//                 // 재진입 리드 UPDATE 이후 알림 처리
//                 for(Lead l : insLeadList){
//                     formatDT = Utilities.transDateTimeFormat(l.RequestDateTime__c);
//                     //targetUserIds.add(l.OwnerId);
//                     Set<String> singleTargetUserId = new Set<String>{l.OwnerId};
//                     title = '신규 예비고객 배정';
//                     body = l.LastName+'님이 '+formatDT+ '에 신규로 배정되었습니다.';
//                     UTIL_Notification.unCalloutNotiSend(notiType.Id, admin.Id, l.Id, title, body, singleTargetUserId);
                    
//                 }
// /*                 
//                 /////// feed tracking(신규인입 히스토리) 등록 2024-02-14 시작//////
//                     FeedTracking__c feed = new FeedTracking__c();
//                     feed.Lead__c = l.Id;
//                     feed.ReAssign__c = '재인입';
//                     feed.LeadSource__c = LeadSourceMap.get(l.LeadSource__c).Name;
//                     feedInsertList.add(feed);
//                     System.debug('feedInsertList >> '+ feedInsertList);
                
//                 if(feedInsertList?.size()>0){
//                     INSERT feedInsertList;
//                 }
//                 /////// feed tracking(신규인입 히스토리) 등록 2024-02-14 끝//////
//                  */
                
//             }
            
//             ///////////////////////////////////////////////////////////////////////

//             // db유입 update
//             // db유입 > 할당교사 AssignUser, 할당시간 업데이트 AssignDate
//             system.debug('>>> updDbLogList: ' + updDbLogList.size());
//             if(updDbLogList?.size() > 0){
//                 update updDbLogList;
//             }
//         } catch (Exception e) {
//             Database.rollback(sp);
//         }
        
    }

    public void finish(Database.BatchableContext dbc) {
        system.debug('>>> finish()');
        
        // 채널관리 > 분배기준 업데이트(마지막 분배 교사 LastAssign__c, 추가할당 Assigning__c )
        // if (updChannelList?.size() > 0) {
        //     update updChannelList;
            
        // }
        
        // // 가중치 순번 upsert
        // if (upsWeightMap?.size() > 0) {
        //     List<WeightTurn__c> upsList = new List<WeightTurn__c>();
        //     for (WeightTurn__c val : upsWeightMap.values()) {
        //         upsList.add(val);
        //     }

        //     upsert upsList;
        // }
    }

}