import { api, track, LightningElement } from 'lwc';

export default class CreateCourseLessonGroups extends LightningElement {

    @api lessonId;

    @track availableGroups = [
        { label: '3-1', value: '1' },
        { label: 'НАИ-172у', value: '2' },
        { label: 'АИ-176', value: '3' }
    ];

    @track attendingGroups = [ ];

    handleGroupChange(event) {
        const selectedOptionsList = event.detail.value;
        console.log(`Options selected: ${selectedOptionsList}`);
    }

    @api
    handleSave() {
        console.log('save groups');
    }
}