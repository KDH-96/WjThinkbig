/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
@isTest
public with sharing class SendSMSControllerTest {

    @TestSetup
    private static void setData(){
        User SetupUser = TestUtilities.getUser('thinkB1');
        Device__c SetupDevice = TestUtilities.getDevice('PC','PC');
        Channel__c SetupChannel = TestUtilities.getChannel('제휴','C002');
        LeadSource__c SetupLeadSource = TestUtilities.getLeadSource('에버랜드_연간회원','L002');
        ProductService__c SetupProductService =TestUtilities.getProductService('슈퍼팟','P003');
        Promotion_Freetrial__c SetupFreePromotion = TestUtilities.getPromotion_Freetrial('3만솜 + 슈퍼팟잉글리시무료체험7일 + 연령별도서 2권','E0003');
        Promotion_Join__c SetupJoinPromotion = TestUtilities.getPromotion_Join('10만솜 + 마일리지 10만','J0003');
        MediaCode__c SetupMediaCode = TestUtilities.getMediaCode('밴드','band');
        Group__c SetupGroup = TestUtilities.getGroup('A그룹');
        SMS_Message_Template__c SetupSMSTemplate = TestUtilities.getSMSMessageTemplate('TEST', 'TEST Title', 'TEST Message Template');
        
        GroupDetail__c SetupGroupDetail = new GroupDetail__c(SortOrder__c=1
                                            ,MinDistriNo__c= 10
                                            ,WeightedValue__c = '1.0'
                                            ,Group__c = SetupGroup.Id
                                            ,User__c = SetupUser.Id);
        INSERT SetupGroupDetail;
        Lead SetupLead = new Lead(AssignDateTime__c = System.Now()
                                ,LastName = '씽크빅'
                                ,MobilePhone= '01011112222'
                                ,Channel__c = SetupChannel.Id
                                ,LeadSource__c = SetupLeadSource.Id
                                ,ProductService__c = SetupProductService.Id
                                ,Device__c = SetupDevice.Id
                                ,Promotion_Freetrial__c = SetupFreePromotion.Id
                                ,Promotion_Join__c = SetupJoinPromotion.Id
                                ,MediaCode__c = SetupMediaCode.Id
                                ,ChildName__c = '씽자식'
                                ,ChildBirthday__c = Date.valueOf('2018-12-18')
                                ,RequestDateTime__c = Datetime.valueOf('2024-01-15 14:30:00')
                                ,RequestStatusDetail__c = 'New'
                                ,PostalCode = '04521'
                                ,Street = '서울 중구 청계천로 24 (다동, 케이스퀘어시티)'
                                ,LastAssign__c = SetupGroupDetail.User__c
                                ,OwnerId = SetupGroupDetail.User__c
                                );

        INSERT SetupLead; 
    }   
    @isTest
    static void getSMSTemplateControllerTest() {
        Lead le = [SELECT Id, MobilePhone FROM Lead];
        SendSMSController.getSMSTemplateController(le.Id);
    }
    @isTest
    static void SendSMSTest() {
        Lead le = [SELECT Id FROM Lead];
        SMS_Message_Template__c messageTemplate = [SELECT Id, Name, SMS_Title__c, SMS_Content_Message__c FROM SMS_Message_Template__c];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        Map<String, Object> result = SendSMSController.SendSMS('01012345678', messageTemplate.SMS_Content_Message__c, messageTemplate.SMS_Title__c, '01011111111', le.Id);
        Test.stopTest();
    }

    @isTest
    static void SendSMSTestForSendMobile() {
        Lead le = [SELECT Id FROM Lead];
        SMS_Message_Template__c messageTemplate = [SELECT Id, Name, SMS_Title__c, SMS_Content_Message__c FROM SMS_Message_Template__c];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        Map<String, Object> result = SendSMSController.SendSMS('0101111111', messageTemplate.SMS_Content_Message__c, messageTemplate.SMS_Title__c, '15771500', le.Id);
        Test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"respCode":"S", "respMsg":"Success"}');
            res.setStatusCode(200);
            return res;
        }
    }

}