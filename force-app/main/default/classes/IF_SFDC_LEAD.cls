/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/

@RestResource(urlMapping='/leadFromLandingPage/*')
global with sharing class IF_SFDC_LEAD {


    global class ReturnMessage {
        global String Code;
        global String Message;
    }
   

    /**
     * @description RestAPI 인터페이스를 통해 들어온 데이터 DB유입 레코드 추가
     * @param  { String }       MobilePhone
     * @param  { String }       Name
     * @param  { String }       RequestDateTime
     * @param  { String }       LeadSource
     * @param  { String }       LeadSourceDetail
     * @param  { String }       ContractNumber
     * @param  { String }       ProductName
     * @param  { String }       Amount
     * @param  { String }       FullPaymentFlg
     * @param  { String }       RegisterName
     * @param  { String }       MembershipNumber
     * @param  { String }       ChildName
     * @param  { String }       ChildAge
     * @param  { String }       ChildBirthday
     * @param  { String }       Address1
     * @param  { String }       Address2
     * @param  { String }       PostalCode
     * @param  { String }       Requirement
     * @param  { String }       MediaCode
     * @param  { String }       Device
     * @param  { String }       Channel
     * @param  { String }       ProductService
     * @param  { String }       PromotionFreetrial
     * @param  { String }       PromotionJoin
     * @return { ReturnMessage }  retMsg 
     */
    @HttpPost
    global static ReturnMessage createLead(String MobilePhone
                                    ,String Name
                                    ,String RequestDateTime
                                    ,String LeadSource
                                    ,String LeadSourceDetail
                                    ,String ContractNumber
                                    ,String ProductName
                                    ,String Amount
                                    ,String FullPaymentFlg
                                    ,String RegisterName
                                    ,String MembershipNumber
                                    ,String ChildName
                                    ,String ChildAge
                                    ,String ChildBirthday
                                    ,String Address1
                                    ,String Address2
                                    ,String PostalCode
                                    ,String Requirement
                                    ,String MediaCode
                                    ,String Device
                                    ,String Channel
                                    ,String ProductService
                                    ,String PromotionFreetrial
                                    ,String PromotionJoin
                                    ) 
                                    {

        ReturnMessage reMsg = new ReturnMessage();
        Savepoint sp = Database.setSavepoint();
        try {
            DB_Log__c newDB = new DB_Log__c();
            newDB.MobilePhone__c = MobilePhone;
            newDB.Name__c = Name;
            newDB.RequestDateTime__c = RequestDateTime;
            newDB.LeadSource__c = LeadSource;
            newDB.LeadSourceDetail__c = LeadSourceDetail;
            newDB.ContractNumber__c = ContractNumber;
            newDB.ProductName__c = ProductName;
            newDB.Amount__c = Amount;
            newDB.FullPaymentFlg__c = FullPaymentFlg;
            newDB.RegisterName__c = RegisterName;
            newDB.MembershipNumber__c = MembershipNumber;
            newDB.ChildName__c = ChildName;
            newDB.ChildAge__c = ChildAge;
            newDB.ChildBirthday__c = ChildBirthday;
            newDB.Address1__c = Address1;
            newDB.Address2__c = Address2;
            newDB.PostalCode__c = PostalCode;
            newDB.Requirement__c = Requirement;
            newDB.MediaCode__c = MediaCode;
            newDB.Device__c = Device;
            newDB.Channel__c = Channel;
            newDB.ProductService__c = ProductService;
            newDB.Promotion_Freetrial__c = PromotionFreetrial;
            newDB.Promotion_Join__c = PromotionJoin;

            INSERT newDB;

        reMsg.Code = 'S';
        reMsg.Message = '리드 등록 성공';

        } catch (Exception e) {
            Database.rollback(sp);
            reMsg.Code = 'E';  
            reMsg.Message = '리드 등록 실패. 상세 에러 메세지: ' + e.getMessage();
        }
        return reMsg;
    }

    
}