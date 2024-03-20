/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-01-2024
 * @last modified by  : ms.kim
**/
@isTest
public without sharing class tri_FeedTracking_Test {

    @isTest
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){
            
            Lead le = TestUtilities.getLead('test');

            Database.LeadConvertResult lcr = TestUtilities.getLeadConverte(le.Id);

            FeedTracking__c ft = new FeedTracking__c(
                Value__c = 'test'
                ,Opportunity__c = lcr.getOpportunityId()
            );
            
            insert ft;
        } 
    }
}