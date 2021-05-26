import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateCourseLesson extends NavigationMixin(LightningElement) {

    @api recordId;

    lessonId;
    saveAndAddGroups = false;

    connectedCallback() {
        console.log('recordId: ' + this.recordId);
    }

    @api 
    handleSave() {
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    @api
    handleSaveAndAddGroups() {
        this.saveAndAddGroups = true;
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleSuccess(event) {
        this.lessonId = event.detail.id;
        if (this.saveAndAddGroups) {
            const lessonId = this.lessonId;
            this.dispatchEvent(new CustomEvent('addgroups', { detail: { lessonId } }));
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.lessonId,
                    objectApiName: 'Lesson__c',
                    actionName: 'view',
                },
            });
        }
    }

}