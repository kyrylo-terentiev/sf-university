({
    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleSave : function(component, event, helper) {
        console.log('save');
    }
})
