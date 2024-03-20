/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 01-31-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
public class Scheduler_BatchChangeOwnerOppty implements Schedulable {
    
    private Set<Id> ids;
    private String selVal = '';

    public Scheduler_BatchChangeOwnerOppty(Set<Id> pIds, String pVal) {
        this.ids = pIds;
        this.selVal = pVal;
    }
    
    public void execute(SchedulableContext sc){
        Batch_ChangeOwnerOppty bat = new Batch_ChangeOwnerOppty(this.ids, this.selVal, true);
        Database.executeBatch(bat, 1000);
    }
}