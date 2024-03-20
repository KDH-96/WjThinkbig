/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : ms.kim
**/
@isTest
public class Scheduler_BatchChangeOwnerOppty_Test {

    @TestSetup
    private static void setData(){
        Account acc = TestUtilities.getAccount('test', '개인 계정');
        Opportunity oppty = TestUtilities.getOpportunity(acc.Id, 'test', '직가입');
    }
    @isTest
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> oppty_ids = new Set<Id>();
        oppty_ids.add(oppty.Id);

        System.runAs(adminUser){
            
            try{
                Scheduler_BatchChangeOwnerOppty sc = new Scheduler_BatchChangeOwnerOppty(oppty_ids, '무료체험취소');
                String sch = '0 0 * * * ?';
                String jobID = system.schedule('Scheduler_BatchChangeOwnerOppty_Test', sch, sc);

            }catch(Exception e){}
        } 
    }
}