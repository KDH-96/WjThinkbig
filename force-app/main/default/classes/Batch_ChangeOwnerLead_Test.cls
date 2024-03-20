/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : ms.kim
**/
@isTest
public class Batch_ChangeOwnerLead_Test {

    @isTest
    static  void runTest(){
        
        User u = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];
        Lead le = TestUtilities.getLead('test');
        Set<Id> lead_ids = new Set<Id>();
        lead_ids.add(le.Id);

        System.runAs(u){
            
            Test.startTest();
            Batch_ChangeOwnerLead ba = new Batch_ChangeOwnerLead(lead_ids, '체험미신청',true);
            Database.executeBatch(ba,1);
            Test.stopTest();
        }
    }

    @isTest
    static  void runTest2(){
        
        User u = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];
        Lead le = TestUtilities.getLead('test');
        Set<Id> lead_ids = new Set<Id>();
        lead_ids.add(le.Id);

        System.runAs(u){
            
            Test.startTest();
            Batch_ChangeOwnerLead ba = new Batch_ChangeOwnerLead(lead_ids, '6차 부재 이상',true);
            Database.executeBatch(ba,1);
            Test.stopTest();
        }
    }

    @isTest
    static void runDummy () {
        Batch_ChangeOwnerLead.dummy();
    }
}