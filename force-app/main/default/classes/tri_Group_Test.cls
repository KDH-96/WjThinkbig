/**
 * @description       : 
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-19-2024
 * @last modified by  : wj.chae
**/
@isTest
public without sharing class tri_Group_Test {

    @isTest
    static void runTest1(){
        User adminUser = [
            SELECT Id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true 
            LIMIT 1
        ];

        System.runAs(adminUser){
            
            // create test data
            Group__c gr1 = new Group__c(
                Name = 'Test Group 1', 
                LeadSource__c = 'L001;L002'
            );

            insert gr1;
            System.assertEquals('L001;L002', gr1.LeadSource__c);

        } 
    }

    @isTest
    static void runTest2(){
        User adminUser = [
            SELECT Id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true 
            LIMIT 1
        ];

        System.runAs(adminUser){
            
            Group__c gr = new Group__c(
                Name = 'Test Group 2',
                LeadSource__c = 'L001'
            );
                    
            insert gr;
            System.assertEquals('L001', gr.LeadSource__c, '다른 교사그룹에 등록된 유입경로가 포함되어 있습니다.');

        } 
    }

    @isTest
    static void runTest3(){
        User adminUser = [
            SELECT Id 
            FROM User 
            WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true 
            LIMIT 1
        ];

        System.runAs(adminUser){
            
            // set data
            Group__c gr = new Group__c(
                Name = 'Test Group 3',
                LeadSource__c = 'L001'
            );
            
            insert gr; 

            Group__c gr2 = new Group__c(
                Id = gr.Id,
                LeadSource__c = 'L005'
            );
            update gr2;

            System.assertEquals('L005', gr2.LeadSource__c);

        } 
    }

}