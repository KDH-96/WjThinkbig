global class ScheduleBatchDelivInfo implements Schedulable{
    
    global void execute(SchedulableContext sc){
        BatchDeliveryInfo bdi = new BatchDeliveryInfo();
        Database.executeBatch(bdi,1000);
    }

}