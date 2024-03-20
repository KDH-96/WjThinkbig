/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : ms.kim
**/
@isTest
public class Batch_ReturnLead_Test {

    @TestSetup
    private static void setData(){

        User u = new User(
            LastName          = 'singleId'
            ,FirstName         = 'singleId'
            ,UserName          = 'singleId'+'@wjtbtest.com'
            ,TimeZoneSidKey    = 'GMT'
            ,LanguageLocaleKey = 'ko'
            ,ProfileId         =  UserInfo.getProfileId()
            ,Email             = 'singleId'+'@wjtbtest.com'
            ,Alias             = 'singleId'
            ,LocaleSidKey      = 'ko'
            ,EmailEncodingKey  = 'UTF-8'
        );
        insert u;

        Lead le = TestUtilities.getLead('test');
        le.LastCounselDateTime__c = Datetime.now().addMonths(-3);
        le.OwnerId = u.Id;
        update le;
    }

    @isTest
    static  void runTest(){
        
        User u = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(u){
            
            Test.startTest();
            Batch_ReturnLead ba = new Batch_ReturnLead();
            Database.executeBatch(ba,1);
            Test.stopTest();
        }
    }
}