/**
 * @description       : 교사그룹 개체 트리거
 * @author            : wj.chae
 * @group             : 
 * @last modified on  : 02-16-2024
 * @last modified by  : wj.chae
**/
trigger tri_Group on Group__c (before insert, before update) {

    if (Trigger.isBefore) {
        
        List<String> sources = new List<String>();
        Set<Id> ids = new Set<Id>();
        if (Trigger.isInsert) {
            for (Group__c gr : Trigger.new) {
                if (String.isNotBlank(gr.LeadSource__c)) {
                    sources.addAll(gr.LeadSource__c.split(';'));
                }
            }
        }
        else if (Trigger.isUpdate) {
            for (Id key : Trigger.newMap.keySet()) {
                Group__c oldVal = Trigger.oldMap.get(key);
                Group__c newVal = Trigger.newMap.get(key);

                if (String.isNotBlank(newVal.LeadSource__c) && 
                    oldVal.LeadSource__c != newVal.LeadSource__c) {
                    sources.addAll(newVal.LeadSource__c.split(';'));
                    ids.add(key);
                }
            }
        }
        
        String strQuoteLeadSource = '(\'' + String.join(sources, '\',\'') + '\')';
        String strQuoteIds = '(\'' + String.join(ids, '\',\'') + '\')';
        String qrGroup = 
            'SELECT Id, Name, LeadSource__c ' + 
            'FROM Group__c ' + 
            'WHERE LeadSource__c INCLUDES ' + strQuoteLeadSource + ' AND Id NOT IN ' + strQuoteIds + ' AND IsDeleted = false';

        List<Group__c> groupList = DataBase.query(qrGroup);

        if (Trigger.isUpdate) {
            for (Id key : Trigger.newMap.keySet()) {
                Group__c gr = Trigger.newMap.get(key);

                if (groupList?.size() > 0) {
                    gr.LeadSource__c.addError('다른 교사그룹에 등록된 유입경로가 포함되어 있습니다.');
                }
            }
        }
        else {
            for (Group__c gr : Trigger.new) {
                if (groupList?.size() > 0) {
                    gr.LeadSource__c.addError('다른 교사그룹에 등록된 유입경로가 포함되어 있습니다.');
                }
            }
        }
    }
}