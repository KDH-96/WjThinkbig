/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : ms.kim
**/
@isTest
public without sharing class CustomButtonController_Test {
    
    @TestSetup
    private static void setData(){
        Lead le = TestUtilities.getLead('test');
    }

    @isTest
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){
            
            Lead le = [SELECT Id FROM Lead LIMIT 1];

            CustomButtonController.CustomBtnEvent(le.Id, 'ConvertFreeTrial');
            CustomButtonController.CustomBtnEvent(le.Id, 'UnappliedFreeTrial');
            CustomButtonController.CustomBtnEvent(le.Id, 'DirectJoin');
        } 
    }

    @isTest
    static void runTest2(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){
            
            Lead le = [SELECT Id FROM Lead LIMIT 1];
            Set<Id> le_ids = new Set<Id>();
            le_ids.add(le.Id);

            Id opptyid = CustomButtonController.fnConvertLead(le_ids, '직가입').get(le.Id);
            CustomButtonController.CustomBtnEvent(opptyid, 'CancelFreeTrial');
        } 
    }

    @isTest
    static void runDummy () {
        CustomButtonController.dummy();
    }
}