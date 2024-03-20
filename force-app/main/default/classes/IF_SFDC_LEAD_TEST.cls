/**
 * @description       : 
 * @author            : dohun.kim@woongjin.co.kr
 * @group             : 
 * @last modified on  : 01-31-2024
 * @last modified by  : dohun.kim@woongjin.co.kr
**/
@isTest
public class IF_SFDC_LEAD_TEST {
    

    @isTest    
    static void IF_SFDC_LEAD_TEST() {
        String MobilePhone = '01001010202';
        String Name ='TEST';
        String RequestDateTime ='20240129092300';
        String LeadSource ='L001';
        String LeadSourceDetail ='https://www.wjthinkbig.com/event/mc/everland/superpot.do';
        String ContractNumber ='X1234523';
        String ProductName ='슈퍼팟';
        String Amount ='100000';
        String FullPaymentFlg ='Y';
        String RegisterName ='K';
        String MembershipNumber ='ASDF11234567890';
        String ChildName ='K씽크빅';
        String ChildAge ='15';
        String ChildBirthday ='20181231';
        String Address1 ='서울 중구 청계천로 24 (다동, 케이스퀘어시티)';
        String Address2 ='8층';
        String PostalCode ='04521';
        String Requirement ='요청사항없음';
        String MediaCode ='naverpost_mo';
        String Device ='PC';
        String Channel ='C003';
        String ProductService ='P003';
        String PromotionFreetrial ='E0003';
        String PromotionJoin ='J0003';

        IF_SFDC_LEAD.createLead(MobilePhone
                                , Name
                                , RequestDateTime
                                , LeadSource
                                , LeadSourceDetail
                                , ContractNumber
                                , ProductName
                                , Amount
                                , FullPaymentFlg
                                , RegisterName
                                , MembershipNumber
                                , ChildName
                                , ChildAge
                                , ChildBirthday
                                , Address1
                                , Address2
                                , PostalCode
                                , Requirement
                                , MediaCode
                                , Device
                                , Channel
                                , ProductService
                                , PromotionFreetrial
                                , PromotionJoin);
    }
}