/**
 * @description       : 
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : wj.chae
**/
public class Scheduler_BatchReturnLead  implements Schedulable {

    public void execute(SchedulableContext sc){
        Batch_ReturnLead bat = new Batch_ReturnLead();
        Database.executebatch(bat, 1000);
    }

}