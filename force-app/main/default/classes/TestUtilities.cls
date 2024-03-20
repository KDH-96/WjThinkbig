/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-22-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/

@isTest
public class TestUtilities {

    /**
     * @description 사용자 생성
     * @author ms.kim
     * @param  singleId 
     * @return
     */
    public static User getUser( String singleId){
        
        User u;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs (thisUser) {
            u = new User( 
                 LastName          = singleId
                ,FirstName         = singleId
                ,UserName          = singleId+'@wjtbtest.com'
                ,TimeZoneSidKey    = 'GMT'
                ,LanguageLocaleKey = 'ko'
                ,ProfileId         =  UserInfo.getProfileId()
                ,UserRoleId        =  UserInfo.getUserRoleId()
                ,Email             = singleId+'@wjtbtest.com'
                ,Alias             = singleId
                ,LocaleSidKey      = 'ko'
                ,EmailEncodingKey  = 'UTF-8'
            );
    
            insert u;
        }

        return u;
    }

    /**
     * @description 채널 생성
     * @author ms.kim
     * @param  oName 채널 이름
     * @param  Code 채널 코드
     * @return
     */
    public static Channel__c getChannel( String oName, String Code){
        Channel__c c = new Channel__c(
            Name = oName
            , Code__c = Code
        );

        insert c;
        return c;
    }

    /**
     * @description 유입경로 생성
     * @author ms.kim
     * @param  oName 유입경로 이름
     * @param  Code 유입경로 코드
     * @return
     */
    public static LeadSource__c getLeadSource( String oName, String Code){
        LeadSource__c ls = new LeadSource__c(
            Name = oName
            , Code__c = Code
        );

        insert ls;
        return ls;
    }
    
    /**
     * @description 제품(서비스) 생성
     * @author ms.kim
     * @param  oName 제품(서비스) 이름
     * @param  Code 제품(서비스) 코드
     * @return
     */
    public static ProductService__c getProductService( String oName, String Code){
        ProductService__c ps = new ProductService__c(
            Name = oName
            , Code__c = Code
        );

        insert ps;
        return ps;
    }

    /**
     * @description 장치 생성
     * @author ms.kim
     * @param  oName 장치 이름
     * @param  Code 장치 코드
     * @return
     */
    public static Device__c getDevice( String oName, String Code){
        Device__c d = new Device__c(
            Name = oName
            , Code__c = Code
        );

        insert d;
        return d;
    }

    /**
     * @description 무체프로모션 생성
     * @author ms.kim
     * @param  oName 무체프로모션 이름
     * @param  Code 무체프로모션 코드
     * @return
     */
    public static Promotion_Freetrial__c getPromotion_Freetrial( String oName, String Code){
        Promotion_Freetrial__c pf = new Promotion_Freetrial__c(
            Name = oName
            , Code__c = Code
        );

        insert pf;
        return pf;
    }

    /**
     * @description 가입프로모션 생성
     * @author ms.kim
     * @param  oName 가입프로모션 이름
     * @param  Code 가입프로모션 코드
     * @return
     */
    public static Promotion_Join__c getPromotion_Join( String oName, String Code){
        Promotion_Join__c pj = new Promotion_Join__c(
            Name = oName
            , Code__c = Code
        );

        insert pj;
        return pj;
    }

    /**
     * @description 미디어코드 생성
     * @author ms.kim
     * @param  oName 미디어코드 이름
     * @param  Code 미디어코드 코드
     * @return
     */
    public static MediaCode__c getMediaCode( String oName, String Code){
        MediaCode__c mc = new MediaCode__c(
            Name = oName
            , Code__c = Code
        );

        insert mc;
        return mc;
    }
    
    /**
     * @description 교사그룹 생성
     * @author ms.kim
     * @param  oName 교사그룹 이름
     * @return
     */
    public static Group__c getGroup( String oName){
        Group__c gr = new Group__c(
            Name = oName
        );

        insert gr;
        return gr;
    }
    
    /**
     * @description 리드 생성
     * @author ms.kim
     * @param  nm 성
     * @return
     */
    public static Lead getLead( String nm){
        Lead le = new Lead(
            LastName = nm
            ,Channel__c = getChannel('test', 'test').Id
            ,LeadSource__c = getLeadSource('test', 'test').Id
            ,ProductService__c = getProductService('test', 'test').Id
            ,PostalCode = '0000'
            ,Street = 'test'
            ,MobilePhone = '01012345678'
        );

        insert le;
        return le;
    }

    /**
     * @description 리드 변환
     * @author ms.kim
     * @param  leadid 리드 Id
     */
    public static Database.LeadConvertResult getLeadConverte( String leadid){
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadid);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        return lcr;
    }

    /**
     * @description 계정 생성
     * @author ms.kim
     * @param  nm           계정 명
     * @param  recordTypeNm 계정 레코드 유형 명
     * @return              
     */
    public static Account getAccount( String nm, String recordTypeNm){
        Account acct = new Account( LastName = nm);
        acct.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get( recordTypeNm)?.getRecordTypeId();
        insert acct;
        return acct;
    }

    /**
     * @description 기회 생성
     * @author ms.kim
     * @param  nm           기회 명
     * @param  recordTypeNm 기회 레코드 유형 명
     * @return              
     */
    public static Opportunity getOpportunity( String accid, String nm, String recordTypeNm){
        Opportunity oppty = new Opportunity( 
            Name = nm
            , AccountId = accid
            , StageName = 'test'
            , CloseDate = System.today()
        );
        oppty.RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get( recordTypeNm)?.getRecordTypeId();
        insert oppty;
        return oppty;
    }
    
            /**
     * @description SMS Template 생성
     * @author dohun.kim
     * @param  nm           sms Template 명
     * @return              
     */
    public static SMS_Message_Template__c getSMSMessageTemplate(String nm, String SMSTitle, String SMSContentMsg){
        SMS_Message_Template__c SMS = new SMS_Message_Template__c( 
            Name = nm
            , SMS_Title__c = SMSTitle
            , SMS_Content_Message__c = SMSContentMsg
        );
        insert SMS;
        return SMS;
    }

}