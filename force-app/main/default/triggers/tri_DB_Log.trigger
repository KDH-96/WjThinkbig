/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 02-23-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
trigger tri_DB_Log on DB_Log__c (before insert) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        
        for (DB_Log__c db : Trigger.new) {
            
            db.MobilePhone__c = 
            String.isEmpty(db.MobilePhone__c) ? null : db.MobilePhone__c.trim();
            if (!String.isEmpty(db.MobilePhone__c)) {
                // 전화번호 숫자 제외하고 지움 처리
                db.MobilePhone__c = db.MobilePhone__c.replaceAll('[^0-9]', '');
                //od.MobilePhone = od.MobilePhone.replaceAll('[^0-9]', '');
                
                /* if (db.MobilePhone__c.length() >= 11) {
                    db.MobilePhone__c = db.MobilePhone__c.substring(0, 3) + '-' + db.MobilePhone__c.substring(3, 7) + '-' + db.MobilePhone__c.substring(7);
                } */

                    if (db.MobilePhone__c.length() == 10) {
                        string FirstNum = db.MobilePhone__c.substring(0, 3);
                        string MiddleNum = db.MobilePhone__c.substring(3, 6);
                        string LastNum = db.MobilePhone__c.substring(6);
                        db.MobilePhone__c = FirstNum + '-' + MiddleNum + '-' + LastNum;
                    } else if (db.MobilePhone__c.length() == 11) {
                        string FirstNum = db.MobilePhone__c.substring(0, 3);
                        string MiddleNum = db.MobilePhone__c.substring(3, 7);
                        string LastNum = db.MobilePhone__c.substring(7);
                        db.MobilePhone__c = FirstNum + '-' + MiddleNum + '-' + LastNum;
                    }
            }
            
            db.Name__c = 
            String.isEmpty(db.Name__c) ? null : db.Name__c.trim();
            
            db.RequestDateTime__c = 
            String.isEmpty(db.RequestDateTime__c) ? null : db.RequestDateTime__c.trim();
            
            /**
             * 요청일자 DateTime형식으로 변환
             */
            if (!String.isEmpty(db.RequestDateTime__c)) {
                // 요청일자 숫자 제외하고 지움 처리
                db.RequestDateTime__c = db.RequestDateTime__c.replaceAll('[^0-9]', '');

                // ex) 20240201093000 -> 2024-02-01 09:30:00
                if (db.RequestDateTime__c.length() >= 14) {
                    db.RequestDateTime__c = db.RequestDateTime__c.substring(0, 4) + '-' + db.RequestDateTime__c.substring(4, 6) + '-' + db.RequestDateTime__c.substring(6, 8) + ' ' + db.RequestDateTime__c.substring(8, 10) + ':' + db.RequestDateTime__c.substring(10, 12) + ':' + db.RequestDateTime__c.substring(12, 14);
                
                // ex) 202402010930 -> 2024-02-01 09:30:00 (초가 없을 시)
                }else if(db.RequestDateTime__c.length() >= 12){
                    db.RequestDateTime__c = db.RequestDateTime__c.substring(0, 4) + '-' + db.RequestDateTime__c.substring(4, 6) + '-' + db.RequestDateTime__c.substring(6, 8) + ' ' + db.RequestDateTime__c.substring(8, 10) + ':' + db.RequestDateTime__c.substring(10, 12) + ':00';
                }
            }

            
            db.LeadSource__c = 
                String.isEmpty(db.LeadSource__c) ? null : db.LeadSource__c.trim();
            db.LeadSourceDetail__c = 
                String.isEmpty(db.LeadSourceDetail__c) ? null : db.LeadSourceDetail__c.trim();
            db.ContractNumber__c = 
                String.isEmpty(db.ContractNumber__c) ? null : db.ContractNumber__c.trim();
            db.ProductName__c = 
                String.isEmpty(db.ProductName__c) ? null : db.ProductName__c.trim();
            db.Amount__c = 
                String.isEmpty(db.Amount__c) ? null : db.Amount__c.trim();
            
            if(!String.isEmpty(db.Amount__c)){
                // DB로 유입된 상품총액이 숫자로만 구성되어 있는지 확인 후 회계표시
                if(isNumeric(db.Amount__c)){
                    Decimal amountValue = Decimal.valueOf(db.Amount__c);
                    String formattedAmount = amountValue.format();
                    db.Amount__c = formattedAmount;
                }
            }
            
            db.RegisterName__c = 
                String.isEmpty(db.RegisterName__c) ? null : db.RegisterName__c.trim();
            db.MembershipNumber__c = 
                String.isEmpty(db.MembershipNumber__c) ? null : db.MembershipNumber__c.trim();
            db.ChildName__c = 
                String.isEmpty(db.ChildName__c) ? null : db.ChildName__c.trim();
            db.ChildAge__c = 
                String.isEmpty(db.ChildAge__c) ? null : db.ChildAge__c.trim();
            db.ChildBirthday__c = 
                String.isEmpty(db.ChildBirthday__c) ? null : db.ChildBirthday__c.trim();

            if (!String.isEmpty(db.ChildBirthday__c)) {
                // 생일 숫자 제외하고 지움 처리
                db.ChildBirthday__c = db.ChildBirthday__c.replaceAll('[^0-9]', '');
                if (db.ChildBirthday__c.length() >= 8) {
                    db.ChildBirthday__c = db.ChildBirthday__c.substring(0, 4) + '-' + db.ChildBirthday__c.substring(4, 6) + '-' + db.ChildBirthday__c.substring(6, 8);
                }
            }

            db.Address1__c = 
                String.isEmpty(db.Address1__c) ? null : db.Address1__c.trim();
            db.Address2__c = 
                String.isEmpty(db.Address2__c) ? null : db.Address2__c.trim();
            db.PostalCode__c = 
                String.isEmpty(db.PostalCode__c) ? null : db.PostalCode__c.trim();
            db.Requirement__c = 
                String.isEmpty(db.Requirement__c) ? null : db.Requirement__c.trim();
            db.MediaCode__c = 
                String.isEmpty(db.MediaCode__c) ? null : db.MediaCode__c.trim();
            db.Device__c = 
                String.isEmpty(db.Device__c) ? null : db.Device__c.trim();
            db.Channel__c = 
                String.isEmpty(db.Channel__c) ? null : db.Channel__c.trim();
            db.ProductService__c = 
                String.isEmpty(db.ProductService__c) ? null : db.ProductService__c.trim();
            db.Promotion_Freetrial__c = 
                String.isEmpty(db.Promotion_Freetrial__c) ? null : db.Promotion_Freetrial__c.trim();
            db.Promotion_Join__c = 
                String.isEmpty(db.Promotion_Join__c) ? null : db.Promotion_Join__c.trim();
        }

        /**
         * Salesforce에 등록되어 있는 예비고객들의 기회 변환 확인 후, 기회 레코드 타입 조건에 맞는 DB 신청상태 상세 필드 데이터 추가
         */
        
        Set<String> LeadSet = new Set<String>();
        Map<String, String> leadStatusMap = new Map<String, String>();

        for (DB_Log__c db : Trigger.new) {
            LeadSet.add(db.MobilePhone__c);
            LeadSet.add(db.MobilePhone__c.replaceAll('[^0-9]', ''));
        }
        
        List<Lead> existLeadList = new List<Lead>([SELECT Id, MobilePhone, LastName, RequestDateTime__c, CreatedDate, ChildName__c, ConvertedOpportunityId, ConvertedOpportunity.Name, isConverted, RequestStatusDetail__c, ConvertedOpportunity.RecordType.Name FROM Lead WHERE MobilePhone = :LeadSet ORDER BY CreatedDate DESC]);
        
        if(!existLeadList.isEmpty() && existLeadList.size()>0){
            
            for (Lead l : existLeadList) {
                String key = l.MobilePhone;
                String keyReplace = l.MobilePhone.replaceAll('[^0-9]', '');
                if (l.ConvertedOpportunityId != null) {
                    leadStatusMap.put(key, (l.ConvertedOpportunity.RecordType.Name == '무료체험') ? 'ReEntry_FreeTrial' : 'ReEntry_DirectJoin');
                    leadStatusMap.put(keyReplace, (l.ConvertedOpportunity.RecordType.Name == '무료체험') ? 'ReEntry_FreeTrial' : 'ReEntry_DirectJoin');
                } else {
                    leadStatusMap.put(key, 'ReEntry');
                    leadStatusMap.put(keyReplace, 'ReEntry');
                }
            }
        }

        for (DB_Log__c db : Trigger.new) {
            String key = db.MobilePhone__c;
            String keyReplace = db.MobilePhone__c.replaceAll('[^0-9]', '');
            if (leadStatusMap.containsKey(key)){
                db.RequestStatusDetail__c = leadStatusMap.get(key);
            }else if(leadStatusMap.containsKey(keyReplace)) {
                db.RequestStatusDetail__c = leadStatusMap.get(keyReplace);
            }
            db.ReEntryDateTime__c = !existLeadList.isEmpty() && existLeadList.size()>0 ? DateTime.valueOf(db.RequestDateTime__c) : null;
        }

    }

    // 상품 총액이 숫자로만 되어 있는지 확인
    private static Boolean isNumeric(String Amount) {
    try {
        Decimal.valueOf(Amount); 
        return true;
    } catch (Exception e) {
        return false;
    }
}
}