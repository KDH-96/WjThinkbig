/**
 * @description       : 
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : ms.kim
**/
public  class Batch_ReturnLead implements Database.Batchable<sObject>, Database.Stateful {
    /**
     * 상담종료일 +60일 이후
     * 최종 상담이력 이후 60일이 지나면 자동 회수, 본사에게 회수
     */
    public Database.QueryLocator start(Database.BatchableContext dbc) {

        String strQuery = 'SELECT Id, LastCounselDateTime__c FROM Lead WHERE LastCounselDateTime__c  <> null AND LastCounselDateTime__c < LAST_N_DAYS:60 AND Owner.UserRole.Name != \'본사\'';

        return Database.getQueryLocator(strQuery);

    }

    public void execute(Database.BatchableContext dbc, List<Lead> rsltList) {

        List<Lead> updLeadList = new List<Lead>();
        for (Lead lead : rsltList) {
            updLeadList.add(new Lead(
                Id = lead.Id
                ,OwnerId = UserInfo.getUserId()
            ));
        }
    }

    public void finish(Database.BatchableContext dbc) {
        // nothing
    }
}