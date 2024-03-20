/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 02-20-2024
 * @last modified by  : wj.chae
**/
public class Scheduler_LeadBatchController implements Schedulable{

  public void execute(SchedulableContext ctx){

    Datetime currentTime = Datetime.now();
    
    System.debug('currentTime.hour()  >>> '+ currentTime.hour());
    if (currentTime.hour() >= 0 && currentTime.hour() < 8) {
      return;
    }

    Batch_ReEnterLeadUpdateController ReEnterLeadBatch = new Batch_ReEnterLeadUpdateController();
    Database.executebatch(ReEnterLeadBatch, 1000);
    Batch_LeadDistributeControllerVer2 distributeLeadBatch = new Batch_LeadDistributeControllerVer2();
    Database.executebatch(distributeLeadBatch, 1000); 

  }
}