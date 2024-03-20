/**
 * @description       : 
 * @author            : ms.kim
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : ms.kim
**/
@isTest
public with sharing class Scheduler_BatchReturnLead_Test {

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
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){
            
            try{
                Scheduler_BatchReturnLead sc = new Scheduler_BatchReturnLead();
                String sch = '0 0 * * * ?';
                String jobID = system.schedule('Scheduler_BatchReturnLead_Test', sch, sc);

            }catch(Exception e){}
        } 
    }
}