/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : ms.kim
**/
@isTest
public class Scheduler_BatchChangeOwnerLead_Test {

    @isTest
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];
        Lead le = TestUtilities.getLead('test');
        Set<Id> lead_ids = new Set<Id>();
        lead_ids.add(le.Id);

        System.runAs(adminUser){
            
            try{
                Scheduler_BatchChangeOwnerLead sc = new Scheduler_BatchChangeOwnerLead(lead_ids, '체험미신청');
                String sch = '0 0 * * * ?';
                String jobID = system.schedule('Scheduler_BatchChangeOwnerLead_Test', sch, sc);

            }catch(Exception e){}
        } 
    }
}