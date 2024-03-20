@isTest
public class UTIL_Notification_Test {
    
    @testSetup
    public static void setup(){
        User u = [SELECT Id,name,profile.name from user where id =: UserInfo.getUserId()];
        RecordType accType = [SELECT Id FROM RecordType WHERE Name = '개인 계정' LIMIT 1];
        Date td = Date.today();
        
        Account acc = new Account(FirstName = 'Test', LastName = 'Account', RecordTypeId = accType.Id);
        insert acc;
                
    }
    
    @isTest
    public static void UTIL_Notification_Test(){
        CustomNotificationType notiType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'DeliveryNotification' limit 1];
        User u = [SELECT Id FROM user WHERE id =: UserInfo.getUserId()];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        
        Set<String> targetUserIds = new Set<String>();
        
        String title = 'test';
        String body = 'notification';
        targetUserIds.add(u.Id);
        UTIL_Notification.unCalloutNotiSend(notiType.Id, u.Id, acc.Id, title, body, targetUserIds);
        UTIL_Notification.CalloutNotiSend(notiType.Id, u.Id, acc.Id, title, body, targetUserIds);
        
        Test.stopTest();

    }

}