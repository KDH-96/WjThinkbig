/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-28-2024
 * @last modified by  : ms.kim
**/
@isTest
public without sharing class tri_Opportunity_Test {

    @TestSetup
    private static void setData(){
        Channel__c ch = TestUtilities.getChannel('test1', 'test1');
        LeadSource__c ls = TestUtilities.getLeadSource('test1', 'test1');
        ProductService__c ps = TestUtilities.getProductService('test1', 'test1');
        Device__c d = TestUtilities.getDevice('test1', 'test1');
        Promotion_Join__c pj = TestUtilities.getPromotion_Join('test1', 'test1');
        Promotion_Freetrial__c pf = TestUtilities.getPromotion_Freetrial('test1', 'test1');
        MediaCode__c mc = TestUtilities.getMediaCode('test1', 'test1');

        Lead l = TestUtilities.getLead('test222');
        Account acc = TestUtilities.getAccount('test', '개인 계정');
        Opportunity oppty = TestUtilities.getOpportunity(acc.Id, 'test', '직가입');
        oppty.ContractNumber1__c = 'test1';
        update oppty;


    }

    @isTest
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){

            Account acc = [SELECT Id FROM Account LIMIT 1];
            Opportunity oppty = new Opportunity(
                Name = 'test'
                ,AccountId = acc.Id
                ,StageName = 'test'
                ,CloseDate = System.today()
            );
            insert oppty;

            oppty.ChildBirthday__c = System.today();
            oppty.NOKNumber__c = 'test';
            oppty.Note__c = 'test';
            update oppty;
            delete oppty;
        } 
    }

    @isTest
    static void runTest2(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){
            
            User u = TestUtilities.getUser('test11');
            Channel__c ch = [SELECT Id FROM Channel__c LIMIT 1];
            LeadSource__c ls = [SELECT Id FROM LeadSource__c LIMIT 1];
            ProductService__c ps = [SELECT Id FROM ProductService__c LIMIT 1];
            Device__c d = [SELECT Id FROM Device__c LIMIT 1];
            Promotion_Join__c pj = [SELECT Id FROM Promotion_Join__c LIMIT 1];
            Promotion_Freetrial__c pf = [SELECT Id FROM Promotion_Freetrial__c LIMIT 1];
            MediaCode__c mc = [SELECT Id FROM MediaCode__c LIMIT 1];

            Lead le = [SELECT Id FROM Lead LIMIT 1];
            Database.LeadConvertResult lcr = TestUtilities.getLeadConverte(le.Id);
            Id opptyid = lcr.getOpportunityId();
            Opportunity oppty = [SELECT Id
                                        , ContractNumber1__c
                                        , OwnerId
                                        , RequestDateTime__c
                                        , Channel__c
                                        , LeadSource__c
                                        , ProductService__c
                                        , Device__c
                                        , Promotion_Join__c
                                        , Promotion_Freetrial__c
                                        , MediaCode__c
                                 FROM Opportunity 
                                 WHERE Id =:opptyid
                                 LIMIT 1];
            oppty.ContractNumber1__c = '';
            oppty.OwnerId = u.Id;
            oppty.RequestDateTime__c = DateTime.now();
            oppty.Channel__c = ch.Id;
            oppty.LeadSource__c = ls.Id;
            oppty.ProductService__c = ps.Id;
            oppty.Device__c = d.Id;
            oppty.Promotion_Join__c = pj.Id;
            oppty.Promotion_Freetrial__c = pf.Id;
            oppty.MediaCode__c = mc.Id;

            update oppty;
        } 
    }
}