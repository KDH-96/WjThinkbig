/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
@isTest
public class Batch_ReEnterLeadUpdateControllerTest {
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

        GroupDetail__c SetupGroupDetail = new GroupDetail__c(SortOrder__c=1
                                            ,MinDistriNo__c= 10
                                            ,WeightedValue__c = '1.0'
                                            ,Group__c = SetupGroup.Id
                                            ,User__c = SetupUser.Id);
        INSERT SetupGroupDetail;
        Lead SetupLead = new Lead(AssignDateTime__c = System.Now()
                                ,LastName = '씽크빅'
                                ,MobilePhone= '010-1111-2222'
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
        SetupLead.MobilePhone = '010-1111-2222';
        UPDATE SetupLead;
        
        Database.LeadConvertResult SetupConverLead = TestUtilities.getLeadConverte(SetupLead.Id);
                                               

        SetupLead.Status = '무료체험 전환';
        UPDATE SetupLead;
    }   

    @isTest
    static void Batch_ReEnterLeadUpdateControllerTest() {

        Lead SetupLead = [SELECT Id, Status, ConvertedOpportunityId, isConverted FROM Lead LIMIT 1];

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
        SetupDbLog.MediaCode__c ='band';
        SetupDbLog.Device__c ='PC';
        SetupDbLog.Channel__c='C002';
        SetupDbLog.ProductService__c ='P003';
        SetupDbLog.Promotion_Freetrial__c ='E0003';
        SetupDbLog.Promotion_Join__c ='J0003';

        INSERT SetupDbLog;

        Test.startTest();
        Batch_ReEnterLeadUpdateController ba = new Batch_ReEnterLeadUpdateController();
        Id jobid = Database.executeBatch(ba);
        Test.stopTest();
    
        List<Lead> leads = [SELECT Id FROM Lead WHERE MobilePhone ='010-1111-2222' AND LastName='씽크빅'];
        System.assertNotEquals(0, leads.size(), '예비고객이 업데이트 되지 않음.');
        System.assertEquals(1, leads.size(), '업데이트 되는 예비고객이 1개 이상.');
    }

    @isTest
    static void SchedulerLeadBatch_Test(){
        Test.startTest();
        Scheduler_LeadBatchController scb = new Scheduler_LeadBatchController ();   
        String chron = '0 10 * * * ?';        
        system.schedule('Lead UPDATE Test Schedule', chron, scb);
        Test.stopTest();
    }
}