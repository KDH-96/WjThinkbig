global class ScheduleBatchDINoti implements Schedulable{
    
    global void execute(SchedulableContext sc){
        BatchDINoti3Days bdn3 = new BatchDINoti3Days();
        Database.executeBatch(bdn3,1000);
    }

}