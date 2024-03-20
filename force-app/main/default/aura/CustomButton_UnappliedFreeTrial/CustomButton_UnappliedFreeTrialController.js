({
    doAction : function(component, event, helper) {  

        helper.showSpinner(component);
        var action = component.get("c.CustomBtnEvent");
        action.setParams({
            recordId : component.get("v.recordId"),
            eventType : 'UnappliedFreeTrial'
        });
        action.setCallback(this, function(response) {
            $A.get("e.force:closeQuickAction").fire();
            var state = response.getState();
            if (state === "SUCCESS") {
                var retMap = response.getReturnValue();
                var msg = retMap['msg'];
                if(msg == 'done'){
                    helper.showToast(component, 'Success', '미사용DB로 회수되었습니다');
                }else{ 
                    helper.showToast(component, 'error', msg);
                }               

                $A.get('e.force:refreshView').fire();
            }else if(state === "ERROR") {
                helper.showToast(component, 'error', 'Unknown Error!');
            }
        });
        $A.enqueueAction(action);
    },

    onClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})