import { api, track, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateCourseLesson extends NavigationMixin(LightningElement) {
    @api courseId;
    lessonId;

    handleSuccess(event) {
        this.lessonId = event.detail.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.lessonId,
                objectApiName: 'Lesson__c',
                actionName: 'view',
            },
        });
    }

    handleSubmit(event) {
        let fields = event.detail.fields;
        event.preventDefault();
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleCancel(event) {
        const closeEvent = new CustomEvent('close', { value: event.value });
        this.dispatchEvent(closeEvent);
    }

}