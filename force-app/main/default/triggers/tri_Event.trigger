/**
 * @description       : 이벤트 개체 트리거
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-08-2024
 * @last modified by  : ms.kim
**/
trigger tri_Event on Event (before insert) {

    if(Trigger.isBefore && Trigger.isInsert) {

        for (Event ev : Trigger.new) {
            if(!ev.IsReminderSet){
                ev.IsReminderSet = true;
                ev.ReminderDateTime = ev.StartDateTime.addMinutes(-15);
            }
        }
    }
}