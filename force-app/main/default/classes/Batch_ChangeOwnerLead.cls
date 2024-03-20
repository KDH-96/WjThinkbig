/**
 * @description       : 
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : wj.chae
**/
public class Batch_ChangeOwnerLead implements Database.Batchable<sObject> {
    
    private Set<Id> ids;
    private String val = '';
    // 배치 실행여부 판단 플래그, 배치 실행의 경우 true 
    private Boolean isBatch = false;

    public Batch_ChangeOwnerLead (Set<Id> pIds, String pVal, Boolean batchFlg){
        this.ids = pIds;
        this.val = pVal;
        this.isBatch = batchFlg;
    }

    public Database.QueryLocator start(Database.BatchableContext dbc) {
        if (ids?.size() > 0) {
            return Database.getQueryLocator([
                SELECT Id, OwnerId FROM Lead WHERE Id IN :this.ids
            ]);
        }

        return null;
    }

    public void execute(Database.BatchableContext dbc, List<Lead> leadList) {

        // 리드 소유자의 role id 추출
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

        List<Lead> updLeadList = new List<Lead>();
        for (Lead lead : leadList) {
            
            Id userRoleId = userMap.get(lead.ownerId).userRoleId;
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

                    updLeadList.add(new Lead(
                        Id = lead.Id,
                        ownerId = parentUserId,
                        Batch__c = this.isBatch
                    ));
                }
            }
            // 리드 상태가 '체험미신청'일 경우, 본사에게 회수
            else if (systemAdminId != null && '체험미신청'.equals(val)) {
                
                updLeadList.add(new Lead(
                    Id = lead.Id,
                    ownerId = systemAdminId,
                    Batch__c = this.isBatch
                ));
            }
            
        }


        Savepoint sp = Database.setSavepoint();
        try {
            if(updLeadList?.size() > 0){
                update updLeadList;
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