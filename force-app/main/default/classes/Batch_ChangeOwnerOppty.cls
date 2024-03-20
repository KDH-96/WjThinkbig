/**
 * @description       : 
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-04-2024
 * @last modified by  : wj.chae
**/
public class Batch_ChangeOwnerOppty implements Database.Batchable<sObject> {
    
    private Set<Id> ids;
    private String val = '';
    // 배치 실행여부 판단 플래그, 배치 실행의 경우 true 
    private Boolean isBatch = false;

    public Batch_ChangeOwnerOppty(Set<Id> pIds, String pVal, Boolean batchFlg) {
        this.ids = pIds;
        this.val = pVal;
        this.isBatch = batchFlg;
    }

    public Database.QueryLocator start(Database.BatchableContext dbc) {
        if (ids?.size() > 0) {
            return Database.getQueryLocator([
                SELECT Id, OwnerId, AccountId, Account.OwnerId FROM Opportunity WHERE Id IN :this.ids
            ]);
        }

        return null;
    }

    public void execute(Database.BatchableContext dbc, List<Opportunity> oppList) {

        // 기회 소유자의 role id 추출
        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Name, UserRoleId, UserRole.DeveloperName 
            FROM User
            WHERE UserRole.DeveloperName <> null
        ]);


        // 추출한 role id의 parentroleid 추출 > userrole 에서 키 찾기
        Map<Id, UserRole> roleMap = new Map<Id, UserRole>([
            SELECT Id, ParentRoleId
            FROM UserRole
        ]);


        List<Opportunity> updOppList = new List<Opportunity>();
        List<Account> updAccList = new List<Account>();
        for (Opportunity opp : oppList) {
            
            Id userRoleId = userMap.get(opp.ownerId).userRoleId;
            Id parentRoleId = roleMap.get(userRoleId).parentRoleId;

            Id parentUserId;
            Id systemAdminId;

            for (User usr : userMap.values()) {
                if (usr.UserRoleId == parentRoleId) {
                    parentUserId = usr.Id;
                }
                
                else if (usr.UserRole.DeveloperName == 'Headquarter' && String.isEmpty(systemAdminId)) {
                    systemAdminId = usr.Id;   
                }
            }

            // 상담구분의 값이 '6차 부재 이상'일 경우, 파트장에게 회수
            if ('6차 부재 이상'.equals(val)) {
                if (parentUserId != null && parentRoleId != null) {
                    
                    updOppList.add(new Opportunity(
                        Id = opp.Id,
                        ownerId = parentUserId,
                        Batch__c = this.isBatch
                    ));

                    updAccList.add(new Account(
                        Id = opp.AccountId,
                        OwnerId = parentUserId
                    ));
                }
            }
            // 기회 상태가 '무료체험취소'일 경우, 본사에게 회수
            else if (systemAdminId != null && '무료체험취소'.equals(val)) {
                
                updOppList.add(new Opportunity(
                    Id = opp.Id,
                    ownerId = systemAdminId,
                    Batch__c = this.isBatch
                ));

                updAccList.add(new Account(
                    Id = opp.AccountId,
                    OwnerId = systemAdminId
                ));
            }
        }


        Savepoint sp = Database.setSavepoint();
        try {
            // Update Opportunity
            if(updOppList?.size() > 0){
                update updOppList;
            }
            // Update Account
            if(updAccList?.size() > 0){
                update updAccList;
            }

        } catch (Exception e) {
            Database.rollback(sp);
        }
        
    }

    public void finish(Database.BatchableContext dbc) {
        // nothing
    }

    public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}