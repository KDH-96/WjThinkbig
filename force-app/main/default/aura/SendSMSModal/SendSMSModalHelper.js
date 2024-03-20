({
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        component.set("v.buttonsDisabled", true);
    },
    showToast : function(component, type, message) {
        console.log('helper success Start!');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        type: type,
        message: message,
        mode: 'dismissible'
        });
        toastEvent.fire();
    }
})