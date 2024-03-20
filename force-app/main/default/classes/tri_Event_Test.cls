/**
 * @description       : 이벤트 개체 트리거 테스트 클래스
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-04-2024
 * @last modified by  : wj.chae
**/
@isTest
public without sharing class tri_Event_Test {

    @isTest
    static void runTest(){
        User adminUser = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = '시스템 관리자') AND IsActive = true LIMIT 1];

        System.runAs(adminUser){
            
            Lead le = TestUtilities.getLead('test');
            
            Event ev1 = new Event(
                Subject = '다음 상담 예약'
                , NextCounselResv__c = System.today()
                , StartDateTime = System.now()
                , EndDateTime = System.now().addHours(1)
                , Description = 'test'
                , WhoId = le.Id
            );

            insert ev1;

            Id opptyid = TestUtilities.getLeadConverte(le.Id).getOpportunityId();
            Event ev2 = new Event(
                Subject = '다음 상담 예약'
                , NextCounselResv__c = System.today()
                , StartDateTime = System.now()
                , EndDateTime = System.now().addHours(1)
                , Description = 'test'
                , WhatId = opptyid
            );
            insert ev2;
        } 
    }
}