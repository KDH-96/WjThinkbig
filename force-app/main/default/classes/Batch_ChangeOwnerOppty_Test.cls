/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : ms.kim
**/
@isTest
public class Batch_ChangeOwnerOppty_Test {
    
    @TestSetup
    private static void setData(){
        Account acc = TestUtilities.getAccount('test', '개인 계정');
        Opportunity oppty = TestUtilities.getOpportunity(acc.Id, 'test', '직가입');
    }

    @isTest
    static  void runTest(){
        
        User u = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> oppty_ids = new Set<Id>();
        oppty_ids.add(oppty.Id);

        System.runAs(u){
            
            Test.startTest();
            Batch_ChangeOwnerOppty ba = new Batch_ChangeOwnerOppty(oppty_ids, '무료체험취소', true);
            Database.executeBatch(ba,1);
            Test.stopTest();
        }
    }

    @isTest
    static void runDummy () {
        Batch_ChangeOwnerOppty.dummy();
    }
}