({
    doAction : function(component, event, helper) {  

        helper.showSpinner(component);
        var action = component.get("c.CustomBtnEvent");
        action.setParams({
            recordId : component.get("v.recordId"),
            eventType : 'DirectJoin'
        });
        action.setCallback(this, function(response) {
            $A.get("e.force:closeQuickAction").fire();
            var state = response.getState();
            if (state === "SUCCESS") {
                var retMap = response.getReturnValue();
                var msg = retMap['msg'];
                var navEvent = $A.get("e.force:navigateToSObject");

                if(msg == 'done'){
                    helper.showToast(component, 'Success', '직가입 전환되었습니다');
                    
                    navEvent.setParams({
                        "recordId": retMap['opptyId'],
                        "slideDevName": "detail"
                    });
                    navEvent.fire();

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