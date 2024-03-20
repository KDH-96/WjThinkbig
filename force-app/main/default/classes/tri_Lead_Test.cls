/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 01-31-2024
 * @last modified by  : ms.kim
**/
@isTest
public without sharing class tri_Lead_Test {

    @TestSetup
    private static void setData(){
        User u = TestUtilities.getUser('test');
    }

    @isTest
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){

            Lead le = TestUtilities.getLead('test');

            le.ChildBirthday__c = System.today();
            le.Note__c = 'test';
            update le;

            Database.LeadConvertResult lcr = TestUtilities.getLeadConverte(le.Id);
            System.assert(lcr.isSuccess());
            
            delete le;
        } 
    }
}