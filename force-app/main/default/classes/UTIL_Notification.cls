global without sharing class UTIL_Notification {
    
    @future(callout=true)
    global static void CalloutNotiSend(String typeId, String senderId, String targetId, String title, String body, Set<String> userIds){
        
        Messaging.CustomNotification noti = new Messaging.CustomNotification();
        
        noti.setBody(body);
        noti.setTitle(title);
        noti.setSenderId(senderId);
        noti.setNotificationTypeId(typeId);
        
        noti.setTargetId(targetId);
        
        try{
            noti.send(userIds);
        }catch (Exception e){
            System.debug('error : ' + e.getMessage());
        }
        
    }
    
    global static void unCalloutNotiSend(String typeId, String senderId, String targetId, String title, String body, Set<String> userIds){
        
        Messaging.CustomNotification noti = new Messaging.CustomNotification();
        
        noti.setBody(body);
        noti.setTitle(title);
        noti.setSenderId(senderId);
        noti.setNotificationTypeId(typeId);
        
        noti.setTargetId(targetId);
        
        system.debug(body);
        system.debug(title);
        system.debug(senderId);
        system.debug(typeId);
        system.debug(targetId);
        
        try{
            noti.send(userIds);
        }catch (Exception e){
            System.debug('error : ' + e.getMessage());
        }
        
    }
    
    
}