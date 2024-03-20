@isTest
public class loadDeliveryInfos_Test {

    @testSetup
    public static void setup(){
        User u = [SELECT Id,name,profile.name from user where id =: UserInfo.getUserId()];
        RecordType accType = [SELECT Id FROM RecordType WHERE Name = '개인 계정' LIMIT 1];
        Date td = Date.today();

        
        Account acc = new Account(FirstName = 'Test', LastName = 'Account', RecordTypeId = accType.Id);
        insert acc;
        
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), DeliveryRequestDate__c = td,
                                          ParentPhone__c = '010-1234-5678', AccountId = acc.Id,
                                          StageName = '무료체험 전환', CloseDate = td);
        Opportunity opp2 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-2345-5678', AccountId = acc.Id,
                                          StageName = '체험진행중', CloseDate = td, ReturnRequestDate__c = td);
        Opportunity opp3 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-3456-5678', AccountId = acc.Id,
                                          StageName = '체험진행중', CloseDate = td, ReturnRequestDate__c = td);
        Opportunity opp4 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-4567-5678', AccountId = acc.Id,
                                          StageName = '체험진행중', CloseDate = td, ReturnRequestDate__c = td);
        Opportunity opp5 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), DeliveryRequestDate__c = td,
                                          ParentPhone__c = '010-5678-5678', AccountId = acc.Id,
                                          StageName = '배송 준비', CloseDate = td);
        Opportunity opp6 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), DeliveryRequestDate__c = td, 
                                          ParentPhone__c = '010-6789-5678', AccountId = acc.Id,
                                          StageName = '무료체험 전환', CloseDate = td);

        Opportunity opp7 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-1234-1111', AccountId = acc.Id, ReEntryDateTime__c = td,
                                          StageName = '무료체험 전환', CloseDate = td);
        Opportunity opp8 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-1234-2222', AccountId = acc.Id, ReEntryDateTime__c = td,
                                          StageName = '체험진행중', CloseDate = td, ReturnRequestDate__c = td);
        Opportunity opp9 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-1234-3333', AccountId = acc.Id, ReEntryDateTime__c = td,
                                          StageName = '체험진행중', CloseDate = td, ReturnRequestDate__c = td);
        Opportunity opp10 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-1234-4444', AccountId = acc.Id, ReEntryDateTime__c = td,
                                          StageName = '체험진행중', CloseDate = td, ReturnRequestDate__c = td);
        Opportunity opp11 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-1234-5555', AccountId = acc.Id, ReEntryDateTime__c = td,
                                          StageName = '배송 준비', CloseDate = td);
        Opportunity opp12 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-1234-6666', AccountId = acc.Id, ReEntryDateTime__c = td,
                                          StageName = '무료체험 전환', CloseDate = td);
        Opportunity opp13 = new Opportunity(Name = 'Test', OwnerId = UserInfo.getUserId(), 
                                          ParentPhone__c = '010-1234-7777', AccountId = acc.Id, ReEntryDateTime__c = td,
                                          StageName = '무료체험 전환', CloseDate = td);

        opps.add(opp);
        opps.add(opp2);
        opps.add(opp3);
        opps.add(opp4);
        opps.add(opp5);
        opps.add(opp6);
        opps.add(opp7);
        opps.add(opp8);
        opps.add(opp9);
        opps.add(opp10);
        opps.add(opp11);
        opps.add(opp12);
        opps.add(opp13);
        insert opps;
        
        List<DeliveryInfo__c> dis = new List<DeliveryInfo__c>();
        DeliveryInfo__c di = new DeliveryInfo__c(DeliveryNumber__c = '532232484556', PhoneNumber__c = '010-1234-5678', ParentName__c = 'AccountTest', Category__c = '패드 발송',
                                                 OpportunityId__c = opp.Id);
        DeliveryInfo__c di2 = new DeliveryInfo__c(DeliveryNumber__c = '533332484556', PhoneNumber__c = '010-2345-5678', ParentName__c = 'AccountTest', Category__c = '패드 회수',
                                                 OpportunityId__c = opp2.Id);
        DeliveryInfo__c di3 = new DeliveryInfo__c(DeliveryNumber__c = '534432484556', PhoneNumber__c = '010-3456-5678', ParentName__c = 'AccountTest', Category__c = '패드 회수',
                                                 OpportunityId__c = opp3.Id);
        DeliveryInfo__c di4 = new DeliveryInfo__c(DeliveryNumber__c = '535532484556', PhoneNumber__c = '010-4567-5678', ParentName__c = 'AccountTest', Category__c = '패드 회수',
                                                 OpportunityId__c = opp4.Id);
        DeliveryInfo__c di5 = new DeliveryInfo__c(DeliveryNumber__c = '536632484556', PhoneNumber__c = '010-5678-5678', ParentName__c = 'AccountTest', Category__c = '패드 발송',
                                                 OpportunityId__c = opp5.Id);
        DeliveryInfo__c di6 = new DeliveryInfo__c(DeliveryNumber__c = '537732484556', PhoneNumber__c = '010-6789-5678', ParentName__c = 'AccountTest', Category__c = '패드 발송',
                                                 OpportunityId__c = opp6.Id);

        DeliveryInfo__c di7 = new DeliveryInfo__c(DeliveryNumber__c = '532232484556', PhoneNumber__c = '010-1234-1111', ParentName__c = 'AccountTest', Category__c = '패드 발송',
                                                 OpportunityId__c = opp7.Id);
        DeliveryInfo__c di8 = new DeliveryInfo__c(DeliveryNumber__c = '533332484556', PhoneNumber__c = '010-1234-2222', ParentName__c = 'AccountTest', Category__c = '패드 회수',
                                                 OpportunityId__c = opp8.Id);
        DeliveryInfo__c di9 = new DeliveryInfo__c(DeliveryNumber__c = '534432484556', PhoneNumber__c = '010-1234-3333', ParentName__c = 'AccountTest', Category__c = '패드 회수',
                                                 OpportunityId__c = opp9.Id);
        DeliveryInfo__c di10 = new DeliveryInfo__c(DeliveryNumber__c = '535532484556', PhoneNumber__c = '010-1234-4444', ParentName__c = 'AccountTest', Category__c = '패드 회수',
                                                 OpportunityId__c = opp10.Id);
        DeliveryInfo__c di11 = new DeliveryInfo__c(DeliveryNumber__c = '536632484556', PhoneNumber__c = '010-1234-5555', ParentName__c = 'AccountTest', Category__c = '패드 발송', DeliveryRequestDate__c = td,
                                                 OpportunityId__c = opp11.Id);
        DeliveryInfo__c di12 = new DeliveryInfo__c(DeliveryNumber__c = '537732484556', PhoneNumber__c = '010-1234-6666', ParentName__c = 'AccountTest', Category__c = '패드 발송', DeliveryRequestDate__c = td,
                                                 OpportunityId__c = opp12.Id);
        dis.add(di);
        dis.add(di2);
        dis.add(di3);
        dis.add(di4);
        dis.add(di5);
        dis.add(di6);
        dis.add(di7);
        dis.add(di8);
        dis.add(di9);
        dis.add(di10);
        dis.add(di11);
        dis.add(di12);
        insert dis;
        
    }
    
    @isTest
    public static void loadDeliveryInfos_Test1_1 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-5678' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void loadDeliveryInfos_Test1_2 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-2345-5678' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_3 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-3456-5678' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_4 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-4567-5678' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_5 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-5678-5678' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_6 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-6789-5678' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_7 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-1111' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_8 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-2222' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_9 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-3333' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_10 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-4444' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_11 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-5555' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test1_12 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-6666' LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di.Id);
        
        Test.stopTest();
        
    }

    @isTest
    public static void loadDeliveryInfos_Test2_1 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-5678' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }
    
    @isTest
    public static void loadDeliveryInfos_Test2_2 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-2345-5678' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

    @isTest
    public static void loadDeliveryInfos_Test2_3 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-3456-5678' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }
    
    @isTest
    public static void loadDeliveryInfos_Test2_4 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-4567-5678' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

    @isTest
    public static void loadDeliveryInfos_Test2_5 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-5678-5678' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

    @isTest
    public static void loadDeliveryInfos_Test2_6 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-6789-5678' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

    @isTest
    public static void loadDeliveryInfos_Test2_7 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-1111' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

    @isTest
    public static void loadDeliveryInfos_Test2_8 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-2222' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

    @isTest
    public static void loadDeliveryInfos_Test2_9 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-3333' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

    @isTest
    public static void loadDeliveryInfos_Test2_10 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-4444' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

    @isTest
    public static void loadDeliveryInfos_Test2_11 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-5555' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

    @isTest
    public static void loadDeliveryInfos_Test2_12 (){
        DeliveryInfo__c di = [SELECT Id, DeliveryNumber__c, OpportunityId__c, DeliveryStatus__c, ReturnRequestDate__c, Category__c 
                              FROM DeliveryInfo__c WHERE PhoneNumber__c = '010-1234-6666' LIMIT 1];
        Opportunity opp = [SELECT Id, OwnerId, StageName, ReEntryDateTime__c FROM Opportunity WHERE Id =: di.OpportunityId__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResGenerator());
        loadDeliveryInfos.loadDelivInfos(di,opp);
        
        Test.stopTest();
    }

}