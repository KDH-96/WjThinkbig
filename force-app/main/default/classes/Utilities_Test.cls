/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : ms.kim
**/
@isTest
public without sharing class Utilities_Test {

    @isTest
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){
            
            Utilities.transWeekday('Sun');
            Utilities.transWeekday('Mon');
            Utilities.transWeekday('Tue');
            Utilities.transWeekday('Wed');
            Utilities.transWeekday('Thu');
            Utilities.transWeekday('Fri');
            Utilities.transWeekday('Sat');
            Utilities.transDateTimeFormat('test');
            Utilities.transDateTimeFormat(Datetime.now());
        } 
    }
}