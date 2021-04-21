import { api, track, LightningElement } from 'lwc';

export default class CreateCourseLesson extends LightningElement {
    @api courseId;
    @track lessonId;

    handleSuccess(event) {
        this.accountId = event.detail.id;
    }
}