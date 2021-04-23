import { api, LightningElement } from 'lwc';

export default class CreateCourseLessonGroups extends LightningElement {

    @api lessonId;

    @api
    handleSave() {
        console.log('save groups');
    }
}