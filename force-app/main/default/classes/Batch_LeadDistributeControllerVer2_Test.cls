/**
 * @description       : 
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-19-2024
 * @last modified by  : wj.chae
**/
@isTest
public with sharing class Batch_LeadDistributeControllerVer2_Test {

    @TestSetup
    private static void setData(){
        User setupUser = TestUtilities.getUser('thinkB1');
        User setupUser2 = TestUtilities.getUser('thinkB2');
        Device__c setupDevice = TestUtilities.getDevice('PC','PC');
        Channel__c setupChannel = TestUtilities.getChannel('제휴','C002');
        LeadSource__c setupLeadSource = TestUtilities.getLeadSource('에버랜드_키즈빌리지','L004');
        ProductService__c setupProductService =TestUtilities.getProductService('슈퍼팟','P003');
        Promotion_Freetrial__c setupFreePromotion = TestUtilities.getPromotion_Freetrial('3만솜 + 슈퍼팟잉글리시무료체험7일 + 연령별도서 2권','E0003');
        Promotion_Join__c setupJoinPromotion = TestUtilities.getPromotion_Join('10만솜 + 마일리지 10만','J0003');
        MediaCode__c setupMediaCode = TestUtilities.getMediaCode('밴드','band');
        // Group__c SetupGroup = TestUtilities.getGroup('A그룹');
        

        Group__c gr = new Group__c(
            Name = '그룹 A',
            LeadSource__c = 'L004;L007',
            Criteria__c = '최소분배수'
        );
        INSERT gr;

        List<GroupDetail__c> setGroupDetailList = new LIst<GroupDetail__c>();
        GroupDetail__c setupGroupDetailUser1 = new GroupDetail__c(
            SortOrder__c = 1,
            MinDistriNo__c= 10,
            WeightedValue__c = '1.0',
            Group__c = gr.Id,
            User__c = setupUser.Id
        );
        setGroupDetailList.add(setupGroupDetailUser1);

        GroupDetail__c setupGroupDetailUser2 = new GroupDetail__c(
            SortOrder__c = 2,
            MinDistriNo__c= 10,
            WeightedValue__c = '1.0',
            Group__c = gr.Id,
            User__c = setupUser2.Id
        );
        setGroupDetailList.add(setupGroupDetailUser2);

        INSERT setGroupDetailList;

        
    }   
    
    @isTest
    static void Batch_LeadDistributeControllerMinDistTest() {

        Group__c grInfo = [SELECT Id, Criteria__c, LastAssign__c FROM Group__c WHERE Name = '그룹 A' LIMIT 1];
        List<GroupDetail__c> gdInfo = [
            SELECT Id, Name, SortOrder__c, WeightedValue__c, MinDistriNo__c, Group__r.LeadSource__c, Group__r.Id, Group__c, User__c 
            FROM GroupDetail__c WHERE Group__c = :grInfo.Id
        ];
        

        DB_Log__c setupDbLog =new DB_Log__c(
            MobilePhone__c = '010-1111-2222',
            Name__c ='씽크빅',
            RequestDateTime__c ='2024-01-29 11:13:00',
            LeadSource__c ='L004',
            LeadSourceDetail__c ='https://dev-www.wjbookclub.co.kr/event/preedtest.do',
            ContractNumber__c ='A1234567',
            ProductName__c ='슈퍼팟',
            Amount__c ='100000',
            FullPaymentFlg__c ='Y',
            RegisterName__c ='씽',
            MembershipNumber__c ='ASDF123',
            ChildName__c ='씽자식',
            ChildBirthday__c ='2018-12-18',
            ChildAge__c ='15',
            Address1__c ='서울 중구 청계천로 24 (다동, 케이스퀘어시티)',
            Address2__c ='16층',
            PostalCode__c ='04521',
            Requirement__c ='요청사항 없음',
            MediaCode__c ='band',
            Device__c ='PC',
            Channel__c='C002',
            ProductService__c ='P003',
            Promotion_Freetrial__c ='E0003',
            Promotion_Join__c ='J0003', 
            Group__c = null
        ); 

        INSERT setupDbLog;
                                    
        Test.startTest();
        Batch_LeadDistributeControllerVer2 ba = new Batch_LeadDistributeControllerVer2();
        Id jobid = Database.executeBatch(ba);
        Test.stopTest();
    
        List<Lead> leads = [SELECT Id FROM Lead WHERE MobilePhone ='010-1111-2222'];
        System.assertNotEquals(0, leads.size(), '예비고객이 생성되지 않음.');
        System.assertEquals(1, leads.size(), '생성되는 예비고객이 1개 이상');
    }


    @isTest
    static void Batch_LeadDistributeControllerWeightedValueTest() {

        Group__c grInfo = [SELECT Id, Criteria__c, LastAssign__c FROM Group__c WHERE Name = '그룹 A' LIMIT 1];
        grInfo.Criteria__c = '가중치';
        grInfo.LastAssign__c = '1';

        UPDATE grInfo;
        
        DB_Log__c setupDbLog = new DB_Log__c(); 
        
        setupDbLog.MobilePhone__c = '010-1111-2222';
        setupDbLog.Name__c ='씽크빅';
        setupDbLog.RequestDateTime__c ='2024-01-29 11:13:00';
        setupDbLog.LeadSource__c ='L004';
        setupDbLog.LeadSourceDetail__c ='https://dev-www.wjbookclub.co.kr/event/preedtest.do';
        setupDbLog.ContractNumber__c ='A1234567';
        setupDbLog.ProductName__c ='슈퍼팟';
        setupDbLog.Amount__c ='100000';
        setupDbLog.FullPaymentFlg__c ='Y';
        setupDbLog.RegisterName__c ='씽';
        setupDbLog.MembershipNumber__c ='ASDF123';
        setupDbLog.ChildName__c ='씽자식';
        setupDbLog.ChildBirthday__c ='2018-12-18';
        setupDbLog.ChildAge__c ='15';
        setupDbLog.Address1__c ='서울 중구 청계천로 24 (다동, 케이스퀘어시티)';
        setupDbLog.Address2__c ='16층';
        setupDbLog.PostalCode__c ='04521';
        setupDbLog.Requirement__c ='요청사항없음';
        setupDbLog.MediaCode__c ='naverost_mop';
        setupDbLog.Device__c ='PC';
        setupDbLog.Channel__c='C002';
        setupDbLog.ProductService__c ='P003';
        setupDbLog.Promotion_Freetrial__c ='E0003';
        setupDbLog.Promotion_Join__c ='J0003';

        INSERT setupDbLog;

        Test.startTest();
        Batch_LeadDistributeControllerVer2 ba = new Batch_LeadDistributeControllerVer2();
        Id jobid = Database.executeBatch(ba);
        Test.stopTest();
    
        List<Lead> leads = [SELECT Id FROM Lead WHERE MobilePhone ='010-1111-2222'];
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