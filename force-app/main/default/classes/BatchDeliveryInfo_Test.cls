@isTest
public class BatchDeliveryInfo_Test {
    
    @testSetup
    public static void setup(){
        User u = [SELECT Id,name,profile.name from user where id =: UserInfo.getUserId()];
        RecordType accType = [SELECT Id FROM RecordType WHERE Name = '개인 계정' LIMIT 1];
        Date td = Date.today();
        
        Account acc = new Account(FirstName = 'Test', LastName = 'Account', RecordTypeId = accType.Id);
        insert acc;
        
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-1234-5678', AccountId = acc.Id,
                                          StageName = '무료체험 전환', CloseDate = td);
        Opportunity opp2 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-2345-5678', AccountId = acc.Id,
                                          StageName = '배송 준비', CloseDate = td, ReturnRequestDate__c = td);
        Opportunity opp3 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-3456-5678', AccountId = acc.Id,
                                          StageName = '배송중', CloseDate = td, ReturnRequestDate__c = td);
        Opportunity opp4 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-4567-5678', AccountId = acc.Id,
                                          StageName = '체험진행중', CloseDate = td, ReturnRequestDate__c = td);
        Opportunity opp5 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-5678-5678', AccountId = acc.Id,
                                          StageName = '체험종료', CloseDate = td);
        opps.add(opp);
        opps.add(opp2);
        opps.add(opp3);
        opps.add(opp4);
        opps.add(opp5);
        insert opps;
        
        List<DeliveryInfo__c> dis = new List<DeliveryInfo__c>();
        DeliveryInfo__c di = new DeliveryInfo__c(DeliveryNumber__c = '532232484556', PhoneNumber__c = '010-1234-5678', DeliveryStatus__c = '배송준비', ParentName__c = 'AccountTest', Category__c = '패드 발송',
                                                 OpportunityId__c = opp.Id, oppTarget__c = true, DelivBatchNotiTarget__c = true);
        DeliveryInfo__c di2 = new DeliveryInfo__c(DeliveryNumber__c = '533332484556', PhoneNumber__c = '010-2345-5678', DeliveryStatus__c = '배송중', ParentName__c = 'AccountTest', Category__c = '패드 발송',
                                                 OpportunityId__c = opp2.Id, oppTarget__c = true, DelivBatchNotiTarget__c = true);
        DeliveryInfo__c di3 = new DeliveryInfo__c(DeliveryNumber__c = '534432484556', PhoneNumber__c = '010-3456-5678', DeliveryStatus__c = '배송완료', ParentName__c = 'AccountTest', Category__c = '패드 발송',
                                                 OpportunityId__c = opp3.Id, oppTarget__c = true, DelivBatchNotiTarget__c = true);
        DeliveryInfo__c di4 = new DeliveryInfo__c(DeliveryNumber__c = '535532484556', PhoneNumber__c = '010-4567-5678', DeliveryStatus__c = '기기회수중', ParentName__c = 'AccountTest', Category__c = '패드 회수',
                                                 OpportunityId__c = opp4.Id, oppTarget__c = true, DelivBatchNotiTarget__c = true);
        DeliveryInfo__c di5 = new DeliveryInfo__c(DeliveryNumber__c = '536632484556', PhoneNumber__c = '010-5678-5678', DeliveryStatus__c = '기기회수완료', ParentName__c = 'AccountTest', Category__c = '패드 회수',
                                                 OpportunityId__c = opp5.Id, oppTarget__c = true, DelivBatchNotiTarget__c = true);
        dis.add(di);
        dis.add(di2);
        dis.add(di3);
        dis.add(di4);
        dis.add(di5);
        insert dis;
        
    }

    @isTest
    public static void ScheduleBatchDelivInfo_Test (){

        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());

        ScheduleBatchDelivInfo scb = new ScheduleBatchDelivInfo ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Schedule', chron, scb);
        
        Test.stopTest();
        
    }

    
    @isTest
    public static void BatchDeliveryInfo_Test (){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());

        BatchDeliveryInfo testBatch = new BatchDeliveryInfo();
        database.executeBatch(testBatch,1000);
        
        Test.stopTest();
        
    }

    @isTest
    public static void BatchOppStage_Test (){

        Test.startTest();

        BatchOppStage testBatch = new BatchOppStage();
        database.executeBatch(testBatch,1000);
        
        Test.stopTest();
        
    }

    @isTest
    public static void BatchDINotification_Test (){

        Test.startTest();

        BatchDINotification testBatch = new BatchDINotification();
        database.executeBatch(testBatch,1000);
        
        Test.stopTest();
        
    }

    @isTest
    public static void FinalBatchDI_Test (){

        Test.startTest();

        FinalBatchDI testBatch = new FinalBatchDI();
        database.executeBatch(testBatch,1000);
        
        Test.stopTest();
        
    }

}