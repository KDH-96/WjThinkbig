/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 02-01-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
@isTest
public with sharing class Batch_LeadDistributeControllerTest {

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
        
        // Channel_Mgmt__c SetupChnnelMgmt = new Channel_Mgmt__c();
        // SetupChnnelMgmt.Device__c = SetupDevice.Id;
        // SetupChnnelMgmt.Channel__c = SetupChannel.Id;
        // SetupChnnelMgmt.LeadSource__c = SetupLeadSource.Id;
        // SetupChnnelMgmt.ProductService__c = SetupProductService.Id;
        // SetupChnnelMgmt.Promotion_Freetrial__c = SetupFreePromotion.Id;
        // SetupChnnelMgmt.Promotion_Join__c = SetupJoinPromotion.Id;
        // SetupChnnelMgmt.Group__c = SetupGroup.Id;
        // SetupChnnelMgmt.Criteria__c = '최소분배수';
        
        // INSERT SetupChnnelMgmt;

        // GroupDetail__c SetupGroupDetail = new GroupDetail__c(SortOrder__c=1
        //                                     ,MinDistriNo__c= 10
        //                                     ,WeightedValue__c = '1.0'
        //                                     ,Group__c = SetupChnnelMgmt.Group__c
        //                                     ,User__c = SetupUser.Id);
        // INSERT SetupGroupDetail;
    }   
    
    @isTest
    static void Batch_LeadDistributeControllerMinDistTest() {

        DB_Log__c SetupDbLog =new DB_Log__c(); 
        
        SetupDbLog.MobilePhone__c = '010-1111-2222';
        SetupDbLog.Name__c ='씽크빅';
        SetupDbLog.RequestDateTime__c ='2024-01-29 11:13:00';
        SetupDbLog.LeadSource__c ='L002';
        SetupDbLog.LeadSourceDetail__c ='https://dev-www.wjbookclub.co.kr/event/preedtest.do';
        SetupDbLog.ContractNumber__c ='A1234567';
        SetupDbLog.ProductName__c ='슈퍼팟';
        SetupDbLog.Amount__c ='100000';
        SetupDbLog.FullPaymentFlg__c ='Y';
        SetupDbLog.RegisterName__c ='씽';
        SetupDbLog.MembershipNumber__c ='ASDF123';
        SetupDbLog.ChildName__c ='씽자식';
        SetupDbLog.ChildBirthday__c ='2018-12-18';
        SetupDbLog.ChildAge__c ='15';
        SetupDbLog.Address1__c ='서울 중구 청계천로 24 (다동, 케이스퀘어시티)';
        SetupDbLog.Address2__c ='16층';
        SetupDbLog.PostalCode__c ='04521';
        SetupDbLog.Requirement__c ='요청사항 없음';
        SetupDbLog.MediaCode__c ='band';
        SetupDbLog.Device__c ='PC';
        SetupDbLog.Channel__c='C002';
        SetupDbLog.ProductService__c ='P003';
        SetupDbLog.Promotion_Freetrial__c ='E0003';
        SetupDbLog.Promotion_Join__c ='J0003';

        INSERT SetupDbLog;
                                    
        Test.startTest();
        Batch_LeadDistributeController ba = new Batch_LeadDistributeController();
        Id jobid = Database.executeBatch(ba);
        Test.stopTest();
    
        List<Lead> leads = [SELECT Id FROM Lead WHERE MobilePhone ='010-1111-2222' AND LastName='씽크빅'];
        System.assertNotEquals(0, leads.size(), '예비고객이 생성되지 않음.');
        System.assertEquals(1, leads.size(), '생성되는 예비고객이 1개 이상');
    }


    @isTest
    static void Batch_LeadDistributeControllerWeightedValueTest() {

        Channel_Mgmt__c SetupChnnelMgmt = [SELECT Id, Criteria__c FROM Channel_Mgmt__c LIMIT 1];
        SetupChnnelMgmt.Criteria__c = '가중치';

        UPDATE SetupChnnelMgmt;
                                                        
        DB_Log__c SetupDbLog =new DB_Log__c(); 
        
        SetupDbLog.MobilePhone__c = '010-1111-2222';
        SetupDbLog.Name__c ='씽크빅';
        SetupDbLog.RequestDateTime__c ='2024-01-29 11:13:00';
        SetupDbLog.LeadSource__c ='L002';
        SetupDbLog.LeadSourceDetail__c ='https://dev-www.wjbookclub.co.kr/event/preedtest.do';
        SetupDbLog.ContractNumber__c ='A1234567';
        SetupDbLog.ProductName__c ='슈퍼팟';
        SetupDbLog.Amount__c ='100000';
        SetupDbLog.FullPaymentFlg__c ='Y';
        SetupDbLog.RegisterName__c ='씽';
        SetupDbLog.MembershipNumber__c ='ASDF123';
        SetupDbLog.ChildName__c ='씽자식';
        SetupDbLog.ChildBirthday__c ='2018-12-18';
        SetupDbLog.ChildAge__c ='15';
        SetupDbLog.Address1__c ='서울 중구 청계천로 24 (다동, 케이스퀘어시티)';
        SetupDbLog.Address2__c ='16층';
        SetupDbLog.PostalCode__c ='04521';
        SetupDbLog.Requirement__c ='요청사항없음';
        SetupDbLog.MediaCode__c ='naverost_mop';
        SetupDbLog.Device__c ='PC';
        SetupDbLog.Channel__c='C002';
        SetupDbLog.ProductService__c ='P003';
        SetupDbLog.Promotion_Freetrial__c ='E0003';
        SetupDbLog.Promotion_Join__c ='J0003';

        INSERT SetupDbLog;

        Test.startTest();
        Batch_LeadDistributeController ba = new Batch_LeadDistributeController();
        Id jobid = Database.executeBatch(ba);
        Test.stopTest();
    
        List<Lead> leads = [SELECT Id FROM Lead WHERE MobilePhone ='010-1111-2222' AND LastName='씽크빅'];
        System.assertNotEquals(0, leads.size(), '예비고객이 생성되지 않음.');
        System.assertEquals(1, leads.size(), '생성되는 예비고객이 1개 이상');
    } 

    @isTest
    static void SchedulerLeadBatch_Test(){
        Test.startTest();
        Scheduler_LeadBatchController scb = new Scheduler_LeadBatchController ();   
        String chron = '0 10 * * * ?';        
        system.schedule('Lead INSERT Test Schedule', chron, scb);
        Test.stopTest();
    }
    
}