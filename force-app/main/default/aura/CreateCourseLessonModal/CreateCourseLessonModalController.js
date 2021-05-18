({
    init : function(component, event, helper) {
        if (!component.get('v.recordId')) {
            var pageRef = component.get("v.pageReference");
            var state = pageRef.state;
            var base64Context = state.inContextOfRef;
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            component.set("v.recordId", addressableContext.attributes.recordId);
        }
    },

    closeModal : function(component, event, helper) {
        const lessonId = component.get('v.lessonId');
        if (lessonId) {
            var navigateToLessonEvent = $A.get("e.force:navigateToSObject");
            navigateToLessonEvent.setParams({ "recordId": lessonId });
            navigateToLessonEvent.fire(); 
        } else if (component.get('v.recordId')) {
            $A.get('e.force:closeQuickAction').fire();
            var navigateToRecordEvent = $A.get("e.force:navigateToSObject");
            navigateToRecordEvent.setParams({ "recordId": component.get('v.recordId') });
            navigateToRecordEvent.fire();
        } else {
            var navigateToSObjectEvent = $A.get("e.force:navigateToObjectHome");
            navigateToSObjectEvent.setParams({
                "scope": "Lesson__c"
            });
            navigateToSObjectEvent.fire();
        }
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