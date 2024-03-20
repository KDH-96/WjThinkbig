/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-01-2024
 * @last modified by  : ms.kim
**/
@isTest
public without sharing class tri_Task_Test {

    @isTest
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){
            
            Lead le = TestUtilities.getLead('test');
            
            Task t = new Task(
                LeadCounselCategory1__c = '통화완료'
                , LeadCounselCategory2__c = '체험미신청'
                , LeadCounselCategory3__c = '고객변심'
                , Description = 'test'
                , NextCounselResv__c = System.today()
                , WhoId = le.Id
            );

            insert t;

            Id opptyid = TestUtilities.getLeadConverte(le.Id).getOpportunityId();
            Task t2 = new Task(
                OpportunityCounselCategory1__c = '체험관리'
                , OpportunityCounselCategory2__c = '배송완료'
                , Description = 'test'
                , WhatId = opptyid
            );
            insert t2;
        } 
    }
}