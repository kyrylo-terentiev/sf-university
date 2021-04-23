import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateCourseLesson extends NavigationMixin(LightningElement) {
    @api courseId;
    lessonId;
    saveAndAddGroups = false;

    handleSuccess(event) {
        console.log('handleSuccess');
        this.lessonId = event.detail.id;
        if (this.saveAndAddGroups) {
            console.log('open add groups modal');
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

    handleSubmit(event) {
        let fields = event.detail.fields;
        event.preventDefault();
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    onSave(event) {
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    onSaveAndAddGroups(event) {
        this.saveAndAddGroups = true;
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    onCancel(event) {
        const closeEvent = new CustomEvent('close', { value: event.value });
        this.dispatchEvent(closeEvent);
    }
}