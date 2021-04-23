({
    closeModal : function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },

    handleAddGroups : function(component, event) {
        component.set('v.title', 'Add Groups');
        component.set('v.lessonId', event.getParam('lessonId'));
        component.set('v.isAddGroupsStep', true);
    },

    handleSaveLesson : function(component, event, helper) {
        component.find('createLesson').handleSave();
    },

    handleSaveAndAddGroups : function(component, event, helper) {
        component.find('createLesson').handleSaveAndAddGroups();
    },

    handleSaveGroups : function(component, event, helper) {
        component.find('addGroups').handleSave();
    }
})
