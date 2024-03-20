({
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        component.set("v.buttonsDisabled", true);
    },
      
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
        component.set("v.buttonsDisabled", false);
    },

    showToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'type' : type,
            'message': message,
            'mode': 'dismissible'
        });
        toastEvent.fire();
    }
})