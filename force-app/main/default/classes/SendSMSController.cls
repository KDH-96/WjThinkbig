/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 02-22-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
public class SendSMSController {

    /**
     * @description 템플릿 정보 가져오기
     * @author dohun.kim
     * @param  parentId 
     * @return retMap
     */
    @AuraEnabled 
    public static Map<String, String> getSMSTemplateController(Id parentId) {
        
        Map<String, String> retMap = new Map<String, String>();
        Map<String,List<SMS_Message_Template__c>> smsTemplateLists = new Map<String,List<SMS_Message_Template__c>>();
        Map<String,List<Lead>> LeadLists = new Map<String,List<Lead>>();
        Map<String,List<Opportunity>> OppLists = new Map<String,List<Opportunity>>();
        Savepoint sv = Database.setSavepoint();
        try{
        System.debug('parentId >> '+  parentId);
        Map<Id, User> objUser_map = new Map<Id, User>([SELECT Name, Profile.Name, LanguageLocaleKey, MobilePhone FROM User WHERE Id =: UserInfo.getUserId()]);
        User objUser = objUser_map.get(UserInfo.getUserId());
        
        List<SMS_Message_Template__c> smsTemplates = [SELECT Id, Name, SMS_Title__c, SMS_Content_Message__c, LastOrder__c  FROM SMS_Message_Template__c ORDER BY LastOrder__c, Name ];
        
        //List<Lead> objLead = [SELECT Id, LastName, MobilePhone, ChildName__c, ChildPhone__c, Owner.Name, Owner.Phone FROM Lead WHERE Id =:parentId];
        List<Lead> objLead = [SELECT Id, LastName, MobilePhone, NOKNumber__c, Owner.Name FROM Lead WHERE Id =:parentId];
        List<Opportunity> objOpp = [SELECT Id, fm_ParentName__c, ParentPhone__c, NOKNumber__c, Owner.Name FROM Opportunity WHERE Id =:parentId];
        System.debug('objLead >> '+  objLead);
        
        smsTemplateLists.put('SMS_Message_Template__c', smsTemplates);
        LeadLists.put('Lead', objLead);
        OppLists.put('Opportunity', objOpp);

        retMap.put('sendMobilePhone',objUser.MobilePhone);
        retMap.put('smsTemplates',JSON.serialize(smsTemplateLists));
        retMap.put('Lead',JSON.serialize(LeadLists));
        retMap.put('Opportunity',JSON.serialize(OppLists));
        
        }catch(Exception e){
            retMap.put('msg',e.getMessage() + '/' + e.getStackTraceString());
            if(sv != null) Database.rollback(sv);
        }
        return retMap;
    }
    
    /**
     * @description sms 발송
     * @author dohun.kim
     * @param  mobileNo     수신번호
     * @param  smsMsg       메세지 본문 
     * @param  smsTitle     메세지제목
     * @param  sendMobileNo 발신번호
     * @param  parentId     레코드 Id
     * @return responseData
     */
    @AuraEnabled 
    public static Map<String, Object> SendSMS(String mobileNo, String smsMsg, String smsTitle, String sendMobileNo, Id parentId) {
        System.debug('mobileNo >> '+  mobileNo);
        System.debug('smsMsg >> '+  smsMsg);
        System.debug('smsTitle >> '+  smsTitle);
        System.debug('sendMobileNo >> '+  sendMobileNo);
        
        
        System.debug('ParentId >> '+  ParentId);
        List<Lead> leadList = [SELECT Id, LastName, ConvertedOpportunityId FROM Lead WHERE Id = :ParentId OR ConvertedOpportunityId = :parentId];
        System.debug('Lead >> '+  JSON.serializePretty(leadList));

        Map<String, Object> responseData = new Map<String, Object>();
		
        try {
            responseData = IF_SMS_Auth.sendSMS(mobileNo, smsMsg, smsTitle, sendMobileNo);

            Datetime sendTime = Datetime.now();
            System.debug('resp >> '+  responseData);

            List<FeedTracking__c> feedInsertList = new List<FeedTracking__c>();

            string receiveFirstNum = '';
            string receiveMiddleNum = '';
            string receiveLastNum = '';
            string sendFirstNum = '';
            string sendMiddleNum = '';
            string sendLastNum = '';

            if(responseData.get('respCode') == 'S'){
                System.debug('leadList >> '+ leadList);
                if(leadList?.size()>0){
                    
                    if (mobileNo.length() == 10) {
                        receiveFirstNum = mobileNo.substring(0, 3);
                        receiveMiddleNum = mobileNo.substring(3, 6);
                        receiveLastNum = mobileNo.substring(6);
                    } else if (mobileNo.length() == 11) {
                        receiveFirstNum = mobileNo.substring(0, 3);
                        receiveMiddleNum = mobileNo.substring(3, 7);
                        receiveLastNum = mobileNo.substring(7);
                    }
                    if (sendMobileNo.length() == 10) {
                        sendFirstNum = sendMobileNo.substring(0, 3);
                        sendMiddleNum = sendMobileNo.substring(3, 6);
                        sendLastNum = sendMobileNo.substring(6);
                    } else if (sendMobileNo.length() == 11) {
                        sendFirstNum = sendMobileNo.substring(0, 3);
                        sendMiddleNum = sendMobileNo.substring(3, 7);
                        sendLastNum = sendMobileNo.substring(7);
                    } else if (sendMobileNo.length() == 8) {
                        sendFirstNum = sendMobileNo.substring(0, 4);
                        sendMiddleNum = sendMobileNo.substring(4, 8);
                        sendLastNum = '';
                    }

                    for(Lead l : leadList){
                        FeedTracking__c feedInsert = new FeedTracking__c(
                            FieldAPIName__c = 'SMS'
                            ,SendMobilePhone__c = sendMobileNo.length() ==8 ? sendFirstNum + '-' + sendMiddleNum :sendFirstNum + '-' + sendMiddleNum + '-' + sendLastNum
                            ,ReceiveMobilePhone__c = receiveFirstNum + '-' + receiveMiddleNum + '-' + receiveLastNum
                            ,SMSSendTime__c = sendTime
                            ,Lead__c =  l.Id
                            ,Opportunity__c = l.ConvertedOpportunityId != null ? l.ConvertedOpportunityId : null
                            ,SMSTitle__c = smsTitle
                        );

                        feedInsertList.add(feedInsert);
                    }
                }
            }
            if(feedInsertList?.size()>0) INSERT feedInsertList;

        } catch(Exception e) {
            responseData.put('respMsg', e.getMessage() + '/' + e.getStackTraceString());
        }

        return responseData;
    }
}