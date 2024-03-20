public with sharing class loadDeliveryInfos {
    
    public loadDeliveryInfos(ApexPages.StandardController controller){
    }
        
    // 배치용
    public static DeliveryInfo__c loadDelivInfos(DeliveryInfo__c di, Opportunity opp){
        system.debug(di);
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://www.hanjin.com/kor/CMS/DeliveryMgr/WaybillResult.do?mCode=MN038&schLang=KR&wblnumText2=' + di.DeliveryNumber__c);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');

        HttpResponse res = http.send(req);
        
        //system.debug(res);
        //system.debug(res.getBody());
        if(res.getBody().contains('Information')){ // 송장번호로 조회되는 정보가 없는 경우
            
        }else{
            
            String delivNum,delivDateTime,delivStatus,delivLocation;
            String sjData,sjNum,delivDate1,delivTime1,delivLoc;
            Boolean isDeliv = false;
            List<String> delivDate = new List<String>();
            List<String> insertDate = new List<String>();
            List<String> delivTime = new List<String>();
            List<String> insertTime = new List<String>();

            if(Test.isRunningTest()){
                sjNum = di.DeliveryNumber__c;
                insertDate.add(String.valueOf(Date.today().year()));
                insertDate.add(String.valueOf(Date.today().month()));
                insertDate.add(String.valueOf(Date.today().day()));
                delivTime1 = DateTime.now().format();
                insertTime.add(String.valueOf(Date.today().year()));
                insertTime.add(String.valueOf(Date.today().month()));
                insertTime.add(String.valueOf(Date.today().day()));
                insertTime.add('08');
                insertTime.add('45');
                delivLoc = '서울';
                if(di.DeliveryNumber__c == '534432484556' || di.DeliveryNumber__c == '537732484556'){
                    delivDate.add('1');
                    delivDate.add('2');
                } else if(di.DeliveryNumber__c == '535532484556' || di.DeliveryNumber__c == '536632484556'){
                    delivDate.add('1');
                    delivDate.add('2');
                    delivDate.add('3');
                    delivDate.add('4');
                }else {
                    isDeliv = true;
                }
                
            }else{
                sjData = res.getBody().split('songjang-num')[1];
                // 운송장번호
                sjNum = sjData.split('delivery-time')[0].split('"num">')[1].split('<')[0];
                // 배송날짜, 입력용
                delivDate = sjData.split('waybill-tbl')[1].split('w-date">');
                delivDate1 = delivDate[delivDate.size() - 1].split('</td>')[0];
                insertDate = delivDate1.split('-');
                // 배송시간, 입력용
                delivTime = sjData.split('waybill-tbl')[1].split('w-time">');
                delivTime1 = delivTime[delivTime.size() - 1].split('</td>')[0];
                insertTime = delivTime1.split(':');
                // 배송지
                delivLoc = sjData.split('"gap"')[1].split('주소">')[1].split('<')[0];
                // 배송완료여부
                isDeliv = res.getBody().contains('배송완료');
            }

            System.debug(sjNum);
            System.debug(delivDate1);
            System.debug(delivTime1);
            System.debug(delivLoc);
            System.debug(isDeliv);
            
            //        DeliveryInfo__c a = [select ID, DeliveryStatus__c, DeliveryDateTime__c, DeliveryLocation__c, DeliveryNumber__c from DeliveryInfo__c where DeliveryNumber__c =: deliv_num limit 1];
            if(isDeliv){
                if(opp.ReEntryDateTime__c == null && (opp.StageName == '배송중' || opp.StageName == '배송 준비' || opp.StageName == '무료체험 전환') && di.DeliveryStatus__c != '배송완료' && di.Category__c == '패드 발송'){
                    di.DeliveryStatus__c = '배송완료';
                    di.DeliveryCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    di.DelivBatchNotiTarget__c = true;
                }else if(opp.ReEntryDateTime__c == null && opp.StageName == '체험진행중' && di.DeliveryStatus__c != '기기회수완료' && di.Category__c == '패드 회수'){
                    di.DeliveryStatus__c = '기기회수완료';
                    di.DeliveryCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    di.ReturnCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    di.DelivBatchNotiTarget__c = true;
                }
                // 재인입
                if(opp.ReEntryDateTime__c != null && di.Category__c == '패드 발송'){
                    di.DeliveryStatus__c = '배송완료';
                    di.DeliveryCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    di.DelivBatchNotiTarget__c = true;
                }else if(opp.ReEntryDateTime__c != null && di.Category__c == '패드 회수'){
                    di.DeliveryStatus__c = '기기회수완료';
                    di.DeliveryCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    di.ReturnCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    di.DelivBatchNotiTarget__c = true;
                }
            }else{
                if(delivDate.size() > 1){
                    if(delivDate.size() == 2){
                        if(opp.ReEntryDateTime__c == null && (opp.StageName == '무료체험 전환' || opp.StageName == '배송 준비') && di.Category__c == '패드 발송'){
                            di.DeliveryStatus__c = '배송준비';
                        }else if(opp.ReEntryDateTime__c == null && opp.StageName == '체험진행중' && di.Category__c == '패드 회수'){
                            di.DeliveryStatus__c = '기기회수중';
                        }
                        // 재인입
                        if(opp.ReEntryDateTime__c != null && di.Category__c == '패드 발송'){
                            di.DeliveryStatus__c = '배송준비';
                        }else if(opp.ReEntryDateTime__c != null && di.Category__c == '패드 회수'){
                            di.DeliveryStatus__c = '기기회수중';
                        }
                    }else{
                        if(opp.ReEntryDateTime__c == null && (opp.StageName == '배송 준비' || opp.StageName == '무료체험 전환') && di.Category__c == '패드 발송'){
                            di.DeliveryStatus__c = '배송중';
                        }else if(opp.ReEntryDateTime__c == null && opp.StageName == '체험진행중' && di.Category__c == '패드 회수'){
                            di.DeliveryStatus__c = '기기회수중';
                        }
                        // 재인입
                        if(opp.ReEntryDateTime__c != null && di.Category__c == '패드 발송'){
                            di.DeliveryStatus__c = '배송중';
                        }else if(opp.ReEntryDateTime__c != null && di.Category__c == '패드 회수'){
                            di.DeliveryStatus__c = '기기회수중';
                        }
                    }
                }
            }
            di.DeliveryDateTime__c = DateTime.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]),Integer.valueOf(insertTime[0]),Integer.valueOf(insertTime[1]),00);
            di.DeliveryLocation__c = delivLoc;
            di.oppTarget__c = true;
            
        }
        
        return di;

    }

    // 실시간 조회 및 업데이트 버튼용
    @RemoteAction
    public static void loadDelivInfos(String deliv_id){
        DeliveryInfo__c di = [SELECT Id, DeliveryStatus__c, DeliveryDateTime__c, DeliveryLocation__c, DeliveryNumber__c, OpportunityId__c, oppTarget__c, 
                              Name, DeliveryCompleteDate__c, OpportunityName__c, ReturnRequestDate__c, ReturnCompleteDate__c, Category__c FROM DeliveryInfo__c WHERE Id =: deliv_id limit 1];
        Opportunity opp = [SELECT Id, StageName, OwnerId, Name, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c limit 1];
        User admin = [SELECT Id FROM User WHERE Profile.name = '시스템 관리자' limit 1];
        CustomNotificationType notiType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'DeliveryNotification' limit 1];
        
        system.debug(di.DeliveryNumber__c);
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://www.hanjin.com/kor/CMS/DeliveryMgr/WaybillResult.do?mCode=MN038&schLang=KR&wblnumText2=' + di.DeliveryNumber__c);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');

        HttpResponse res = http.send(req);
        
        //system.debug(res);
        //system.debug(res.getBody());

        
        if(res.getBody().contains('Information')){ // 송장번호로 조회되는 정보가 없는 경우
            
        }else{
            
            String delivNum,delivDateTime,delivStatus,delivLocation;
            String sjData,sjNum,delivDate1,delivTime1,delivLoc;
            Boolean isDeliv = false;
            List<String> delivDate = new List<String>();
            List<String> insertDate = new List<String>();
            List<String> delivTime = new List<String>();
            List<String> insertTime = new List<String>();
            
            if(Test.isRunningTest()){
                sjNum = di.DeliveryNumber__c;
                insertDate.add(String.valueOf(Date.today().year()));
                insertDate.add(String.valueOf(Date.today().month()));
                insertDate.add(String.valueOf(Date.today().day()));
                delivTime1 = DateTime.now().format();
                insertTime.add(String.valueOf(Date.today().year()));
                insertTime.add(String.valueOf(Date.today().month()));
                insertTime.add(String.valueOf(Date.today().day()));
                insertTime.add('08');
                insertTime.add('45');
                delivLoc = '서울';
                if(di.DeliveryNumber__c == '534432484556' || di.DeliveryNumber__c == '537732484556'){
                    delivDate.add('1');
                    delivDate.add('2');
                } else if(di.DeliveryNumber__c == '535532484556' || di.DeliveryNumber__c == '536632484556'){
                    delivDate.add('1');
                    delivDate.add('2');
                    delivDate.add('3');
                    delivDate.add('4');
                }else {
                    isDeliv = true;
                }
                
            }else{
                sjData = res.getBody().split('songjang-num')[1];
                // 운송장번호
                sjNum = sjData.split('delivery-time')[0].split('"num">')[1].split('<')[0];
                // 배송날짜, 입력용
                delivDate = sjData.split('waybill-tbl')[1].split('w-date">');
                delivDate1 = delivDate[delivDate.size() - 1].split('</td>')[0];
                insertDate = delivDate1.split('-');
                // 배송시간, 입력용
                delivTime = sjData.split('waybill-tbl')[1].split('w-time">');
                delivTime1 = delivTime[delivTime.size() - 1].split('</td>')[0];
                insertTime = delivTime1.split(':');
                // 배송지
                delivLoc = sjData.split('"gap"')[1].split('주소">')[1].split('<')[0];
                // 배송완료여부
                isDeliv = res.getBody().contains('배송완료');
            }
            
            System.debug(sjNum);
            System.debug(delivDate1);
            System.debug(insertDate);
            System.debug(delivTime1);
            System.debug(insertTime);
            System.debug(delivLoc);
            System.debug(isDeliv);
            
            if(isDeliv){
                Set<String> targetUserIds = new Set<String>();
                if(opp.ReEntryDateTime__c == null && (opp.StageName == '배송중' || opp.StageName == '배송 준비' || opp.StageName == '무료체험 전환') && di.DeliveryStatus__c != '배송완료'  && di.Category__c == '패드 발송'){
                    opp.StageName = '체험진행중';
                    di.DeliveryStatus__c = '배송완료';
                    di.DeliveryCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    
                    String title = '배송 완료';
                    String body = '기회(' + di.OpportunityName__c + ')의 물품이 배송 완료 되었습니다.\n- 배송현황 : ' + di.Name + '\n* 클릭 시 배송현황 정보 확인';
                    targetUserIds.add(opp.OwnerId);
                    UTIL_Notification.unCalloutNotiSend(notiType.Id, admin.Id, di.Id, title, body, targetUserIds);
                    
                }else if(opp.ReEntryDateTime__c == null && opp.StageName == '체험진행중' && di.DeliveryStatus__c != '기기회수완료' && di.Category__c == '패드 회수'){
                    opp.StageName = '체험종료';
                    di.DeliveryStatus__c = '기기회수완료';
                    di.DeliveryCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    di.ReturnCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    
                    String title = '기기회수 완료';
                    String body = '기회(' + di.OpportunityName__c + ')의 물품이 회수 완료 되었습니다.\n- 배송현황 : ' + di.Name + '\n* 클릭 시 배송현황 정보 확인';
                    targetUserIds.add(opp.OwnerId);
                    UTIL_Notification.unCalloutNotiSend(notiType.Id, admin.Id, di.Id, title, body, targetUserIds);
                    
                }
                // 재인입
                if(opp.ReEntryDateTime__c != null && di.DeliveryStatus__c != '배송완료'  && di.Category__c == '패드 발송'){
                    di.DeliveryStatus__c = '배송완료';
                    di.DeliveryCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    
                    String title = '배송 완료';
                    String body = '기회(' + di.OpportunityName__c + ')의 물품이 배송 완료 되었습니다.\n- 배송현황 : ' + di.Name + '\n* 클릭 시 배송현황 정보 확인';
                    targetUserIds.add(opp.OwnerId);
                    UTIL_Notification.unCalloutNotiSend(notiType.Id, admin.Id, di.Id, title, body, targetUserIds);
                    
                }else if(opp.ReEntryDateTime__c != null && di.DeliveryStatus__c != '기기회수완료' && di.Category__c == '패드 회수'){
                    di.DeliveryStatus__c = '기기회수완료';
                    di.DeliveryCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    di.ReturnCompleteDate__c = Date.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]));
                    
                    String title = '기기회수 완료';
                    String body = '기회(' + di.OpportunityName__c + ')의 물품이 회수 완료 되었습니다.\n- 배송현황 : ' + di.Name + '\n* 클릭 시 배송현황 정보 확인';
                    targetUserIds.add(opp.OwnerId);
                    UTIL_Notification.unCalloutNotiSend(notiType.Id, admin.Id, di.Id, title, body, targetUserIds);
                    
                }
            }else{
                if(delivDate.size() > 1){
                    if(delivDate.size() == 2){
                        if(opp.ReEntryDateTime__c == null && (opp.StageName == '무료체험 전환' || opp.StageName == '배송 준비') && di.Category__c == '패드 발송'){
                            //opp.StageName = '배송 준비';
                            di.DeliveryStatus__c = '배송준비';
                        }else if(opp.ReEntryDateTime__c == null && opp.StageName == '체험진행중' && di.Category__c == '패드 회수'){
                            di.DeliveryStatus__c = '기기회수중';
                        }
                        // 재인입
                        if(opp.ReEntryDateTime__c != null && di.Category__c == '패드 발송'){
                            di.DeliveryStatus__c = '배송준비';
                        }else if(opp.ReEntryDateTime__c != null && di.Category__c == '패드 회수'){
                            di.DeliveryStatus__c = '기기회수중';
                        }                        
                    }else{
                        if(opp.ReEntryDateTime__c == null && (opp.StageName == '배송 준비' || opp.StageName == '무료체험 전환') && (di.Category__c == '패드 발송')){
                            opp.StageName = '배송중';
                            di.DeliveryStatus__c = '배송중';
                        }else if(opp.ReEntryDateTime__c == null && opp.StageName == '체험진행중' && di.Category__c == '패드 회수'){
                            di.DeliveryStatus__c = '기기회수중';
                        }
                        // 재인입
                        if(opp.ReEntryDateTime__c != null && (di.Category__c == '패드 발송')){
                            di.DeliveryStatus__c = '배송중';
                        }else if(opp.ReEntryDateTime__c != null && di.Category__c == '패드 회수'){
                            di.DeliveryStatus__c = '기기회수중';
                        }                        
                    }
                }
            }
            di.DeliveryDateTime__c = DateTime.newInstance(Integer.valueOf(insertDate[0]),Integer.valueOf(insertDate[1]),Integer.valueOf(insertDate[2]),Integer.valueOf(insertTime[0]),Integer.valueOf(insertTime[1]),00);
            di.DeliveryLocation__c = delivLoc;
            
            update opp;
            update di;
            
        }

            BatchDeliveryInfo bdi = new BatchDeliveryInfo();
            Database.executeBatch(bdi,1000);

    }

}