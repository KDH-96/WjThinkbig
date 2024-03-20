({
    showToast : function(component, title, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title': title,
            'type' : type,
            'message': message,
            'mode': 'dismissible'
        });
        toastEvent.fire();
    }
})