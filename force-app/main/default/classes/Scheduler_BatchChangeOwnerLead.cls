/**
 * @description       : 
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 01-31-2024
 * @last modified by  : wj.chae
**/
public class Scheduler_BatchChangeOwnerLead implements Schedulable {

    private Set<Id> ids;
    private String selVal = '';

    public Scheduler_BatchChangeOwnerLead(Set<Id> pIds, String pVal) {
        this.ids = pIds;
        this.selVal = pVal;
    }

    public void execute(SchedulableContext sc){
        Batch_ChangeOwnerLead bat = new Batch_ChangeOwnerLead(this.ids, this.selVal, true);
        Database.executeBatch(bat, 1000);
    }
}